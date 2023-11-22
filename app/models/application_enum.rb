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

      id = Integer(id)
      all.detect { |currency| currency.id == id }
    end

    private :new
  end

  attribute :id

  def hash
    [self.class.name, id].hash
  end
end
