# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.services
#
#  id              :bigint(8)        not null, primary key
#  initial_price   :decimal(, )      not null
#  name            :string
#  renew_at        :timestamptz
#  renew_price     :decimal(, )      not null
#  uuid            :uuid             not null
#  variables       :jsonb
#  created_at      :timestamptz      not null
#  account_id      :integer(4)       not null
#  renew_period_id :integer(2)
#  state_id        :integer(2)       default(10), not null
#  type_id         :integer(2)       not null
#
# Indexes
#
#  services_account_id_idx  (account_id)
#  services_renew_at_idx    (renew_at)
#  services_type_id_idx     (type_id)
#  services_uuid_idx        (uuid)
#
# Foreign Keys
#
#  services_account_id_fkey  (account_id => accounts.id)
#  services_type_id_fkey     (type_id => service_types.id)
#
class Billing::Service < ApplicationRecord
  self.table_name = 'billing.services'

  STATE_ID_ACTIVE = 10
  STATE_ID_SUSPENDED = 20

  STATES = {
    STATE_ID_ACTIVE => 'Active',
    STATE_ID_SUSPENDED => 'Suspended'
  }.freeze

  RENEW_PERIOD_ID_DAY = 10
  RENEW_PERIOD_ID_MONTH = 20
  RENEW_PERIOD_EMPTY = 'Disabled'
  RENEW_PERIODS = {
    RENEW_PERIOD_ID_DAY => 'Day',
    RENEW_PERIOD_ID_MONTH => 'Month'
  }.freeze

  include WithPaperTrail

  belongs_to :type, class_name: 'Billing::ServiceType'
  belongs_to :account, class_name: 'Account'
  has_many :transactions, class_name: 'Billing::Transaction', dependent: :restrict_with_error
  has_many :package_counters, class_name: 'Billing::PackageCounter', dependent: :destroy

  attr_readonly :account_id, :type_id

  validates :initial_price, :renew_price, presence: true
  validates :initial_price, :renew_price, numericality: true, allow_nil: true
  validates :state_id, inclusion: { in: STATES.keys }
  validates :renew_period_id, inclusion: { in: RENEW_PERIODS.keys }, allow_nil: true
  validate :validate_variables

  after_create :create_initial_transaction
  after_create :provisioning_object_after_create

  scope :ready_for_renew, lambda {
    where('renew_period_id is not null AND renew_at <= ? ', Time.current)
  }
  scope :one_time_services, lambda {
    where('renew_period_id is null')
  }

  def display_name
    name
  end

  def state
    STATES[state_id]
  end

  def renew_period
    renew_period_id.nil? ? RENEW_PERIOD_EMPTY : RENEW_PERIODS[renew_period_id]
  end

  def variables_json
    return if variables.nil?
    # need to show invalid variables JSON as is in new/edit form.
    return variables if variables.is_a?(String)

    JSON.generate(variables)
  end

  def variables_json=(value)
    self.variables = value.blank? ? nil : JSON.parse(value)
  rescue JSON::ParserError
    # need to show invalid variables JSON as is in new/edit form.
    self.variables = value
  end

  def build_provisioning_object
    type.provisioning_class.constantize.new(self)
  end

  private

  def provisioning_object_after_create
    build_provisioning_object.after_create
  end

  def validate_variables
    errors.add(:variables, 'must be a JSON object or empty') if !variables.nil? && !variables.is_a?(Hash)
  end

  def create_initial_transaction
    return if initial_price == 0

    account.lock! # will generate SELECT FOR UPDATE SQL statement
    transaction = Billing::Transaction.new(
      service: self, account:, amount: initial_price, description: 'Service creation'
    )
    unless transaction.save
      errors.add(:base, "Unable to create transaction: #{transaction.errors.full_messages.to_sentence}")
      throw(:abort)
    end
  end
end
