# frozen_string_literal: true

module Importing
  class DestinationDecorator < ::Importing::BaseDecorator
    def routing_tag_ids
      routing_tags_column(:routing_tag_ids, name_column: :routing_tag_names)
    end
  end
end
