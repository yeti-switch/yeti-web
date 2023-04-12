# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routing_plan_lnp_rules
#
#  id                       :integer(4)       not null, primary key
#  drop_call_on_error       :boolean          default(FALSE), not null
#  dst_prefix               :string           default(""), not null
#  lrn_rewrite_result       :string
#  lrn_rewrite_rule         :string
#  req_dst_rewrite_result   :string
#  req_dst_rewrite_rule     :string
#  rewrite_call_destination :boolean          default(FALSE), not null
#  created_at               :timestamptz
#  database_id              :integer(2)       not null
#  routing_plan_id          :integer(4)       not null
#
# Indexes
#
#  routing_plan_lnp_rules_prefix_range_routing_plan_id_idx          (((dst_prefix)::prefix_range), routing_plan_id) USING gist
#  routing_plan_lnp_rules_routing_plan_id_dst_prefix_database__idx  (routing_plan_id,dst_prefix,database_id) UNIQUE
#
# Foreign Keys
#
#  routing_plan_lnp_rules_database_id_fkey  (database_id => lnp_databases.id)
#

class Lnp::RoutingPlanLnpRule < ApplicationRecord
  self.table_name = 'class4.routing_plan_lnp_rules'

  belongs_to :database, class_name: 'Lnp::Database', foreign_key: :database_id
  belongs_to :routing_plan, class_name: 'Routing::RoutingPlan', foreign_key: :routing_plan_id

  validates :routing_plan, :database, presence: true
  validates :dst_prefix, format: { without: /\s/ }
  validates :dst_prefix, uniqueness: { scope: %i[routing_plan_id database_id] }
end
