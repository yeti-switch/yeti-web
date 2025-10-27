# frozen_string_literal: true

require 'activeadmin/inputs/tom_select_input'

module ActiveAdmin
  module Inputs
    # Legacy alias for TomSelectInput - maintained for backward compatibility
    # @deprecated Use TomSelectInput instead
    class SearchableSelectInput < TomSelectInput
    end
  end
end
