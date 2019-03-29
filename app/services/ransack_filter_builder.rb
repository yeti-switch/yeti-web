# frozen_string_literal: true

class RansackFilterBuilder
  RANSACK_TYPE_SUFIXES_DIC = {
    boolean: %w[eq not_eq],
    datetime: %w[eq not_eq gt gteq lt lteq in not_in],
    inet: %w[eq not_eq in not_in],
    number: %w[eq not_eq gt gteq lt lteq in not_in],
    string: %w[eq not_eq cont start end in not_in cont_any],
    uuid: %w[eq not_eq in not_in]
  }.freeze

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

  class << self
    def suffixes_for_type(type)
      RANSACK_TYPE_SUFIXES_DIC[type]
    end

    def type_supported?(type)
      RANSACK_TYPE_SUFIXES_DIC.key?(type)
    end
  end
end
