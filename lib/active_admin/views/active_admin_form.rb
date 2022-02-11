# frozen_string_literal: true

module ActiveAdmin
  module Views
    class ActiveAdminForm < FormtasticProxy
      def commit_action_with_cancel_link
        action :submit, button_html: { data: { disable_with: 'Please wait...' } }
        cancel_link
      end

      def account_input(name, fb: nil, label: 'Account', q: nil, **options)
        resource_id = if fb.present?
                        fb.object.respond_to?(name) ? fb.object.send(name) : nil
                      else
                        object.respond_to?(name) ? object.send(name) : nil
                      end

        ransack_query = q ? q[:q] : nil
        classes = [
          'chosen-ajax',
          "#{name}-input",
          options.key?(:input_html) ? options[:input_html].delete(:class) : nil
        ].compact.join(' ')
        input_options = {
          as: :select,
          label: label,
          input_html: {
            class: classes,
            'data-path': "/accounts/search?#{q&.to_param}",
            'data-clear-on-change': ".#{name}-input-child"
          },
          collection: resource_id ? Account.ransack(ransack_query).result.where(id: resource_id) : []
        }
        input_options = options.deep_merge(input_options)

        if fb.present?
          fb.input name, input_options
        else
          input name, input_options
        end
      end

      def contractor_input(name, fb: nil, label: 'Contractor', q: nil, **options)
        resource_id = if fb.present?
                        fb.object.respond_to?(name) ? fb.object.send(name) : nil
                      else
                        object.respond_to?(name) ? object.send(name) : nil
                      end

        ransack_query = q ? q[:q] : nil
        classes = [
          'chosen-ajax',
          "#{name}-input",
          options.key?(:input_html) ? options[:input_html].delete(:class) : nil
        ].compact.join(' ')
        input_options = {
          as: :select,
          label: label,
          input_html: {
            class: classes,
            'data-path': "/contractors/search?#{q&.to_param}",
            'data-clear-on-change': ".#{name}-input-child"
          },
          collection: resource_id ? Contractor.ransack(ransack_query).result.where(id: resource_id) : []
        }
        input_options = options.deep_merge(input_options)

        if fb.present?
          fb.input name, input_options
        else
          input name, input_options
        end
      end
    end
  end
end
