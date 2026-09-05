# frozen_string_literal: true

class SplitBillCdrBatch < ActiveRecord::Migration[7.2]
  def up
    execute %q{
    DROP FUNCTION billing.bill_cdr_batch(bigint, text, integer);

    CREATE OR REPLACE FUNCTION billing.bill_cdr_batch_start(i_batch_id bigint) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
BEGIN
    insert into billing.cdr_batches(id) values(i_batch_id);
    -- claims the batch for this transaction, see billing.bill_cdr_batch_part
    perform set_config('billing.cdr_batch', i_batch_id::text, true);
    return true;
exception
    WHEN unique_violation then
        RAISE WARNING 'billing.bill_cdr_batch_start:  Data batch % already billed. Skip it.',i_batch_id;
        return false; -- batch already processed;
END;
$$;

    CREATE OR REPLACE FUNCTION billing.bill_cdr_batch_part(i_batch_id bigint, i_data jsonb, i_data_version integer DEFAULT 2) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    v_package_data record;
    v_c_acc_data record;
    v_v_acc_data record;
    v_dp_stats_data record;
    v_gw_stats_data record;
BEGIN
    if current_setting('billing.cdr_batch', true) is distinct from i_batch_id::text then
        RAISE EXCEPTION 'billing.bill_cdr_batch_part: batch % was not started in this transaction',i_batch_id;
    end if;

    if i_data_version=2 then
        --- ok;
    else
        RAISE EXCEPTION 'billing.bill_cdr_batch_part: No logic for this data version';
    end if;

    for v_c_acc_data in
      select
        customer_acc_id,
        sum(customer_price) as customer_price,
        destination_reverse_billing
      from jsonb_populate_recordset(null::billing.cdr_v2,i_data)
      where customer_acc_id is not null AND customer_price > 0 AND package_counter_id is null
      group by customer_acc_id, destination_reverse_billing
    LOOP
      IF v_c_acc_data.destination_reverse_billing IS NULL OR v_c_acc_data.destination_reverse_billing = false THEN
        UPDATE billing.accounts SET balance = balance - COALESCE(v_c_acc_data.customer_price,0) WHERE id = v_c_acc_data.customer_acc_id;
      ELSE
        UPDATE billing.accounts SET balance = balance + COALESCE(v_c_acc_data.customer_price,0) WHERE id = v_c_acc_data.customer_acc_id;
      END IF;
    END LOOP;

    for v_package_data in
      select
        package_counter_id,
        sum(customer_duration) as customer_duration
      from jsonb_populate_recordset(null::billing.cdr_v2,i_data)
      where customer_duration is not null AND package_counter_id is not null
      group by package_counter_id
    LOOP
      UPDATE billing.package_counters SET duration = duration-v_package_data.customer_duration WHERE id=v_package_data.package_counter_id;
    END LOOP;

    for v_v_acc_data in
      select
        vendor_acc_id,
        sum(vendor_price) as vendor_price,
        dialpeer_reverse_billing
      from jsonb_populate_recordset(null::billing.cdr_v2,i_data)
      where vendor_acc_id is not null AND vendor_price>0
      group by vendor_acc_id, dialpeer_reverse_billing
    LOOP
      IF v_v_acc_data.dialpeer_reverse_billing IS NULL OR v_v_acc_data.dialpeer_reverse_billing = false THEN
        UPDATE billing.accounts SET balance = balance + COALESCE(v_v_acc_data.vendor_price,0) WHERE id = v_v_acc_data.vendor_acc_id;
      ELSE
        UPDATE billing.accounts SET balance = balance - COALESCE(v_v_acc_data.vendor_price,0) WHERE id = v_v_acc_data.vendor_acc_id;
      END IF;
    END LOOP;

    FOR v_dp_stats_data IN
      SELECT
        dialpeer_id,
        sum(duration)::integer as duration,
        count(*)::integer as calls,
        (count(*) FILTER(WHERE duration>0))::integer as successful_calls,
        (count(*) FILTER(WHERE duration=0))::integer as failed_calls
      FROM jsonb_populate_recordset(null::billing.cdr_v2,i_data)
      WHERE dialpeer_id is not null AND duration is not null AND duration >= 0 /* Negative duration should not exists */
      GROUP BY dialpeer_id
    LOOP
      perform runtime_stats.update_dp(
        v_dp_stats_data.dialpeer_id,
        v_dp_stats_data.calls,
        v_dp_stats_data.successful_calls,
        v_dp_stats_data.failed_calls,
        v_dp_stats_data.duration
      );
    END LOOP;

    FOR v_gw_stats_data IN
      SELECT
        term_gw_id,
        sum(duration)::integer as duration,
        count(*)::integer as calls,
        (count(*) FILTER(WHERE duration>0))::integer as successful_calls,
        (count(*) FILTER(WHERE duration=0))::integer as failed_calls
      FROM jsonb_populate_recordset(null::billing.cdr_v2,i_data)
      WHERE term_gw_id is not null AND duration is not null AND duration >= 0 /* Negative duration should not exists */
      GROUP BY term_gw_id
    LOOP
      perform runtime_stats.update_gw(
        v_gw_stats_data.term_gw_id,
        v_gw_stats_data.calls,
        v_gw_stats_data.successful_calls,
        v_gw_stats_data.failed_calls,
        v_gw_stats_data.duration
      );
    END LOOP;

END;
$$;
    }
  end

  def down
    execute %q{
    DROP FUNCTION billing.bill_cdr_batch_part(bigint, jsonb, integer);
    DROP FUNCTION billing.bill_cdr_batch_start(bigint);

    CREATE OR REPLACE FUNCTION billing.bill_cdr_batch(i_batch_id bigint, i_data text, i_data_version integer DEFAULT 2) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    v_batch_data billing.cdr_v2;
    v_package_data record;
    v_c_acc_data record;
    v_v_acc_data record;
    v_dp_stats_data record;
    v_gw_stats_data record;
    _j_data json;
BEGIN
    begin
        _j_data:=i_data::json;
    exception
        when others then
            RAISE exception 'billing.bill_cdr_batch: Invalid json payload';
    end;

    BEGIN
        insert into billing.cdr_batches(id) values(i_batch_id);
    exception
        WHEN unique_violation then
            RAISE WARNING 'billing.bill_cdr_batch:  Data batch % already billed. Skip it.',i_batch_id;
            return; -- batch already processed;
    end ;

    if i_data_version=2 then
        --- ok;
    else
        RAISE EXCEPTION 'billing.bill_cdr_batch: No logic for this data version';
    end if;

    for v_c_acc_data in
      select
        customer_acc_id,
        sum(customer_price) as customer_price,
        destination_reverse_billing
      from json_populate_recordset(null::billing.cdr_v2,_j_data)
      where customer_acc_id is not null AND customer_price > 0 AND package_counter_id is null
      group by customer_acc_id, destination_reverse_billing
    LOOP
      IF v_c_acc_data.destination_reverse_billing IS NULL OR v_c_acc_data.destination_reverse_billing = false THEN
        UPDATE billing.accounts SET balance = balance - COALESCE(v_c_acc_data.customer_price,0) WHERE id = v_c_acc_data.customer_acc_id;
      ELSE
        UPDATE billing.accounts SET balance = balance + COALESCE(v_c_acc_data.customer_price,0) WHERE id = v_c_acc_data.customer_acc_id;
      END IF;
    END LOOP;

    for v_package_data in
      select
        package_counter_id,
        sum(customer_duration) as customer_duration
      from json_populate_recordset(null::billing.cdr_v2,_j_data)
      where customer_duration is not null AND package_counter_id is not null
      group by package_counter_id
    LOOP
      UPDATE billing.package_counters SET duration = duration-v_package_data.customer_duration WHERE id=v_package_data.package_counter_id;
    END LOOP;

    for v_v_acc_data in
      select
        vendor_acc_id,
        sum(vendor_price) as vendor_price,
        dialpeer_reverse_billing
      from json_populate_recordset(null::billing.cdr_v2,_j_data)
      where vendor_acc_id is not null AND vendor_price>0
      group by vendor_acc_id, dialpeer_reverse_billing
    LOOP
      IF v_v_acc_data.dialpeer_reverse_billing IS NULL OR v_v_acc_data.dialpeer_reverse_billing = false THEN
        UPDATE billing.accounts SET balance = balance + COALESCE(v_v_acc_data.vendor_price,0) WHERE id = v_v_acc_data.vendor_acc_id;
      ELSE
        UPDATE billing.accounts SET balance = balance - COALESCE(v_v_acc_data.vendor_price,0) WHERE id = v_v_acc_data.vendor_acc_id;
      END IF;
    END LOOP;

    FOR v_dp_stats_data IN
      SELECT
        dialpeer_id,
        sum(duration)::integer as duration,
        count(*)::integer as calls,
        (count(*) FILTER(WHERE duration>0))::integer as successful_calls,
        (count(*) FILTER(WHERE duration=0))::integer as failed_calls
      FROM json_populate_recordset(null::billing.cdr_v2,_j_data)
      WHERE dialpeer_id is not null AND duration is not null AND duration >= 0 /* Negative duration should not exists */
      GROUP BY dialpeer_id
    LOOP
      perform runtime_stats.update_dp(
        v_dp_stats_data.dialpeer_id,
        v_dp_stats_data.calls,
        v_dp_stats_data.successful_calls,
        v_dp_stats_data.failed_calls,
        v_dp_stats_data.duration
      );
    END LOOP;

    FOR v_gw_stats_data IN
      SELECT
        term_gw_id,
        sum(duration)::integer as duration,
        count(*)::integer as calls,
        (count(*) FILTER(WHERE duration>0))::integer as successful_calls,
        (count(*) FILTER(WHERE duration=0))::integer as failed_calls
      FROM json_populate_recordset(null::billing.cdr_v2,_j_data)
      WHERE term_gw_id is not null AND duration is not null AND duration >= 0 /* Negative duration should not exists */
      GROUP BY term_gw_id
    LOOP
      perform runtime_stats.update_gw(
        v_gw_stats_data.term_gw_id,
        v_gw_stats_data.calls,
        v_gw_stats_data.successful_calls,
        v_gw_stats_data.failed_calls,
        v_gw_stats_data.duration
      );
    END LOOP;

END;
$$;
    }
  end
end
