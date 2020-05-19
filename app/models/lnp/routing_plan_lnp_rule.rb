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

class Lnp::RoutingPlanLnpRule < Yeti::ActiveRecord
  self.table_name = 'class4.routing_plan_lnp_rules'

  belongs_to :database, class_name: 'Lnp::Database', foreign_key: :database_id
  belongs_to :routing_plan, class_name: 'Routing::RoutingPlan', foreign_key: :routing_plan_id

  validates :routing_plan, :database, presence: true
  validates :dst_prefix, format: { without: /\s/ }
  validates :dst_prefix, uniqueness: { scope: %i[routing_plan_id database_id] }
end
