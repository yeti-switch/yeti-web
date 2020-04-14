# frozen_string_literal: true

module Importing
  class NumberlistItemDecorator < ::Importing::BaseDecorator
    def tag_action_value
      routing_tags_column(:tag_action_value, name_column: :tag_action_value_names)
    end
  end
end
