# == Schema Information
#
# Table name: invoices
#
#  id                       :integer          not null, primary key
#  account_id               :integer          not null
#  start_date               :datetime         not null
#  end_date                 :datetime         not null
#  amount                   :decimal(, )      not null
#  vendor_invoice           :boolean          default(FALSE), not null
#  calls_count              :integer          not null
#  first_call_at            :datetime
#  last_call_at             :datetime
#  contractor_id            :integer
#  created_at               :datetime         not null
#  calls_duration           :integer          not null
#  state_id                 :integer          default(1), not null
#  first_successful_call_at :datetime
#  last_successful_call_at  :datetime
#  successful_calls_count   :integer
#  type_id                  :integer          not null
#

class Billing::Invoice < Cdr::Base
  has_many :vendor_cdrs, -> { where vendor_invoice: true }, class_name: 'Cdr', foreign_key: 'vendor_invoice_id'
  has_many :customer_cdrs, -> { where vendor_invoice: false }, class_name: 'Cdr', foreign_key: 'customer_invoice_id'


  belongs_to :account, class_name: 'Account', foreign_key: 'account_id'
  belongs_to :contractor, class_name: 'Contractor', foreign_key: :contractor_id #, :conditions => {:customer => true}act
  belongs_to :state, class_name: Billing::InvoiceState, foreign_key: :state_id
  belongs_to :type, class_name: Billing::InvoiceType, foreign_key: :type_id

  has_one :invoice_document, dependent: :destroy
  has_many :full_destinations, class_name: Billing::InvoiceDestination, foreign_key: :invoice_id, dependent: :delete_all
  has_many :destinations, -> {where("successful_calls_count>0") }, class_name: Billing::InvoiceDestination, foreign_key: :invoice_id


  before_destroy do
     cdrs =  Cdr::Cdr.where('time_start >= ? AND time_start <= ? ', self.start_date, self.end_date)
     if self.vendor_invoice
       cdrs.where(vendor_invoice_id: self.id).update_all(vendor_invoice_id: nil)
     else
       cdrs.where(customer_invoice_id: self.id).update_all(customer_invoice_id: nil)
     end
  end

  validates_presence_of :contractor, :account,  :end_date , :start_date

  has_paper_trail class_name: 'AuditLogItem'


  scope :for_customer, -> { where vendor_invoice: false }
  scope :for_vendor, -> { where vendor_invoice: true }
  scope :approved, -> { where state_id: Billing::InvoiceState::APPROVED }
  scope :pending, -> { where state_id: Billing::InvoiceState::PENDING }

  before_create do
    execute_sp("SET LOCAL TIMEZONE TO ?", account.timezone.name)
  end

  # after_create do
  #   execute_sp("SELECT * FROM billing.invoice_generate(?)", self.id)
  # end

  after_create do

    execute_sp("lock table billing.invoices in exclusive mode") # see ticket #108
    # we need lock customer-vendor pair. Now I use lock table for this - this is dirty workaround
    # But we just need prevent vendor's invoice generation if any customer's invoice was generating now and vice versa

    if self.start_date.nil?
      previous_invoice=Billing::Invoice.where(account_id: self.account_id).order("end_date desc").limit(1).take
      if previous_invoice.nil?
        raise "Can't detect date start"
      end
      self.start_date=previous_invoice.end_date
    end

    if vendor_invoice # vendor invoice

      res=fetch_sp_val("select 1 from cdr.cdr WHERE vendor_acc_id=? AND time_start>=? and time_start<? AND vendor_invoice_id IS NOT NULL LIMIT 1",
                       self.account_id, self.start_date, self.end_date
      )
      if !res.nil?
        raise "billing.invoice_generate: some vendor invoices already found for this interval"
      end

      execute_sp("
        WITH invoice_data as (
          UPDATE cdr.cdr SET vendor_invoice_id=?
          WHERE
            vendor_acc_id =? AND
            time_start>=? AND
            time_start<? AND
            vendor_invoice_id IS NULL
          RETURNING *
        )
        insert into billing.invoice_destinations(
          dst_prefix, country_id, network_id, rate,
          calls_count,
          successful_calls_count,
          calls_duration,
          amount,
          invoice_id,
          first_call_at,
          first_successful_call_at,
          last_call_at,
          last_successful_call_at
        ) select
          dialpeer_prefix, dst_country_id, dst_network_id, dialpeer_next_rate,
          count(id),  -- calls count
          count(nullif(success,false)),  -- succesful_calls_count
          sum(duration),
          sum(vendor_price),
          ?,
          min(time_start),
          min(case success when true then time_start else null end),
          max(time_start),
          max(case success when true then time_start else null end)
        from invoice_data
        group by dialpeer_prefix, dst_country_id, dst_network_id, dialpeer_next_rate",
                 self.id, self.account_id, self.start_date, self.end_date, self.id
      )
    else # customer invoice

      res=fetch_sp_val("select 1 from cdr.cdr WHERE customer_acc_id=? AND time_start>=? and time_start<? AND customer_invoice_id IS NOT NULL LIMIT 1",
                       self.account_id, self.start_date, self.end_date
      )
      if !res.nil?
        raise "billing.invoice_generate: some customer invoices already found for this interval"
      end

      execute_sp("
        WITH invoice_data as (
          UPDATE cdr.cdr SET customer_invoice_id=?
          WHERE
            customer_acc_id =? AND
            time_start >=? AND
            time_start < ? AND
            customer_invoice_id IS NULL
          RETURNING *
        )
        insert into billing.invoice_destinations(
          dst_prefix, country_id, network_id, rate,
          calls_count,
          successful_calls_count,
          calls_duration,
          amount,
          invoice_id,
          first_call_at,
          first_successful_call_at,
          last_call_at,
          last_successful_call_at
        ) select
          destination_prefix, dst_country_id, dst_network_id, destination_next_rate,
          count(nullif(is_last_cdr,false)),
          count(nullif((success AND is_last_cdr),false)),  -- succesful_calls_count
          sum(duration),
          sum(customer_price),
          ?,
          min(time_start),
          min(case success when true then time_start else null end),
          max(time_start),
          max(case success when true then time_start else null end)
        from invoice_data
        group by destination_prefix, dst_country_id, dst_network_id, destination_next_rate",
                 self.id, self.account_id, self.start_date, self.end_date, self.id
      )
    end
    detalize_invoice

  end


  after_initialize do
    if self.new_record?
      self.amount ||= 0
      self.calls_count ||= 0
      self.calls_duration ||= 0
    end
  end

  def detalize_invoice
    data=destinations.summary
    self.amount=data.amount
    self.calls_count=data.calls_count
    self.successful_calls_count=data.successful_calls_count
    self.calls_duration=data.calls_duration
    self.first_call_at=data.first_call_at
    self.first_successful_call_at=data.first_successful_call_at
    self.last_call_at=data.last_call_at
    self.last_successful_call_at=data.last_successful_call_at
    self.save!
  end

  def cdr_filter_for_invoice
    "time_start=>'#{self.start_date.strftime("%Y-%m-%d %H%M%S.%L")}' AND time_end <'#{self.end_date.strftime("%Y-%m-%d %H%M%S.%L")}'"
  end

  def display_name
    "Invoice #{self.id}"
  end


  def approve
    self.state_id=Billing::InvoiceState::APPROVED
    self.save
    send_email
  end

  def approvable?
    Billing::InvoiceState::PENDING==self.state_id
  end

  def regenerate_document_allowed?
    Billing::InvoiceState::PENDING==self.state_id
  end

  def regenerate_document
    transaction do
      invoice_document.delete unless invoice_document.nil?
      begin
        InvoiceDocs.new(self).save!
      rescue InvoiceDocs::TemplateUndefined => e
        Rails.logger.info { e.message }
      end
    end
  end

  def invoice_period
    if self.vendor_invoice?
       self.account.vendor_invoice_period
    else
      self.account.customer_invoice_period
    end
  end

  def odt_template
    if self.vendor_invoice?
      self.account.vendor_invoice_template
    else
      self.account.customer_invoice_template
    end
  end

  def file_name
    "#{self.id}_#{self.start_date}_#{self.end_date}"
  end

  def self.totals
    except(:eager_load).select("sum(amount) as total_amount, sum(calls_count) as total_calls_count, sum(calls_duration) as total_calls_duration").take
  end

  def contacts_for_invoices
    account.contacts_for_invoices
  end

  def subject
    display_name
  end

  #FIX this copy paste
  def send_email
      if !invoice_document.nil?
        invoice_document.send_invoice
    end
  end

end
