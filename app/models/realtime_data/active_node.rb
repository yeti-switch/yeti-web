# == Schema Information
#
# Table name: nodes
#
#  id              :integer          not null, primary key
#  signalling_ip   :string
#  signalling_port :integer
#  name            :string
#  pop_id          :integer          not null
#  rpc_endpoint    :string
#

class RealtimeData::ActiveNode < Node

  def self.random_node
    ids = self.pluck(:id)
    self.find(ids.sample)
  end

  def api
    @api ||= if rpc_endpoint.present?
               YetisNode::Client.new(rpc_endpoint, transport: :json_rpc)
             else
               YetisNode::Client.new(rpc_uri)
             end
  end

  def total_calls_count
    api.calls_count
  end

  def stats
    api.stats
  end

  def system_status
    @system_status ||= api.system_status
  end

  def clear_cache
    api.router_clear_cache
  end

  def drop_call(id)
    api.call_disconnect(id)
  end

  def active_call(id)
    RealtimeData::ActiveCall.new(api.calls(id))
  end

  def active_calls(options = {})
    empty_on_error = !!options[:empty_on_error]
    params = options[:params] || []
    begin
      api.calls(*params)
    rescue StandardError => e
      if empty_on_error
        logger.warn { e.message }
        logger.warn { e.backtrace.join("\n") }
        return []
      else
        raise e
      end
    end
  end

end
