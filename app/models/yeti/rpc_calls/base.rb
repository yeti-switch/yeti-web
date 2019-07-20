# frozen_string_literal: true

module Yeti
  module RpcCalls
    class Base
      Result = Struct.new(:data, :errors)
      FETCH_TYPES = %i[parallel first_success].freeze

      class_attribute :parameter_keys, instance_writer: false, default: {}
      class_attribute :logger, instance_writer: false, default: Rails.logger
      class_attribute :_fetch_type, instance_writer: false, default: :parallel

      class << self
        def call(*args)
          new(*args).call
        end

        def fetch_type(type)
          if FETCH_TYPES.exclude?(type)
            raise ArgumentError, "invalid fetch_type #{type}, available: #{FETCH_TYPES.join(', ')}"
          end

          self._fetch_type = type
        end

        def parameter(name, options = {})
          name = name.to_sym
          raise ArgumentError, "parameter #{name.inspect} already defined" if parameter_keys.include?(name)

          self.parameter_keys = parameter_keys.merge name => options
          define_method(name) do
            params.fetch(name) do
              default = options[:default]
              default.is_a?(Proc) ? instance_exec(&default) : default
            end
          end
        end
      end

      attr_reader :nodes, :params

      def initialize(nodes, params = {})
        @nodes = nodes
        params ||= {}
        params.assert_valid_keys(*parameter_keys)
        @params = params
      end

      def call
        data, errors = send("#{_fetch_type}_fetch")
        Result.new(data, errors)
      end

      private

      def first_success_fetch
        errors = []
        nodes.each do |node|
          data = process_node(node)
          # will return data on first success response from node
          return [data, errors]
        rescue YetisNode::Error => e
          errors.push error_for(node, e)
        end
        [[], errors]
      end

      def parallel_fetch
        errors = []
        data = []
        parallel_nodes do |node|
          data.concat process_node(node)
        rescue YetisNode::Error => e
          errors.push error_for(node, e)
        end
        [data, errors]
      end

      # @param node [Node] - node instance
      # @return [String] - parsed error message from node
      def error_for(node, e)
        "#{node.rpc_endpoint} - #{e.message}"
      end

      # @param node [Node] - node instance
      # @return [Array<Hash>] list of objects retrieved from node
      def process_node(_node)
        raise NotImplementedError, "implement #process_node private method in #{self.class}"
      end

      def parallel_nodes
        Parallel.map(nodes, in_threads: nodes.size) { |node| yield(node) }
      end
    end
  end
end
