# frozen_string_literal: true

class ApplicationValue
  include ActiveModel::API

  class << self
    def attribute(name)
      name = name.to_sym

      define_method(name) { @attributes[name] }
      setter = :"#{name}="
      define_method(setter) { |value| @attributes[name] = value }
      private setter
    end

    def attributes(*names)
      names.each { |name| attribute(name) }
    end
  end

  def initialize(**)
    @attributes = {}
    assign_attributes(**)
    freeze
  end

  def [](name)
    raise ArgumentError, "Unknown attribute #{name}" unless respond_to?(name)

    public_send(name)
  end

  def hash
    [self.class.name, @attributes].hash
  end

  def ==(other)
    other.is_a?(self.class) && hash == other.hash
  end

  alias eql? ==

  private

  def assign_attributes(**attributes)
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
end
