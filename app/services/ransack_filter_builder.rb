# frozen_string_literal: true

class RansackFilterBuilder
  RANSACK_ARRAY_SUFFIXES = %w[in not_in cont_any].freeze

  def initialize(attr:, operator:)
    @attr = attr
    @operator = operator
  end

  def apply(records, value)
    records.ransack(filter_name => value).result
  end

  def filter_name
    "#{@attr}_#{@operator}"
  end

  def verify(values)
    return values if RANSACK_ARRAY_SUFFIXES.include?(@operator)
    raise JSONAPI::Exceptions::InvalidFilterValue.new(filter_name, values.join(',')) if values.size != 1

    values.first
  end
end
