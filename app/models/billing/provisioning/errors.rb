# frozen_string_literal: true

module Billing
  module Provisioning
    module Errors
      class Error < StandardError
      end

      class InvalidVariablesError < Error
        attr_reader :errors

        # @param errors [Hash,String]
        # @param msg [String,nil]
        def initialize(errors, msg = nil)
          if errors.is_a?(String)
            msg = errors
            errors = { base: [msg] }
          end
          @errors = errors
          super(msg || "Validation error: #{full_error_messages.join(', ')}")
        end

        def full_error_messages(errors = @errors, prefix = nil)
          full_messages = []
          errors.each do |key, values|
            if values.is_a?(Array)
              full_messages.concat parse_errors_array(key, values, prefix)
            elsif values.is_a?(Hash)
              full_messages.concat full_error_messages(values, [prefix, key].compact.join('.'))
            else
              raise ArgumentError, "Invalid error format: #{values.inspect}\nerrors: #{errors.inspect}"
            end
          end
          full_messages
        end

        def parse_errors_array(key, values, prefix)
          values.map do |value|
            if prefix.nil?
              key == :base || key.nil? ? value : "#{prefix}.#{key} - #{value}"
            else
              key == :base || key.nil? ? "#{prefix} - #{value}" : "#{prefix}.#{key} - #{value}"
            end
          end
        end
      end
    end
  end
end
