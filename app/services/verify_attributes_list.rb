# frozen_string_literal: true

class VerifyAttributesList < ApplicationService
  class_attribute :row_number_offset, instance_writer: false, default: 0
  parameter :attributes_list, required: true

  Error = Class.new(StandardError) do
    attr_reader :error_lines

    def initialize(error_lines)
      @error_lines = error_lines
      super('Verify Failed')
    end
  end

  TRUE_VALUE = 'TRUE'
  FALSE_VALUE = 'FALSE'

  class_attribute :_verify_attribute, instance_writer: false, default: {}
  class_attribute :_verify_items, instance_writer: false, default: []

  class << self
    def verify_attribute(attr_name, apply:)
      attr_name = attr_name.to_sym
      raise ArgumentError, "verifier for #{attr_name} already added" if _verify_attribute.key?(attr_name)

      _verify_attribute[attr_name] = apply
    end

    def verify_items(apply:)
      _verify_items.push(apply)
    end

    private

    def inherited(subclass)
      super
      subclass._verify_attribute = _verify_attribute.dup
      subclass._verify_items = _verify_items.dup
    end
  end

  # verify :prefix, apply: ->(prefix, row_number) do
  #   add_error('Prefix must be exist', row_number) if prefix.nil?
  #
  #   prefix
  # end

  def call
    raise ArgumentError, 'invalid attributes_list' unless attributes_list.is_a?(Array)
    raise ArgumentError, 'attributes_list must contain at least one item' if attributes_list.empty?

    @errors = {}
    items = []
    attributes_list.each_with_index do |attributes, index|
      raise ArgumentError, "invalid attributes #{attributes.class} at attributes_list[#{index}]" unless attributes.is_a?(Hash)

      row_number = index + row_number_offset
      items << process_attributes(attributes, row_number)
    end
    run_verify_items(items)
    raise Error, build_error_lines if @errors.present?

    items
  end

  private

  # @param attributes [Hash]
  # @param row_number [Integer]
  def process_attributes(attributes, row_number)
    raise NotImplementedError
  end

  # @param message [String]
  # @param row_number [Integer]
  def add_error(message, row_number)
    @errors[message] ||= []
    @errors[message] << row_number
  end

  # @return [Array<String>]
  def build_error_lines
    @errors.map do |message, row_numbers|
      "#{message} at #{row_numbers.join(', ')}"
    end
  end

  def convert_to_integer(value)
    return if value.blank?

    Integer(value)
  rescue TypeError, ArgumentError
    nil
  end

  def convert_to_decimal(value)
    return if value.blank?

    BigDecimal(value)
  rescue TypeError, ArgumentError
    nil
  end

  def convert_to_time(value)
    return if value.blank?

    Time.zone.parse(value)
  rescue ArgumentError
    nil
  end

  def convert_to_boolean(value)
    case value
    when TRUE_VALUE
      true
    when FALSE_VALUE
      false
    end
  end

  def verify_attribute(attr_name, item, row_number:)
    instance_exec(item[attr_name], row_number, &_verify_attribute[attr_name])
  end

  def run_verify_items(items)
    _verify_items.each { |apply| instance_exec(items, &apply) }
  end
end
