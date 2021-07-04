# frozen_string_literal: true

class Routing::RoutingPlanStaticRouteBatchCreatorForm < ApplicationForm
  attribute :routing_plan, :string
  attribute :prefixes, :string
  attribute :priority, :integer
  attribute :weight, :integer
  attribute :country, :string
  attribute :network, :string

  attr_reader :vendors

  validates :routing_plan, :priority, :weight, :prefixes, :vendors, presence: true
  validates :weight, :priority, numericality: { greater_than: 0, less_than_or_equal_to: ApplicationRecord::PG_MAX_SMALLINT, allow_nil: false, only_integer: true }

  def vendors=(s)
    @vendors = s.reject(&:blank?)
  end

  private

  def _save
    prio = priority
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
