# frozen_string_literal: true

module ActiveAdminFormPatch
  # @param name [Symbol] column name for account foreign key.
  # @param label [String] label for input, default 'Account'.
  # @param scope [Class,ActiveRecord::Relation] model class or scope.
  # @param path [String] url for search query.
  # @param path_params [Hash,nil] static params for search query, default nil.
  # @param fill_params [Hash,nil] dynamic params for chosen-ajax-filled collection.
  # @param fill_required [Symbol,nil] required dynamic param key, if blank collection will be empty.
  # @param options [Hash] other input params
  #   :'data-path-params' [String] json hash: key is dynamic parameter for search query, value is selector of a field.
  #   :'data-required-param' [String,nil] selector of a field, if blank collection will be empty.
  #   :input_html [Hash] options will be passed directly to html builder of input node.
  #
  def association_ajax_input(name, label:, scope:, path:, path_params: nil, fill_params: nil, fill_required: nil, **options)
    ransack_query = path_params ? path_params[:q] : nil
    if fill_params.nil?
      resource_id = object.respond_to?(name) ? object.send(name) : nil
      collection = resource_id ? scope.ransack(ransack_query).result.where(id: resource_id) : []
    elsif !fill_required.nil? && fill_params[fill_required].blank?
      collection = []
    else
      collection = scope.ransack(ransack_query).result.ransack(fill_params).result
    end

    classes = [
      fill_params.nil? ? 'chosen-ajax' : 'chosen-ajax-fillable',
      "#{name}-input",
      options.key?(:input_html) ? options[:input_html].delete(:class) : nil
    ].compact.join(' ')
    input_options = {
      as: :select,
      label: label,
      input_html: {
        class: classes,
        'data-path': "#{path}?#{path_params&.to_param}"
      },
      collection: collection
    }
    input_options = options.deep_merge(input_options)

    input name, input_options
  end

  # @param name [Symbol] column name for account foreign key.
  # @param label [String] label for input, default 'Account'.
  # path_params [Hash,nil] static params for search query, default nil.
  # fill_params [Hash,nil] dynamic params for chosen-ajax-filled collection, key - ransack key for search, value.
  # fill_required [Symbol,nil] required dynamic param key, if blank collection will be empty.
  # @param options [Hash] other input params
  #   :'data-path-params' [String] json hash: key is parameter for search query, value is selector of a field.
  #   :'data-required-param' [String,nil] selector of a field, if blank collection will be empty.
  #   :input_html [Hash] options will be passed directly to html builder of input node.
  #
  def account_input(name, label: 'Account', **options)
    association_ajax_input(name, label: label, scope: Account.order(:name), path: '/accounts/search', **options)
  end

  # @param name [Symbol] column name for contractor foreign key.
  # @param label [String] label for input, default 'Contractor'.
  # @param options [Hash] other input params
  #   :path_params [Hash,nil] static params for search query, default nil.
  #   :input_html [Hash] options will be passed directly to html builder of input node.
  #
  def contractor_input(name, label: 'Contractor', **options)
    association_ajax_input(name, label: label, scope: Contractor.order(:name), path: '/contractors/search', **options)
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
