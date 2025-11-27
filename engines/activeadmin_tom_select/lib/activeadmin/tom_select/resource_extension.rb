# frozen_string_literal: true

module ActiveAdmin
  module TomSelect
    # @api private
    module ResourceExtension
      def searchable_select_option_collections
        @searchable_select_option_collections ||= {}
      end
    end
  end
end
