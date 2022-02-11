# frozen_string_literal: true

module ResourceDSL
  module ContractorFilter
    def contractor_filter(name, q: nil, label: 'Contractor', **options)
      classes = [
        'chosen-ajax',
        options.key?(:input_html) ? options.delete(:class) : nil
      ].compact.join(' ')
      filter_options = {
        as: :select,
        label: label,
        input_html: {
          class: classes,
          'data-path': "/contractors/search?#{q&.to_param}"
        },
        collection: proc {
          resource_id = params.fetch(:q, {})[name]
          resource_id ? Contractor.ransack(q[:q]).result.where(id: resource_id) : []
        }
      }
      filter_options = options.deep_merge(filter_options)

      filter name, filter_options
    end
  end
end
