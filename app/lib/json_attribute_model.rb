# frozen_string_literal: true

class JsonAttributeModel
  # Base class for json attribute.
  # @see JsonAttributeType
  # @see WithJsonAttributes#json_attribute

  include ActiveModel::Model
  include ActiveModel::Attributes

  class << self
    def column_names
      attribute_types.keys.map(&:to_s)
    end
  end

  attr_accessor :_unknown_attributes

  def initialize(*)
    self._unknown_attributes = {}
    super
  end

  # serializes model as hash of it's attributes
  def as_json(options = {})
    filled_attributes.with_indifferent_access.as_json(options)
  end

  # models are equal if classes and attributes values are the same
  def ==(other)
    return super unless other.is_a?(self.class)

    attributes.all? { |name, value| value == other.send(name) }
  end

  # Allows to call :presence validation on the json_attribute itself
  def blank?
    attributes.values.all?(&:blank?)
  end

  def [](attr_name)
    attribute(attr_name.to_sym)
  end

  def []=(attr_name, value)
    write_attribute(attr_name.to_sym, value)
  end

  def inspect
    attribute_string = filled_attributes.map { |name, value| "#{name}: #{value.inspect}" }.join(', ')
    "#<#{self.class.name} #{attribute_string}>"
  end

  private

  def filled_attributes
    attributes.reject { |_, value| value.nil? }
  end

  def unknown_attributes_raise?
    false
  end

  def _assign_attribute(name, value)
    super
  rescue ActiveModel::UnknownAttributeError
    raise e if unknown_attributes_raise?

    _unknown_attributes[name] = value
  end

  def write_attribute(name, value)
    super
  rescue ActiveModel::UnknownAttributeError
    raise e if unknown_attributes_raise?

    _unknown_attributes[name] = value
  end
end
