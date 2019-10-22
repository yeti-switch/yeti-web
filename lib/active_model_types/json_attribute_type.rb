# frozen_string_literal: true

class JsonAttributeType < ActiveModel::Type::Value
  # Type for JSON model attribute.
  # @see JsonAttributeModel
  # @see WithJsonAttributes#json_attribute

  class CastError < StandardError
  end

  def initialize(class_name:)
    @model_class_name = class_name
  end

  def type
    :json
  end

  def cast_value(value)
    case value
    when String
      decoded = begin
                  ActiveSupport::JSON.decode(value)
                rescue StandardError
                  nil
                end
      model_class.new(decoded) unless decoded.nil?
    when Hash
      model_class.new(value)
    when ActionController::Parameters
      model_class.new(value.to_unsafe_h)
    when model_class
      value
    else
      raise CastError, "failed casting #{value.inspect}, only String, Hash or #{model_class} instances are allowed"
    end
  end

  def serialize(value)
    case value
    when Hash, model_class
      ActiveSupport::JSON.encode(value)
    else
      super
    end
  end

  def changed_in_place?(raw_old_value, new_value)
    cast_value(raw_old_value) != new_value
  end

  private

  def model_class
    @model_class ||= @model_class_name.constantize
  end
end

ActiveRecord::Type.register :json_object, JsonAttributeType
