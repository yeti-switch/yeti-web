# frozen_string_literal: true

class CdrStat < Pgq::ConsumerGroup
  def initialize(logger, queue, consumer, options)
    super
    require_relative '../models/routing_base'
    key = options['mode']
    ::RoutingBase.establish_connection options.dig('databases', key, 'primary')
    @sp_name = options['stored_procedure']
  end

  def perform_batch
    safe_batch_perform do
      events_qty = ::RoutingBase.fetch_sp_val("SELECT processed_records FROM #{@sp_name}()")

      if events_qty.nil?
        # no batch
        return 0
      end

      events_qty = events_qty.to_i
      if events_qty.zero?
        log_info 'Empty batch'
        return -1
      end

      log_info "=> batch: events #{events_qty}"
      events_qty
    end
  end
end
