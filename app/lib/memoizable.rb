# frozen_string_literal: true

module Memoizable
  # Allows to define memoized methods with ease.
  # Usage:
  #
  #   class SomeService
  #     include Memoizable
  #
  #     def initialize(node_id)
  #       @node_id = node_id
  #     end
  #
  #     define_memoizable :node, apply: -> do
  #       Node.find(@node_id) if @node_id
  #     end
  #   end
  #
  #   s = SomeService.new(5) # no sql query
  #   s.node # one sql query
  #   s.node # no sql query - memoized value returned
  #   s = SomeService.new(nil) # no sql query
  #   s.node # no sql query but value is memoized
  #   s.node # no sql query - memoized value returned
  #

  extend ActiveSupport::Concern

  class_methods do
    # Creates memoized method which only executes once and return cached value after that.
    # @param name [Symbol, String] - name of method
    # @param variable [Symbol, String] - name of instance variable (default `__memoized_#{name}`)
    # @param apply [Proc] - provide lambda instead of block here if needed
    # @yield once per instance
    # @yieldreturn value that will be memoized and returned on next accesses to this method
    def define_memoizable(name, variable: nil, apply: nil)
      variable_name = :"@#{variable || "__memoized_#{name.to_s.gsub(/[!?]+/, '__')}"}"
      raise ArgumentError, 'provide :apply callable object' if apply.nil?

      define_method(name) do
        return instance_variable_get(variable_name) if instance_variable_defined?(variable_name)

        instance_variable_set variable_name, instance_exec(&apply)
      end
      name.to_sym
    end
  end
end
