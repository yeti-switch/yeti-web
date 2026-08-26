# frozen_string_literal: true

# ActiveAdmin counts the collection to render pagination totals. Its default
# `COUNT(DISTINCT ...)` is dramatically slow on the big tables here, so swap in
# ActiveRecordFastCount#fast_count (lib/active_record/fast_count.rb).
#
# Lived on ActiveAdmin::Helpers::Collection until ActiveAdmin 4 removed that
# module; `collection_size` now belongs to ActiveAdmin::IndexHelper.
module ActiveAdmin
  module FastCount
    def collection_size(records = collection)
      records = Draper.undecorate(records)

      # Arrays / proxy objects, as upstream handles them.
      unless records.is_a? ActiveRecord::Relation
        return records.respond_to?(:count) ? records.count : 0
      end

      if records.group_values.present?
        records.except(:select, :order).count.count
      else
        # fast_count avoids the DISTINCT that cripples COUNT on large tables.
        records.fast_count(:all)
      end
    end
  end
end

Rails.application.config.to_prepare do
  ActiveAdmin::IndexHelper.prepend ActiveAdmin::FastCount
end
