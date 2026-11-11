# frozen_string_literal: true

module ActiveAdmin
  module Inputs
    # Renders a structured chips/autocomplete condition builder. The resulting
    # Ransack query is stored in a hidden `filter` field (still submitted as the
    # report's `filter`) and shown back to the user as a live hint below the
    # chips. cdr_filter_builder.js reads the column metadata and writes both.
    #
    #   f.input :filter, as: :cdr_filter, columns: Report::CustomCdr::CDR_COLUMNS
    class CdrFilterInput < Formtastic::Inputs::StringInput
      def to_html
        input_wrapping do
          label_html <<
            builder_html <<
            builder.hidden_field(method, id: target_id)
        end
      end

      private

      def builder_html
        template.content_tag(:div, class: 'cdr-filter-builder', data: { target: target_id }) do
          metadata_script + preview_html
        end
      end

      # JS fills this with the resulting Ransack query string.
      def preview_html
        template.content_tag(:p, '', class: 'inline-hints cdr-filter-preview')
      end

      def metadata_script
        json = CdrReportFilter.columns_metadata(columns).to_json
        template.content_tag(:script, json.html_safe, type: 'application/json')
      end

      def columns
        options[:columns] || Report::CustomCdr::CDR_COLUMNS
      end

      def target_id
        @target_id ||= "#{method}_cdr_filter_field"
      end
    end
  end
end
