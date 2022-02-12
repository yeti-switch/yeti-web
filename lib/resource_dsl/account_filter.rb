# frozen_string_literal: true

module ResourceDSL
  module AccountFilter
    # @param name [Symbol] column name for account foreign key.
    # @param label [String] label for input, default 'Account'.
    # path_params [Hash,nil] static params for search query, default nil.
    # fill_params [Hash,nil] dynamic params for chosen-ajax-filled collection, key - ransack key for search, value.
    # fill_required [Symbol,nil] required dynamic param key, if blank collection will be empty.
    # @param options [Hash] other input params
    #   :'data-path-params' [String] json hash: key is parameter for search query, value is selector of a field.
    #   :input_html [Hash] options will be passed directly to html builder of input node.
    #
    def account_filter(name, label: 'Account', **options)
      association_ajax_filter(
        name,
        label: label,
        scope: -> { Account.order(:name) },
        path: '/accounts/search',
        **options
      )
    end
  end
end
