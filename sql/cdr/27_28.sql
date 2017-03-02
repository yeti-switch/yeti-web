begin;
insert into sys.version(number,comment) values(28,'Calls duration for invoice');


CREATE TABLE billing.invoice_states (
  id smallint primary key,
  name varchar not null unique
);

INSERT INTO  billing.invoice_states (id,name) VALUES (2,'Approved');
INSERT INTO  billing.invoice_states (id,name) VALUES (1,'Pending');

ALTER TABLE  billing.invoices
  add calls_duration bigint,
  add state_id SMALLINT not null default 1 REFERENCES billing.invoice_states(id);

UPDATE billing.invoices bi set calls_duration=coalesce((select sum(calls_duration) from billing.invoice_destinations where invoice_id=bi.id),0);

ALTER TABLE billing.invoices ALTER COLUMN calls_duration set NOT NULL ;


DROP FUNCTION billing.invoice_generate(integer, integer, boolean, timestamp with time zone, timestamp with time zone);

CREATE OR REPLACE FUNCTION billing.invoice_generate(i_id integer)
  RETURNS void AS
  $BODY$
DECLARE
v_id integer;
v_amount numeric;
v_count bigint;
v_duration bigint;
v_min_date timestamp;
v_max_date timestamp;
v_sql varchar;
v_invoice billing.invoices%rowtype;
BEGIN
    lock table billing.invoices in exclusive mode; -- see ticket #108
    select into strict v_invoice * from billing.invoices where id=i_id;

    if v_invoice.start_date is null then
        select into v_invoice.start_date end_date from billing.invoices where account_id=v_invoice.account_id order by end_date desc limit 1;
        if not found then
            RAise exception 'Can''t detect date start';
        end if;
    end if;

    if v_invoice.vendor_invoice then
        PERFORM * FROM cdr.cdr
            WHERE vendor_acc_id=v_invoice.account_id AND time_start>=v_invoice.start_date AND time_end<v_invoice.end_date AND vendor_invoice_id IS NOT NULL;
        IF FOUND THEN
            RAISE EXCEPTION 'billing.invoice_generate: some vendor invoices already found for this interval';
        END IF;

        execute format('UPDATE cdr.cdr SET vendor_invoice_id=%L
            WHERE vendor_acc_id =%L AND time_start>=%L AND time_end<%L AND vendor_invoice_id IS NULL',
            v_invoice.id, v_invoice.account_id, v_invoice.start_date, v_invoice.end_date
        );

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
                    group by dialpeer_prefix, dst_country_id, dst_network_id, dialpeer_next_rate',
                    v_invoice.id, v_invoice.account_id, v_invoice.start_date, v_invoice.end_date, v_invoice.id);

        SELECT INTO v_count, v_duration, v_amount, v_min_date, v_max_date
            coalesce(sum(calls_count),0),
            coalesce(sum(calls_duration),0),
            COALESCE(sum(amount),0),
            min(first_call_at),
            max(last_call_at)
        from billing.invoice_destinations
        where invoice_id =v_invoice.id;

        UPDATE billing.invoices
        SET amount=v_amount, calls_count=v_count, calls_duration=v_duration, first_call_date=v_min_date,last_call_date=v_max_date, start_date=v_invoice.start_date
        WHERE id=v_invoice.id;
    ELSE -- customer invoice generation
        PERFORM * FROM cdr.cdr
            WHERE customer_acc_id=v_invoice.account_id AND time_start>=v_invoice.start_date AND time_end<v_invoice.end_date AND customer_invoice_id IS NOT NULL;
        IF FOUND THEN
            RAISE EXCEPTION 'billing.invoice_generate: some customer invoices already found for this interval';
        END IF;

        execute format('UPDATE cdr.cdr SET customer_invoice_id=%L
            WHERE customer_acc_id =%L AND time_start>=%L AND time_end<%L AND customer_invoice_id IS NULL',
            v_invoice.id, v_invoice.account_id, v_invoice.start_date, v_invoice.end_date
        );

        execute format ('insert into billing.invoice_destinations(
            dst_prefix,country_id,network_id,rate,calls_count,calls_duration,amount,invoice_id,first_call_at,last_call_at
            ) select  destination_prefix,
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
                    group by destination_prefix, dst_country_id, dst_network_id, destination_next_rate',
                    v_invoice.id, v_invoice.account_id, v_invoice.start_date, v_invoice.end_date, v_invoice.id);

        SELECT INTO v_count,v_duration,v_amount,v_min_date,v_max_date
            coalesce(sum(calls_count),0),
            coalesce(sum(calls_duration),0),
            COALESCE(sum(amount),0),
            min(first_call_at),
            max(last_call_at)
        from billing.invoice_destinations
        where invoice_id =v_invoice.id;

        UPDATE billing.invoices
        SET amount=v_amount,calls_count=v_count,calls_duration=v_duration, first_call_date=v_min_date,last_call_date=v_max_date, start_date=v_invoice.start_date
        WHERE id=v_invoice.id;
        END IF;

RETURN;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

commit;