# frozen_string_literal: true

class ApplicationEnum < ApplicationValue
  class << self
    def setup_collection(&block)
      @setup_collection = block
    end

    # @return [Array]
    def all
      @all ||= begin
                 attrs_list = instance_exec(&@setup_collection)
                 attrs_list.map { |attrs| new(**attrs) }.freeze
               end
    end

    def ids
      all.map(&:id)
    end

    delegate :pluck, :map, to: :all

    def find(id)
      return if id.nil?

      find_by id: Integer(id)
    end

    # Filters enum collection by attributes
    # @param conditions [Hash] key - attribute name, value - attribute value
    # @return [Array]
    def filter_by(conditions)
      all.select { |enum| enum_match?(enum, conditions) }
    end

    # Finds first enum in collection by attributes
    # @param conditions [Hash] key - attribute name, value - attribute value
    # @return [ApplicationEnum,nil]
    def find_by(conditions)
      all.detect { |enum| enum_match?(enum, conditions) }
    end

    # @param enum [ApplicationEnum]
    # @param conditions [Hash] key - attribute name, value - attribute value
    # @return [Boolean]
    def enum_match?(enum, conditions)
      conditions.all? do |key, value|
        enum_value = enum.send(key)
        value.is_a?(Array) ? value.include?(enum_value) : enum_value == value
      end
    end

    private :new, :enum_match?
  end

  attribute :id

  def hash
    [self.class.name, id].hash
  end
end
