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
  attribute :rate_group_id, type: :foreign_key, class_name: 'Routing::RateGroup'
  attribute :valid_from, type: :date
  attribute :valid_till, type: :date
  attribute :rate_policy_id, type: :foreign_key, class_name: 'Routing::DestinationRatePolicy'
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
  attribute :routing_tag_ids, type: :foreign_key, class_name: 'Routing::RoutingTag'

  # presence validations
  validates :dst_number_min_length, presence: true, if: :dst_number_min_length_changed?
  validates :dst_number_max_length, presence: true, if: :dst_number_max_length_changed?
  validates :initial_rate, presence: true, if: :initial_rate_changed?
  validates :next_rate, presence: true, if: :next_rate_changed?
  validates :initial_interval, presence: true, if: :initial_interval_changed?
  validates :next_interval, presence: true, if: :next_interval_changed?
  validates :connect_fee, presence: true, if: :connect_fee_changed?
  validates :dp_margin_fixed, presence: true, if: :dp_margin_fixed_changed?
  validates :dp_margin_percent, presence: true, if: :dp_margin_percent_changed?
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
    only_integer: true,
    allow_blank: true
  }, if: :dst_number_min_length_changed?
  validates :dst_number_max_length, numericality: {
    greater_than_or_equal_to: :dst_number_min_length,
    less_than_or_equal_to: 100,
    allow_nil: false,
    only_integer: true,
    allow_blank: true
  }, if: -> { :dst_number_max_length_changed? && dst_number_min_length =~ /^[0-9]+$/ }
  validates :dp_margin_percent, numericality: {
    greater_than: 0,
    allow_blank: true
  }, if: :dp_margin_percent_changed?
  validates :connect_fee, numericality: {
    greater_than_or_equal_to: 0,
    allow_blank: true
  }, if: :connect_fee_changed?
  validates :dp_margin_fixed, numericality: {
    greater_than_or_equal_to: 0,
    allow_blank: true
  }, if: :dp_margin_fixed_changed?
  validates :asr_limit, numericality: {
    greater_than_or_equal_to: 0.00,
    less_than_or_equal_to: 1.00,
    allow_blank: true
  }, if: :asr_limit_changed?
  validates :initial_interval, numericality: {
    greater_than: 0,
    only_integer: true,
    allow_blank: true
  }, if: :initial_interval_changed?
  validates :acd_limit, numericality: {
    greater_than_or_equal_to: 0,
    allow_blank: true
  }, if: :acd_limit_changed?
  validates :short_calls_limit, numericality: {
    greater_than_or_equal_to: 0,
    allow_blank: true
  }, if: :short_calls_limit_changed?
  validates :next_interval, numericality: {
    only_integer: true,
    greater_than: 0,
    allow_blank: true
  }, if: :next_interval_changed?
  validates :initial_rate, numericality: { allow_blank: true }, if: :initial_rate_changed?
  validates :next_rate, numericality: { allow_blank: true }, if: :next_rate_changed?

  # date validations
  validates_date :valid_from, on_or_before: :valid_till, if: -> { valid_from.present? && valid_till.present? }

  # format validations
  validates :prefix, format: { without: /\s/, message: I18n.t('activerecord.errors.models.routing\destination.attributes.prefix.with_spaces') }, if: :prefix_changed?

  # require validations
  validates :valid_from, required_with: :valid_till, if: -> { valid_from.nil? || valid_till.nil? }
  validates :dst_number_min_length, required_with: :dst_number_max_length, if: -> { dst_number_min_length.nil? || dst_number_max_length.nil? }
end
