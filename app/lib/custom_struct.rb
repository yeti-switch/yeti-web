# frozen_string_literal: true

class CustomStruct
  attr_reader :members

  def initialize(attrs)
    @members = []
    @attributes = {}

    attrs.each do |name, value|
      name = name.to_sym
      add_member(name)
      write_attribute(name, value)
    end
  end

  def [](name)
    name = name.to_sym
    has_attributes!(name)

    read_attribute(name)
  end

  def []=(name, value)
    name = name.to_sym
    has_attributes!(name)

    write_attribute(name, value)
  end

  def to_h
    @attributes.dup
  end

  def values
    @attributes.values
  end

  def to_s
    attrs = @attributes.map { |name, val| "#{name}=#{val}" }.join(' ')
    "#<#{self.class} #{attrs}>"
  end

  def freeze
    super
    members.each do |name|
      value = read_attribute(name)
      value.freeze if value && !value.frozen?
    end
  end

  alias inspect to_s

  private

  def read_attribute(name)
    @attributes[name]
  end

  def write_attribute(name, value)
    check_frozen!

    value = value.presence unless value.is_a?(FalseClass)
    value = self.class.new(value) if value.is_a?(Hash)
    @attributes[name] = value
  end

  def has_attribute?(name)
    @attributes.key?(name)
  end

  def add_member(name)
    check_frozen!
    raise NameError, "member #{name} already added" if @members.include?(name)

    @members.push(name)

    unless singleton_class.method_defined?(name)
      singleton_class.define_method(name) { read_attribute(name) }
      singleton_class.define_method("#{name}=") { |value| write_attribute(name, value) }
    end
  end

  def has_attributes!(name)
    raise NameError, "no member #{name} in a #{self.class}" unless has_attribute?(name)
  end

  def check_frozen!
    raise FrozenError, "can't modify frozen #{self.class}" if frozen?
  end
end
