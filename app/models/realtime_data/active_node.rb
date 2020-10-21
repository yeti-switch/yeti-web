# frozen_string_literal: true

# == Schema Information
#
# Table name: nodes
#
#  id           :integer(4)       not null, primary key
#  name         :string
#  rpc_endpoint :string
#  pop_id       :integer(4)       not null
#
# Indexes
#
#  node_name_key           (name) UNIQUE
#  nodes_rpc_endpoint_key  (rpc_endpoint) UNIQUE
#
# Foreign Keys
#
#  node_pop_id_fkey  (pop_id => pops.id)
#

class RealtimeData::ActiveNode < Node
  def self.random_node
    ids = pluck(:id)
    find(ids.sample)
  end

  def api
    @api ||= if rpc_endpoint.present?
               YetisNode::Client.new(rpc_endpoint, transport: :json_rpc, logger: logger)
             else
               YetisNode::Client.new(rpc_uri, logger: logger)
             end
  end

  def total_calls_count
    api.calls_count
  end

  delegate :stats, to: :api

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
        []
      else
        raise e
      end
    end
  end
end
