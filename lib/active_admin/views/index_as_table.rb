module ActiveAdmin
  module Views
    class IndexAsTable < ActiveAdmin::Component

      def table_for(*args, &block)

        if assigns[:visible_columns].is_a?(Array)
          span do
            link_to 'Visible columns', '#', {id: 'toggle_block_available_columns', class: 'active'}
          end
          if assigns[:visible_columns].any?
            span do
              ' | '
            end
            span do
              link_to 'Reset', '#', {id: 'reset_visible_columns'}
            end
          end
        end

        insert_tag IndexTableFor, *args, &block

        if assigns[:visible_columns].is_a?(Array)
          div id: 'block_available_columns', title: 'Visible table columns' do
            select_tag(:select_available_columns,
                       options_for_select(assigns[:all_available_columns],
                                          assigns[:visible_columns].any? ? assigns[:visible_columns] : assigns[:all_available_columns]),
                       { multiple: true, size: 20 })
          end
        end

      end

      # Display columns only listed in assigns[:visible_columns]
      # or all if assigns[:visible_columns] is empty
      # if assigns[:visible_columns] not empty
      # than display only columns listed in @visible_columns
      def column(*args, &block)
        return super unless assigns.has_key?(:visible_columns) || args[0].nil?

        column_js_code = args[0].to_s.parameterize(separator: '_')
        assigns[:all_available_columns] = [] if assigns[:all_available_columns].blank?
        assigns[:all_available_columns] << column_js_code

        return super if assigns[:visible_columns].empty?

        if assigns[:visible_columns].include?(column_js_code)
          super
        end
      end


      def build(page_presenter, collection)
                    table_options = {
                      id: "index_table_#{active_admin_config.resource_name.plural}",
                      sortable: true,
                      class: "index_table index",
                      i18n: active_admin_config.resource_class,
                      paginator: page_presenter[:paginator] != false,
                      row_class: page_presenter[:row_class],
                      footer_data: page_presenter[:footer_data]
                    }

                    table_for collection, table_options do |t|
                      table_config_block = page_presenter.block || default_table
                      instance_exec(t, &table_config_block)
                    end
      end

      def boolean_edit_column(attribute_name)

        column(attribute_name, sortable: attribute_name, class: "editable_column") do |resource|
           value = resource.send(attribute_name)
           div  "data-resource-id" => resource.id, "data-path" => resource_path(resource), "data-value" => !value, "data-attr" => attribute_name   do
             content_tag("span", class: value ? "status_tag ok" : "status_tag") do
                value ?  "Yes" : "No"
              end
           end

        end
      end
    end
  end
end
