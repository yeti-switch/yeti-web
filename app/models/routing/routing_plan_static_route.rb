# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routing_plan_static_routes
#
#  id                :integer(4)       not null, primary key
#  prefix            :string           default(""), not null
#  priority          :integer(2)       default(100), not null
#  weight            :integer(2)       default(100), not null
#  network_prefix_id :integer(4)
#  routing_plan_id   :integer(4)       not null
#  vendor_id         :integer(4)       not null
#
# Indexes
#
#  routing_plan_static_routes_prefix_range_vendor_id_routing_p_idx  (((prefix)::prefix_range), vendor_id, routing_plan_id) USING gist
#  routing_plan_static_routes_vendor_id_idx                         (vendor_id)
#
# Foreign Keys
#
#  routing_plan_static_routes_routing_plan_id_fkey  (routing_plan_id => routing_plans.id)
#  routing_plan_static_routes_vendor_id_fkey        (vendor_id => contractors.id)
#

class Routing::RoutingPlanStaticRoute < ApplicationRecord
  self.table_name = 'class4.routing_plan_static_routes'

  belongs_to :routing_plan
  belongs_to :vendor, -> { where vendor: true }, class_name: 'Contractor', foreign_key: :vendor_id

  include WithPaperTrail

  include Yeti::NetworkDetector

  validates :prefix, format: { without: /\s/ }
  validates :vendor, :routing_plan, :priority, :weight, presence: true
  validates :weight, :priority, numericality: { greater_than: 0, less_than_or_equal_to: PG_MAX_SMALLINT, allow_nil: false, only_integer: true }

  validate do
    errors.add(:routing_plan, :invalid) if !routing_plan_id.nil? && !routing_plan.use_static_routes?
  end

  def display_name
    "#{prefix} | #{id}"
  end
end
