# frozen_string_literal: true

class ArrayType < ActiveModel::Type::Value
  attr_reader :value_type, :options

  def initialize(options = {})
    type = options.delete(:type) || ActiveModel::Type::Value.new
    if type.is_a?(Symbol)
      type_options = options.delete(:type_opts) || {}
      @value_type = ActiveModel::Type.lookup(type, type_options)
    else
      @value_type = type
    end
    @options = options
  end

  def type
    :array
  end

  private

  def cast_value(value)
    return [] if value.blank?

    Array.wrap(value).map { |val| value_type.send(:cast_value, val) }
  end
end

ActiveModel::Type.register :array, ArrayType
