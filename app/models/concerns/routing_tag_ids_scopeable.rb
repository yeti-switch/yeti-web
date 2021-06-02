# frozen_string_literal: true

module RoutingTagIdsScopeable
  extend ActiveSupport::Concern

  included do
    scope :routing_tag_ids_covers, lambda { |*routing_tag_ids|
      type = ActiveModel::Type::Integer.new(limit: 2)
      routing_tag_ids = routing_tag_ids.map do |id|
        type.serialize(id)
      rescue ActiveModel::RangeError
        nil
      end
      return none if routing_tag_ids.any?(&:nil?)

      where('yeti_ext.tag_compare(routing_tag_ids, ARRAY[?], routing_tag_mode_id)>0', routing_tag_ids)
    }

    scope :tagged, lambda { |value|
      if ActiveModel::Type::Boolean.new.cast(value)
        where("routing_tag_ids <> '{}'") # has tags
      else
        where("routing_tag_ids = '{}'") # no tags
      end
    }

    scope :routing_tag_ids_count_equals, ->(count) { where('array_length(routing_tag_ids, 1) = ?', count) if count.to_i >= 0 }
  end
end
