# frozen_string_literal: true

class BaseResource < JSONAPI::Resource
  AVAILABLE_FILTERS_TYPES = %i[string number boolean].freeze
  RANSACK_TYPE_SUFIXES_DIC = {
    string: %w[eq not_eq matches],
    boolean: %w[eq not_eq],
    number: %w[eq not_eq gt gteq lt lteq]
  }.freeze

  abstract

  def self.type(custom_type)
    self._type = custom_type
  end

  def self.ransack_filter(attr, options)
    type = options[:type]
    raise ArgumentError, "type #{type} is not supported" unless AVAILABLE_FILTERS_TYPES.include?(type)

    RANSACK_TYPE_SUFIXES_DIC[type].each do |suf|
      ransack_operator = "#{attr}_#{suf}"

      filter ransack_operator, apply: (lambda do |records, value, _options|
        records.ransack(ransack_operator => value.first).result
      end)
    end
  end
end
