# frozen_string_literal: true

class BatchUpdateForm::Gateway < BatchUpdateForm::Base
  model_class 'Gateway'
  attribute :enabled, type: :boolean
  attribute :priority
  attribute :weight
  attribute :is_shared, type: :boolean
  attribute :acd_limit
  attribute :asr_limit
  attribute :short_calls_limit

  # presence
  validates :priority, presence: true, if: :priority_changed?
  validates :weight, presence: true, if: :weight_changed?
  validates :asr_limit, presence: true, if: :asr_limit_changed?
  validates :acd_limit, presence: true, if: :acd_limit_changed?

  # numericality
  validates :priority, numericality: {
    greater_than: 0,
    less_than_or_equal_to: Yeti::ActiveRecord::PG_MAX_SMALLINT,
    only_integer: true
  }, if: :priority_changed?
  validates :weight, numericality: {
    only_integer: true,
    less_than_or_equal_to: Yeti::ActiveRecord::PG_MAX_SMALLINT,
    greater_than: 0
  }, if: :weight_changed?
  validates :acd_limit, numericality: {
    greater_than_or_equal_to: 0.00
  }, if: :acd_limit_changed?
  validates :asr_limit, numericality: {
    less_than_or_equal_to: 1.00,
    greater_than_or_equal_to: 0.00
  }, if: :asr_limit_changed?
  validates :short_calls_limit, numericality: {
    greater_than_or_equal_to: 0.00,
    less_than_or_equal_to: 1.00
  }, if: :short_calls_limit_changed?
end
