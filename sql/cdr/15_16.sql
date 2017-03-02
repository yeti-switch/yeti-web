begin;
insert into sys.version(number,comment) values(16,'CDR partitioning FIX');

CREATE OR REPLACE FUNCTION sys.cdr_createtable(i_offset integer)
  RETURNS void AS
  $BODY$
DECLARE
v_tbname varchar;
v_ftbname varchar;
v_tdate varchar;
v_start varchar;
v_end varchar;
v_c integer;
v_sql varchar;

BEGIN
        -- get tablename for next month;
        v_tdate:=to_char(now()+'1 month'::interval - i_offset * '1 month'::interval ,'YYYYMM');
        v_start:=to_char(now()+'1 month'::interval - i_offset * '1 month'::interval ,'YYYY-MM-01');
        v_end:=to_char(now()+'2 month'::interval - i_offset * '1 month'::interval,'YYYY-MM-01');

        v_tbname:='cdr_'||v_tdate;
        v_ftbname:='cdr.'||v_tbname::varchar;

        -- CHECK if table exists
        SELECT into v_c count(*) from pg_tables where schemaname='cdr' and tablename=v_tbname;
        IF v_c>0 THEN
                RAISE NOTICE 'sys.cdr_createtable: next table % already created',v_tbname;
                RETURN;
        ELSE
                v_sql:='CREATE TABLE '||v_ftbname||'(
                CONSTRAINT '||v_tbname||'_time_start_check CHECK (
                        time_start >= '''||v_start||' 00:00:00+00''
                        AND time_start < '''||v_end||' 00:00:00+00''
                )
                ) INHERITS (cdr.cdr)';
                EXECUTE v_sql;
                v_sql:='ALTER TABLE '||v_ftbname||' ADD PRIMARY KEY(id)';
                EXECUTE v_sql;
                RAISE NOTICE 'sys.cdr_createtable: next table % creating started',v_tbname;
                PERFORM sys.cdr_reindex('cdr',v_tbname);
                -- update trigger
                INSERT INTO sys.cdr_tables(date_start,date_stop,"name",writable,readable) VALUES (v_start,v_end,v_ftbname,'t','t');
                PERFORM sys.cdrtable_tgr_reload();
        END IF;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 10000;



CREATE OR REPLACE FUNCTION sys.cdrtable_tgr_reload()
  RETURNS void AS
  $BODY$
DECLARE
v_tbname varchar;
v_sql1 varchar:='CREATE OR REPLACE FUNCTION cdr.cdr_i_tgf() RETURNS trigger AS $trg$
BEGIN  [MEAT]
RETURN NULL;
END; $trg$ LANGUAGE plpgsql VOLATILE COST 100';
--v_sql2 varchar:='ALTER FUNCTION cdrs.cdrs_i_tgf() OWNER TO accadmin;';
v_tb_row record;
v_meat varchar;
v_prfx varchar;
v_counter integer;
BEGIN
        v_meat:='';
        v_counter:='1';
        PERFORM * FROM sys.cdr_tables WHERE active;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'no tables for write data';
        end IF;
        FOR v_tb_row IN SELECT * FROM sys.cdr_tables WHERE active ORDER BY date_start LOOP
                IF v_counter=1 THEN
                        v_prfx='IF ';
                ELSE
                        v_prfx='ELSIF ';
                END IF;
                v_meat:=v_meat||v_prfx||'( NEW.time_start >= '''||v_tb_row.date_start||' 00:00:00+00'' AND NEW.time_start < '''||v_tb_row.date_stop||' 00:00:00+00'' ) THEN INSERT INTO '||v_tb_row.name||' VALUES (NEW.*);'|| E'\n';
                v_counter:=v_counter+1;
        END LOOP;
        v_meat:=v_meat||' ELSE '|| E'\n'||' RAISE EXCEPTION ''cdr.cdr_i_tg: time_start out of range.''; '||E'\n'||' END IF;';
        v_sql1:=REPLACE(v_sql1,'[MEAT]',v_meat);
        set standard_conforming_strings=on;
        EXECUTE v_sql1;
      --  EXECUTE v_sql2;
        RAISE NOTICE 'sys.cdrtable_tgr_reload: CDR trigger reloaded';
       -- RETURN 'OK';
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;



/* INVOICES */

CREATE TABLE billing.invoice_documents(
  id serial primary key,
  invoice_id integer not null references billing.invoices(id),
  data bytea,
  filename varchar not null
);

create unique index on billing.invoice_documents using btree(invoice_id);

alter table billing.invoices rename column first_cdr_date to first_call_date;
alter table billing.invoices rename column last_cdr_date to last_call_date;

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
                UPDATE billing.invoices SET amount=v_amount,calls_count=v_count,first_call_date=v_min_date,last_call_date=v_max_date WHERE id=v_id;
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


                UPDATE billing.invoices SET amount=v_amount,calls_count=v_count,first_call_date=v_min_date,last_call_date=v_max_date WHERE id=v_id;
        END IF;
RETURN v_id;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;



commit;