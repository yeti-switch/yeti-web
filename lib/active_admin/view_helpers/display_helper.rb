# frozen_string_literal: true

module ActiveAdmin
  module ViewHelpers
    module DisplayHelper
      STATUS_TAG_CACHE = [
        '<span class="status_tag yes">Yes</span>'.html_safe.freeze,
        '<span class="status_tag no">No</span>'.html_safe.freeze
      ].freeze
      BOOLEAN_VALUES = [true, false].freeze

      alias original_pretty_format pretty_format

      def pretty_format(object)
        # Array of Strings
        if object.is_a?(Array) && object.all? { |el| el.is_a?(String) }
          return object.join(', ')
        end

        original_pretty_format(object)
      end

      def boolean_status_tag(value)
        STATUS_TAG_CACHE[value ? 0 : 1]
      end

      def is_boolean_val?(value)
        BOOLEAN_VALUES.include?(value)
        # value.is_a?(TrueClass) || value.is_a?(FalseClass)
      end
    end
  end
end
