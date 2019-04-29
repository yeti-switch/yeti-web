# frozen_string_literal: true

module ActiveAdmin
  module Views
    class IndexAsJsTable < IndexAsTable
      class Column
        DISPLAY_NAME_METHODS = %i[display_name name title].freeze
        attr_reader :title, :options, :column_proc, :helpers, :meth
        alias h helpers

        def initialize(title, options = {}, &block)
          @title = title
          @meth = options[:meth]
          @helpers = options[:helpers]
          @options = options[:column] || {}
          @column_proc = block
        end

        def resource_class
          options[:resource_class]
        end

        def sort_key
          @sort_key ||= begin
            if options[:sortable].present?
              options[:sortable]
            elsif column_proc && resource_class.respond_to?(:column_names)
              title if resource_class.column_names.index(title.to_s)
            end
          end
        end

        def html_class
          @html_class ||= Array.wrap(options[:class]).join(' ')
        end

        def pretty_title
          @pretty_title ||= begin
            if title.is_a?(Symbol)
              title.to_s.gsub('_id', '').gsub(/_-/, ' ').humanize
            else
              title
            end
          end
        end

        def value_for(record)
          value = column_proc ? h.execute_block(record, &column_proc) : record.public_send(meth)
          value = value.strftime('%F %T') if value.is_a?(Time)
          value = value.strftime('%F') if value.is_a?(Date)
          value = resource_link(value) if value.is_a?(ActiveRecord::Base)
          value
        end

        def schema
          @schema ||= begin
            result = { type: column_type }
            result = result.merge(options[:schema_data] || {})
            result[:cellClass] = [result[:class], 'col', column_class].compact.join(' ')
            result
          end
        end

        private

        def column_type
          return @column_type if defined?(@column_type)

          @column_type = begin
            return options[:type] if options.key?(:type)
            return unless resource_class.respond_to?(:columns)

            col_data = resource_class.columns.detect { |c| c.name == title.to_s }
            return :boolean if col_data&.type == :boolean

            reflection = resource_class.reflections[title.to_s]
            return :html if reflection && column_proc.nil?

            nil
          end
        end

        def column_class
          "col-#{title.to_s.downcase.tr(' ', '-')}"
        end

        def resource_link(record)
          h.auto_link(record)
        end
      end

      def self.index_name
        'js_table'
      end

      def build(page_presenter, collection)
        @collection = collection
        @columns_data = []
        @table_options = {
          sortable: true,
          i18n: active_admin_config.resource_class,
          row_class: page_presenter[:row_class]
        }
        @table_html_options = {
          id: "index_table_#{active_admin_config.resource_name.plural}",
          class: 'index_table index js-index-table'
        }

        js_table_for do |t|
          table_config_block = page_presenter.block || default_table
          instance_exec(t, &table_config_block)
        end
      end

      def js_table_for
        yield(self)
        payload = Oj.dump(table_data_payload, mode: :compat)
        schema = Oj.dump(table_schema_payload, mode: :compat)
        config = Oj.dump(table_config_payload, mode: :compat)
        opts = { 'data-payload': payload, 'data-schema': schema, 'data-config': config, **@table_html_options }
        table(opts) do
          thead do
            tr { @columns_data.each { |col| build_table_header(col) } }
          end
          tbody
        end
      end

      def column(*args, &block)
        options = args.extract_options!
        title = args.first
        meth = args.size > 1 ? args.second : title
        options[:resource_class] = active_admin_config.resource_class
        col = Column.new(title, { meth: meth, column: options, helpers: self }, &block)
        @columns_data.push(col)
      end

      def selectable_column
        return unless active_admin_config.batch_actions.any?

        title = arbre { resource_selection_toggle_cell }.html_safe
        opts = { class: 'col-selectable', sortable: false, type: :selectable }
        column(title, opts) { |r| r.id.to_s }
      end

      def id_column
        raise "#{resource_class.name} has no primary_key!" unless resource_class.primary_key

        title = resource_class.human_attribute_name(resource_class.primary_key)
        opts = { sortable: resource_class.primary_key, type: :id_link }
        column(title, opts) { |r| r.id.to_s }
      end

      def actions(options = {}, &block)
        name = options.delete(:name) { '' }
        defaults = options.delete(:defaults) { true }
        options[:class] ||= 'col-actions'
        options[:type] ||= :actions
        options[:schema_data] = { class: options[:css_class] }

        if defaults
          column name, options do |resource|
            {
              show: authorized?(ActiveAdmin::Auth::READ, resource),
              edit: authorized?(ActiveAdmin::Auth::UPDATE, resource),
              destroy: authorized?(ActiveAdmin::Auth::DESTROY, resource)
            }
          end
        else
          column name, options do |resource|
            instance_exec(resource, &block) if block_given?
          end
        end
      end

      def arbre(extra_assigns = {}, &block)
        assigns = arbre_context.assigns.merge(extra_assigns || {})
        helpers = arbre_context.helpers
        Arbre::Context.new(assigns, helpers) { instance_exec(&block) }.to_s
      end

      def execute_block(*args, &block)
        helpers.instance_exec(*args, &block)
      end

      def show_url
        controller.action_methods.include?('show') ? resource_path('') : nil
      end

      def edit_url
        controller.action_methods.include?('edit') ? edit_resource_path('') : nil
      end

      def destroy_url
        controller.action_methods.include?('destroy') ? resource_path('') : nil
      end

      private

      def table_config_payload
        @table_config_payload ||= {
          rowClass: @table_options[:row_class],
          rowIdPrefix: dom_id_prefix,
          showUrl: show_url,
          editUrl: edit_url,
          destroyUrl: destroy_url,
          idUrl: show_url || edit_url,
          showTitle: I18n.t('active_admin.view'),
          editTitle: I18n.t('active_admin.edit'),
          destroyTitle: I18n.t('active_admin.delete')
        }
      end

      def table_schema_payload
        @columns_data.map(&:schema)
      end

      def table_data_payload
        @collection.map do |record|
          {
            id: record.id,
            columns: @columns_data.map { |col| col.value_for(record) }
          }
        end
      end

      def build_table_header(col)
        classes = Arbre::HTML::ClassList.new
        sort_key = @table_options[:sortable] && col.sort_key
        params = request.query_parameters.except :page, :order, :commit, :format

        classes << 'sortable' if sort_key
        classes << "sorted-#{current_sort[1]}" if sort_key && current_sort[0] == sort_key
        classes << col.html_class

        if sort_key
          th class: classes do
            link_to col.pretty_title, params: params, order: "#{sort_key}_#{order_for_sort_key(sort_key)}"
          end
        else
          th col.pretty_title, class: classes
        end
      end

      def order_for_sort_key(sort_key)
        current_key, current_order = current_sort
        return 'desc' unless current_key == sort_key

        current_order == 'desc' ? 'asc' : 'desc'
      end

      def current_sort
        @current_sort ||= begin
          order_clause = active_admin_config.order_clause.new(active_admin_config, params[:order])

          if order_clause.valid?
            [order_clause.field, order_clause.order]
          else
            []
          end
        end
      end

      def default_table
        proc do
          selectable_column
          if resource_class.primary_key
            column :id
          end
          active_admin_config.resource_columns.each do |attribute|
            column attribute
          end
        end
      end

      def dom_id_prefix
        if resource_class.respond_to?(:model_name)
          resource_class.model_name.singular
        else
          resource_class.name.underscore.tr('/', '_')
        end
      end
    end
  end
end
