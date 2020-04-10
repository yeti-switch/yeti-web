# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routing_plan_lnp_rules
#
#  id                     :integer          not null, primary key
#  routing_plan_id        :integer          not null
#  dst_prefix             :string           default(""), not null
#  database_id            :integer          not null
#  created_at             :datetime
#  lrn_rewrite_rule       :string
#  lrn_rewrite_result     :string
#  req_dst_rewrite_rule   :string
#  req_dst_rewrite_result :string
#

FactoryGirl.define do
  factory :lnp_routing_plan_lnp_rule, class: Lnp::RoutingPlanLnpRule do
    association :routing_plan, factory: :routing_plan
    database { create(:lnp_database, :thinq) }
  end
end
