# frozen_string_literal: true

class NodeRpcClient
  class_attribute :logger, instance_writer: false, default: Rails.logger

  class Error < StandardError
  end

  # @param [Array<Node>,nil] omit or pass nil to use all nodes
  # @param [Object] value when error came
  # @yield in thread for each node
  # @yieldparam client [NodeRpcClient]
  # @yieldparam node [Node]
  # @return [Array] flatten array of data returned by all threads.
  # @example Usage
  #
  #   rows = NodeRpcClient.perform_parallel(default: []) do |client, node|
  #     result = client.sip_options_probers
  #     result.map { |row| row.merge(node: node) }
  #   end
  #
  def self.perform_parallel(nodes = nil, default: nil, &block)
    nodes ||= Node.all.to_a

    data = Parallel.map(nodes, in_threads: nodes.count) do |node|
      client = new(node.rpc_endpoint)
      block.call(client, node)
    rescue Error => e
      Rails.logger.error { "#{e.class}: #{e.message}" }
      default
    end
    data.flatten
  end

  def initialize(rpc_endpoint, options = {})
    options = options.merge(logger: logger) if logger
    @client = JRPC::TcpClient.new(rpc_endpoint, options)
  rescue JRPC::Error => e
    raise Error, e.message
  end

  # @param ids [Array<Integer>,nil] specific ids or all probers
  # @return [Array<Hash>]
  # @raise [NodeRpcClient::Error]
  def sip_options_probers(ids = [])
    perform_request('options_prober.show.probers', params: ids)
  end

  private

  def perform_request(method, params: nil)
    result = @client.perform_request(method, params: params)
    result.is_a?(Array) ? result.map(&:deep_symbolize_keys) : result.deep_symbolize_keys
  rescue JRPC::Error => e
    raise Error, e.message
  end

  def perform_notification(method, params: nil)
    @client.perform_request(method, params: params, type: :notification)
  rescue JRPC::Error => e
    raise Error, e.message
  end
end
query_builder_findquery_builder_find
