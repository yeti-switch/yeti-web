# frozen_string_literal: true

class BaseResource < JSONAPI::Resource
  abstract

  def self.type(custom_type)
    self._type = custom_type
  end

  # @param attr [Symbol] filter prefix
  # @param type [Symbol] filter type
  #   @see RansackFilterBuilder::RANSACK_TYPE_SUFIXES_DIC
  # @param column [Symbol]
  # @param verify [Proc, nil] custom validate/change values (receives [Array<String>] values)
  def self.ransack_filter(attr, type:, column: nil, verify: nil)
    raise ArgumentError, "type #{type} is not supported" unless RansackFilterBuilder.type_supported?(type)

    RansackFilterBuilder.suffixes_for_type(type).each do |suf|
      builder = RansackFilterBuilder.new(attr: attr, operator: suf, column: column, verify: verify)
      filter builder.filter_name,
             verify: ->(values, _ctx) { builder.verify(values) },
             apply: ->(records, values, _opts) { builder.apply(records, values) }
    end
  end

  def self.relationship_filter(name, options = {})
    foreign_key = options.fetch(:foreign_key, :"#{name}_id")

    filter :"#{name}.id", apply: lambda { |records, values, _options|
      records.where(foreign_key => values)
    }
  end
end
