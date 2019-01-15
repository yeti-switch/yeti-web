# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id                            :integer          not null, primary key
#  contractor_id                 :integer          not null
#  balance                       :decimal(, )      not null
#  min_balance                   :decimal(, )      not null
#  max_balance                   :decimal(, )      not null
#  name                          :string           not null
#  origination_capacity          :integer
#  termination_capacity          :integer
#  customer_invoice_period_id    :integer
#  customer_invoice_template_id  :integer
#  vendor_invoice_template_id    :integer
#  next_customer_invoice_at      :datetime
#  next_vendor_invoice_at        :datetime
#  vendor_invoice_period_id      :integer
#  send_invoices_to              :integer          is an Array
#  timezone_id                   :integer          default(1), not null
#  next_customer_invoice_type_id :integer
#  next_vendor_invoice_type_id   :integer
#  balance_high_threshold        :decimal(, )
#  balance_low_threshold         :decimal(, )
#  send_balance_notifications_to :integer          is an Array
#  uuid                          :uuid             not null
#  external_id                   :integer
#  vat                           :decimal(, )      default(0.0), not null
#  total_capacity                :integer
#  destination_rate_limit        :decimal(, )
#  max_call_duration             :integer
#

class Account < Yeti::ActiveRecord
  belongs_to :contractor

  # belongs_to :customer_invoice_period, class_name: 'Billing::InvoicePeriod', foreign_key: 'customer_invoice_period_id'
  # belongs_to :vendor_invoice_period, class_name: 'Billing::InvoicePeriod', foreign_key: 'vendor_invoice_period_id'

  belongs_to :customer_invoice_period, class_name: 'Billing::InvoicePeriod'
  belongs_to :vendor_invoice_period, class_name: 'Billing::InvoicePeriod'

  belongs_to :vendor_invoice_template, class_name: 'Billing::InvoiceTemplate', foreign_key: 'vendor_invoice_template_id'
  belongs_to :customer_invoice_template, class_name: 'Billing::InvoiceTemplate', foreign_key: 'customer_invoice_template_id'
  belongs_to :timezone, class_name: 'System::Timezone', foreign_key: :timezone_id

  has_many :payments, dependent: :destroy
  has_many :invoices, class_name: 'Billing::Invoice'
  has_many :api_access, ->(record) { unscope(:where).where("? = ANY(#{table_name}.account_ids)", record.id) }, class_name: 'System::ApiAccess', autosave: false
  has_many :customers_auths, dependent: :restrict_with_error
  has_many :dialpeers, dependent: :restrict_with_error

  has_paper_trail class_name: 'AuditLogItem'

  default_scope { includes(:contractor) }
  scope :vendors_accounts, -> { joins(:contractor).where('contractors.vendor' => true) }
  scope :customers_accounts, -> { joins(:contractor).where('contractors.customer' => true) }
  scope :collection, -> { order(:name) }

  validates_numericality_of :min_balance, :balance
  validates_uniqueness_of :uuid, :name
  validates_presence_of :name, :contractor, :timezone, :vat
  validates_numericality_of :max_balance, greater_than_or_equal_to: ->(account) { account.min_balance }

  validates_numericality_of :termination_capacity, :origination_capacity, :total_capacity,
                            greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: true, only_integer: true

  validates_uniqueness_of :external_id, allow_blank: true

  validates_numericality_of :vat, greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false # this is percents
  validates_numericality_of :destination_rate_limit, greater_than_or_equal_to: 0, allow_nil: true
  validates_numericality_of :max_call_duration, greater_than_or_equal_to: 0, allow_nil: true

  after_initialize do
    if new_record?
      self.balance ||= 0
      self.max_balance ||= 0
      self.min_balance ||= 0
    end
  end

  def send_invoices_to_emails
    contacts_for_invoices.map(&:email).join(',')
  end

  def send_balance_notifications_to_emails
    contacts_for_balance_notifications.map(&:email).join(',')
  end

  def self.totals
    except(:eager_load).select('sum(balance) as total_balance').take
  end

  def contacts_for_invoices
    @contacts ||= Billing::Contact.where(id: send_invoices_to)
  end

  def contacts_for_balance_notifications
    @contacts_balance ||= Billing::Contact.where(id: send_balance_notifications_to)
  end

  before_save do
    if customer_invoice_period_id_changed?

      if customer_invoice_period
        self.next_customer_invoice_at = customer_invoice_period.next_date_from_now
        self.next_customer_invoice_type_id = customer_invoice_period.invoice_type(last_customer_invoice_date, next_customer_invoice_at)
      else
        self.next_customer_invoice_at = nil
        self.next_customer_invoice_type_id = nil
      end
    end

    if vendor_invoice_period_id_changed?

      if vendor_invoice_period
        self.next_vendor_invoice_at = vendor_invoice_period.next_date_from_now
        self.next_vendor_invoice_type_id = vendor_invoice_period.invoice_type(last_vendor_invoice_date, next_vendor_invoice_at)
      else
        self.next_vendor_invoice_at = nil
        self.next_vendor_invoice_type_id = nil
      end
    end
  end

  before_destroy :remove_self_from_related_api_access!

  def last_customer_invoice_date
    invoices.for_customer.order('end_date desc').limit(1).take.try!(:end_date) || customer_invoice_period.initial_date
  end

  def last_vendor_invoice_date
    invoices.for_vendor.order('end_date desc').limit(1).take.try!(:end_date) || vendor_invoice_period.initial_date
  end

  def schedule_next_customer_invoice!
    last_date = next_customer_invoice_at
    self.next_customer_invoice_at = customer_invoice_period.next_date(last_date)
    self.next_customer_invoice_type_id = customer_invoice_period.invoice_type(last_date, next_customer_invoice_at)
    save!
  end

  def schedule_next_vendor_invoice!
    last_date = next_vendor_invoice_at
    self.next_vendor_invoice_at = vendor_invoice_period.next_date(last_date)
    self.next_vendor_invoice_type_id = vendor_invoice_period.invoice_type(last_date, next_vendor_invoice_at)
    save!
  end

  # after_update :, if: proc {|obj| obj.vendor_invoice_period_id_changed? }

  def display_name
    "#{name} | #{id}"
  end

  scope :insufficient_balance, -> { where('balance<=min_balance OR balance>=max_balance') }

  def min_balance_reached?
    balance <= min_balance
  end

  def max_balance_reached?
    self.balance >= self.max_balance
  end

  def min_balance_close?
    balance <= min_balance * 1.1
  end

  def max_balance_close?
    balance * 1.1 >= max_balance
  end

  def fire_low_balance_alarm(data)
    Notification::Alert.fire_account_low_balance(self, data)
  end

  def clear_low_balance_alarm(data)
    Notification::Alert.clear_account_low_balance(self, data)
  end

  def fire_high_balance_alarm(data)
    Notification::Alert.fire_account_high_balance(self, data)
  end

  def clear_high_balance_alarm(data)
    Notification::Alert.clear_account_high_balance(self, data)
  end

  def remove_self_from_related_api_access!
    api_access.each do |record|
      record.account_ids.delete(id)
      record.save!
    end
  end
end
