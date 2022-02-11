# frozen_string_literal: true

module ResourceDSL
  module AccountFilter
    def account_filter(name, q: nil, label: 'Account', **options)
      classes = [
        'chosen-ajax',
        options.key?(:input_html) ? options.delete(:class) : nil
      ].compact.join(' ')
      filter_options = {
        as: :select,
        label: label,
        input_html: {
          class: classes,
          'data-path': "/accounts/search?#{q&.to_param}"
        },
        collection: proc {
          resource_id = params.fetch(:q, {})[name]
          resource_id ? Account.ransack(q[:q]).result.where(id: resource_id) : []
        }
      }
      filter_options = options.deep_merge(filter_options)

      filter name, filter_options
    end
  end
end
