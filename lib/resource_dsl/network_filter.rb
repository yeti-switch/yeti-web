# frozen_string_literal: true

module ResourceDSL
  module NetworkFilter
    # @param name [Symbol] column name for contractor foreign key.
    # @param label [String] label for input, default 'Contractor'.
    # @param options [Hash] other input params
    #   :path_params [Hash,nil] static params for search query, default nil.
    #   :input_html [Hash] options will be passed directly to html builder of input node.
    #
    def network_filter(name, label: 'Network', **options)
      association_ajax_filter(
        name,
        label: label,
        scope: -> { System::Network.order(:name) },
        path: '/system_networks/search',
        **options
      )
    end
  end
end
