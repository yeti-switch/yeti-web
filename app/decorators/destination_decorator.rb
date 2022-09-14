# frozen_string_literal: true

class DestinationDecorator < BillingDecorator
  delegate_all
  decorates Routing::Destination

  def routing_tags
    h.routing_tags_badges(
      routing_tag_ids: model.routing_tag_ids,
      routing_tag_mode_id: model.routing_tag_mode_id
    )
  end

  def decorated_display_name
    if reject_calls?
      h.content_tag(:font, display_name, color: :red)
    elsif enabled?
      h.content_tag(:font, display_name, color: :orange)
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
