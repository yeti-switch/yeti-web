# frozen_string_literal: true

class BatchUpdateForm::Dialpeer < BatchUpdateForm::Base
  model_class 'Dialpeer'
  attribute :enabled, type: :boolean
  attribute :prefix
  attribute :dst_number_min_length
  attribute :dst_number_max_length
  attribute :routing_tag_mode_id, type: :foreign_key, class_name: 'Routing::RoutingTagMode'
  attribute :routing_group_id, type: :foreign_key, class_name: 'RoutingGroup'
  attribute :priority
  attribute :force_hit_rate
  attribute :exclusive_route, type: :boolean
  attribute :initial_interval
  attribute :initial_rate
  attribute :next_interval
  attribute :next_rate
  attribute :connect_fee
  attribute :lcr_rate_multiplier
  attribute :gateway_id, type: :foreign_key, class_name: 'Gateway'
  attribute :gateway_group_id, type: :foreign_key, class_name: 'GatewayGroup'
  attribute :vendor_id, type: :foreign_key, class_name: 'Contractor', scope: :vendors
  attribute :account_id, type: :foreign_key, class_name: 'Account'
  attribute :routeset_discriminator_id, type: :foreign_key, class_name: 'Routing::RoutesetDiscriminator'
  attribute :valid_from, type: :date
  attribute :valid_till, type: :date
  attribute :asr_limit
  attribute :acd_limit
  attribute :short_calls_limit
  attribute :capacity
  attribute :src_name_rewrite_rule
  attribute :src_name_rewrite_result
  attribute :src_rewrite_rule
  attribute :src_rewrite_result
  attribute :dst_rewrite_rule
  attribute :dst_rewrite_result

  # presence
  validates :dst_number_min_length, presence: true, if: :dst_number_min_length_changed?
  validates :dst_number_max_length, presence: true, if: :dst_number_max_length_changed?
  validates :initial_interval, presence: true, if: :initial_interval_changed?
  validates :initial_rate, presence: true, if: :initial_rate_changed?
  validates :next_interval, presence: true, if: :next_interval_changed?
  validates :next_rate, presence: true, if: :next_rate_changed?
  validates :connect_fee, presence: true, if: :connect_fee_changed?
  validates :acd_limit, presence: true, if: :acd_limit_changed?
  validates :asr_limit, presence: true, if: :asr_limit_changed?
  validates :prefix, presence: true, if: :prefix_changed?
  validates :priority, presence: true, if: :priority_changed?
  validates :valid_from, presence: true, if: :valid_from_changed?
  validates :valid_till, presence: true, if: :valid_till_changed?
  validates :short_calls_limit, presence: true, if: :short_calls_limit_changed?

  # required with
  validates :account_id, required_with: :vendor_id
  validates :gateway_id, required_with: :vendor_id, unless: :gateway_is_shared?
  validates :gateway_group_id, required_with: :vendor_id
  validates :valid_from, required_with: :valid_till
  validates :dst_number_min_length, required_with: :dst_number_max_length

  # numericality
  validates :initial_rate, numericality: true, if: :initial_rate_changed?
  validates :next_rate, numericality: true, if: :next_rate_changed?
  validates :connect_fee, numericality: true, if: :connect_fee_changed?
  validates :initial_interval, numericality: { greater_than: 0, only_integer: true }, if: :initial_interval_changed?
  validates :next_interval, numericality: { greater_than: 0, only_integer: true }, if: :next_interval_changed?
  validates :priority, numericality: {
    only_integer: true
  }, if: :priority_changed?
  validates :acd_limit, numericality: {
    greater_than_or_equal_to: 0.00,
    less_than_or_equal_to: 1.00
  }, if: :acd_limit_changed?
  validates :asr_limit, numericality: {
    greater_than_or_equal_to: 0.00,
    less_than_or_equal_to: 1.00
  }, if: :asr_limit_changed?
  validates :short_calls_limit, numericality: {
    greater_than_or_equal_to: 0.00,
    less_than_or_equal_to: 1.00
  }, if: :short_calls_limit_changed?
  validates :force_hit_rate, numericality: {
    greater_than_or_equal_to: 0.00,
    less_than_or_equal_to: 1.00,
    allow_blank: true
  }, if: :force_hit_rate_changed?
  validates :capacity, numericality: {
    greater_than: 0,
    less_than_or_equal_to: Yeti::ActiveRecord::PG_MAX_SMALLINT
  }, if: :capacity_changed?
  validates :dst_number_max_length, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100,
    only_integer: true
  }, if: :dst_number_max_length_changed?
  validates :dst_number_min_length, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100,
    only_integer: true
  }, if: :dst_number_min_length_changed?

  validates :prefix, format: { without: /\s/, message: 'spaced is not allowed' }, if: :prefix_changed?

  validate :vendor_owners_the_gateway, if: %i[vendor_id_changed? gateway_id_changed?]

  validate :vendor_owners_the_gateway_group, if: %i[vendor_id_changed? gateway_group_id_changed?]

  validate if: :vendor_id_changed? do
    errors.add(:base, 'contractor must be vendor') if is_customer?(vendor_id)
  end

  validate if: %i[account_id_changed? vendor_id_changed?] do
    errors.add(:account_id, 'must be owned by selected vendor') unless vendor_is_owners_account?
  end

  def vendor_is_owners_account?
    vendor_id.to_i == Account.find(account_id).contractor_id
  end

  def vendor_owners_the_gateway
    return true if gateway_id.nil?

    gateway = Gateway.find_by(id: gateway_id.to_i)
    return true if gateway&.is_shared?

    unless vendor_id.to_i == gateway.contractor_id
      errors.add(:gateway_id, 'must be owned by selected vendor or be shared')
    end

    unless gateway.allow_termination
      errors.add(:gateway_id, 'must be allowed for termination')
    end
  end

  def vendor_owners_the_gateway_group
    return true if gateway_group_id.nil?

    gateway_group = GatewayGroup.find_by(id: gateway_group_id.to_i)
    errors.add(:gateway_group_id, 'must be owners by selected vendor') if gateway_group&.vendor_id != vendor_id.to_i
  end

  def is_customer?(id)
    Contractor.find(id).customer?
  end

  def gateway_is_shared?
    return false if gateway_id.nil?

    Gateway.find_by(id: gateway_id)&.is_shared?
  end

  validates_date :valid_from, on_or_before: :valid_till, if: %i[valid_from_changed? valid_till_changed?]
end
