# frozen_string_literal: true

require 'active_admin/views/index_as_table'

module ActiveAdmin
  module Views
    class IndexAsTable < ActiveAdmin::Component
      # Mirrors ActiveAdmin 4's own IndexAsTable#build, with two additions:
      #   - `footer_data:` is threaded through to TableFor (see
      #     lib/active_admin/views/components/table_for.rb)
      #   - the hidden "Visible columns" dialog is appended after the table
      #     (its trigger buttons render in the table_tools row)
      # Keep in sync with the gem when upgrading ActiveAdmin.
      def build(page_presenter, collection)
        add_class 'index-as-table'
        table_options = {
          id: "index_table_#{active_admin_config.resource_name.plural}",
          sortable: true,
          i18n: active_admin_config.resource_class,
          paginator: page_presenter[:paginator] != false,
          tbody_html: page_presenter[:tbody_html],
          row_html: page_presenter[:row_html],
          # To be deprecated, please use row_html instead.
          row_class: page_presenter[:row_class],
          footer_data: page_presenter[:footer_data]
        }

        if page_presenter.block
          insert_tag(IndexTableFor, collection, table_options) do |t|
            instance_exec(t, &page_presenter.block)
          end
        else
          render 'index_as_table_default', table_options: table_options
        end

        build_available_columns_dialog
      end

      # Display only the columns listed in assigns[:visible_columns], or all of
      # them when that list is empty. Every column encountered is recorded in
      # assigns[:all_available_columns] so the dialog can offer it.
      def column(*args, &block)
        return super unless assigns.key?(:visible_columns) || args[0].nil?

        column_js_code = args[0].to_s.parameterize(separator: '_')
        assigns[:all_available_columns] = [] if assigns[:all_available_columns].blank?
        assigns[:all_available_columns] << column_js_code

        return super if assigns[:visible_columns].empty?

        super if assigns[:visible_columns].include?(column_js_code)
      end

      def boolean_edit_column(attribute_name)
        column(attribute_name, sortable: attribute_name, class: 'editable_column') do |resource|
          value = resource.send(attribute_name)
          div 'data-resource-id' => resource.id, 'data-path' => resource_path(resource), 'data-value' => !value, 'data-attr' => attribute_name do
            content_tag('span', class: value ? 'status_tag ok' : 'status_tag') do
              value ? 'Yes' : 'No'
            end
          end
        end
      end

      private

      def build_available_columns_dialog
        return unless assigns[:visible_columns].is_a?(Array)

        selected = assigns[:visible_columns].presence || assigns[:all_available_columns]
        div id: 'block_available_columns', title: 'Visible table columns' do
          select_tag(:select_available_columns,
                     options_for_select(assigns[:all_available_columns], selected),
                     multiple: true, size: 20)
        end
      end
    end
  end
end
