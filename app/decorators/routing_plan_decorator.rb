class RoutingPlanDecorator < BillingDecorator

  delegate_all
  decorates Routing::RoutingPlan


  def decorated_display_name
    if !have_routing_groups?
      h.content_tag(:font,display_name, color: :red)
    else
      display_name
    end
  end

end