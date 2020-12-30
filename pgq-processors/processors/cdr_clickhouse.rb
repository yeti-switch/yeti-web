# frozen_string_literal: true

require 'rest-client'
require_relative 'cdr_http_base'

class CdrClickhouse < CdrHttpBase
  @consumer_name = 'cdr_clickhouse'
  TIME_FIELDS = %w[
    time_start
    time_connect
    time_end
  ].freeze

  def perform_group(events)
    perform_http_request(events)
  end

  private

  def http_url
    sql = "INSERT INTO #{@params['clickhouse_db']}.#{@params['clickhouse_table']} FORMAT JSONEachRow"
    query = { query: sql }.to_query
    "#{@params['url']}?#{query}"
  end

  def http_body(events)
    events_to_encode = events.map do |event|
      event = permit_field_for(event)
      event = event.merge 'date_start' => event['time_start'] if event['time_start']
      event
    end
    JsonEachRowCoder.dump(
      events_to_encode,
      time_fields: TIME_FIELDS,
      date_fields: ['date_start']
    )
  end

  def http_headers
    {}
  end
end
