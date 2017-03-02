begin;
insert into sys.version(number,comment) values(26,'Invoices fix');

-- Function: billing.invoice_generate(integer, integer, boolean, timestamp with time zone, timestamp with time zone)

-- DROP FUNCTION billing.invoice_generate(integer, integer, boolean, timestamp with time zone, timestamp with time zone);

CREATE OR REPLACE FUNCTION billing.invoice_generate(
    i_contractor_id integer,
    i_account_id integer,
    i_vendor_flag boolean,
    i_startdate timestamp with time zone,
    i_enddate timestamp with time zone)
  RETURNS integer AS
$BODY$
DECLARE
v_id integer;
v_amount numeric;
v_count bigint;
v_min_date timestamp;
v_max_date timestamp;
v_sql varchar;
BEGIN
    if i_startdate is null then
        select into i_startdate end_date from billing.invoices where account_id=i_account_id order by end_date desc limit 1;
        if not found then
            RAise exception 'Can''t detect date start';
        end if;
    end if;

    lock table billing.invoices IN EXCLUSIVE mode; -- see ticket #108
    INSERT into billing.invoices(contractor_id,account_id,start_date,end_date,amount,vendor_invoice,calls_count)
        VALUES(i_contractor_id,i_account_id,i_startdate,i_enddate,0,i_vendor_flag,0) RETURNING id INTO v_id;


        if i_vendor_flag THEN -- IF vendor
                PERFORM * FROM cdr.cdr WHERE vendor_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND vendor_invoice_id IS NOT NULL;
                IF FOUND THEN
                        RAISE EXCEPTION 'billing.invoice_generate: some vendor invoices already found for this interval';
                END IF;
                execute format('UPDATE cdr.cdr SET vendor_invoice_id=%L
                    WHERE vendor_acc_id =%L AND time_start>=%L AND time_end<%L AND vendor_invoice_id IS NULL', v_id, i_account_id, i_startdate, i_enddate);

                execute format('insert into billing.invoice_destinations(
                    dst_prefix,country_id,network_id,rate,calls_count,calls_duration,amount,invoice_id,first_call_at,last_call_at
                    ) select  dialpeer_prefix,
                            dst_country_id,
                            dst_network_id,
                            dialpeer_next_rate,
                            count(nullif(is_last_cdr,false)),
                            sum(duration),
                            sum(vendor_price),
                            %L,
                            min(time_start),
                            max(time_start)
                    from cdr.cdr
                    where vendor_acc_id =%L AND time_start>=%L AND time_end<%L AND vendor_invoice_id =%L
                    group by dialpeer_prefix, dst_country_id, dst_network_id, dialpeer_next_rate', v_id, i_account_id, i_startdate, i_enddate, v_id);

                SELECT INTO v_count, v_amount, v_min_date, v_max_date
                    coalesce(sum(calls_count),0),
                    COALESCE(sum(amount),0),
                    min(first_call_at),
                    max(last_call_at)
                    from billing.invoice_destinations
                    where invoice_id =v_id;

                RAISE NOTICE 'wer % - %',v_count,v_amount;

                UPDATE billing.invoices SET amount=v_amount,calls_count=v_count,first_call_date=v_min_date,last_call_date=v_max_date WHERE id=v_id;
        ELSE -- customer invoice generation
                PERFORM * FROM cdr.cdr WHERE customer_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND customer_invoice_id IS NOT NULL;
                IF FOUND THEN
                        RAISE EXCEPTION 'billing.invoice_generate: some customer invoices already found for this interval';
                END IF;
                execute format('UPDATE cdr.cdr SET customer_invoice_id=%L
                    WHERE customer_acc_id =%L AND time_start>=%L AND time_end<%L AND customer_invoice_id IS NULL', v_id, i_account_id, i_startdate, i_enddate);

                /* we need rewrite this ot dynamic SQL to use partiotioning */
                execute format ('insert into billing.invoice_destinations(
                    dst_prefix,country_id,network_id,rate,calls_count,calls_duration,amount,invoice_id,first_call_at,last_call_at)
                    select  destination_prefix,
                            dst_country_id,
                            dst_network_id,
                            destination_next_rate,
                            count(nullif(is_last_cdr,false)),
                            sum(duration),
                            sum(customer_price),
                            %L,
                            min(time_start),
                            max(time_start)
                    from cdr.cdr
                    where customer_acc_id =%L AND time_start>=%L AND time_end<%L AND customer_invoice_id =%L
                    group by destination_prefix, dst_country_id, dst_network_id, destination_next_rate',v_id, i_account_id, i_startdate, i_enddate, v_id);

                SELECT INTO v_count,v_amount,v_min_date,v_max_date
                    coalesce(sum(calls_count),0),
                    COALESCE(sum(amount),0),
                    min(first_call_at),
                    max(last_call_at)
                from billing.invoice_destinations
                where invoice_id =v_id;


                UPDATE billing.invoices SET amount=v_amount,calls_count=v_count,first_call_date=v_min_date,last_call_date=v_max_date WHERE id=v_id;
        END IF;
RETURN v_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

commit;