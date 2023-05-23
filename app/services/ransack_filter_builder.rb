# frozen_string_literal: true

class RansackFilterBuilder
  RANSACK_TYPE_SUFIXES_DIC = {
    boolean: %w[eq not_eq],
    datetime: %w[eq not_eq gt gteq lt lteq in not_in],
    inet: %w[eq not_eq in not_in],
    number: %w[eq not_eq gt gteq lt lteq in not_in],
    string: %w[eq not_eq cont start end in not_in cont_any],
    uuid: %w[eq not_eq in not_in],
    enum: %w[eq not_eq in not_in],
    foreign_key: %w[eq not_eq in not_in]
  }.freeze

  RANSACK_ARRAY_SUFFIXES = %w[in not_in cont_any].freeze

  # @param attr [Symbol] name of filter
  # @param operator [Symbol] ransack filter predicate
  # @param column [Symbol] column name
  def initialize(attr:, operator:, column: nil, verify: nil, collection: nil)
    @attr = attr
    @operator = operator
    @column = column
    @verify = verify
    @collection = collection
  end

  # Applies ransack filter to records
  # @param records [ActiveRecord::Relation]
  # @param value [Array<String>, String]
  # @return [ActiveRecord::Relation]
  def apply(records, value)
    records.ransack(ransack_filter_name => value).result
  end

  # Ransack filter name
  # @return [String]
  def ransack_filter_name
    "#{@column || @attr}_#{@operator}"
  end

  # Public filter name
  # @return [String]
  def filter_name
    "#{@attr}_#{@operator}"
  end

  # @param values [Array<String>]
  def verify(values)
    if RANSACK_ARRAY_SUFFIXES.include?(@operator)
      values = @verify.call(values) if @verify
      return values
    end

    raise JSONAPI::Exceptions::InvalidFilterValue.new(filter_name, values.join(',')) if values.size != 1

    if @collection && values.any? { |val| @collection.exclude?(val) }
      raise JSONAPI::Exceptions::InvalidFilterValue.new(filter_name, values.join(','))
    end

    values = @verify.call(values) if @verify
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
