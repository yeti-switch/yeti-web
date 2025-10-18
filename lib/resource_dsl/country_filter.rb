# frozen_string_literal: true

module ResourceDSL
  module CountryFilter
    # @param name [Symbol] column name for contractor foreign key.
    # @param label [String] label for input, default 'Contractor'.
    # @param options [Hash] other input params
    #   :path_params [Hash,nil] static params for search query, default nil.
    #   :input_html [Hash] options will be passed directly to html builder of input node.
    #
    def country_filter(name, label: 'Country', **options)
      filter name, label: do
        ajax resource: 'System::Country'
        as :tom_select
        ajax_params options[:path_params] if options[:path_params].present?
        input_html options[:input_html] if options[:input_html].present?
      end
    end
  end
end
