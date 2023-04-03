# frozen_string_literal: true

module Pgq::Api
  # should mixin to class, which have connection

  # == consuming

  def pgq_next_batch(queue_name, consumer_name)
    result = connection.select_value(sanitize_sql_array(['SELECT pgq.next_batch(?, ?)', queue_name, consumer_name]))
    result&.to_i
  end

  def pgq_get_batch_events(consumer_name, batch_id)
    connection.select_all(sanitize_sql_array(['SELECT * FROM pgq.get_batch_events(?) WHERE pgq_ext.is_event_done(?, ?, ev_id) = false ORDER BY ev_id', batch_id, consumer_name, batch_id]))
  end

  def pgq_finish_batch(batch_id)
    connection.select_value(sanitize_sql_array(['SELECT pgq.finish_batch(?)', batch_id]))
  end

  # == retry

  def pgq_event_retry(batch_id, event_id, retry_seconds)
    connection.select_value(sanitize_sql_array(['SELECT pgq.event_retry(?, ?, ?)', batch_id, event_id, retry_seconds])).to_i
  end

  def pgq_event_done?(consumer, batch_id, event_id)
    result = connection.select_value(sanitize_sql_array(['SELECT pgq_ext.is_event_done(?, ?, ?)', consumer, batch_id, event_id]))
    result == 't'
  end

  def pgq_event_done!(consumer, batch_id, event_id)
    result = connection.select_value(sanitize_sql_array(['SELECT pgq_ext.set_event_done(?, ?, ?)', consumer, batch_id, event_id]))
    result == 't'
  end

  # == info methods

  def pgq_get_queue_info(queue_name)
    connection.select_value(sanitize_sql_array(['SELECT pgq.get_queue_info(?)', queue_name]))
  end

  # Get list of queues.
  # Result: (queue_name, queue_ntables, queue_cur_table, queue_rotation_period, queue_switch_time, queue_external_ticker, queue_ticker_max_count, queue_ticker_max_lag, queue_ticker_idle_period, ticker_lag)
  def pgq_get_queues_info
    connection.select_values('SELECT pgq.get_queue_info()')
  end

  def pgq_get_consumer_info
    connection.select_all('SELECT *, EXTRACT(epoch FROM last_seen) AS last_seen_sec, EXTRACT(epoch FROM lag) AS lag_sec FROM pgq.get_consumer_info()')
  end

  def pgq_get_consumer_queue_info(queue_name)
    connection.select_one(sanitize_sql_array(['SELECT *, EXTRACT(epoch FROM last_seen) AS last_seen_sec, EXTRACT(epoch FROM lag) AS lag_sec FROM pgq.get_consumer_info(?)', queue_name])) || {}
  end
end
