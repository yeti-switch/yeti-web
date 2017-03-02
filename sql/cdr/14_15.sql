begin;
insert into sys.version(number,comment) values(15,'Invoices,Static routes');

ALTER TABLE billing.invoices add created_at timestamp with time zone not null default now();
update billing.invoices set created_at = start_date;

alter table billing.invoices rename COLUMN cdrs to calls_count;

CREATE TABLE billing.invoice_destinations(
  id bigserial primary key,
  dst_prefix varchar,
  country_id integer,
  network_id integer,
  rate numeric,
  calls_count bigint,
  calls_duration bigint,
  amount numeric,
  invoice_id integer not null references billing.invoices(id),
  first_call_at timestamptz,
  last_call_at TIMESTAMPTZ
);
CREATE INDEX ON billing.invoice_destinations USING btree (invoice_id );



CREATE OR REPLACE FUNCTION billing.invoice_remove(i_invoice_id integer)
  RETURNS void AS
$BODY$
DECLARE
v_vendor_flag boolean;
BEGIN
        SELECT into v_vendor_flag vendor_invoice from billing.invoices WHERE id=i_invoice_id;
        IF NOT FOUND THEN
               --RAISE EXCEPTION 'Already removed';
               RETURN;
        END IF;

        IF v_vendor_flag THEN
                UPdate cdr.cdr set vendor_invoice_id = NULL where vendor_invoice_id=i_invoice_id;
        ELSE
                UPdate cdr.cdr set customer_invoice_id = NULL where customer_invoice_id=i_invoice_id;
        END IF;

        delete from billing.invoice_destinations where invoice_id=i_invoice_id;
        DELETE FROM billing.invoices where id=i_invoice_id;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


-- Function: billing.invoice_generate(integer, integer, boolean, timestamp without time zone, timestamp without time zone)

-- DROP FUNCTION billing.invoice_generate(integer, integer, boolean, timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION billing.invoice_generate(
    i_contractor_id integer,
    i_account_id integer,
    i_vendor_flag boolean,
    i_startdate timestamp without time zone,
    i_enddate timestamp without time zone)
  RETURNS integer AS
$BODY$
DECLARE
v_id integer;
v_amount numeric;
v_count bigint;
v_min_date timestamp;
v_max_date timestamp;
BEGIN
        BEGIN
                INSERT into billing.invoices(contractor_id,account_id,start_date,end_date,amount,vendor_invoice,calls_count)
                        VALUES(i_contractor_id,i_account_id,i_startdate,i_enddate,0,i_vendor_flag,0) RETURNING id INTO v_id;
        EXCEPTION
                WHEN foreign_key_violation THEN
                        RAISE EXCEPTION 'billing.invoice_generate: account not found in this moment';
        END;

        if i_vendor_flag THEN
                PERFORM * FROM cdr.cdr WHERE vendor_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND vendor_invoice_id IS NOT NULL;
                IF FOUND THEN
                        RAISE EXCEPTION 'billing.invoice_generate: some vendor invoices already found for this interval';
                END IF;
                UPDATE cdr.cdr SET vendor_invoice_id=v_id WHERE vendor_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND vendor_invoice_id IS NULL;
                SELECT INTO v_count,v_amount,v_min_date,v_max_date
                        count(*),
                        COALESCE(sum(vendor_price),0),
                        min(time_start),
                        max(time_start)
                        from cdr.cdr
                        WHERE vendor_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND vendor_invoice_id =v_id;
                        RAISE NOTICE 'wer % - %',v_count,v_amount;
                UPDATE billing.invoices SET amount=v_amount,cdrs=v_count,first_cdr_date=v_min_date,last_cdr_date=v_max_date WHERE id=v_id;
        ELSE
                PERFORM * FROM cdr.cdr WHERE customer_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND customer_invoice_id IS NOT NULL;
                IF FOUND THEN
                        RAISE EXCEPTION 'billing.invoice_generate: some customer invoices already found for this interval';
                END IF;
                UPDATE cdr.cdr SET customer_invoice_id=v_id WHERE customer_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND customer_invoice_id IS NULL;

                /* we need rewrite this ot dynamic SQL to use partiotioning */
                insert into billing.invoice_destinations(country_id,network_id,rate,calls_count,calls_duration,amount,invoice_id,first_call_at,last_call_at)
                    select  dst_country_id,
                            dst_network_id,
                            destination_next_rate,
                            count(nullif(is_last_cdr,false)),
                            sum(duration),
                            sum(customer_price),
                            v_id,
                            min(time_start),
                            max(time_start)
                    from cdr.cdr
                    where customer_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND customer_invoice_id =v_id
                    group by dst_country_id,dst_network_id,destination_next_rate;

                SELECT INTO v_count,v_amount,v_min_date,v_max_date
                    coalesce(sum(calls_count),0),
                    COALESCE(sum(amount),0),
                    min(first_call_at),
                    max(last_call_at)
                from billing.invoice_destinations
                where invoice_id =v_id;


                UPDATE billing.invoices SET amount=v_amount,calls_count=v_count,first_cdr_date=v_min_date,last_cdr_date=v_max_date WHERE id=v_id;
        END IF;
RETURN v_id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

commit;