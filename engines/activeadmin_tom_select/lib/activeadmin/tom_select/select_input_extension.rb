# frozen_string_literal: true

module ActiveAdmin
  module TomSelect
    module SelectInputExtension
      def to_html
        super
      rescue RuntimeError => e
        error_html = e.message.gsub("\n", '<br>').html_safe
        error_style = 'color: red; padding: 10px; background: #fee; ' \
          'border: 1px solid #fcc; border-radius: 4px; margin: 5px 0;'
        template.content_tag(:div, error_html, class: 'searchable-select-error', style: error_style)
      end

      def input_html_options
        super.tap do |options|
          add_css_class(options)
          add_data_attributes(options)
        end
      end

      def collection_from_options
        if ajax?
          collection = if TomSelect.inline_ajax_options
                         all_options_collection.unshift(['Any', ''])
                       else
                         selected_value_collection.unshift(['Any', ''])
                       end

          collection.reject { |item| item.first.to_s.strip.empty? && item.last.to_s.strip.empty? }
        elsif options[:multiple].blank?
          original_collection = super.dup
          original_collection.to_a.unshift(['Any', ''])
        else
          super
        end
      end

      private

      def add_css_class(options)
        css_class = self.class.name.demodulize.underscore.dasherize
        classes = []
        classes << options[:class]

        if ajax_options.present?
          classes << 'ajax-tom-select'
        else
          classes << css_class
        end

        options[:class] = classes.compact.join(' ')
      end

      def add_data_attributes(options)
        options['data-ajax-url'] = ajax_url if ajax? && !TomSelect.inline_ajax_options
        options['data-clearable'] = true if clearable?
        options['data-placeholder'] = placeholder if placeholder?

        # Add parent-child relationship data attributes
        if parent_filter?
          options['data-parent-filter'] = parent_filter_name
          options['data-parent-parameter'] = parent_parameter_name
          options['data-parent-relationship'] = parent_relationship_type
        end

        if has_auto_fill_children?
          options['data-auto-fill-children'] = auto_fill_child_names.join(',')
        end

        if has_related_filters?
          options['data-related-children'] = related_filter_names.join(',')
        end
      end

      def ajax?
        return false unless options.key?(:ajax)

        options[:ajax].present? && options[:ajax] != false
      end

      def clearable?
        options.fetch(:clearable, true)
      end

      def placeholder?
        options.key?(:placeholder)
      end

      def placeholder
        options.fetch(:placeholder, '')
      end

      def ajax_url
        return unless ajax?

        [ajax_resource.route_collection_path(path_params),
         '/',
         option_collection.collection_action_name,
         '?',
         ajax_params.to_query].join
      end

      def all_options_collection
        option_collection_scope.all.map do |record|
          option_for_record(record)
        end
      end

      def selected_value_collection
        selected_records.collect { |s| option_for_record(s) }
      end

      def option_for_record(record)
        [option_collection.display_text(record), record.id]
      end

      def selected_records
        @selected_records ||=
          if selected_values
            option_collection_scope.where(id: selected_values)
          else
            []
          end
      end

      def selected_values
        @object&.send(input_name)
      end

      def option_collection_scope
        option_collection.scope(template, path_params.merge(ajax_params))
      end

      def option_collection
        ajax_resource
          .searchable_select_option_collections
          .fetch(ajax_option_collection_name) do
          model_name = ajax_resource_class.name
          raise('The required ajax endpoint is missing. ' \
                  "Add `searchable_select_options` to the '#{model_name}' admin resource:\n\n  " \
                  "ActiveAdmin.register #{model_name} do\n    " \
                  "searchable_select_options(scope: proc { #{model_name} },\n                               " \
                  "text_attribute: :name)  # or :title, :email, etc.\n  " \
                  "end\n\n" \
                  "Or disable ajax mode for this input:\n  " \
                  "f.input :#{method}, as: :searchable_select, ajax: false")
        end
      end

      def ajax_resource
        @ajax_resource ||=
          template.active_admin_namespace.resource_for(ajax_resource_class) ||
          raise("No admin found for '#{ajax_resource_class.name}' to fetch " \
                  'options for searchable select input from.')
      end

      def ajax_resource_class
        ajax_options.fetch(:resource) do
          raise_cannot_auto_detect_resource unless reflection
          reflection.klass
        end
      end

      def raise_cannot_auto_detect_resource
        raise('Cannot auto detect resource to fetch options for searchable select input from. ' \
                "Explicitly pass class of an ActiveAdmin resource:\n\n  " \
                "f.input(:custom_category,\n          " \
                "type: :searchable_select,\n          " \
                "ajax: {\n            " \
                "resource: Category\n          " \
                "})\n")
      end

      def ajax_option_collection_name
        ajax_options.fetch(:collection_name, :all)
      end

      def ajax_params
        ajax_options.fetch(:params, {})
      end

      def path_params
        ajax_options.fetch(:path_params, {})
      end

      def ajax_options
        return {} if options[:ajax] == true || options[:ajax].blank?

        options[:ajax]
      end

      # Parent-child filter methods
      def parent_filter?
        ajax_options.key?(:parent_filter)
      end

      def parent_filter_name
        ajax_options[:parent_filter].to_s
      end

      def parent_parameter_name
        param = ajax_options.fetch(:parent_parameter) do
          "#{parent_filter_name.to_s.gsub(/_id$/, '_id')}_eq"
        end
        param.to_s
      end

      def parent_relationship_type
        # Determine if this is an auto-fill or related-filter relationship
        # by checking if the parent has this child in auto_fill list
        'auto-fill' # This will be determined by JS based on parent's data attributes
      end

      # Auto-fill children (pre-populate on dropdown open)
      def has_auto_fill_children?
        ajax_options.key?(:auto_fill_in_related_filters) &&
          ajax_options[:auto_fill_in_related_filters].is_a?(Array) &&
          ajax_options[:auto_fill_in_related_filters].any?
      end

      def auto_fill_child_names
        ajax_options.fetch(:auto_fill_in_related_filters, []).map(&:to_s)
      end

      # Related filters (add query params only when typing)
      def has_related_filters?
        ajax_options.key?(:related_filters) &&
          ajax_options[:related_filters].is_a?(Array) &&
          ajax_options[:related_filters].any?
      end

      def related_filter_names
        ajax_options.fetch(:related_filters, []).map(&:to_s)
      end
    end
  end
end
