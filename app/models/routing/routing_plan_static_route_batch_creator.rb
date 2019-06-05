# frozen_string_literal: true

class Routing::RoutingPlanStaticRouteBatchCreator
  include ActiveModel::Model

  def self.inheritance_column
    :_type
  end

  attr_accessor :routing_plan, :prefixes, :vendors, :priority, :weight, :country, :network

  validates_presence_of :routing_plan, :priority, :weight, :prefixes, :vendors
  validates_numericality_of :weight, :priority, greater_than: 0, less_than_or_equal_to: Yeti::ActiveRecord::PG_MAX_SMALLINT, allow_nil: false, only_integer: true

  def vendors=(s)
    @vendors = s.reject(&:blank?)
    # @vendors.reverse!
  end

  def save
    if valid?
      prio = priority.to_i
      prefix_arr = prefixes.delete(' ').split(',').uniq
      Routing::RoutingPlanStaticRoute.transaction do
        vendors.each do |vendor|
          prefix_arr.each do |prefix|
            Routing::RoutingPlanStaticRoute.create!(
              routing_plan_id: routing_plan,
              prefix: prefix,
              priority: prio,
              vendor_id: vendor
            )
          end
          prio -= 5
        end
      end
    end
  end
end
