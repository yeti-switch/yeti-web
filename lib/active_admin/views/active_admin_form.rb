# frozen_string_literal: true

module ActiveAdmin
  module Views
    class ActiveAdminForm < FormtasticProxy
      def commit_action_with_cancel_link
        action :submit, button_html: { data: { disable_with: 'Please wait...' } }
        cancel_link
      end

      def account_input(name, label: 'Account', q: nil, **options)
        resource_id = object[name]

        classes = [
          'chosen-ajax',
          options.key?(:input_html) ? options[:input_html].delete(:class) : nil
        ].compact.join(' ')
        input_options = {
          as: :select,
          label: label,
          input_html: {
            class: classes,
            'data-path': "/accounts/search?#{q&.to_param}"
          },
          collection: resource_id ? Account.ransack(q).result.where(id: resource_id) : []
        }
        input_options = options.deep_merge(input_options)

        input name, input_options
      end
    end
  end
end
