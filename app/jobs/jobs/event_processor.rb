module Jobs
  class EventProcessor < ::BaseJob


    def execute
      processed_count = 0
      events_count = events.count
      events.find_each do |ev|
        Event.transaction do
          processed_count += 1 if safe_process_event(ev)
        end
      end
      logger.info "Job #{type} processed #{processed_count}/#{events_count} events."
    end

    def process_event(ev)
      args = ev.command.split /\s+/
      logger.info "RPC send #{args} to node #{ev.node.id}"
      ev.node.api.rpc_send(args.shift, args)
    end

    private

    def events
      @events ||= Event.preload(:node).order('created_at')
    end

    def safe_process_event(ev)
      process_event(ev)
      ev.destroy!
      true
    rescue StandardError => e
      logger.warn { "Processing event ##{ev.id} was failed" }
      logger.warn { "<#{e.class}>: #{e.message}" }
      logger.warn { e.backtrace.join("\n") }
      ev.retries += 1
      ev.last_error = e.message
      ev.save!
      false
    end

  end
end
