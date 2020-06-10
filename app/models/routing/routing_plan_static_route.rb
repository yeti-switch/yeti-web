# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routing_plan_static_routes
#
#  id                :integer          not null, primary key
#  routing_plan_id   :integer          not null
#  prefix            :string           default(""), not null
#  vendor_id         :integer          not null
#  priority          :integer          default(100), not null
#  network_prefix_id :integer
#  weight            :integer          default(100), not null
#

class Routing::RoutingPlanStaticRoute < Yeti::ActiveRecord
  self.table_name = 'class4.routing_plan_static_routes'

  belongs_to :routing_plan
  belongs_to :vendor, -> { where vendor: true }, class_name: 'Contractor', foreign_key: :vendor_id

  has_paper_trail class_name: 'AuditLogItem'

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
