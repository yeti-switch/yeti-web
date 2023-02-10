# frozen_string_literal: true

class RoutingGroupDecorator < BillingDecorator
  delegate_all
  decorates Routing::RoutingGroup

  def routing_plans_links(newline: false)
    routing_plans = model.routing_plans.sort_by(&:name)
    return if routing_plans.empty?

    arbre do
      routing_plans.each do |rp|
        text_node h.link_to(rp.name, routing_routing_plans_path(rp.id))
        newline ? br : text_node(' ')
      end
    end
  end
end
