class Routing::RoutingPlanStaticRouteBatchCreator
  include ActiveModel::Model

  attr_accessor :routing_plan, :prefixes, :vendors, :priority, :weight, :country, :network

  validates_presence_of :routing_plan, :priority, :weight, :prefixes, :vendors
  validates_numericality_of :weight, :priority, greater_than: 0, less_than_or_equal_to: Yeti::ActiveRecord::PG_MAX_SMALLINT, allow_nil: false, only_integer: true

  def vendors=(s)
    @vendors = s.reject { |i| i.blank? }
    #@vendors.reverse!
  end

  def save
    if self.valid?
      prio = priority.to_i
      prefix_arr = prefixes.gsub(' ', '').split(',').uniq
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
          prio = prio-5
        end
      end
    end

  end


end