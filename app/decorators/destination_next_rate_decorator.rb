# frozen_string_literal: true

class DestinationNextRateDecorator < ApplicationDecorator
  delegate_all
  decorates Routing::DestinationNextRate

  def link_to_rate_group
    return unless model.destination.rate_group_id

    h.link_to(model.destination.rate_group.display_name, routing_rate_group_path(model.destination.rate_group.id))
  end
end
