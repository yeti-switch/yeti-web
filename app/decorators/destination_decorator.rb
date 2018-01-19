class DestinationDecorator < BillingDecorator

  delegate_all
  decorates Destination

  include RoutingTagIdsDecorator

  def decorated_display_name
    if reject_calls?
      h.content_tag(:font,display_name, color: :red)
    elsif enabled?
      h.content_tag(:font,display_name, color: :orange)
    else
      display_name
    end
  end

  def decorated_valid_from
    is_valid_from? ? valid_from : h.content_tag(:font, valid_from, color: :red)
  end

  def decorated_valid_till
    is_valid_till? ? valid_till : h.content_tag(:font, valid_till, color: :red)
  end

end
