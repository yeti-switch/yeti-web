# frozen_string_literal: true

class BatchUpdateForm::RoutingPlan < BatchUpdateForm::Base
  model_class 'Routing::RoutingPlan'
  attribute :sorting_id, type: :foreign_key, class_name: 'Sorting'
  attribute :use_lnp, type: :boolean
  attribute :rate_delta_max
  attribute :validate_dst_number_format, type: :boolean
  attribute :validate_dst_number_network, type: :boolean

  validates :rate_delta_max, presence: true, if: :rate_delta_max_changed?
  validates :rate_delta_max, numericality: {
    greater_than_or_equal_to: 0,
    allow_blank: true
  }, if: :rate_delta_max_changed?
end
