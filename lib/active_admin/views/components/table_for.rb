# frozen_string_literal: true

# Adds a totals footer (<tfoot>) to ActiveAdmin's TableFor.
#
# Usage, from an `index` block:
#
#   index footer_data: ->(collection) { collection.totals_per_currency } do
#     column :amount, footer: -> { @footer_data.each { |d| div { d.total } } }
#   end
#
# `footer_data:` is a proc evaluated once against the *unpaginated* collection;
# its result is exposed to each column's `footer:` proc as @footer_data.
#
# @see https://github.com/activeadmin/activeadmin/issues/3797
#
# Through ActiveAdmin 3 this file carried a full copy of TableFor, because the
# footer hooks did not exist. It is now a patch: ActiveAdmin 4's own
# `build_table_cell` -> `helpers.format_attribute` already renders booleans as
# status tags, which is all the old `render_data` override did.

require 'active_admin/views/components/table_for'

module ActiveAdmin
  module Views
    class TableFor
      # AA4 keeps Column#@options private, but the `footer:` procs live there.
      class Column
        attr_reader :options
      end
    end

    module TableForFooter
      def build(obj, *attrs)
        options = attrs.extract_options!
        @footer_data_proc = options.delete(:footer_data)
        super(obj, *attrs, options)
      end

      def column(*args, &block)
        super

        return unless @footer_data

        within @footer_row do
          build_table_footer(@columns.last)
        end
      end

      protected

      # `super`'s build sets @collection before calling this, so the
      # footer_data proc can see the collection.
      def build_table
        build_table_head

        if @footer_data_proc.is_a?(Proc)
          @footer_data = instance_exec(footer_collection, &@footer_data_proc)
          build_table_foot
        end

        build_table_body
      end

      def build_table_foot
        @tfoot = tfoot do
          @footer_row = tr
        end
      end

      def build_table_footer(col)
        td class: col.html_class do
          instance_exec(&col.options[:footer]) if col.options[:footer].is_a?(Proc)
        end
      end

      private

      # Totals span the whole collection, not the current page; ordering and
      # eager-loading only slow the aggregate down.
      def footer_collection
        return @collection unless @collection.respond_to?(:except)

        @collection.except(:limit, :offset, :includes).reorder('')
      end
    end

    TableFor.prepend TableForFooter
  end
end
