# frozen_string_literal: true

class RoutingPlanDecorator < BillingDecorator
  delegate_all
  decorates Routing::RoutingPlan

  def decorated_display_name
    if !have_routing_groups?
      h.content_tag(:font, display_name, color: :red)
    else
      display_name
    end
  end

  def routing_groups_links(newline: false)
    routing_groups = model.routing_groups.sort_by(&:name)
    return if routing_groups.empty?

    arbre do
      routing_groups.each do |rg|
        text_node h.link_to(rg.name, dialpeers_path(q: { routing_group_id_eq: rg.id }))
        newline ? br : text_node(' ')
      end
    end
  end
end
