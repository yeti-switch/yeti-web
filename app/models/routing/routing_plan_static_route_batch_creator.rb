class Routing::RoutingPlanStaticRouteBatchCreator
  include ActiveModel::Model

  attr_accessor :routing_plan, :prefixes, :vendors, :priority, :country, :network

  validates_presence_of :routing_plan, :priority, :prefixes, :vendors
  validates_numericality_of :priority, only_integer: true, greater_than: 0

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