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
      association_ajax_filter(
        name,
        label: label,
        scope: -> { System::Country.order(:name) },
        path: '/system_countries/search',
        **options
      )
    end
  end
end
