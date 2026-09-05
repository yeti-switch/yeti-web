# frozen_string_literal: true

module CdrProcessor
  module Processors
    class CdrBilling < CdrProcessor::ConsumerGroup
      # billing.bill_cdr_batch_part feeds the payload to
      # jsonb_populate_recordset(null::billing.cdr_v2, ...), so every other column
      # of a cdr_full event (~370 of them) is parsed and thrown away. Keep this
      # list in sync with the billing.cdr_v2 composite type.
      BILLED_FIELDS = %w[
        id
        customer_id
        vendor_id
        customer_acc_id
        vendor_acc_id
        customer_auth_id
        destination_id
        dialpeer_id
        orig_gw_id
        term_gw_id
        routing_group_id
        rateplan_id
        destination_next_rate
        destination_fee
        dialpeer_next_rate
        dialpeer_fee
        internal_disconnect_code
        internal_disconnect_reason
        disconnect_initiator_id
        customer_price
        vendor_price
        duration
        success
        profit
        time_start
        time_connect
        time_end
        lega_disconnect_code
        lega_disconnect_reason
        legb_disconnect_code
        legb_disconnect_reason
        src_prefix_in
        src_prefix_out
        dst_prefix_in
        dst_prefix_out
        destination_initial_interval
        destination_next_interval
        destination_initial_rate
        orig_call_id
        term_call_id
        local_tag
        from_domain
        destination_reverse_billing
        dialpeer_reverse_billing
        package_counter_id
        customer_duration
        destination_attempt_fee
        dialpeer_attempt_fee
      ].freeze

      # A pgq batch is unbounded - when the ticker lags it can hold hundreds of
      # thousands of events - while a single statement cannot exceed the 1GB
      # PostgreSQL puts on any one value.
      PART_SIZE = 10_000

      def perform_events(events)
        group = events.map { |event| event.data&.slice(*BILLED_FIELDS) }
        perform_group_with_timing(group)
      end

      # All parts of a batch commit together, so billing.cdr_batches keeps one
      # marker row per batch: a failure half way through rolls the marker back
      # and pgq replays the whole batch.
      def perform_group(group)
        primary_connection.transaction do
          if start_batch?
            group.each_slice(PART_SIZE) { |part| bill_part(part) }
          end
        end
      end

      private

      def start_batch?
        primary_connection.select_value(
          'SELECT billing.bill_cdr_batch_start($1::bigint)', 'CdrBilling Start', [@batch_id]
        )
      end

      # exec_update rather than exec_query: the function returns void, which has
      # no ActiveRecord type, so building a result set logs "unknown OID 2278".
      def bill_part(part)
        primary_connection.exec_update(
          'SELECT billing.bill_cdr_batch_part($1::bigint, $2::jsonb)', 'CdrBilling Part',
          [@batch_id, coder.dump(part)]
        )
      end
    end
  end
end
