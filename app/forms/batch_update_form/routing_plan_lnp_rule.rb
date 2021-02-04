# frozen_string_literal: true

class BatchUpdateForm::RoutingPlanLnpRule < BatchUpdateForm::Base
  model_class 'Lnp::RoutingPlanLnpRule'
  attribute :routing_plan_id, type: :foreign_key, class_name: 'Routing::RoutingPlan'
  attribute :req_dst_rewrite_rule
  attribute :req_dst_rewrite_result
  attribute :database_id, type: :foreign_key, class_name: 'Lnp::Database'
  attribute :lrn_rewrite_rule
  attribute :lrn_rewrite_result
end
