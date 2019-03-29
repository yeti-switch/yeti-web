# frozen_string_literal: true

class BaseResource < JSONAPI::Resource
  abstract

  def self.type(custom_type)
    self._type = custom_type
  end

  def self.ransack_filter(attr, options)
    type = options[:type]
    raise ArgumentError, "type #{type} is not supported" unless RansackFilterBuilder.type_supported?(type)

    RansackFilterBuilder.suffixes_for_type(type).each do |suf|
      builder = RansackFilterBuilder.new(attr: attr, operator: suf)
      filter builder.filter_name,
             verify: ->(values, _ctx) { builder.verify(values) },
             apply: ->(records, values, _opts) { builder.apply(records, values) }
    end
  end
end
