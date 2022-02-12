# frozen_string_literal: true

module ActiveAdminFormPatch
  def account_input(name, label: 'Account', path_params: nil, **options)
    resource_id = object.respond_to?(name) ? object.send(name) : nil

    ransack_query = path_params ? path_params[:q] : nil
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
        'data-path': "/accounts/search?#{path_params&.to_param}"
      },
      collection: resource_id ? Account.ransack(ransack_query).result.where(id: resource_id) : []
    }
    input_options = options.deep_merge(input_options)

    input name, input_options
  end

  def contractor_input(name, label: 'Contractor', path_params: nil, **options)
    resource_id = object.respond_to?(name) ? object.send(name) : nil

    ransack_query = path_params ? path_params[:q] : nil
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
        'data-path': "/contractors/search?#{path_params&.to_param}"
      },
      collection: resource_id ? Contractor.ransack(ransack_query).result.where(id: resource_id) : []
    }
    input_options = options.deep_merge(input_options)

    input name, input_options
  end
end

ActiveAdmin::Views::ActiveAdminForm.class_eval do
  def commit_action_with_cancel_link
    action :submit, button_html: { data: { disable_with: 'Please wait...' } }
    cancel_link
  end
end

ActiveAdmin::Views::ActiveAdminForm.include ActiveAdminFormPatch
ActiveAdmin::FormBuilder.include ActiveAdminFormPatch
