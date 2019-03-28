# frozen_string_literal: true

class BaseResource < JSONAPI::Resource
  RANSACK_TYPE_SUFIXES_DIC = {
    boolean: %w[eq not_eq],
    datetime: %w[eq not_eq gt gteq lt lteq in not_in],
    inet: %w[eq not_eq in not_in],
    number: %w[eq not_eq gt gteq lt lteq in not_in],
    string: %w[eq not_eq cont start end in not_in cont_any],
    uuid: %w[eq not_eq in not_in]
  }.freeze

  abstract

  def self.type(custom_type)
    self._type = custom_type
  end

  def self.ransack_filter(attr, options)
    type = options[:type]
    raise ArgumentError, "type #{type} is not supported" unless RANSACK_TYPE_SUFIXES_DIC.key?(type)

    RANSACK_TYPE_SUFIXES_DIC[type].each do |suf|
      builder = RansackFilterBuilder.new(attr: attr, operator: suf)
      filter builder.filter_name,
             verify: ->(values, _ctx) { builder.verify(values) },
             apply: ->(records, values, _opts) { builder.apply(records, values) }
    end
  end
end
