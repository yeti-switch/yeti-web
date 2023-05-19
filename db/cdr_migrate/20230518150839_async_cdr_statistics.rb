class AsyncCdrStatistics < ActiveRecord::Migration[7.0]
  def up
    execute %q{

select pgq.create_queue('async_cdr_statistics');
select pgq.register_consumer('async_cdr_statistics', 'async_cdr_statistics');

create type switch.async_cdr_statistics_ty as (
    processed_records integer,
    data json
);

CREATE OR REPLACE FUNCTION switch.async_cdr_statistics() RETURNS switch.async_cdr_statistics_ty
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    v_batch_id bigint;
    v_batch_size integer;
    v_cdrs_json json;
    v_result switch.async_cdr_statistics_ty;
BEGIN
    v_batch_id = pgq.next_batch('async_cdr_statistics','async_cdr_statistics');
    if v_batch_id is null then
        -- no events, sleeping
        v_result.processed_records = null;
        RETURN v_result;
    end if;

    select into v_cdrs_json, v_batch_size json_agg(ev_data::json), count(*) from pgq.get_batch_events(v_batch_id);

    perform switch.process_cdr_statistics(v_cdrs_json);

    perform pgq.finish_batch(v_batch_id);
    v_result.processed_records = v_batch_size;
    RETURN v_result;
END;
$$;


CREATE OR REPLACE FUNCTION switch.process_cdr_statistics(i_cdrs json) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    v_agg_period varchar not null default 'minute';
    v_ts timestamp;
    v_cas_data record;
    v_customer_data record;
    v_vendor_data record;
BEGIN

    for v_cas_data in
        select
            date_trunc('hour', time_start) as ts,
            customer_auth_id,
            coalesce(sum(duration),0) as duration,
            coalesce(sum(customer_duration),0) as customer_duration,
            count(*) as count,
            coalesce(sum(vendor_price),0) as vendor_price,
            coalesce(sum(customer_price),0) as customer_price,
            coalesce(sum(customer_price_no_vat),0) as customer_price_no_vat
        from json_populate_recordset(null::cdr.cdr, i_cdrs)
        where customer_auth_id is not null
        group by customer_auth_id, date_trunc('hour', time_start)
    loop
        update stats.customer_auth_stats set
            duration = duration + v_cas_data.duration,
            customer_duration = customer_duration + v_cas_data.customer_duration,
            calls_count = calls_count + v_cas_data.count,
            customer_price = customer_price + v_cas_data.customer_price,
            customer_price_no_vat = customer_price_no_vat + v_cas_data.customer_price_no_vat,
            vendor_price = vendor_price + v_cas_data.vendor_price
        where customer_auth_id = v_cas_data.customer_auth_id and timestamp = v_cas_data.ts;
        if not found then
            insert into stats.customer_auth_stats(
                timestamp, customer_auth_id,
                duration, customer_duration, calls_count,
                customer_price, customer_price_no_vat, vendor_price)
            values(
                v_cas_data.ts, v_cas_data.customer_auth_id,
                v_cas_data.duration, v_cas_data.customer_duration, v_cas_data.count,
                v_cas_data.customer_price, v_cas_data.customer_price_no_vat, v_cas_data.vendor_price
            );
        end if;
    end loop;

    for v_customer_data in
         select
            date_trunc(v_agg_period, time_start) ts,
            customer_acc_id,
            coalesce(sum(duration),0) as duration,
            coalesce(sum(customer_duration),0) as customer_duration,
            count(*) as count,
            coalesce(sum(customer_price),0) as customer_price,
            coalesce(sum(customer_price_no_vat),0) as customer_price_no_vat,
            coalesce(sum(profit),0) as profit
        from json_populate_recordset(null::cdr.cdr, i_cdrs)
        where customer_acc_id is not null
        group by customer_acc_id, date_trunc(v_agg_period, time_start)
    loop
        update stats.traffic_customer_accounts set
            duration = duration + v_customer_data.duration,
            count = count + v_customer_data.count,
            amount = amount + v_customer_data.customer_price,
            profit = profit + v_customer_data.profit
        where account_id = v_customer_data.customer_acc_id and timestamp = v_customer_data.ts;
        if not found then
            insert into stats.traffic_customer_accounts(
                timestamp, account_id,
                duration, count, amount, profit)
            values(
                v_customer_data.ts, v_customer_data.customer_acc_id,
                v_customer_data.duration, v_customer_data.count, v_customer_data.customer_price, v_customer_data.profit);
        end if;
    end loop;

    for v_vendor_data in
        select
            date_trunc(v_agg_period, time_start) ts,
            vendor_acc_id,
            coalesce(sum(duration),0) as duration,
            count(*) as count,
            coalesce(sum(vendor_price),0) as vendor_price,
            coalesce(sum(profit),0) as profit
        from json_populate_recordset(null::cdr.cdr, i_cdrs)
        where vendor_acc_id is not null
        group by vendor_acc_id, date_trunc(v_agg_period, time_start)
    loop
        update stats.traffic_vendor_accounts set
            duration = duration + v_vendor_data.duration,
            count = count + v_vendor_data.count,
            amount = amount + v_vendor_data.vendor_price,
            profit = profit + v_vendor_data.profit
        where account_id = v_vendor_data.vendor_acc_id and timestamp = v_vendor_data.ts;
        if not found then
            insert into stats.traffic_vendor_accounts(
                timestamp, account_id,
                duration, count, amount, profit)
            values(
                v_vendor_data.ts, v_vendor_data.vendor_acc_id,
                v_vendor_data.duration, v_vendor_data.count, v_vendor_data.vendor_price, v_vendor_data.profit
            );
        end if;
    end loop;

    insert into stats.termination_quality_stats(
        dialpeer_id, destination_id, gateway_id, time_start, success, duration, pdd, early_media_present)
    select
        dialpeer_id, destination_id, term_gw_id, time_start, success, duration, pdd, early_media_present
    from json_populate_recordset(null::cdr.cdr, i_cdrs)
    where dialpeer_id is not null and destination_id is not null and term_gw_id is not null;

    RETURN 0;
END;
$$;


CREATE OR REPLACE FUNCTION stats.update_rt_stats(i_cdr cdr.cdr) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
BEGIN
    perform pgq.insert_event('async_cdr_statistics', 'cdr', event.serialize(i_cdr), null, null, null, null);
    RETURN ;
END;
$$;

}
  end

    def down
    execute %q{



CREATE or replace FUNCTION stats.update_rt_stats(i_cdr cdr.cdr) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    v_agg_period varchar:='minute';
    v_ts timestamp;
    v_profit numeric;

BEGIN
    if i_cdr.customer_acc_id is null or i_cdr.customer_acc_id=0 or i_cdr.customer_auth_id is null or i_cdr.customer_auth_id=0 then
        return;
    end if;
    v_profit=coalesce(i_cdr.profit,0);

    v_ts=date_trunc('hour',i_cdr.time_start);
    update stats.customer_auth_stats set
        duration = duration + coalesce(i_cdr.duration, 0),
        customer_duration = customer_duration + coalesce(i_cdr.customer_duration, 0),
        calls_count = calls_count + 1,
        customer_price = customer_price + coalesce(i_cdr.customer_price, 0),
        customer_price_no_vat = customer_price_no_vat + coalesce(i_cdr.customer_price_no_vat, 0),
        vendor_price = vendor_price + coalesce(i_cdr.vendor_price, 0)
    where customer_auth_id = i_cdr.customer_auth_id and timestamp = v_ts;
    if not found then
        begin
            insert into stats.customer_auth_stats(
                timestamp, customer_auth_id, duration, customer_duration, calls_count, customer_price, customer_price_no_vat, vendor_price)
            values(
              v_ts,
              i_cdr.customer_auth_id,
              coalesce(i_cdr.duration, 0),
              coalesce(i_cdr.customer_duration, 0),
              1,
              coalesce(i_cdr.customer_price, 0),
              coalesce(i_cdr.customer_price_no_vat, 0),
              coalesce(i_cdr.vendor_price, 0)
            );
        exception
            when unique_violation then
              update stats.customer_auth_stats set
                duration = duration + coalesce(i_cdr.duration, 0),
                customer_duration = customer_duration + coalesce(i_cdr.customer_duration, 0),
                calls_count = calls_count + 1,
                customer_price = customer_price + coalesce(i_cdr.customer_price, 0),
                customer_price_no_vat = customer_price_no_vat + coalesce(i_cdr.customer_price_no_vat, 0),
                vendor_price = vendor_price + coalesce(i_cdr.vendor_price, 0)
              where customer_auth_id = i_cdr.customer_auth_id and timestamp = v_ts;
        end;
    end if;

    v_ts=date_trunc(v_agg_period,i_cdr.time_start);
    update stats.traffic_customer_accounts set
        duration=duration+coalesce(i_cdr.duration,0),
        count=count+1,
        amount=amount+coalesce(i_cdr.customer_price),
        profit=profit+v_profit
    where account_id=i_cdr.customer_acc_id and timestamp=v_ts;
    if not found then
        begin
            insert into stats.traffic_customer_accounts(timestamp,account_id,duration,count,amount,profit)
                values(v_ts,i_cdr.customer_acc_id,coalesce(i_cdr.duration,0),1,coalesce(i_cdr.customer_price),v_profit);
        exception
            when unique_violation then
                update stats.traffic_customer_accounts set
                    duration=duration+coalesce(i_cdr.duration,0),
                    count=count+1,
                    amount=amount+coalesce(i_cdr.customer_price),
                    profit=profit+v_profit
                where account_id=i_cdr.customer_acc_id and timestamp=v_ts;
        end;
    end if;



    if i_cdr.vendor_acc_id is null or i_cdr.vendor_acc_id=0 then
        return;
    end if;
    update stats.traffic_vendor_accounts set
        duration=duration+coalesce(i_cdr.duration,0),
        count=count+1,
        amount=amount+coalesce(i_cdr.vendor_price),
        profit=profit+v_profit
    where account_id=i_cdr.vendor_acc_id and timestamp=v_ts;
    if not found then
        begin
            insert into stats.traffic_vendor_accounts(timestamp,account_id,duration,count,amount,profit)
                values(v_ts,i_cdr.vendor_acc_id,coalesce(i_cdr.duration,0),1,coalesce(i_cdr.vendor_price),v_profit);
        exception
            when unique_violation then
                update stats.traffic_vendor_accounts set
                    duration=duration+coalesce(i_cdr.duration,0),
                    count=count+1,
                    amount=amount+coalesce(i_cdr.vendor_price),
                    profit=profit+v_profit
                where account_id=i_cdr.vendor_acc_id and timestamp=v_ts;
        end;
    end if;

    insert into stats.termination_quality_stats(dialpeer_id,destination_id, gateway_id,time_start,success,duration,pdd,early_media_present)
        values(i_cdr.dialpeer_id, i_cdr.destination_id, i_cdr.term_gw_id, i_cdr.time_start, i_cdr.success, i_cdr.duration, i_cdr.pdd, i_cdr.early_media_present);


    RETURN ;
END;
$$;

select pgq.unregister_consumer('async_cdr_statistics', 'async_cdr_statistics');
select pgq.drop_queue('async_cdr_statistics');

DROP FUNCTION switch.async_cdr_statistics();
DROP FUNCTION switch.process_cdr_statistics(json);

drop type switch.async_cdr_statistics_ty;

}

    end
end


