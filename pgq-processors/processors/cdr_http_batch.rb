# frozen_string_literal: true

require 'rest-client'
require_relative 'cdr_http_base'

class CdrHttpBatch < CdrHttpBase
  @consumer_name = 'cdr_http'

  def perform_group(events)
    events_to_send = events.select { |event| send_event?(event) }
    return if events_to_send.empty?

    permitted_events = events_to_send.map { |event| permit_field_for(event) }
    perform_http_request(permitted_events)
  end

  private

  def http_body(events)
    { data: events }.to_json
  end
end
