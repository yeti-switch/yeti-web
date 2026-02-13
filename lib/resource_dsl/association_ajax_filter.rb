# frozen_string_literal: true

module ResourceDSL
  module AssociationAjaxFilter
    # @param name [Symbol] column name for account foreign key.
    # @param label [String] label for input, default 'Account'.
    # @param scope [Proc] should return model class or scope.
    # @param path [String] url for search query.
    # @param path_params [Hash,nil] static params for search query, default nil.
    # @param fill_params [Proc<Hash>,nil] proc that returns dynamic params for tom-select-ajax-filled collection.
    # @param fill_required [Symbol,nil] required dynamic param key, if blank collection will be empty.
    # @param options [Hash] other input params
    #   :'data-path-params' [String] json hash: key is dynamic parameter for search query, value is selector of a field.
    #   :'data-required-param' [String,nil] selector of a field, if blank collection will be empty.
    #   :input_html [Hash] options will be passed directly to html builder of input node.
    #
    def association_ajax_filter(name, label:, scope:, path:, path_params: nil, fill_params: nil, fill_required: nil, **options)
      ransack_query = path_params ? path_params[:q] : nil
      if fill_params.nil?
        collection = proc do
          resource_id = params.dig(:q, name)
          resource_id ? scope.call.ransack(ransack_query).result.where(id: resource_id) : []
        end
      else
        collection = proc do
          fill_params_data = instance_exec(&fill_params)
          if !fill_required.nil? && fill_params_data[fill_required].blank?
            []
          else
            scope.call.ransack(ransack_query).result.ransack(fill_params_data).result
          end
        end
      end

      classes = [
        fill_params.nil? ? 'tom-select-ajax' : 'tom-select-ajax-fillable',
        "#{name}-input",
        options.key?(:input_html) ? options[:input_html].delete(:class) : nil
      ].compact.join(' ')
      input_options = {
        as: :select,
        label: label,
        include_blank: true,
        input_html: {
          class: classes,
          'data-path': "#{path}?#{path_params&.to_param}",
          placeholder: 'Any'
        },
        collection: collection
      }
      filter_options = options.deep_merge(input_options)

      filter name, filter_options
    end
  end
end
