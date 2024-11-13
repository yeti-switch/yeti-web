# frozen_string_literal: true

module QueryBuilder
  class Base
    extend Forwardable

    VALUE_METHODS = %i[size first last map each collect].freeze

    instance_delegate VALUE_METHODS => :to_a

    class << self
      def define_chainable(name, &block)
        define_method(name) do |*args|
          perform_chainable(*args, &block)
        end
      end
    end

    define_chainable :where do |conditions|
      filter_values.merge!(conditions.symbolize_keys)
    end

    define_chainable :includes do |*values|
      old_includes = include_values.dup
      old_includes_nested = old_includes.extract_options!
      new_includes = []
      new_includes_nested = {}
      values.flatten.each do |val|
        if val.is_a?(Hash)
          new_includes_nested.deep_merge!(val)
        else
          new_includes << val
        end
      end
      simple = (old_includes + new_includes).uniq.map(&:to_sym)
      nested = old_includes_nested.deep_merge(new_includes_nested)
      self.include_values = simple + [nested]
    end

    define_chainable :none do
      self.is_none = true
    end

    def initialize
      @filter_values = {}
      @include_values = []
      @is_none = false
    end

    def dup
      new_instance = self.class.new(*dup_params)
      new_instance.filter_values = filter_values.dup
      new_instance.include_values = include_values.dup
      new_instance.is_none = is_none
      new_instance
    end

    def to_a
      return @to_a if defined?(@to_a)

      @to_a = find_collection
    end

    def find(id)
      find_record(id)
    end

    def reset
      remove_instance_variable(:"@to_a")
      self
    end

    def all
      self
    end

    protected

    attr_accessor :filter_values, :include_values, :is_none

    private

    def dup_params
      []
    end

    def find_record(_id)
      raise NotImplementedError, "implement #find_record method in #{self.class}"
    end

    def find_collection
      raise NotImplementedError, "implement #find_collection method in #{self.class}"
    end

    def perform_chainable(*args, &block)
      new_instance = dup
      new_instance.instance_exec(*args, &block)
      new_instance
    end
  end
end
