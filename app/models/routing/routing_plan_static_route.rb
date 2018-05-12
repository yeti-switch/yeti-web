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
#

class Routing::RoutingPlanStaticRoute < ActiveRecord::Base
  self.table_name='class4.routing_plan_static_routes'

  belongs_to :routing_plan
  belongs_to :vendor, -> { where vendor: true }, class_name: 'Contractor', foreign_key: :vendor_id

  has_paper_trail class_name: 'AuditLogItem'

  include Yeti::NetworkDetector

  validates_format_of :prefix, without: /\s/
  validates_presence_of :vendor, :routing_plan

  validate do
    self.errors.add(:routing_plan, :invalid) unless routing_plan.use_static_routes?
  end

  def display_name
    "#{self.prefix} | #{self.id}"
  end
end
