class AddCustomerAuthStats < ActiveRecord::Migration[6.1]
  def up
    execute %q{

    create table stats.customer_auth_stats(
      id bigserial primary key,
      customer_auth_id integer not null,
      timestamp timestamptz not null,
      duration integer not null default 0,
      customer_duration integer not null default 0,
      calls_count integer not null default 0,
      customer_price numeric not null default 0,
      customer_price_no_vat numeric not null default 0,
      vendor_price numeric not null default 0
    );

    create unique index on stats.customer_auth_stats(customer_auth_id,timestamp);

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
    if i_cdr.customer_acc_id is null or i_cdr.customer_acc_id=0 then
        return;
    end if;
    v_ts=date_trunc(v_agg_period,i_cdr.time_start);
    v_profit=coalesce(i_cdr.profit,0);

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

drop table stats.customer_auth_stats;

            }

  end
end
