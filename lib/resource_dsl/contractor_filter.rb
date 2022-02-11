# frozen_string_literal: true

module ResourceDSL
  module ContractorFilter
    def contractor_filter(name, path_params: nil, label: 'Contractor', **options)
      classes = [
        'chosen-ajax',
        "#{name}-filter",
        options.key?(:input_html) ? options[:input_html].delete(:class) : nil
      ].compact.join(' ')
      filter_options = {
        as: :select,
        label: label,
        include_blank: true,
        input_html: {
          class: classes,
          'data-path': "/contractors/search?#{path_params&.to_param}",
          'data-clear-on-change': ".#{name}-filter-child",
          'data-empty-option': 'Any'
        },
        collection: proc {
          resource_id = params.fetch(:q, {})[name]
          ransack_query = path_params ? path_params[:q] : nil
          resource_id ? Contractor.ransack(ransack_query).result.where(id: resource_id) : []
        }
      }
      filter_options = options.deep_merge(filter_options)

      filter name, filter_options
    end
  end
end
