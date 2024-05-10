# frozen_string_literal: true

# == Schema Information
#
# Table name: services
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
#  state_id        :integer(2)       not null
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
  self.table_name = 'services'

  STATE_ACTIVE = 0
  STATE_SUSPENDED = 1

  STATES = {
    STATE_ACTIVE => 'Active',
    STATE_SUSPENDED => 'Suspended'
  }.freeze

  STATE_COLORS = {
    STATE_ACTIVE => :ok,
    STATE_SUSPENDED => :red
  }.freeze

  RENEW_PERIOD_DAY = 1
  RENEW_PERIOD_MONTH = 2
  RENEW_PERIODS = {
    RENEW_PERIOD_DAY => 'Day',
    RENEW_PERIOD_MONTH => 'Month'
  }.freeze

  include WithPaperTrail

  belongs_to :type, class_name: 'Billing::ServiceType', foreign_key: :type_id
  belongs_to :account, class_name: 'Account', foreign_key: :account_id
  has_many :transactions, :class_name => 'Billing::Transaction', foreign_key: :service_id

  validates :type_id, presence: true
  validates :account_id, presence: true
  validates :initial_price, :renew_price, presence: true
  validates :state_id, inclusion: { in: STATES.keys }, allow_nil: false
  validates :renew_period_id, inclusion: { in: RENEW_PERIODS.keys }, allow_nil: true

  after_save :create_initial_transaction

  scope :for_renew, lambda {
    where('renew_period_id is not null AND renew_at <= ? ', Time.now)
  }
  scope :one_time_services, lambda {
    where('renew_period_id is null')
  }
  def display_name
    name
  end

  def state_name
    STATES[state_id]
  end

  def state_color
    STATE_COLORS[state_id]
  end

  def renew_period_name
    renew_period_id.nil? ? 'Disabled' : RENEW_PERIODS[renew_period_id]
  end

  after_initialize do
    if new_record?
      self.state_id = STATE_ACTIVE
    end
  end
  def create_initial_transaction
    return if initial_price == 0

    account.lock! # will generate SELECT FOR UPDATE SQL statement
    t = Billing::Transaction.new(service_id: id, account_id: account_id, amount: initial_price, description: 'Service creation')
    throw(:abort) unless t.save
  end

  def renew
    account.lock! # will generate SELECT FOR UPDATE SQL statement
    if (account.balance - account.min_balance < renew_price) && !type.force_renew
      self.state_id = STATE_SUSPENDED
      save!
    else
      t = Billing::Transaction.new(service_id: id, account_id: account_id, amount: renew_price, description: 'Renew service')
      throw(:abort) unless t.save
      self.state_id = STATE_ACTIVE
      if renew_period_id == RENEW_PERIOD_DAY
        self.renew_at = Date.tomorrow
      elsif renew_period_id == RENEW_PERIOD_MONTH
        self.renew_at = Date.today.at_beginning_of_month.next_month
      end
      save!
    end
  end
end
