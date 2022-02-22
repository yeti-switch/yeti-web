# frozen_string_literal: true

# Simplified array type that works similar to ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array
# but for ActiveModel.
# @see WithActiveModelArrayAttribute
class ArrayType < ActiveModel::Type::Value
  include ActiveModel::Type::Helpers::Mutable

  attr_reader :subtype, :reject_blank
  delegate :type, :user_input_in_time_zone, :limit, :precision, :scale, to: :subtype

  def initialize(subtype, reject_blank: false)
    @subtype = subtype
    @reject_blank = reject_blank
  end

  def cast(value)
    if value.is_a?(::Array)
      result = value.map { |item| @subtype.serialize(item) }
      result = result.reject(&:blank?) if reject_blank
      result
    else
      value
    end
  end

  def ==(other)
    other.is_a?(ArrayType) && subtype == other.subtype && reject_blank == other.reject_blank
  end
end

ActiveModel::Type.register :array, ArrayType
