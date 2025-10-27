# frozen_string_literal: true

require 'activeadmin/inputs/filters/tom_select_input'

module ActiveAdmin
  module Inputs
    module Filters
      # Legacy alias for TomSelectInput - maintained for backward compatibility
      # @deprecated Use TomSelectInput instead
      class SearchableSelectInput < TomSelectInput
      end
    end
  end
end
