# frozen_string_literal: true

class BatchUpdateForm::Destination < BatchUpdateForm::Base
  model_class 'Routing::Destination'
  attribute :enabled, type: :boolean
  attribute :prefix
  attribute :dst_number_min_length
  attribute :dst_number_max_length
  attribute :routing_tag_mode_id, type: :foreign_key, class_name: 'Routing::RoutingTagMode'
  attribute :reject_calls, type: :boolean
  attribute :quality_alarm, type: :boolean
  attribute :rateplan_id, type: :foreign_key, class_name: 'Rateplan'
  attribute :valid_from, type: :date
  attribute :valid_till, type: :date
  attribute :rate_policy_id, type: :foreign_key, class_name: 'DestinationRatePolicy'
  attribute :initial_interval
  attribute :initial_rate
  attribute :next_interval
  attribute :next_rate
  attribute :use_dp_intervals, type: :boolean
  attribute :connect_fee
  attribute :profit_control_mode_id, type: :foreign_key, class_name: 'Routing::RateProfitControlMode'
  attribute :dp_margin_fixed
  attribute :dp_margin_percent
  attribute :asr_limit
  attribute :acd_limit
  attribute :short_calls_limit

  # presence validations
  validates :dst_number_min_length, presence: true, if: :dst_number_min_length_changed?
  validates :dst_number_max_length, presence: true, if: :dst_number_max_length_changed?
  validates :initial_rate, presence: true, if: :initial_rate_changed?
  validates :rateplan_id, presence: true, if: :rateplan_id_changed?
  validates :next_rate, presence: true, if: :next_rate_changed?
  validates :initial_interval, presence: true, if: :initial_interval_changed?
  validates :next_interval, presence: true, if: :next_interval_changed?
  validates :connect_fee, presence: true, if: :connect_fee_changed?
  validates :dp_margin_fixed, presence: true, if: :dp_margin_fixed_changed?
  validates :dp_margin_percent, presence: true, if: :dp_margin_percent_changed?
  validates :rate_policy_id, presence: true, if: :rate_policy_id_changed?
  validates :asr_limit, presence: true, if: :asr_limit_changed?
  validates :acd_limit, presence: true, if: :acd_limit_changed?
  validates :short_calls_limit, presence: true, if: :short_calls_limit_changed?
  validates :valid_from, presence: true, if: :valid_from_changed?
  validates :valid_till, presence: true, if: :valid_till_changed?

  # numericality validations
  validates :dst_number_min_length, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100,
    allow_nil: false,
    only_integer: true
  }, if: :dst_number_min_length_changed?

  validates :dst_number_max_length, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100,
    allow_nil: false,
    only_integer: true
  }, if: :dst_number_max_length_changed?
  validates :dp_margin_percent, numericality: {
    greater_than: 0
  }, if: :dp_margin_percent_changed?
  validates :connect_fee, numericality: {
    greater_than_or_equal_to: 0
  }, if: :connect_fee_changed?
  validates :dp_margin_fixed, numericality: {
    greater_than_or_equal_to: 0
  }, if: :dp_margin_fixed_changed?
  validates :asr_limit, numericality: {
    greater_than_or_equal_to: 0.00,
    less_than_or_equal_to: 1.00
  }, if: :asr_limit_changed?
  validates :initial_interval, numericality: {
    greater_than: 0,
    only_integer: true
  }, if: :initial_interval_changed?
  validates :acd_limit, numericality: {
    greater_than_or_equal_to: 0
  }, if: :acd_limit_changed?
  validates :short_calls_limit, numericality: {
    greater_than_or_equal_to: 0
  }, if: :short_calls_limit_changed?

  validates :initial_rate, numericality: true, if: :initial_rate_changed?
  validates :next_rate, numericality: true, if: :next_rate_changed?
  validates :next_interval, numericality: true, if: :next_interval_changed?

  # date validations
  validates_date :valid_from, on_or_before: :valid_till, if: %i[valid_from_changed? valid_till_changed?]

  # format validations
  validates :prefix, format: { without: /\s/, message: 'spaces are not allowed' }, if: :prefix_changed?

  # require validations
  validates :valid_from, required_with: :valid_till
  validates :dst_number_min_length, required_with: :dst_number_max_length

  validate if: -> { dst_number_min_length_changed? && dst_number_max_length_changed? } do
    errors.add :dst_number_min_length, "must be less than #{dst_number_max_length}" if dst_number_min_length > dst_number_max_length
  end

  validates :next_interval, numericality: { only_integer: true, greater_than: 0 }, if: :next_interval_changed?
end
