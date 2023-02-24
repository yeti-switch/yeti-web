class ImproveCdrBilling < ActiveRecord::Migration[6.1]

  def up
        execute %q{

drop FUNCTION runtime_stats.update_dp(i_destination_id bigint, i_dialpeer_id bigint, i_success boolean, i_duration integer);

CREATE or replace FUNCTION runtime_stats.update_dp(
  i_dialpeer_id bigint,
  i_calls integer,
  i_successful_calls integer,
  i_failed_calls integer,
  i_duration integer
) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
BEGIN
        if i_dialpeer_id is null OR i_calls is null OR i_successful_calls is null OR i_failed_calls is null OR i_duration IS NULL then
            return;
        end if;

        UPDATE runtime_stats.dialpeers_stats SET
          calls = calls + i_calls,
          calls_success = calls_success + i_successful_calls,
          calls_fail = calls_fail + i_failed_calls,
          total_duration = total_duration + i_duration,
          acd = (total_duration + i_duration )::real/(calls_success + i_successful_calls)::real,
          asr = (calls_success + i_successful_calls)::real/(calls + i_calls)::real
        WHERE dialpeer_id = i_dialpeer_id;
        IF NOT FOUND THEN
          /* Unique violation possible there in if multiple CDR billed in parallel. This case is not valid, let it fail */
          INSERT into runtime_stats.dialpeers_stats(
            dialpeer_id,
            calls,
            calls_success,
            calls_fail,
            total_duration,
            acd,
            asr
          ) VALUES(
            i_dialpeer_id,
            i_calls,
            i_successful_calls,
            i_failed_calls,
            i_duration,
            i_duration::real/i_successful_calls::real,
            i_successful_calls::real/i_calls::real
          );
        END IF;
END;
$$;

drop FUNCTION runtime_stats.update_gw(i_orig_gw_id integer, i_term_gw_id integer, i_success boolean, i_duration integer);
CREATE or replace FUNCTION runtime_stats.update_gw(
  i_gw_id bigint,
  i_calls integer,
  i_successful_calls integer,
  i_failed_calls integer,
  i_duration integer
)
 RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$

DECLARE

BEGIN

    if i_gw_id is null OR i_calls is null OR i_successful_calls is null OR i_failed_calls is null OR i_duration IS NULL then
      return;
    end if;

    UPDATE runtime_stats.gateways_stats SET
      calls = calls + i_calls,
      calls_success = calls_success + i_successful_calls,
      calls_fail = calls_fail + i_failed_calls,
      total_duration = total_duration + i_duration,
      acd = (total_duration + i_duration )::real/(calls_success + i_successful_calls)::real,
      asr = (calls_success + i_successful_calls)::real/(calls + i_calls)::real
    WHERE gateway_id = i_gw_id;
    IF NOT FOUND THEN
      /* Unique violation possible there in if multiple CDR billed in parallel. This case is not valid, let it fail */
      INSERT into runtime_stats.gateways_stats(
        gateway_id,
        calls,
        calls_success,
        calls_fail,
        total_duration,
        acd,
        asr
      ) VALUES(
        i_gw_id,
        i_calls,
        i_successful_calls,
        i_failed_calls,
        i_duration,
        i_duration::real/i_successful_calls::real,
        i_successful_calls::real/i_calls::real
      );
    END IF;
END;
$$;




    CREATE or replace FUNCTION billing.bill_cdr_batch(i_batch_id bigint, i_data text, i_data_version integer DEFAULT 2) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    v_batch_data billing.cdr_v2;
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
      where customer_acc_id is not null AND customer_price > 0
      group by customer_acc_id, destination_reverse_billing
    LOOP
      IF v_c_acc_data.destination_reverse_billing IS NULL OR v_c_acc_data.destination_reverse_billing = false THEN
        UPDATE billing.accounts SET balance = balance - COALESCE(v_c_acc_data.customer_price,0) WHERE id = v_c_acc_data.customer_acc_id;
      ELSE
        UPDATE billing.accounts SET balance = balance + COALESCE(v_c_acc_data.customer_price,0) WHERE id = v_c_acc_data.customer_acc_id;
      END IF;
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

drop FUNCTION billing.bill_cdr(i_cdr billing.cdr_v2);

drop FUNCTION billing.unbill_cdr(i_cdr_id bigint);
            }
  end


  def down
    execute %q{


drop FUNCTION runtime_stats.update_dp(
  i_dialpeer_id bigint,
  i_calls integer,
  i_successful_calls integer,
  i_failed_calls integer,
  i_duration integer
);

drop FUNCTION runtime_stats.update_gw(
  i_gw_id bigint,
  i_calls integer,
  i_successful_calls integer,
  i_failed_calls integer,
  i_duration integer
);


CREATE or replace FUNCTION runtime_stats.update_dp(i_destination_id bigint, i_dialpeer_id bigint, i_success boolean, i_duration integer) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$

DECLARE
i integer;
v_id bigint;
v_success integer;
v_duration integer;
BEGIN
        if i_destination_id is null or i_dialpeer_id is null or i_destination_id=0 or i_dialpeer_id =0 then
            return;
        end if;

        v_success=i_success::integer;
        IF i_success THEN
                v_duration=i_duration;
        ELSE
                v_duration=0;
        END IF;
        UPDATE runtime_stats.dialpeers_stats SET
                calls=calls+1,calls_success=calls_success+v_success,calls_fail=calls_fail+(1-v_success),
                total_duration=total_duration+v_duration,
                acd=(total_duration+v_duration)::real/(calls+1)::real,
                asr=(calls_success+v_success)::real/(calls+1)::real
        WHERE dialpeer_id=i_dialpeer_id;
        IF NOT FOUND THEN
                -- we can get lost update in this case if row deleted in concurrent transaction. but this is minor issue;
                BEGIN
                        INSERT into runtime_stats.dialpeers_stats(dialpeer_id,calls,calls_success,calls_fail,total_duration,acd,asr)
                        VALUES(i_dialpeer_id,1,v_success,1-v_success,v_duration,v_duration::real/1,v_success::real/1);
                EXCEPTION
                        WHEN unique_violation THEN
                                UPDATE runtime_stats.dialpeers_stats SET
                                calls=calls+1,calls_success=calls_success+v_success,calls_fail=calls_fail+(1-v_success),
                                total_duration=total_duration+v_duration,
                                acd=(total_duration+v_duration)::real/(calls+1)::real,
                                asr=(calls_success+v_success)::real/(calls+1)::real
                                WHERE dialpeer_id=i_dialpeer_id;
                END;
        END IF;
END;
$$;

CREATE or replace FUNCTION runtime_stats.update_gw(i_orig_gw_id integer, i_term_gw_id integer, i_success boolean, i_duration integer) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$

DECLARE
i integer;
v_id bigint;
v_success integer;
v_duration integer;
BEGIN
    if i_term_gw_id is null or i_term_gw_id is null then
        return;
    end if;
        v_success=i_success::integer;
        IF i_success THEN
                v_duration=i_duration;
        ELSE
                v_duration=0;
        END IF;
        UPDATE runtime_stats.gateways_stats SET
                calls=calls+1,calls_success=calls_success+v_success,calls_fail=calls_fail+(1-v_success),
                total_duration=total_duration+v_duration,
                acd=(total_duration+v_duration)::real/(calls+1)::real,
                asr=(calls_success+v_success)::real/(calls+1)::real
        WHERE gateway_id=i_term_gw_id;
        IF NOT FOUND THEN
                -- we can get lost update in this case if row deleted in concurrent transaction. but this is minor issue;
                BEGIN
                        INSERT into runtime_stats.gateways_stats(gateway_id,calls,calls_success,calls_fail,total_duration,acd,asr)
                        VALUES(i_term_gw_id,1,v_success,1-v_success,v_duration,v_duration::real/1,v_success::real/1);
                EXCEPTION
                        WHEN unique_violation THEN
                                UPDATE runtime_stats.gateways_stats SET
                                calls=calls+1,calls_success=calls_success+v_success,calls_fail=calls_fail+(1-v_success),
                                total_duration=total_duration+v_duration,
                                acd=(total_duration+v_duration)::real/(calls+1)::real,
                                asr=(calls_success+v_success)::real/(calls+1)::real
                                WHERE gateway_id=i_term_gw_id;
                END;
        END IF;

END;
$$;

CREATE or replace FUNCTION billing.unbill_cdr(i_cdr_id bigint) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    v_cdr record;
BEGIN
        SELECT into v_cdr * from class4.cdrs WHERE id=i_cdr_id;
        PERFORM billing.bill_account(v_cdr.vendor_acc_id, +v_cdr.vendor_price::numeric);
        PERFORM billing.bill_account(v_cdr.customer_acc_id, -v_cdr.customer_price::numeric);
        delete from class4.cdrs where id=i_cdr_id;
END;
$$;


CREATE or replace FUNCTION billing.bill_cdr(i_cdr billing.cdr_v2) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
BEGIN
    if i_cdr.dialpeer_reverse_billing is not null and i_cdr.dialpeer_reverse_billing=true then
      UPDATE billing.accounts SET balance=balance-i_cdr.vendor_price WHERE id=i_cdr.vendor_acc_id;
    else
      UPDATE billing.accounts SET balance=balance+i_cdr.vendor_price WHERE id=i_cdr.vendor_acc_id;
    end if;

    if i_cdr.destination_reverse_billing is not null and i_cdr.destination_reverse_billing=true then
      UPDATE billing.accounts SET balance=balance+i_cdr.customer_price WHERE id=i_cdr.customer_acc_id;
    else
      UPDATE billing.accounts SET balance=balance-i_cdr.customer_price WHERE id=i_cdr.customer_acc_id;
    end if;

    return;
END;
$$;

    CREATE or replace FUNCTION billing.bill_cdr_batch(i_batch_id bigint, i_data text, i_data_version integer DEFAULT 2) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    v_batch_data billing.cdr_v2;
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

    for v_batch_data IN select * from json_populate_recordset(null::billing.cdr_v2,_j_data) LOOP
        if v_batch_data.customer_price >0  or v_batch_data.vendor_price>0 then
            perform billing.bill_cdr(v_batch_data);
        end if;
        -- update runtime statistics

        perform runtime_stats.update_dp(v_batch_data.destination_id,v_batch_data.dialpeer_id,
            v_batch_data.success,v_batch_data.duration
            );

        perform runtime_stats.update_gw(v_batch_data.orig_gw_id,v_batch_data.term_gw_id,
            v_batch_data.success,v_batch_data.duration
            );


    end loop;
END;
$$;

            }
  end

end
