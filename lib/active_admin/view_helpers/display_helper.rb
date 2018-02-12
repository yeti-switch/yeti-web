module ActiveAdmin
  module ViewHelpers
    module DisplayHelper

      alias_method :original_pretty_format, :pretty_format

      def pretty_format(object)
        # Array of Strings
        if object.is_a?(Array) && object.all? { |el| el.is_a?(String) }
          return object.join(', ')
        end

        original_pretty_format(object)
      end

    end
  end
end
