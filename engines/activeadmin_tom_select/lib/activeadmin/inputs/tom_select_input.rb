# frozen_string_literal: true

module ActiveAdmin
  module Inputs
    # Tom Select input type for ActiveAdmin forms.
    #
    # @see ActiveAdmin::TomSelect::SelectInputExtension
    #   SelectInputExtension for list of available options.
    class TomSelectInput < Formtastic::Inputs::SelectInput
      include ActiveAdmin::TomSelect::SelectInputExtension

      # Override to prevent adding empty options
      def input_options
        super.merge(include_blank: false)
      end
    end
  end
end
