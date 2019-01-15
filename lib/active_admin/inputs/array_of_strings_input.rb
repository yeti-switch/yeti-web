# frozen_string_literal: true

module ActiveAdmin
  module Inputs
    class ArrayOfStringsInput < Formtastic::Inputs::StringInput
      def input_html_options
        super.merge(extra_input_html_options)
      end

      def extra_input_html_options
        {
          value: value
        }
      end

      # ActiveAdmin has bug: Edit form do not uses Decorated object
      # in this case we need to duplicate array-join here
      # on update(render form) activeadmin uses Decorated object, and this is redundant here
      def value
        return options[:input_html][:value] if options[:input_html]&.key?(:value)

        val = object.public_send(method)
        return val.join(', ') if val.is_a?(Array)

        val
      end

      def hint_text
        super || I18n.t(:hint_array_of_strings)
      end
    end
  end
end
