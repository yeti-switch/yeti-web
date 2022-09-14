# frozen_string_literal: true

class NumberlistItemDecorator < Draper::Decorator
  delegate_all
  decorates Routing::NumberlistItem

  def display_tag_action_value
    h.tag_action_values_badges(model.tag_action_value)
  end
end
