# frozen_string_literal: true

class NodeParallelRpc
  Error = Class.new(StandardError)

  class << self
    def call(nodes: nil, default: nil, default_on_error: false, &block)
      new(nodes).call(default: default, default_on_error: default_on_error, &block)
    end
  end

  # @param nodes [Array<Node>,nil] omit or pass nil to use all nodes.
  def initialize(nodes = nil)
    @nodes = nodes || Node.all.to_a
  end

  # @param default [Object] value when error came (default empty array).
  # @yield in thread for each node
  # @yieldparam node [Node]
  # @return [Array] flatten array of data returned by all threads.
  # @example Usage
  #
  #   rows = NodeParallelRpc.call(default: []) do |node|
  #     result = node.api.sip_options_probers
  #     result.map { |row| row.merge(node: node) }
  #   end
  #
  def call(default: [], default_on_error: false, &block)
    data = Parallel.map(@nodes, in_threads: @nodes.size) do |node|
      if default_on_error
        safe_process_node(node, default, &block)
      else
        process_node(node, &block)
      end
    end
    data.flatten
  rescue StandardError => e
    # Here we capture error from thread created by Parallel and raise new one,
    # because original exception will not have useful information, like where it were called.
    CaptureError.log_error(e)
    raise Error, "Caught #{e.class} #{e.message}"
  end

  private

  def process_node(node)
    yield node
  end

  def safe_process_node(node, default)
    yield node
  rescue NodeApi::Error => e
    Rails.logger.error { "#{e.class}: #{e.message}" }
    default
  end
end
