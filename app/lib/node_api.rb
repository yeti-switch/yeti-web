# frozen_string_literal: true

class NodeApi
  class_attribute :_mutex, instance_accessor: false, default: Thread::Mutex.new
  class_attribute :_nodes, instance_accessor: false, default: {}
  class_attribute :default_options, instance_writer: false, default: { logger: Rails.logger }

  class << self
    def find(uri)
      _mutex.synchronize do
        _nodes[uri] ||= new(uri)
      end
    end

    def reset(uri)
      api = _mutex.synchronize do
        _nodes.delete(uri)
      end
      api&.close
      nil
    end

    def reset_all
      apis = _mutex.synchronize do
        _nodes.delete_if { true }
      end
      apis.each_value(&:close)
      nil
    end

    def inherited(subclass)
      super
      subclass._mutex = Thread::Mutex.new
      subclass._nodes = {}
      subclass.default_options = default_options.dup
    end
  end

  class Error < StandardError
  end
  class ConnectionError < Error
  end

  attr_reader :uri
  delegate :close, to: :api

  def initialize(uri)
    @_mutex = Thread::Mutex.new
    @uri = uri
    options = default_options.dup
    @api = wrap_errors { JRPC::TcpClient.new(uri, options) }
  end

  def calls_count
    perform_request('yeti.show.calls.count')
  end

  def registrations(*ids)
    perform_request('yeti.show.registrations', ids)
  end

  def registrations_count(params = nil)
    perform_request('yeti.show.registrations.count', params)
  end

  def stats
    perform_request('yeti.show.status')
  end

  def router_cache_clear(params = nil)
    perform_request('yeti.request.router.cache.clear', params)
  end

  def call_disconnect(id)
    params = [id]
    perform_request('yeti.request.call.disconnect', params)
  end

  def aors(auth_id = nil)
    params = Array.wrap(auth_id)
    perform_request('yeti.show.aors', params)
  end

  def calls(*params)
    perform_request('yeti.show.calls', params)
  end

  def calls_filtered(*params)
    perform_request('yeti.show.calls.filtered', params)
  end

  def system_status(*params)
    perform_request('yeti.show.system.status', params)
  end

  # @param ids [Array<Integer>,nil] specific ids or all probers
  # @return [Array<Hash>]
  # @raise [NodeApi::Error]
  def sip_options_probers(ids = [])
    perform_request('options_prober.show.probers', ids)
  end

  def configuration
    perform_request('yeti.show.configuration')
  end

  def interfaces
    perform_request('yeti.show.interfaces')
  end

  def version
    perform_request('yeti.show.version')
  end

  def resource_state(type_id, id = nil)
    params = [type_id, id || :all]
    perform_request('yeti.show.resource_state', params)
  end

  def reload_sip_options_probers
    perform_request('yeti.request.options_prober.reload')
  end

  def custom_request(method_name, params = [])
    perform_request(method_name, params)
  end

  private

  attr_reader :_mutex, :api

  def perform_notification(method, params = [])
    _mutex.synchronize do
      wrap_errors { api.perform_request(method, params: params, type: :notification) }
    end
    nil
  end

  def perform_request(method, params = [])
    result = _mutex.synchronize do
      wrap_errors { api.perform_request(method, params: params) }
    end
    normalize_result(result)
  end

  def normalize_result(result)
    return result.deep_symbolize_keys if result.is_a?(Hash)
    return result.map { |item| normalize_result(item) } if result.is_a?(Array)

    result
  end

  def wrap_errors
    yield
  rescue JRPC::ConnectionError => e
    raise ConnectionError, e.message
  rescue JRPC::Error => e
    raise Error, e.message
  end
end
