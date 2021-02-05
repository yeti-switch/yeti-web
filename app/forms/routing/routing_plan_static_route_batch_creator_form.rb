# frozen_string_literal: true

class Routing::RoutingPlanStaticRouteBatchCreatorForm < ApplicationForm

  def self.inheritance_column
    :_type
  end

  attribute :routing_plan
  attribute :prefixes
  attribute :priority
  attribute :weight
  attribute :country
  attribute :network

  attr_reader :vendors

  validates :routing_plan, :priority, :weight, :prefixes, :vendors, presence: true
  validates :weight, :priority, numericality: { greater_than: 0, less_than_or_equal_to: Yeti::ActiveRecord::PG_MAX_SMALLINT, allow_nil: false, only_integer: true }

  def vendors=(s)
    @vendors = s.reject(&:blank?)
  end

  private

  def _save
    prio = priority.to_i
    prefix_arr = prefixes.delete(' ').split(',').uniq
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
