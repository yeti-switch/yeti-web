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
  STATE_ID_TERMINATED = 30

  STATES = {
    STATE_ID_ACTIVE => 'Active',
    STATE_ID_SUSPENDED => 'Suspended',
    STATE_ID_TERMINATED => 'Terminated'
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
  has_many :transactions, class_name: 'Billing::Transaction'

  # callback defined before association because it should be called before it's `dependent: :destroy` callback
  before_destroy :provisioning_object_before_destroy
  has_many :package_counters, class_name: 'Billing::PackageCounter', dependent: :destroy

  attr_readonly :account_id, :type_id

  before_validation { self.variables = nil if variables.blank? }

  validates :initial_price, :renew_price, presence: true
  validates :initial_price, :renew_price, numericality: true, allow_nil: true
  validates :state_id, inclusion: { in: STATES.keys }
  validates :renew_period_id, inclusion: { in: RENEW_PERIODS.keys }, allow_nil: true
  validates :renew_at, presence: true, allow_nil: false, if: proc { !renew_period_id.nil? }
  validates :renew_at, absence: true, allow_nil: true, if: proc { renew_period_id.nil? }
  validate :validate_variables
  validate :prevent_state_change_from_terminated, on: :update

  before_create :verify_provisioning_variables
  before_create :assign_uuid
  before_update :verify_provisioning_variables, if: :variables_changed?

  after_create :create_initial_transaction
  after_create :provisioning_object_after_create

  after_destroy :provisioning_object_after_destroy

  scope :ready_for_renew, lambda {
    where('renew_period_id is not null AND renew_at <= ? ', Time.current)
      .where.not(state_id: STATE_ID_TERMINATED)
      .order(renew_at: :asc)
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

  def terminated?
    state_id == STATE_ID_TERMINATED
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

  def provisioning_object_before_destroy
    build_provisioning_object.before_destroy
  end

  def provisioning_object_after_destroy
    build_provisioning_object.after_destroy
  end

  def validate_variables
    if !variables.nil? && !variables.is_a?(Hash)
      errors.add(:variables, 'must be a JSON object or empty')
    end
  end

  def prevent_state_change_from_terminated
    return unless state_id_changed? && state_id_was == STATE_ID_TERMINATED

    errors.add(:state_id, 'cannot be changed once terminated')
  end

  def verify_provisioning_variables
    self.variables = build_provisioning_object.verify_service_variables!
  rescue Billing::Provisioning::Errors::InvalidVariablesError => e
    e.full_error_messages.each { |msg| errors.add(:variables, msg) }
    throw(:abort)
  end

  def assign_uuid
    self.uuid = SecureRandom.uuid
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
