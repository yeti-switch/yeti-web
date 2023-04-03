# frozen_string_literal: true

module Importing
  class RoutingTagDetectionRuleDecorator < ::Importing::BaseDecorator
    def tag_action_value
      routing_tags_column(:tag_action_value, name_column: :tag_action_value_names)
    end

    def routing_tag_ids
      routing_tags_column(:routing_tag_ids, name_column: :routing_tag_names)
    end
  end
end
