# frozen_string_literal: true

module RoutingTagIdsScopeable
  extend ActiveSupport::Concern

  included do
    scope :routing_tag_ids_covers, lambda { |*id|
      where("yeti_ext.tag_compare(routing_tag_ids, ARRAY[#{id.join(',')}], routing_tag_mode_id)>0")
    }

    scope :tagged, lambda { |value|
      if ActiveModel::Type::Boolean.new.cast(value)
        where("routing_tag_ids <> '{}'") # has tags
      else
        where("routing_tag_ids = '{}'") # no tags
      end
    }
  end
end
