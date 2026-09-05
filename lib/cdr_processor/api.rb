# frozen_string_literal: true

require 'zlib'

module CdrProcessor
  module Api
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

    # The adapter casts the boolean result, so anything but true (including the
    # NULL returned for an unknown event) means "not done".
    def pgq_event_done?(consumer, batch_id, event_id)
      result = connection.select_value(sanitize_sql_array(['SELECT pgq_ext.is_event_done(?, ?, ?)', consumer, batch_id, event_id]))
      result == true
    end

    # Returns true when the event has just been marked as done, false when it
    # already was.
    def pgq_event_done!(consumer, batch_id, event_id)
      result = connection.select_value(sanitize_sql_array(['SELECT pgq_ext.set_event_done(?, ?, ?)', consumer, batch_id, event_id]))
      result == true
    end

    # Marks every given event of the batch as done in a single statement.
    # Calling #pgq_event_done! per event costs one round trip per CDR, which
    # dominates batch time at CDR volumes.
    def pgq_events_done!(consumer, batch_id, event_ids)
      return if event_ids.blank?

      ids = event_ids.map(&:to_i).join(',')
      connection.execute(
        sanitize_sql_array(
          ['SELECT pgq_ext.set_event_done(?, ?, ev_id) FROM unnest(?::bigint[]) AS ev_id', consumer, batch_id, "{#{ids}}"]
        )
      )
    end

    # == consumer lock

    # Advisory locks are global to the database, so the key is namespaced:
    # classid identifies the component, objid the queue/consumer pair.
    LOCK_NAMESPACE = 'yeti.cdr_processor'

    # pg_try_advisory_lock takes signed int4, so the unsigned CRC32 is
    # reinterpreted as signed. pg_locks reports the unsigned value, but comparing
    # it against the signed literal matches - int4 casts to oid bitwise.
    def pgq_lock_key(value)
      [Zlib.crc32(value)].pack('L').unpack1('l')
    end

    def pgq_consumer_key(queue_name, consumer_name)
      pgq_lock_key("#{queue_name}/#{consumer_name}")
    end

    # Session level, so it spans the several autocommit statements a batch takes
    # (next_batch .. get_batch_events .. finish_batch). Never unlocked - the
    # session ends with the process, which releases it.
    def pgq_consumer_lock!(queue_name, consumer_name)
      connection.select_value(
        sanitize_sql_array(
          ['SELECT pg_try_advisory_lock(?, ?)', pgq_lock_key(LOCK_NAMESPACE), pgq_consumer_key(queue_name, consumer_name)]
        )
      ) == true
    end

    # objsubid is 2 for the two argument form of pg_try_advisory_lock.
    def pgq_consumer_lock?(queue_name, consumer_name)
      connection.select_value(
        sanitize_sql_array(
          [
            "SELECT EXISTS (
               SELECT 1 FROM pg_locks
               WHERE locktype = 'advisory' AND pid = pg_backend_pid() AND granted
                 AND objsubid = 2 AND classid = ? AND objid = ?
             )",
            pgq_lock_key(LOCK_NAMESPACE), pgq_consumer_key(queue_name, consumer_name)
          ]
        )
      ) == true
    end

    # == info methods

    def pgq_get_queue_info(queue_name)
      connection.select_value(sanitize_sql_array(['SELECT pgq.get_queue_info(?)', queue_name]))
    end

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
end
