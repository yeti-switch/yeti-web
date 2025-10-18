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
      filter name, label: do
        ajax resource: 'System::Network'
        as :tom_select
        ajax_params options[:path_params] if options[:path_params].present?
        input_html options[:input_html] if options[:input_html].present?
      end
    end
  end
end
