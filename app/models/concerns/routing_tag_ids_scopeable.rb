module RoutingTagIdsScopeable
  extend ActiveSupport::Concern

  included do

    scope :routing_tag_ids_covers, ->(*id) do
      where("yeti_ext.tag_compare(routing_tag_ids, ARRAY[#{id.join(',')}])>0")
    end

    scope :tagged, ->(value) do
      if ActiveRecord::Type::Boolean.new.type_cast_from_user(value)
        where("routing_tag_ids <> '{}'") # has tags
      else
        where("routing_tag_ids = '{}'") # no tags
      end
    end

  end
end
