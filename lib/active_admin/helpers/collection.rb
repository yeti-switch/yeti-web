module ActiveAdmin
  module Helpers
    module Collection

      def collection_size(c=collection)
        if c.is_a? ActiveRecord::Relation
          c  = c.except :select, :order
          c.group_values.present? ? c.count.count : c.count
        else
            c.respond_to?(:count) ? c.count : 0
        end
      end


    end
  end
end