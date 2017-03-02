module Jobs
  class EventProcessor < ::BaseJob


    def execute

      events.each do |ev|
        begin
          Event.transaction do
            process_event(ev)
            ev.destroy!
          end
        rescue StandardError => e
          logger.warn e.message
          logger.warn e.backtrace.join("\n")
          ev.retries+=1
          ev.last_error = e.message
          ev.save!
        end
      end
      events.count
    end

    protected

    def events
      @events ||= Event.eager_load(:node).order('created_at')
    end

    def process_event(ev)
      args = ev.command.split /\s+/
      logger.info "RPC send #{args} to node #{ev.node.id}"
      ev.node.api.rpc_send(*args)
    end

  end
end

