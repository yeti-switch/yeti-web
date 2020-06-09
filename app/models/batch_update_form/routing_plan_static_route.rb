# frozen_string_literal: true

class BatchUpdateForm::RoutingPlanStaticRoute < BatchUpdateForm::Base
  model_class 'Routing::RoutingPlanStaticRoute'
  attribute :routing_plan_id, type: :foreign_key, class_name: 'Routing::RoutingPlan'
  attribute :prefix
  attribute :priority
  attribute :weight
  attribute :vendor_id, type: :foreign_key, class_name: 'Contractor'

  # presence
  validates :priority, presence: true, if: :priority_changed?
  validates :weight, presence: true, if: :weight_changed?

  # numericality
  validates :priority, numericality: {
    greater_than: 0,
    less_than_or_equal_to: Routing::RoutingPlanStaticRoute::PG_MAX_SMALLINT,
    allow_nil: false,
    only_integer: true
  }, if: :priority_changed?
  validates :weight, numericality: {
    greater_than: 0,
    less_than_or_equal_to: Routing::RoutingPlanStaticRoute::PG_MAX_SMALLINT,
    allow_nil: false,
    only_integer: true
  }, if: :weight_changed?

  validates :prefix, format: { without: /\s/, message: 'spaces are not allowed' }, if: :prefix_changed?
end
