# frozen_string_literal: true

module ActiveAdmin
  module Inputs
    module Filters
      # Tom Select input type for ActiveAdmin filters.
      #
      # @see ActiveAdmin::TomSelect::SelectInputExtension
      #   SelectInputExtension for list of available options.
      class TomSelectInput < SelectInput
        include ActiveAdmin::TomSelect::SelectInputExtension

        # Override to remove the empty "Any" option since we're using
        # Tom Select's clear button plugin instead
        def input_options
          super.merge(include_blank: false)
        end
      end
    end
  end
end
