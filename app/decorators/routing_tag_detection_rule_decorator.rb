# frozen_string_literal: true

class RoutingTagDetectionRuleDecorator < Draper::Decorator
  delegate_all
  decorates Routing::RoutingTagDetectionRule

  def display_tag_action_value
    h.tag_action_values_badges(model.tag_action_value)
  end

  def routing_tags
    h.routing_tags_badges(
      routing_tag_ids: model.routing_tag_ids,
      routing_tag_mode_id: model.routing_tag_mode_id
    )
  end
end
