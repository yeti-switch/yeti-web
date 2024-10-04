# frozen_string_literal: true

ActiveAdmin.before_load do |_app|
  ActiveAdmin::Helpers::Collection.module_eval do
    def collection_size(records = collection)
      records = Draper.undecorate(records)

      # Here we copy original implementation of ActiveAdmin::Helpers::Collection#collection_size
      # for case when query is an Array or proxy object.
      unless records.is_a? ActiveRecord::Relation
        return records.respond_to?(:count) ? records.count : 0
      end

      if records.group_values.present?
        # Here we copy original implementation of ActiveAdmin::Helpers::Collection#collection_size
        # for case when query have group values.
        records.except(:select, :order).count.count
      else
        # We use fast_count to get rid of DISTINCT in count sql
        # which impacts performance dramatically.
        # see ActiveRecordFastCount#fast_count for details.
        records.fast_count(:all)
      end
    end

    def current_page_collection_size
      is_last_page = collection.total_count <= collection_offset + collection.limit_value
      if is_last_page
        collection.total_count - collection_offset
      else
        collection.limit_value
      end
    end

    def collection_offset
      (collection.current_page - 1) * collection.limit_value
    end
  end
end
