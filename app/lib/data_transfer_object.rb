# frozen_string_literal: true

class DataTransferObject
  include Memoizable

  class_attribute :member_opts, instance_accessor: false, default: {}

  class << self
    def members
      member_opts.keys
    end

    # Defines an attribute for the DTO.
    # @param name [Symbol, String] - name of the attribute
    # @param default [Object, Proc, nil] - default value or a callable returning the default value
    # @param required [Boolean] - whether the attribute is required (for documentation purposes)
    def attribute(name, default: nil, required: false)
      name = name.to_sym
      self.member_opts = member_opts.merge(name => { default:, required: })
      define_method(name) { @attributes[name] }
    end
  end

  # @param attributes [Hash{Symbol=>Object}] - attributes to set
  def initialize(attributes = {})
    attributes = attributes.symbolize_keys
    @attributes = default_attributes
    attributes.assert_valid_keys(self.class.members)
    assign_attributes(**attributes)
    verify_required_attributes
  end

  def [](name)
    @attributes[name.to_sym]
  end

  def to_h
    @attributes.dup
  end

  def ==(other)
    self.class == other.class && hash == other.hash
  end

  alias eql? ==

  def hash
    [self.class, @attributes].hash
  end

  def inspect
    attr_strings = self.class.members.map do |name|
      "#{name}: #{@attributes[name].inspect}"
    end
    "#<#{self.class.name} #{attr_strings.join(', ')}>"
  end

  private

  def assign_attributes(**attributes)
    attributes.each do |key, value|
      @attributes[key.to_sym] = value
    end
  end

  def default_attributes
    defaults = {}
    self.class.member_opts.each do |name, options|
      if options.key?(:default)
        default_value = options[:default]
        defaults[name] = default_value.respond_to?(:call) ? default_value.call : default_value
      else
        defaults[name] = nil
      end
    end
    defaults
  end

  def verify_required_attributes
    missing_names = self.class.member_opts.select do |name, options|
      options[:required] && @attributes[name].nil?
    end.keys
    return if missing_names.empty?

    raise ArgumentError, "Missing required attributes: #{missing_names.join(', ')}"
  end
end
