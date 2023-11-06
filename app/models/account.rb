# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.accounts
#
#  id                     :integer(4)       not null, primary key
#  balance                :decimal(, )      not null
#  destination_rate_limit :decimal(, )
#  invoice_ref_template   :string           default("$id"), not null
#  max_balance            :decimal(, )      not null
#  max_call_duration      :integer(4)
#  min_balance            :decimal(, )      not null
#  name                   :string           not null
#  next_invoice_at        :timestamptz
#  origination_capacity   :integer(2)
#  send_invoices_to       :integer(4)       is an Array
#  termination_capacity   :integer(2)
#  total_capacity         :integer(2)
#  uuid                   :uuid             not null
#  vat                    :decimal(, )      default(0.0), not null
#  contractor_id          :integer(4)       not null
#  external_id            :bigint(8)
#  invoice_period_id      :integer(2)
#  invoice_template_id    :integer(4)
#  next_invoice_type_id   :integer(2)
#  timezone_id            :integer(4)       default(1), not null
#
# Indexes
#
#  accounts_contractor_id_idx  (contractor_id)
#  accounts_external_id_key    (external_id) UNIQUE
#  accounts_name_key           (name) UNIQUE
#  accounts_uuid_key           (uuid) UNIQUE
#
# Foreign Keys
#
#  accounts_contractor_id_fkey  (contractor_id => contractors.id)
#  accounts_timezone_id_fkey    (timezone_id => timezones.id)
#

class Account < ApplicationRecord
  self.table_name = 'billing.accounts'

  include WithPaperTrail

  Totals = Struct.new(:total_balance)

  class << self
    def totals
      row = extending(ActsAsTotalsRelation).totals_row_by('sum(balance) as total_balance')
      Totals.new(*row)
    end

    def ransackable_scopes(_auth_object = nil)
      %i[
        search_for ordered_by
      ]
    end
  end

  composed_of :invoice_period,
              class_name: 'Billing::InvoicePeriod',
              mapping: { invoice_period_id: :id },
              constructor: ->(invoice_period_id) { Billing::InvoicePeriod.find(invoice_period_id) }

  composed_of :next_invoice_type,
              class_name: 'Billing::InvoiceType',
              mapping: { next_invoice_type_id: :id },
              constructor: ->(next_invoice_type_id) { Billing::InvoiceType.find(next_invoice_type_id) }

  belongs_to :contractor
  belongs_to :invoice_template, class_name: 'Billing::InvoiceTemplate', optional: true
  belongs_to :timezone, class_name: 'System::Timezone', foreign_key: :timezone_id

  has_many :payments, dependent: :destroy
  has_many :invoices, class_name: 'Billing::Invoice'
  has_many :api_access, ->(record) { unscope(:where).where("? = ANY(#{table_name}.account_ids)", record.id) }, class_name: 'System::ApiAccess', autosave: false
  has_many :customers_auths, dependent: :restrict_with_error
  has_many :dialpeers, dependent: :restrict_with_error
  has_many :cdr_exports, class_name: 'CdrExport', foreign_key: :customer_account_id, dependent: :nullify
  has_many :rate_management_projects, class_name: 'RateManagement::Project'
  has_many :active_rate_management_pricelist_items,
           -> { not_applied },
           class_name: 'RateManagement::PricelistItem'
  has_many :applied_rate_management_pricelist_items,
           -> { applied },
           class_name: 'RateManagement::PricelistItem',
           dependent: :nullify

  has_one :balance_notification_setting,
          class_name: 'AccountBalanceNotificationSetting',
          inverse_of: :account,
          dependent: :destroy

  validates :min_balance, numericality: true, if: -> { min_balance.present? }
  validates :balance, numericality: true
  validates :uuid, :name, uniqueness: true
  validates :name, :timezone, :vat, :max_balance, :min_balance, presence: true
  validates :max_balance, numericality: { greater_than_or_equal_to: :min_balance }, if: -> { min_balance.present? }

  validates :termination_capacity, :origination_capacity, :total_capacity,
            numericality: { greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: true, only_integer: true }

  validates :external_id, uniqueness: { allow_blank: true }

  validates :vat, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: false } # this is percents
  validates :destination_rate_limit, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :max_call_duration, numericality: { greater_than: 0, allow_nil: true }
  validates :invoice_ref_template, presence: true
  validates :invoice_period_id, inclusion: { in: Billing::InvoicePeriod.ids }, allow_nil: true
  validates :next_invoice_type_id, inclusion: { in: Billing::InvoiceType.ids }, allow_nil: true

  after_initialize do
    if new_record?
      self.balance ||= 0
      self.max_balance ||= 0
      self.min_balance ||= 0
    end
  end

  after_create do
    create_balance_notification_setting! if balance_notification_setting.nil?
  end

  before_destroy :check_associated_records
  before_destroy :remove_self_from_related_api_access!

  default_scope { includes(:contractor) }
  scope :vendors_accounts, -> { joins(:contractor).where('contractors.vendor' => true) }
  scope :customers_accounts, -> { joins(:contractor).where('contractors.customer' => true) }
  scope :collection, -> { order(:name) }
  scope :search_for, ->(term) { where("accounts.name || ' | ' || accounts.id::varchar ILIKE ?", "%#{term}%") }
  scope :ordered_by, ->(term) { order(term) }

  scope :ready_for_invoice, lambda {
    # next_invoice_at + max_call_duration => time
    where('invoice_period_id IS NOT NULL')
      .where(
        '(next_invoice_at + MAKE_INTERVAL(secs => COALESCE(max_call_duration, ?))) <= ?',
        GuiConfig.max_call_duration, Time.now
      )
  }

  scope :balance_threshold_notification_required, lambda {
    state_none = AccountBalanceNotificationSetting::CONST::STATE_ID_NONE
    state_low_threshold = AccountBalanceNotificationSetting::CONST::STATE_ID_LOW_THRESHOLD
    state_high_threshold = AccountBalanceNotificationSetting::CONST::STATE_ID_HIGH_THRESHOLD
    joins(:balance_notification_setting).where("
      (state_id = #{state_low_threshold} AND (low_threshold IS NULL OR balance > low_threshold)) -- clear low
      OR
      (state_id = #{state_high_threshold} AND (high_threshold IS NULL OR balance < high_threshold)) -- clear high
      OR
      (state_id = #{state_none} AND low_threshold IS NOT NULL AND balance < low_threshold) -- fire low
      OR
      (state_id = #{state_none} AND high_threshold IS NOT NULL AND balance > high_threshold) -- fire high
    ")
  }

  scope :insufficient_balance, -> { where('balance<=min_balance OR balance>=max_balance') }

  def send_invoices_to_emails
    contacts_for_invoices.map(&:email).join(',')
  end

  def contacts_for_invoices
    @contacts ||= Billing::Contact.where(id: send_invoices_to)
  end

  def display_name
    "#{name} | #{id}"
  end

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

  private

  def remove_self_from_related_api_access!
    api_access.each do |record|
      record.account_ids.delete(id)
      record.save!
    end
  end

  def check_associated_records
    project_ids = rate_management_projects.pluck(:id)
    if project_ids.any?
      errors.add(:base, "Can't be deleted because linked to Rate Management Project(s) ##{project_ids.join(', #')}")
    end

    pricelist_ids = active_rate_management_pricelist_items.pluck(Arel.sql('DISTINCT(pricelist_id)'))
    if pricelist_ids.any?
      errors.add(:base, "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelist_ids.join(', #')}")
    end

    throw(:abort) if errors.any?
  end
end
