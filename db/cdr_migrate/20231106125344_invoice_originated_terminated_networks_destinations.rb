class InvoiceOriginatedTerminatedNetworksDestinations < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      DROP FUNCTION IF EXISTS billing.invoice_generate(integer)
    }

    execute %q{
      DROP FUNCTION IF EXISTS billing.invoice_generate(integer, integer, boolean, timestamp without time zone, timestamp without time zone)
    }

    execute %q{
      ALTER TABLE billing.invoice_networks RENAME TO invoice_originated_networks;

      ALTER TABLE billing.invoice_originated_networks
          DROP COLUMN first_successful_call_at,
          DROP COLUMN last_successful_call_at;

      ALTER INDEX invoice_networks_invoice_id_idx RENAME TO invoice_originated_networks_invoice_id_idx;

      ALTER TABLE billing.invoice_originated_networks
          RENAME CONSTRAINT invoice_networks_invoice_id_fkey TO invoice_originated_networks_invoice_id_fkey;

      ALTER SEQUENCE billing.invoice_networks_id_seq RENAME TO invoice_originated_networks_id_seq;
    }

    execute %q{
      CREATE TABLE billing.invoice_terminated_networks (
          id bigserial PRIMARY KEY,
          country_id integer,
          network_id integer,
          rate numeric,
          calls_count bigint,
          calls_duration bigint,
          amount numeric,
          invoice_id integer NOT NULL,
          first_call_at timestamp with time zone,
          last_call_at timestamp with time zone,
          successful_calls_count bigint,
          billing_duration bigint
      );

      CREATE INDEX invoice_terminated_networks_invoice_id_idx ON billing.invoice_terminated_networks USING btree (invoice_id);

      ALTER TABLE ONLY billing.invoice_terminated_networks
          ADD CONSTRAINT invoice_terminated_networks_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES billing.invoices(id);

      insert into billing.invoice_terminated_networks(
        country_id, network_id, rate, calls_count,
        calls_duration, amount, invoice_id,
        first_call_at, last_call_at, successful_calls_count, billing_duration)
      SELECT country_id, network_id, rate, calls_count,
        calls_duration, amount, invoice_id,
        first_call_at, last_call_at, successful_calls_count, billing_duration
      from billing.invoice_originated_networks where invoice_id in ( select id from billing.invoices where vendor_invoice);
      delete from billing.invoice_originated_networks where invoice_id in ( select id from billing.invoices where vendor_invoice);
    }

    execute %q{
      ALTER TABLE billing.invoice_destinations RENAME TO invoice_originated_destinations;

      ALTER TABLE billing.invoice_originated_destinations
          DROP COLUMN first_successful_call_at,
          DROP COLUMN last_successful_call_at;

      ALTER INDEX invoice_destinations_invoice_id_idx RENAME TO invoice_originated_destinations_invoice_id_idx;

      ALTER TABLE billing.invoice_originated_destinations
          RENAME CONSTRAINT invoice_destinations_invoice_id_fkey TO invoice_originated_destinations_invoice_id_fkey;

      ALTER SEQUENCE billing.invoice_destinations_id_seq RENAME TO invoice_originated_destinations_id_seq;
    }

    execute %q{
      CREATE TABLE billing.invoice_terminated_destinations (
          id bigserial PRIMARY KEY,
          dst_prefix character varying,
          country_id integer,
          network_id integer,
          rate numeric,
          calls_count bigint,
          calls_duration bigint,
          amount numeric,
          invoice_id integer NOT NULL,
          first_call_at timestamp with time zone,
          last_call_at timestamp with time zone,
          successful_calls_count bigint,
          billing_duration bigint
      );

      CREATE INDEX invoice_terminated_destinations_invoice_id_idx ON billing.invoice_terminated_destinations USING btree (invoice_id);

      ALTER TABLE ONLY billing.invoice_terminated_destinations
          ADD CONSTRAINT invoice_terminated_destinations_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES billing.invoices(id);

      insert into billing.invoice_terminated_destinations (
          dst_prefix, country_id, network_id,
          rate, calls_count, calls_duration, amount, invoice_id,
          first_call_at, last_call_at,
          successful_calls_count, billing_duration )
      SELECT dst_prefix, country_id, network_id,
          rate, calls_count, calls_duration, amount, invoice_id,
          first_call_at, last_call_at,
          successful_calls_count, billing_duration
      from billing.invoice_originated_destinations where invoice_id in ( select id from billing.invoices where vendor_invoice);
      delete from billing.invoice_originated_destinations where invoice_id in ( select id from billing.invoices where vendor_invoice);

    }

    execute %q{
      ALTER TABLE billing.invoice_documents DROP COLUMN csv_data
    }
    execute %q{
      ALTER TABLE billing.invoice_documents DROP COLUMN xls_data;


      UPDATE billing.invoices set
        terminated_amount = originated_amount,
        terminated_calls_count = originated_calls_count,
        terminated_calls_duration = originated_calls_duration,
        terminated_successful_calls_count = originated_successful_calls_count,
        terminated_billing_duration = originated_billing_duration
      where vendor_invoice;
      UPDATE billing.invoices set
        originated_amount = 0,
        originated_calls_count = 0,
        originated_calls_duration = 0,
        originated_successful_calls_count = 0,
        originated_billing_duration = 0
      where vendor_invoice;

      ALTER TABLE billing.invoices DROP COLUMN vendor_invoice;
    }
  end

  def down
    execute %q{
      ALTER TABLE billing.invoices ADD COLUMN vendor_invoice boolean NOT NULL DEFAULT false;
      ALTER TABLE billing.invoice_originated_networks RENAME TO invoice_networks;

      ALTER TABLE billing.invoice_networks
          ADD COLUMN first_successful_call_at timestamp with time zone,
          ADD COLUMN last_successful_call_at timestamp with time zone;

      ALTER INDEX invoice_originated_networks_invoice_id_idx RENAME TO invoice_networks_invoice_id_idx;

      ALTER TABLE billing.invoice_networks
          RENAME CONSTRAINT invoice_originated_networks_invoice_id_fkey TO invoice_networks_invoice_id_fkey;

      ALTER SEQUENCE billing.invoice_originated_networks_id_seq RENAME TO invoice_networks_id_seq;
    }

    execute %q{
      DROP TABLE billing.invoice_terminated_networks
    }

    execute %q{
      ALTER TABLE billing.invoice_originated_destinations RENAME TO invoice_destinations;

      ALTER TABLE billing.invoice_destinations
          ADD COLUMN first_successful_call_at timestamp with time zone,
          ADD COLUMN last_successful_call_at timestamp with time zone;

      ALTER INDEX invoice_originated_destinations_invoice_id_idx RENAME TO invoice_destinations_invoice_id_idx;

      ALTER TABLE billing.invoice_destinations
          RENAME CONSTRAINT invoice_originated_destinations_invoice_id_fkey TO invoice_destinations_invoice_id_fkey;

      ALTER SEQUENCE billing.invoice_originated_destinations_id_seq RENAME TO invoice_destinations_id_seq;
    }

    execute %q{
      DROP TABLE billing.invoice_terminated_destinations
    }

    execute %q{
      ALTER TABLE billing.invoice_documents
          ADD COLUMN csv_data bytea,
          ADD COLUMN xls_data bytea
    }

    execute %q{
      CREATE OR REPLACE FUNCTION billing.invoice_generate(i_id integer) RETURNS void
      LANGUAGE plpgsql
      AS $$
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
$$;
    }

    execute %q{
      CREATE OR REPLACE FUNCTION billing.invoice_generate(i_contractor_id integer, i_account_id integer, i_vendor_flag boolean, i_startdate timestamp without time zone, i_enddate timestamp without time zone) RETURNS integer
      LANGUAGE plpgsql
      AS $$
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
$$;
    }
  end
end
