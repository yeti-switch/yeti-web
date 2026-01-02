# frozen_string_literal: true

module Yeti
  module VariablesJson
    extend ActiveSupport::Concern
    included do
      validate :validate_variables

      def variables_json
        return if variables.nil?
        # need to show invalid variables JSON as is in new/edit form.
        return variables if variables.is_a?(String)

        JSON.generate(variables)
      end

      def variables_json=(value)
        self.variables = value.blank? ? nil : JSON.parse(value)
      rescue JSON::ParserError
        # need to show invalid variables JSON as is in new/edit form.
        self.variables = value
      end

      def validate_variables
        if !variables.nil? && !variables.is_a?(Hash)
          errors.add(:variables, 'must be a JSON object or empty')
        end
      end
    end
  end
end
