# frozen_string_literal: true

class NormalizedValueType < DelegateClass(ActiveModel::Type::Value) # :nodoc:
  attr_reader :cast_type, :normalizer, :normalize_nil
  alias normalize_nil? normalize_nil

  def initialize(cast_type:, normalizer:, normalize_nil:)
    @cast_type = cast_type
    @normalizer = normalizer
    @normalize_nil = normalize_nil
    super(cast_type)
  end

  def cast(value)
    normalize(super(value))
  end

  def serialize(value)
    serialize_cast_value(cast(value))
  end

  def serialize_cast_value(value)
    if cast_type.respond_to?(:serialize_cast_value)
      cast_type.serialize_cast_value(value)
    else
      cast_type.serialize(value)
    end
  end

  def ==(other)
    self.class == other.class &&
      normalize_nil? == other.normalize_nil? &&
      normalizer == other.normalizer &&
      cast_type == other.cast_type
  end

  alias eql? ==

  def hash
    [self.class, cast_type, normalizer, normalize_nil?].hash
  end

  def inspect
    Kernel.instance_method(:inspect).bind_call(self)
  end

  private

  def normalize(value)
    normalizer.call(value) if !value.nil? || normalize_nil?
  end
end
