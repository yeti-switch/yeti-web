# frozen_string_literal: true

module Jobs
  class EventProcessor < ::BaseJob
    self.cron_line = '* * * * *'

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
      ev.node.api.custom_request("yeti.#{args.shift}", args)
    end

    private

    def events
      @events ||= Event.preload(:node).order('created_at')
    end

    def safe_process_event(ev)
      process_event(ev)
      ev.destroy!
      true
    rescue NodeApi::ConnectionError => e
      handle_event_error(event: ev, exception: e)
      false
    rescue StandardError => e
      handle_event_error(event: ev, exception: e)
      tags = { job_class: self.class.name }
      extra = { event_id: ev.id, command: ev.command, node_id: ev.node_id }
      CaptureError.capture(e, tags: tags, extra: extra)
      false
    end

    def handle_event_error(event:, exception:)
      logger.warn { "Processing event ##{event.id} was failed" }
      logger.warn { "<#{exception.class}>: #{exception.message}\n#{exception.backtrace&.join("\n")}" }
      event.update!(
        retries: event.retries + 1,
        last_error: exception.message
      )
    end
  end
end
