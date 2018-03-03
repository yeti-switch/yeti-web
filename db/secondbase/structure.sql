--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: billing; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA billing;


--
-- Name: cdr; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA cdr;


--
-- Name: event; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA event;


--
-- Name: pgq; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgq WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION pgq; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgq IS 'Generic queue for PostgreSQL';


--
-- Name: pgq_coop; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgq_coop WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION pgq_coop; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgq_coop IS 'Cooperative queue consuming for PgQ';


--
-- Name: pgq_ext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgq_ext WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION pgq_ext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgq_ext IS 'Target-side batch tracking infrastructure';


--
-- Name: pgq_node; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgq_node WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION pgq_node; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgq_node IS 'Cascaded queue infrastructure';


--
-- Name: reports; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA reports;


--
-- Name: stats; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA stats;


--
-- Name: switch; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA switch;


--
-- Name: sys; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA sys;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = billing, pg_catalog;

--
-- Name: cdr_v2; Type: TYPE; Schema: billing; Owner: -
--

CREATE TYPE cdr_v2 AS (
	id bigint,
	customer_id integer,
	vendor_id integer,
	customer_acc_id integer,
	vendor_acc_id integer,
	customer_auth_id integer,
	destination_id integer,
	dialpeer_id integer,
	orig_gw_id integer,
	term_gw_id integer,
	routing_group_id integer,
	rateplan_id integer,
	destination_next_rate numeric,
	destination_fee numeric,
	dialpeer_next_rate numeric,
	dialpeer_fee numeric,
	internal_disconnect_code integer,
	internal_disconnect_reason character varying,
	disconnect_initiator_id integer,
	customer_price numeric,
	vendor_price numeric,
	duration integer,
	success boolean,
	profit numeric,
	time_start timestamp without time zone,
	time_connect timestamp without time zone,
	time_end timestamp without time zone,
	lega_disconnect_code integer,
	lega_disconnect_reason character varying,
	legb_disconnect_code integer,
	legb_disconnect_reason character varying,
	src_prefix_in character varying,
	src_prefix_out character varying,
	dst_prefix_in character varying,
	dst_prefix_out character varying,
	destination_initial_interval integer,
	destination_next_interval integer,
	destination_initial_rate numeric,
	orig_call_id character varying,
	term_call_id character varying,
	local_tag character varying,
	from_domain character varying,
	destination_reverse_billing boolean,
	dialpeer_reverse_billing boolean
);


--
-- Name: interval_billing_data; Type: TYPE; Schema: billing; Owner: -
--

CREATE TYPE interval_billing_data AS (
	duration numeric,
	amount numeric,
	amount_no_vat numeric
);


SET search_path = switch, pg_catalog;

--
-- Name: dynamic_cdr_data_ty; Type: TYPE; Schema: switch; Owner: -
--

CREATE TYPE dynamic_cdr_data_ty AS (
	customer_id integer,
	customer_external_id bigint,
	vendor_id integer,
	vendor_external_id bigint,
	customer_acc_id integer,
	customer_acc_external_id bigint,
	customer_acc_vat numeric,
	vendor_acc_id integer,
	vendor_acc_external_id bigint,
	customer_auth_id integer,
	customer_auth_external_id bigint,
	destination_id bigint,
	destination_prefix character varying,
	dialpeer_id bigint,
	dialpeer_prefix character varying,
	orig_gw_id integer,
	orig_gw_external_id bigint,
	term_gw_id integer,
	term_gw_external_id bigint,
	routing_group_id integer,
	rateplan_id integer,
	destination_initial_rate numeric,
	destination_next_rate numeric,
	destination_initial_interval integer,
	destination_next_interval integer,
	destination_rate_policy_id smallint,
	dialpeer_initial_interval integer,
	dialpeer_next_interval integer,
	dialpeer_next_rate numeric,
	destination_fee numeric,
	dialpeer_initial_rate numeric,
	dialpeer_fee numeric,
	dst_prefix_in character varying,
	dst_prefix_out character varying,
	src_prefix_in character varying,
	src_prefix_out character varying,
	src_name_in character varying,
	src_name_out character varying,
	diversion_in character varying,
	diversion_out character varying,
	auth_orig_protocol_id smallint,
	auth_orig_ip inet,
	auth_orig_port integer,
	dst_country_id integer,
	dst_network_id integer,
	dst_prefix_routing character varying,
	src_prefix_routing character varying,
	routing_plan_id integer,
	lrn character varying,
	lnp_database_id smallint,
	from_domain character varying,
	to_domain character varying,
	ruri_domain character varying,
	src_area_id integer,
	dst_area_id integer,
	routing_tag_ids smallint[],
	pai_in character varying,
	ppi_in character varying,
	privacy_in character varying,
	rpid_in character varying,
	rpid_privacy_in character varying,
	pai_out character varying,
	ppi_out character varying,
	privacy_out character varying,
	rpid_out character varying,
	rpid_privacy_out character varying,
	customer_acc_check_balance boolean,
	destination_reverse_billing boolean,
	dialpeer_reverse_billing boolean
);


--
-- Name: rtp_stats_data_ty; Type: TYPE; Schema: switch; Owner: -
--

CREATE TYPE rtp_stats_data_ty AS (
	lega_rx_payloads character varying,
	lega_tx_payloads character varying,
	legb_rx_payloads character varying,
	legb_tx_payloads character varying,
	lega_rx_bytes integer,
	lega_tx_bytes integer,
	legb_rx_bytes integer,
	legb_tx_bytes integer,
	lega_rx_decode_errs integer,
	lega_rx_no_buf_errs integer,
	lega_rx_parse_errs integer,
	legb_rx_decode_errs integer,
	legb_rx_no_buf_errs integer,
	legb_rx_parse_errs integer
);


--
-- Name: time_data_ty; Type: TYPE; Schema: switch; Owner: -
--

CREATE TYPE time_data_ty AS (
	time_start double precision,
	leg_b_time double precision,
	time_connect double precision,
	time_end double precision,
	time_1xx double precision,
	time_18x double precision,
	time_limit integer
);


--
-- Name: versions_ty; Type: TYPE; Schema: switch; Owner: -
--

CREATE TYPE versions_ty AS (
	core character varying,
	yeti character varying,
	aleg character varying,
	bleg character varying
);


SET search_path = cdr, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: cdr; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr (
    id bigint NOT NULL,
    customer_id integer,
    vendor_id integer,
    customer_acc_id integer,
    vendor_acc_id integer,
    customer_auth_id integer,
    destination_id integer,
    dialpeer_id integer,
    orig_gw_id integer,
    term_gw_id integer,
    routing_group_id integer,
    rateplan_id integer,
    destination_next_rate numeric,
    destination_fee numeric,
    dialpeer_next_rate numeric,
    dialpeer_fee numeric,
    time_limit character varying,
    internal_disconnect_code integer,
    internal_disconnect_reason character varying,
    disconnect_initiator_id integer,
    customer_price numeric,
    vendor_price numeric,
    duration integer,
    success boolean,
    profit numeric,
    dst_prefix_in character varying,
    dst_prefix_out character varying,
    src_prefix_in character varying,
    src_prefix_out character varying,
    time_start timestamp with time zone,
    time_connect timestamp with time zone,
    time_end timestamp with time zone,
    sign_orig_ip character varying,
    sign_orig_port integer,
    sign_orig_local_ip character varying,
    sign_orig_local_port integer,
    sign_term_ip character varying,
    sign_term_port integer,
    sign_term_local_ip character varying,
    sign_term_local_port integer,
    orig_call_id character varying,
    term_call_id character varying,
    vendor_invoice_id integer,
    customer_invoice_id integer,
    local_tag character varying,
    destination_initial_rate numeric,
    dialpeer_initial_rate numeric,
    destination_initial_interval integer,
    destination_next_interval integer,
    dialpeer_initial_interval integer,
    dialpeer_next_interval integer,
    destination_rate_policy_id integer,
    routing_attempt integer,
    is_last_cdr boolean,
    lega_disconnect_code integer,
    lega_disconnect_reason character varying,
    pop_id integer,
    node_id integer,
    src_name_in character varying,
    src_name_out character varying,
    diversion_in character varying,
    diversion_out character varying,
    lega_rx_payloads character varying,
    lega_tx_payloads character varying,
    legb_rx_payloads character varying,
    legb_tx_payloads character varying,
    legb_disconnect_code integer,
    legb_disconnect_reason character varying,
    dump_level_id integer DEFAULT 0 NOT NULL,
    auth_orig_ip inet,
    auth_orig_port integer,
    lega_rx_bytes integer,
    lega_tx_bytes integer,
    legb_rx_bytes integer,
    legb_tx_bytes integer,
    global_tag character varying,
    dst_country_id integer,
    dst_network_id integer,
    lega_rx_decode_errs integer,
    lega_rx_no_buf_errs integer,
    lega_rx_parse_errs integer,
    legb_rx_decode_errs integer,
    legb_rx_no_buf_errs integer,
    legb_rx_parse_errs integer,
    src_prefix_routing character varying,
    dst_prefix_routing character varying,
    routing_plan_id integer,
    routing_delay double precision,
    pdd double precision,
    rtt double precision,
    early_media_present boolean,
    lnp_database_id smallint,
    lrn character varying,
    destination_prefix character varying,
    dialpeer_prefix character varying,
    audio_recorded boolean,
    ruri_domain character varying,
    to_domain character varying,
    from_domain character varying,
    routing_tag_id smallint,
    src_area_id integer,
    dst_area_id integer,
    auth_orig_transport_protocol_id smallint,
    sign_orig_transport_protocol_id smallint,
    sign_term_transport_protocol_id smallint,
    core_version character varying,
    yeti_version character varying,
    lega_user_agent character varying,
    legb_user_agent character varying,
    uuid uuid,
    pai_in character varying,
    ppi_in character varying,
    privacy_in character varying,
    rpid_in character varying,
    rpid_privacy_in character varying,
    pai_out character varying,
    ppi_out character varying,
    privacy_out character varying,
    rpid_out character varying,
    rpid_privacy_out character varying,
    destination_reverse_billing boolean,
    dialpeer_reverse_billing boolean,
    is_redirected boolean,
    customer_account_check_balance boolean,
    customer_external_id bigint,
    customer_auth_external_id bigint,
    customer_acc_vat numeric,
    customer_acc_external_id bigint,
    routing_tag_ids smallint[],
    vendor_external_id bigint,
    vendor_acc_external_id bigint,
    orig_gw_external_id bigint,
    term_gw_external_id bigint,
    failed_resource_type_id smallint,
    failed_resource_id bigint,
    customer_price_no_vat numeric,
    customer_duration integer,
    vendor_duration integer
);


SET search_path = billing, pg_catalog;

--
-- Name: bill_cdr(cdr.cdr); Type: FUNCTION; Schema: billing; Owner: -
--

CREATE FUNCTION bill_cdr(i_cdr cdr.cdr) RETURNS cdr.cdr
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    _v billing.interval_billing_data%rowtype;
BEGIN
    if i_cdr.duration>0 and i_cdr.success then  -- run billing.
        _v=billing.interval_billing(
            i_cdr.duration,
            i_cdr.destination_fee,
            i_cdr.destination_initial_rate,
            i_cdr.destination_next_rate,
            i_cdr.destination_initial_interval,
            i_cdr.destination_next_interval,
            i_cdr.customer_acc_vat);
         i_cdr.customer_price=_v.amount;
         i_cdr.customer_price_no_vat=_v.amount_no_vat;
         i_cdr.customer_duration=_v.duration;

         _v=billing.interval_billing(
            i_cdr.duration,
            i_cdr.dialpeer_fee,
            i_cdr.dialpeer_initial_rate,
            i_cdr.dialpeer_next_rate,
            i_cdr.dialpeer_initial_interval,
            i_cdr.dialpeer_next_interval,
            0);
         i_cdr.vendor_price=_v.amount;
         i_cdr.vendor_duration=_v.duration;
         i_cdr.profit=i_cdr.customer_price-i_cdr.vendor_price;
    else
        i_cdr.customer_price=0;
        i_cdr.vendor_price=0;
        i_cdr.profit=0;
    end if;
    RETURN i_cdr;
END;
$$;


--
-- Name: interval_billing(numeric, numeric, numeric, numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: billing; Owner: -
--

CREATE FUNCTION interval_billing(i_duration numeric, i_connection_fee numeric, i_initial_rate numeric, i_next_rate numeric, i_initial_interval numeric, i_next_interval numeric, i_vat numeric DEFAULT 0) RETURNS interval_billing_data
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    _v billing.interval_billing_data%rowtype;
BEGIN
    i_vat=COALESCE(i_vat,0);
    _v.amount_no_vat=i_connection_fee+
            i_initial_interval*i_initial_rate::numeric/60 + -- initial interval billing
            (i_duration>i_initial_interval)::boolean::integer * -- next interval billing enabled
            CEIL((i_duration-i_initial_interval)::numeric/i_next_interval) *-- next interval count
            i_next_interval * --interval len
            i_next_rate::numeric/60; -- next interval rate per second

    _v.amount=_v.amount_no_vat*(1+vat/100);

    _v.duration=i_initial_interval+(i_duration>i_initial_interval)::boolean::integer * CEIL((i_duration-i_initial_interval)::numeric/i_next_interval) *i_next_interval;

    RETURN _v;
END;
$$;


--
-- Name: invoice_generate(integer); Type: FUNCTION; Schema: billing; Owner: -
--

CREATE FUNCTION invoice_generate(i_id integer) RETURNS void
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


--
-- Name: invoice_generate(integer, integer, boolean, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: billing; Owner: -
--

CREATE FUNCTION invoice_generate(i_contractor_id integer, i_account_id integer, i_vendor_flag boolean, i_startdate timestamp without time zone, i_enddate timestamp without time zone) RETURNS integer
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


SET search_path = cdr, pg_catalog;

--
-- Name: cdr_i_tgf(); Type: FUNCTION; Schema: cdr; Owner: -
--

CREATE FUNCTION cdr_i_tgf() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN  IF ( NEW.time_start >= '2014-08-01 00:00:00+00' AND NEW.time_start < '2014-09-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201408 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2014-09-01 00:00:00+00' AND NEW.time_start < '2014-10-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201409 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2014-10-01 00:00:00+00' AND NEW.time_start < '2014-11-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201410 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2014-11-01 00:00:00+00' AND NEW.time_start < '2014-12-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201411 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2017-08-01 00:00:00+00' AND NEW.time_start < '2017-09-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201708 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2017-09-01 00:00:00+00' AND NEW.time_start < '2017-10-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201709 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2017-10-01 00:00:00+00' AND NEW.time_start < '2017-11-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201710 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2017-12-01 00:00:00+00' AND NEW.time_start < '2018-01-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201712 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2018-01-01 00:00:00+00' AND NEW.time_start < '2018-02-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201801 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2018-02-01 00:00:00+00' AND NEW.time_start < '2018-03-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201802 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2018-03-01 00:00:00+00' AND NEW.time_start < '2018-04-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201803 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2018-04-01 00:00:00+00' AND NEW.time_start < '2018-05-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201804 VALUES (NEW.*);
 ELSE 
 RAISE EXCEPTION 'cdr.cdr_i_tg: time_start out of range.'; 
 END IF;
RETURN NULL;
END; $$;


SET search_path = event, pg_catalog;

--
-- Name: billing_insert_event(text, anyelement); Type: FUNCTION; Schema: event; Owner: -
--

CREATE FUNCTION billing_insert_event(ev_type text, ev_data anyelement) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
begin
    return pgq.insert_event('cdr_billing', ev_type, event.serialize(ev_data), null, null, null, null);
end;
$$;


--
-- Name: serialize(anyelement); Type: FUNCTION; Schema: event; Owner: -
--

CREATE FUNCTION serialize(i_data anyelement) RETURNS text
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    _s text;
BEGIN
    _s:=row_to_json(i_data,false);
    return _s;
END;
$$;


SET search_path = reports, pg_catalog;

--
-- Name: cdr_interval_report(integer); Type: FUNCTION; Schema: reports; Owner: -
--

CREATE FUNCTION cdr_interval_report(i_id integer) RETURNS integer
    LANGUAGE plpgsql COST 3000
    AS $$
DECLARE
    v_rid integer;
    v_sql varchar;
    v_keys varchar:='';
    v_i integer:=0;
    v_field varchar;
    v_filter varchar;
    v_group_by varchar;
    v_agg varchar;
    v_tsp  varchar;
    v_tsp_ varchar;

    i_date_start timestamp;
    i_date_end timestamp;
    i_filter varchar;
    i_group_by varchar;
    i_interval_length integer;
    i_agg_id integer;
    i_agg_by varchar;
BEGIN
/*
    INSERT INTO reports.cdr_interval_report(created_at,date_start,date_end,
    filter,group_by,interval_length,aggregator_id,aggregate_by)
        values(now(),i_date_start,i_date_end,i_filter,i_group_by,i_interval_length,i_agg_id,i_agg_by) RETURNING id INTO v_rid;
*/
    select into v_rid,i_date_start, i_date_end, i_filter, i_group_by, i_interval_length, i_agg_id, i_agg_by
        id, date_start,date_end,filter,group_by,interval_length,aggregator_id,aggregate_by
        from reports.cdr_interval_report where id=i_id;

    /* build aggregation function */
    select into v_agg "name"||'('||i_agg_by||')' from reports.cdr_interval_report_aggrerator where id=i_agg_id;
    IF NOT FOUND or v_agg is null THEN
        RAISE exception 'reports.cdr_interval_report: can`t build aggregate function';
    end if;

    --selecv_date_agg
    --floor( (UNIX_TIMESTAMP(date) + TIME_TO_SEC(time))/300)*300 as period

    v_tsp='(date_part(''epoch'',time_start)/date_part(''epoch'','''||i_interval_length||' minutes''::interval))::bigint';
    v_tsp_='timestamp ''epoch'' + ('''||i_interval_length||' minutes''::interval * (date_part(''epoch'',time_start)/date_part(''epoch'','''||i_interval_length||' minutes''::interval))::bigint)';

    --SELECT TIMESTAMP 'epoch' + 1195374767 * INTERVAL '1 second'.

    For v_field in select * from regexp_split_to_table(i_group_by,',') LOOP
        v_i:=v_i+1;
        --IF regexp_match(v_field','w');
        v_keys:=v_keys||'key'||v_i::varchar||',';
    end loop;


    v_group_by=COALESCE(', '||NULLIF(i_group_by,''),'');
    v_filter=COALESCE('AND '||NULLIF(i_filter,''),'');

    v_sql:='
        INSERT INTO reports.cdr_interval_report_data(report_id,timestamp'||v_group_by||',aggregated_value)
        SELECT '||v_rid::varchar||','||v_tsp_||v_group_by||','||v_agg||'
            from cdr.cdr
            WHERE
                time_start>='''||i_date_start::varchar||'''
                AND time_start<'''||i_date_end::varchar||''' '||v_filter||'
            GROUP BY '||v_tsp||v_group_by;

    RAISE WARNING 'SQL: %',v_sql;
    EXECUTE v_sql;
    RETURN v_rid;

END;
$$;


SET search_path = stats, pg_catalog;

--
-- Name: update_rt_stats(cdr.cdr); Type: FUNCTION; Schema: stats; Owner: -
--

CREATE FUNCTION update_rt_stats(i_cdr cdr.cdr) RETURNS void
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


SET search_path = switch, pg_catalog;

--
-- Name: round(double precision); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION round(i_duration double precision) RETURNS integer
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    v_mode_id smallint;
BEGIN
    select into v_mode_id call_duration_round_mode_id from sys.config;

    case v_mode_id
        when 1 then -- math rules
            return i_duration::integer;
        when 2 then --always down
            return floor(i_duration);
        when 3 then --always up
            return ceil(i_duration);
        else -- fallback to math rules
            return i_duration::integer;
    end case;

END;
$$;


--
-- Name: writecdr(boolean, integer, integer, integer, boolean, smallint, character varying, integer, character varying, integer, smallint, character varying, integer, character varying, integer, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, integer, boolean, json, character varying, character varying, json, smallint, bigint, json, json, boolean, json); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_transport_protocol_id smallint, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_transport_protocol_id smallint, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id integer, i_audio_recorded boolean, i_rtp_stats_data json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_versions json, i_is_redirected boolean, i_dynamic json) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_cdr cdr.cdr%rowtype;
  v_billing_event billing.cdr_v2;

  v_rtp_stats_data switch.rtp_stats_data_ty;
  v_time_data switch.time_data_ty;
  v_version_data switch.versions_ty;
  v_dynamic switch.dynamic_cdr_data_ty;

  v_nozerolen boolean;
BEGIN
  --  raise warning 'type: % id: %', i_failed_resource_type_id, i_failed_resource_id;
  --  RAISE warning 'DTMF: %', i_dtmf_events;

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);
  v_version_data:=json_populate_record(null::switch.versions_ty, i_versions);
  v_dynamic:=json_populate_record(null::switch.dynamic_cdr_data_ty, i_dynamic);

  v_cdr.core_version=v_version_data.core;
  v_cdr.yeti_version=v_version_data.yeti;
  v_cdr.lega_user_agent=v_version_data.aleg;
  v_cdr.legb_user_agent=v_version_data.bleg;

  v_cdr.pop_id=i_pop_id;
  v_cdr.node_id=i_node_id;

  v_cdr.src_name_in:=v_dynamic.src_name_in;
  v_cdr.src_name_out:=v_dynamic.src_name_out;

  v_cdr.diversion_in:=v_dynamic.diversion_in;
  v_cdr.diversion_out:=v_dynamic.diversion_out;

  v_cdr.customer_id:=v_dynamic.customer_id;
  v_cdr.customer_external_id:=v_dynamic.customer_external_id;

  v_cdr.customer_acc_id:=v_dynamic.customer_acc_id;
  v_cdr.customer_account_check_balance=v_dynamic.customer_acc_check_balance;
  v_cdr.customer_acc_external_id=v_dynamic.customer_acc_external_id;
  v_cdr.customer_acc_vat:=v_dynamic.customer_acc_vat;

  v_cdr.customer_auth_id:=v_dynamic.customer_auth_id;
  v_cdr.customer_auth_external_id:=v_dynamic.customer_auth_external_id;

  v_cdr.vendor_id:=v_dynamic.vendor_id;
  v_cdr.vendor_external_id:=v_dynamic.vendor_external_id;
  v_cdr.vendor_id:=v_dynamic.vendor_acc_id;
  v_cdr.vendor_acc_external_id:=v_dynamic.vendor_acc_external_id;

  v_cdr.destination_id:=v_dynamic.destination_id;
  v_cdr.destination_prefix:=v_dynamic.destination_prefix;
  v_cdr.dialpeer_id:=v_dynamic.dialpeer_id;
  v_cdr.dialpeer_prefix:=v_dynamic.dialpeer_prefix;

  v_cdr.orig_gw_id:=v_dynamic.orig_gw_id;
  v_cdr.orig_gw_external_id:=v_dynamic.orig_gw_external_id;
  v_cdr.term_gw_id:=v_dynamic.term_gw_id;
  v_cdr.term_gw_external_id:=v_dynamic.term_gw_external_id;

  v_cdr.routing_group_id:=v_dynamic.routing_group_id;
  v_cdr.rateplan_id:=v_dynamic.rateplan_id;

  v_cdr.routing_attempt=i_routing_attempt;
  v_cdr.is_last_cdr=i_is_last_cdr;

  v_cdr.destination_initial_rate:=v_dynamic.destination_initial_rate::numeric;
  v_cdr.destination_next_rate:=v_dynamic.destination_next_rate::numeric;
  v_cdr.destination_initial_interval:=v_dynamic.destination_initial_interval;
  v_cdr.destination_next_interval:=v_dynamic.destination_next_interval;
  v_cdr.destination_fee:=v_dynamic.destination_fee;
  v_cdr.destination_rate_policy_id:=v_dynamic.destination_rate_policy_id;
  v_cdr.destination_reverse_billing=v_dynamic.destination_reverse_billing;

  v_cdr.dialpeer_initial_rate:=v_dynamic.dialpeer_initial_rate::numeric;
  v_cdr.dialpeer_next_rate:=v_dynamic.dialpeer_next_rate::numeric;
  v_cdr.dialpeer_initial_interval:=v_dynamic.dialpeer_initial_interval;
  v_cdr.dialpeer_next_interval:=v_dynamic.dialpeer_next_interval;
  v_cdr.dialpeer_fee:=v_dynamic.dialpeer_fee;
  v_cdr.dialpeer_reverse_billing=v_dynamic.dialpeer_reverse_billing;

  /* sockets addresses */
  v_cdr.sign_orig_transport_protocol_id=i_lega_transport_protocol_id;
  v_cdr.sign_orig_ip:=i_legA_remote_ip;
  v_cdr.sign_orig_port=i_legA_remote_port;
  v_cdr.sign_orig_local_ip:=i_legA_local_ip;
  v_cdr.sign_orig_local_port=i_legA_local_port;

  v_cdr.sign_term_transport_protocol_id=i_legb_transport_protocol_id;
  v_cdr.sign_term_ip:=i_legB_remote_ip;
  v_cdr.sign_term_port:=i_legB_remote_port;
  v_cdr.sign_term_local_ip:=i_legB_local_ip;
  v_cdr.sign_term_local_port:=i_legB_local_port;

  v_cdr.local_tag=i_local_tag;

  v_cdr.is_redirected=i_is_redirected;

  /* Call time data */
  v_cdr.time_start:=to_timestamp(v_time_data.time_start);
  v_cdr.time_limit:=v_time_data.time_limit;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect:=to_timestamp(v_time_data.time_connect);
    v_cdr.duration:=switch.round(v_time_data.time_end-v_time_data.time_connect); -- rounding
    v_nozerolen:=true;
    v_cdr.success=true;
  else
    v_cdr.time_connect:=NULL;
    v_cdr.duration:=0;
    v_nozerolen:=false;
    v_cdr.success=false;
  end if;
  v_cdr.routing_delay=(v_time_data.leg_b_time-v_time_data.time_start)::real;
  v_cdr.pdd=(coalesce(v_time_data.time_18x,v_time_data.time_connect)-v_time_data.time_start)::real;
  v_cdr.rtt=(coalesce(v_time_data.time_1xx,v_time_data.time_18x,v_time_data.time_connect)-v_time_data.leg_b_time)::real;
  v_cdr.early_media_present=i_early_media_present;

  v_cdr.time_end:=to_timestamp(v_time_data.time_end);

  -- DC processing
  v_cdr.legb_disconnect_code:=i_legb_disconnect_code;
  v_cdr.legb_disconnect_reason:=i_legb_disconnect_reason;
  v_cdr.disconnect_initiator_id:=i_disconnect_initiator;
  v_cdr.internal_disconnect_code:=i_internal_disconnect_code;
  v_cdr.internal_disconnect_reason:=i_internal_disconnect_reason;
  v_cdr.lega_disconnect_code:=i_lega_disconnect_code;
  v_cdr.lega_disconnect_reason:=i_lega_disconnect_reason;

  v_cdr.src_prefix_in:=v_dynamic.src_prefix_in;
  v_cdr.src_prefix_out:=v_dynamic.src_prefix_out;
  v_cdr.dst_prefix_in:=v_dynamic.dst_prefix_in;
  v_cdr.dst_prefix_out:=v_dynamic.dst_prefix_out;

  v_cdr.orig_call_id=i_orig_call_id;
  v_cdr.term_call_id=i_term_call_id;

  /* removed */
  --v_cdr.dump_file:=i_msg_logger_path;

  v_cdr.dump_level_id:=i_dump_level_id;
  v_cdr.audio_recorded:=i_audio_recorded;

  v_cdr.auth_orig_transport_protocol_id=v_dynamic.auth_orig_protocol_id;
  v_cdr.auth_orig_ip:=v_dynamic.auth_orig_ip;
  v_cdr.auth_orig_ip:=v_dynamic.auth_orig_ip;
  v_cdr.auth_orig_port:=v_dynamic.auth_orig_port;


  v_rtp_stats_data:=json_populate_record(null::switch.rtp_stats_data_ty, i_rtp_stats_data);

  v_cdr.lega_rx_payloads:=v_rtp_stats_data.lega_rx_payloads;
  v_cdr.lega_tx_payloads:=v_rtp_stats_data.lega_tx_payloads;
  v_cdr.legb_rx_payloads:=v_rtp_stats_data.legb_rx_payloads;
  v_cdr.legb_tx_payloads:=v_rtp_stats_data.legb_tx_payloads;

  v_cdr.lega_rx_bytes:=v_rtp_stats_data.lega_rx_bytes;
  v_cdr.lega_tx_bytes:=v_rtp_stats_data.lega_tx_bytes;
  v_cdr.legb_rx_bytes:=v_rtp_stats_data.legb_rx_bytes;
  v_cdr.legb_tx_bytes:=v_rtp_stats_data.legb_tx_bytes;

  v_cdr.lega_rx_decode_errs:=v_rtp_stats_data.lega_rx_decode_errs;
  v_cdr.lega_rx_no_buf_errs:=v_rtp_stats_data.lega_rx_no_buf_errs;
  v_cdr.lega_rx_parse_errs:=v_rtp_stats_data.lega_rx_parse_errs;
  v_cdr.legb_rx_decode_errs:=v_rtp_stats_data.legb_rx_decode_errs;
  v_cdr.legb_rx_no_buf_errs:=v_rtp_stats_data.legb_rx_no_buf_errs;
  v_cdr.legb_rx_parse_errs:=v_rtp_stats_data.legb_rx_parse_errs;

  v_cdr.global_tag=i_global_tag;

  v_cdr.dst_country_id=v_dynamic.dst_country_id;
  v_cdr.dst_network_id=v_dynamic.dst_network_id;
  v_cdr.dst_prefix_routing=v_dynamic.dst_prefix_routing;
  v_cdr.src_prefix_routing=v_dynamic.src_prefix_routing;
  v_cdr.routing_plan_id=v_dynamic.routing_plan_id;
  v_cdr.lrn=v_dynamic.lrn;
  v_cdr.lnp_database_id=v_dynamic.lnp_database_id;

  v_cdr.ruri_domain=v_dynamic.ruri_domain;
  v_cdr.to_domain=v_dynamic.to_domain;
  v_cdr.from_domain=v_dynamic.from_domain;

  v_cdr.src_area_id=v_dynamic.src_area_id;
  v_cdr.dst_area_id=v_dynamic.dst_area_id;
  v_cdr.routing_tag_ids=v_dynamic.routing_tag_ids;


  v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
  v_cdr.uuid:=public.uuid_generate_v1();

  v_cdr.pai_in=v_dynamic.pai_in;
  v_cdr.ppi_in=v_dynamic.ppi_in;
  v_cdr.privacy_in=v_dynamic.privacy_in;
  v_cdr.rpid_in=v_dynamic.rpid_in;
  v_cdr.rpid_privacy_in=v_dynamic.rpid_privacy_in;
  v_cdr.pai_out=v_dynamic.pai_out;
  v_cdr.ppi_out=v_dynamic.ppi_out;
  v_cdr.privacy_out=v_dynamic.privacy_out;
  v_cdr.rpid_out=v_dynamic.rpid_out;
  v_cdr.rpid_privacy_out=v_dynamic.rpid_privacy_out;


  v_cdr:=billing.bill_cdr(v_cdr);

  perform stats.update_rt_stats(v_cdr);

  v_billing_event.id=v_cdr.id;
  v_billing_event.customer_id=v_cdr.customer_id;
  v_billing_event.vendor_id=v_cdr.vendor_id;
  v_billing_event.customer_acc_id=v_cdr.customer_acc_id;
  v_billing_event.vendor_acc_id=v_cdr.vendor_acc_id;
  v_billing_event.customer_auth_id=v_cdr.customer_auth_id;
  v_billing_event.destination_id=v_cdr.destination_id;
  v_billing_event.dialpeer_id=v_cdr.dialpeer_id;
  v_billing_event.orig_gw_id=v_cdr.orig_gw_id;
  v_billing_event.term_gw_id=v_cdr.term_gw_id;
  v_billing_event.routing_group_id=v_cdr.routing_group_id;
  v_billing_event.rateplan_id=v_cdr.rateplan_id;

  v_billing_event.destination_next_rate=v_cdr.destination_next_rate;
  v_billing_event.destination_fee=v_cdr.destination_fee;
  v_billing_event.destination_initial_interval=v_cdr.destination_initial_interval;
  v_billing_event.destination_next_interval=v_cdr.destination_next_interval;
  v_billing_event.destination_initial_rate=v_cdr.destination_initial_rate;
  v_billing_event.destination_reverse_billing=v_cdr.destination_reverse_billing;

  v_billing_event.dialpeer_next_rate=v_cdr.dialpeer_next_rate;
  v_billing_event.dialpeer_fee=v_cdr.dialpeer_fee;
  v_billing_event.dialpeer_reverse_billing=v_cdr.dialpeer_reverse_billing;

  v_billing_event.internal_disconnect_code=v_cdr.internal_disconnect_code;
  v_billing_event.internal_disconnect_reason=v_cdr.internal_disconnect_reason;
  v_billing_event.disconnect_initiator_id=v_cdr.disconnect_initiator_id;
  v_billing_event.customer_price=v_cdr.customer_price;
  v_billing_event.vendor_price=v_cdr.vendor_price;
  v_billing_event.duration=v_cdr.duration;
  v_billing_event.success=v_cdr.success;
  v_billing_event.profit=v_cdr.profit;
  v_billing_event.time_start=v_cdr.time_start;
  v_billing_event.time_connect=v_cdr.time_connect;
  v_billing_event.time_end=v_cdr.time_end;
  v_billing_event.lega_disconnect_code=v_cdr.lega_disconnect_code;
  v_billing_event.lega_disconnect_reason=v_cdr.lega_disconnect_reason;
  v_billing_event.legb_disconnect_code=v_cdr.legb_disconnect_code;
  v_billing_event.legb_disconnect_reason=v_cdr.legb_disconnect_reason;
  v_billing_event.src_prefix_in=v_cdr.src_prefix_in;
  v_billing_event.src_prefix_out=v_cdr.src_prefix_out;
  v_billing_event.dst_prefix_in=v_cdr.dst_prefix_in;
  v_billing_event.dst_prefix_out=v_cdr.dst_prefix_out;
  v_billing_event.orig_call_id=v_cdr.orig_call_id;
  v_billing_event.term_call_id=v_cdr.term_call_id;
  v_billing_event.local_tag=v_cdr.local_tag;
  v_billing_event.from_domain=v_cdr.from_domain;

  -- generate event to routing engine
  perform event.billing_insert_event('cdr_full',v_billing_event);
  INSERT INTO cdr.cdr VALUES( v_cdr.*);
  RETURN 0;
END;
$$;


--
-- Name: writecdr(boolean, integer, integer, integer, boolean, character varying, integer, character varying, integer, character varying, integer, character varying, integer, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, integer, json, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, inet, integer, integer, integer, character varying, character varying, integer, character varying, smallint); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id integer, i_rtp_stats_data json, i_global_tag character varying, i_customer_id character varying, i_vendor_id character varying, i_customer_acc_id character varying, i_vendor_acc_id character varying, i_customer_auth_id character varying, i_destination_id character varying, i_destination_prefix character varying, i_dialpeer_id character varying, i_dialpeer_prefix character varying, i_orig_gw_id character varying, i_term_gw_id character varying, i_routing_group_id character varying, i_rateplan_id character varying, i_destination_initial_rate character varying, i_destination_next_rate character varying, i_destination_initial_interval integer, i_destination_next_interval integer, i_destination_rate_policy_id integer, i_dialpeer_initial_interval integer, i_dialpeer_next_interval integer, i_dialpeer_next_rate character varying, i_destination_fee character varying, i_dialpeer_initial_rate character varying, i_dialpeer_fee character varying, i_dst_prefix_in character varying, i_dst_prefix_out character varying, i_src_prefix_in character varying, i_src_prefix_out character varying, i_src_name_in character varying, i_src_name_out character varying, i_diversion_in character varying, i_diversion_out character varying, i_auth_orig_ip inet, i_auth_orig_port integer, i_dst_country_id integer, i_dst_network_id integer, i_dst_prefix_routing character varying, i_src_prefix_routing character varying, i_routing_plan_id integer, i_lrn character varying, i_lnp_database_id smallint) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    v_cdr cdr.cdr%rowtype;
    v_billing_event billing.cdr_v2;

    v_rtp_stats_data switch.rtp_stats_data_ty;
    v_time_data switch.time_data_ty;


v_nozerolen boolean;
BEGIN
    v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);


v_cdr.pop_id=i_pop_id;
v_cdr.node_id=i_node_id;

v_cdr.src_name_in:=i_src_name_in;
v_cdr.src_name_out:=i_src_name_out;

v_cdr.diversion_in:=i_diversion_in;
v_cdr.diversion_out:=i_diversion_out;

v_cdr.customer_id:=i_customer_id;
v_cdr.vendor_id:=i_vendor_id;
v_cdr.customer_acc_id:=i_customer_acc_id;
v_cdr.vendor_acc_id:=i_vendor_acc_id;
v_cdr.customer_auth_id:=i_customer_auth_id;

v_cdr.destination_id:=i_destination_id;
v_cdr.destination_prefix:=i_destination_prefix;
v_cdr.dialpeer_id:=i_dialpeer_id;
v_cdr.dialpeer_prefix:=i_dialpeer_prefix;

v_cdr.orig_gw_id:=i_orig_gw_id;
v_cdr.term_gw_id:=i_term_gw_id;
v_cdr.routing_group_id:=i_routing_group_id;
v_cdr.rateplan_id:=i_rateplan_id;

v_cdr.routing_attempt=i_routing_attempt;
v_cdr.is_last_cdr=i_is_last_cdr;

v_cdr.destination_initial_rate:=i_destination_initial_rate::numeric;
v_cdr.destination_next_rate:=i_destination_next_rate::numeric;
v_cdr.destination_initial_interval:=i_destination_initial_interval;
v_cdr.destination_next_interval:=i_destination_next_interval;
v_cdr.destination_fee:=i_destination_fee;
v_cdr.destination_rate_policy_id:=i_destination_rate_policy_id;

v_cdr.dialpeer_initial_rate:=i_dialpeer_initial_rate::numeric;
v_cdr.dialpeer_next_rate:=i_dialpeer_next_rate::numeric;
v_cdr.dialpeer_initial_interval:=i_dialpeer_initial_interval;
v_cdr.dialpeer_next_interval:=i_dialpeer_next_interval;
v_cdr.dialpeer_fee:=i_dialpeer_fee;


/* sockets addresses */
v_cdr.sign_orig_ip:=i_legA_remote_ip;
v_cdr.sign_orig_port=i_legA_remote_port;
v_cdr.sign_orig_local_ip:=i_legA_local_ip;
v_cdr.sign_orig_local_port=i_legA_local_port;
v_cdr.sign_term_ip:=i_legB_remote_ip;
v_cdr.sign_term_port:=NULLIF(i_legB_remote_port,0);
v_cdr.sign_term_local_ip:=i_legB_local_ip;
v_cdr.sign_term_local_port:=NULLIF(i_legB_local_port,0);

v_cdr.local_tag=i_local_tag;

/* Call time data */
v_cdr.time_start:=to_timestamp(v_time_data.time_start);
v_cdr.time_limit:=v_time_data.time_limit;

if v_time_data.time_connect is not null then
    v_cdr.time_connect:=to_timestamp(v_time_data.time_connect);
    v_cdr.duration:=switch.round(v_time_data.time_end-v_time_data.time_connect); -- rounding
    v_nozerolen:=true;
    v_cdr.success=true;
else
    v_cdr.time_connect:=NULL;
    v_cdr.duration:=0;
    v_nozerolen:=false;
    v_cdr.success=false;
end if;
v_cdr.routing_delay=(v_time_data.leg_b_time-v_time_data.time_start)::real;
v_cdr.pdd=(coalesce(v_time_data.time_18x,v_time_data.time_connect)-v_time_data.time_start)::real;
v_cdr.rtt=(coalesce(v_time_data.time_1xx,v_time_data.time_18x,v_time_data.time_connect)-v_time_data.leg_b_time)::real;
v_cdr.early_media_present=i_early_media_present;

v_cdr.time_end:=to_timestamp(v_time_data.time_end);

-- DC processing
v_cdr.legb_disconnect_code:=i_legb_disconnect_code;
v_cdr.legb_disconnect_reason:=i_legb_disconnect_reason;
v_cdr.disconnect_initiator_id:=i_disconnect_initiator;
v_cdr.internal_disconnect_code:=i_internal_disconnect_code;
v_cdr.internal_disconnect_reason:=i_internal_disconnect_reason;
v_cdr.lega_disconnect_code:=i_lega_disconnect_code;
v_cdr.lega_disconnect_reason:=i_lega_disconnect_reason;

v_cdr.src_prefix_in:=i_src_prefix_in;
v_cdr.src_prefix_out:=i_src_prefix_out;
v_cdr.dst_prefix_in:=i_dst_prefix_in;
v_cdr.dst_prefix_out:=i_dst_prefix_out;

v_cdr.orig_call_id=i_orig_call_id;
v_cdr.term_call_id=i_term_call_id;

/* removed */
--v_cdr.dump_file:=i_msg_logger_path;

v_cdr.dump_level_id:=i_dump_level_id;

v_cdr.auth_orig_ip:=i_auth_orig_ip;
v_cdr.auth_orig_port:=i_auth_orig_port;


v_rtp_stats_data:=json_populate_record(null::switch.rtp_stats_data_ty, i_rtp_stats_data);

v_cdr.lega_rx_payloads:=v_rtp_stats_data.lega_rx_payloads;
v_cdr.lega_tx_payloads:=v_rtp_stats_data.lega_tx_payloads;
v_cdr.legb_rx_payloads:=v_rtp_stats_data.legb_rx_payloads;
v_cdr.legb_tx_payloads:=v_rtp_stats_data.legb_tx_payloads;

v_cdr.lega_rx_bytes:=v_rtp_stats_data.lega_rx_bytes;
v_cdr.lega_tx_bytes:=v_rtp_stats_data.lega_tx_bytes;
v_cdr.legb_rx_bytes:=v_rtp_stats_data.legb_rx_bytes;
v_cdr.legb_tx_bytes:=v_rtp_stats_data.legb_tx_bytes;

v_cdr.lega_rx_decode_errs:=v_rtp_stats_data.lega_rx_decode_errs;
v_cdr.lega_rx_no_buf_errs:=v_rtp_stats_data.lega_rx_no_buf_errs;
v_cdr.lega_rx_parse_errs:=v_rtp_stats_data.lega_rx_parse_errs;
v_cdr.legb_rx_decode_errs:=v_rtp_stats_data.legb_rx_decode_errs;
v_cdr.legb_rx_no_buf_errs:=v_rtp_stats_data.legb_rx_no_buf_errs;
v_cdr.legb_rx_parse_errs:=v_rtp_stats_data.legb_rx_parse_errs;

v_cdr.global_tag=i_global_tag;

v_cdr.dst_country_id=i_dst_country_id;
v_cdr.dst_network_id=i_dst_network_id;
v_cdr.dst_prefix_routing=i_dst_prefix_routing;
v_cdr.src_prefix_routing=i_src_prefix_routing;
v_cdr.routing_plan_id=i_routing_plan_id;
v_cdr.lrn=i_lrn;
v_cdr.lnp_database_id=i_lnp_database_id;


    v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
    v_cdr:=billing.bill_cdr(v_cdr);

    perform stats.update_rt_stats(v_cdr);


    v_billing_event.id=v_cdr.id;
    v_billing_event.customer_id=v_cdr.customer_id;
    v_billing_event.vendor_id=v_cdr.vendor_id;
    v_billing_event.customer_acc_id=v_cdr.customer_acc_id;
    v_billing_event.vendor_acc_id=v_cdr.vendor_acc_id;
    v_billing_event.customer_auth_id=v_cdr.customer_auth_id;
    v_billing_event.destination_id=v_cdr.destination_id;
    v_billing_event.dialpeer_id=v_cdr.dialpeer_id;
    v_billing_event.orig_gw_id=v_cdr.orig_gw_id;
    v_billing_event.term_gw_id=v_cdr.term_gw_id;
    v_billing_event.routing_group_id=v_cdr.routing_group_id;
    v_billing_event.rateplan_id=v_cdr.rateplan_id;
    v_billing_event.destination_next_rate=v_cdr.destination_next_rate;
    v_billing_event.destination_fee=v_cdr.destination_fee;
    v_billing_event.dialpeer_next_rate=v_cdr.dialpeer_next_rate;
    v_billing_event.dialpeer_fee=v_cdr.dialpeer_fee;
    v_billing_event.internal_disconnect_code=v_cdr.internal_disconnect_code;
    v_billing_event.internal_disconnect_reason=v_cdr.internal_disconnect_reason;
    v_billing_event.disconnect_initiator_id=v_cdr.disconnect_initiator_id;
    v_billing_event.customer_price=v_cdr.customer_price;
    v_billing_event.vendor_price=v_cdr.vendor_price;
    v_billing_event.duration=v_cdr.duration;
    v_billing_event.success=v_cdr.success;
    v_billing_event.profit=v_cdr.profit;
    v_billing_event.time_start=v_cdr.time_start;
    v_billing_event.time_connect=v_cdr.time_connect;
    v_billing_event.time_end=v_cdr.time_end;
    v_billing_event.lega_disconnect_code=v_cdr.lega_disconnect_code;
    v_billing_event.lega_disconnect_reason=v_cdr.lega_disconnect_reason;
    v_billing_event.legb_disconnect_code=v_cdr.legb_disconnect_code;
    v_billing_event.legb_disconnect_reason=v_cdr.legb_disconnect_reason;

        -- generate event to routing engine
    perform event.billing_insert_event('cdr_full',v_billing_event);
    INSERT INTO cdr.cdr VALUES( v_cdr.*);
    RETURN 0;
END;
$$;


--
-- Name: writecdr(boolean, integer, integer, integer, boolean, character varying, integer, character varying, integer, character varying, integer, character varying, integer, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, integer, boolean, json, character varying, character varying, json, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, inet, integer, integer, integer, character varying, character varying, integer, character varying, smallint); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id integer, i_audio_recorded boolean, i_rtp_stats_data json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_customer_id character varying, i_vendor_id character varying, i_customer_acc_id character varying, i_vendor_acc_id character varying, i_customer_auth_id character varying, i_destination_id character varying, i_destination_prefix character varying, i_dialpeer_id character varying, i_dialpeer_prefix character varying, i_orig_gw_id character varying, i_term_gw_id character varying, i_routing_group_id character varying, i_rateplan_id character varying, i_destination_initial_rate character varying, i_destination_next_rate character varying, i_destination_initial_interval integer, i_destination_next_interval integer, i_destination_rate_policy_id integer, i_dialpeer_initial_interval integer, i_dialpeer_next_interval integer, i_dialpeer_next_rate character varying, i_destination_fee character varying, i_dialpeer_initial_rate character varying, i_dialpeer_fee character varying, i_dst_prefix_in character varying, i_dst_prefix_out character varying, i_src_prefix_in character varying, i_src_prefix_out character varying, i_src_name_in character varying, i_src_name_out character varying, i_diversion_in character varying, i_diversion_out character varying, i_auth_orig_ip inet, i_auth_orig_port integer, i_dst_country_id integer, i_dst_network_id integer, i_dst_prefix_routing character varying, i_src_prefix_routing character varying, i_routing_plan_id integer, i_lrn character varying, i_lnp_database_id smallint) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    v_cdr cdr.cdr%rowtype;
    v_billing_event billing.cdr_v2;

    v_rtp_stats_data switch.rtp_stats_data_ty;
    v_time_data switch.time_data_ty;


v_nozerolen boolean;
BEGIN
    v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);


v_cdr.pop_id=i_pop_id;
v_cdr.node_id=i_node_id;

v_cdr.src_name_in:=i_src_name_in;
v_cdr.src_name_out:=i_src_name_out;

v_cdr.diversion_in:=i_diversion_in;
v_cdr.diversion_out:=i_diversion_out;

v_cdr.customer_id:=i_customer_id;
v_cdr.vendor_id:=i_vendor_id;
v_cdr.customer_acc_id:=i_customer_acc_id;
v_cdr.vendor_acc_id:=i_vendor_acc_id;
v_cdr.customer_auth_id:=i_customer_auth_id;

v_cdr.destination_id:=i_destination_id;
v_cdr.destination_prefix:=i_destination_prefix;
v_cdr.dialpeer_id:=i_dialpeer_id;
v_cdr.dialpeer_prefix:=i_dialpeer_prefix;

v_cdr.orig_gw_id:=i_orig_gw_id;
v_cdr.term_gw_id:=i_term_gw_id;
v_cdr.routing_group_id:=i_routing_group_id;
v_cdr.rateplan_id:=i_rateplan_id;

v_cdr.routing_attempt=i_routing_attempt;
v_cdr.is_last_cdr=i_is_last_cdr;

v_cdr.destination_initial_rate:=i_destination_initial_rate::numeric;
v_cdr.destination_next_rate:=i_destination_next_rate::numeric;
v_cdr.destination_initial_interval:=i_destination_initial_interval;
v_cdr.destination_next_interval:=i_destination_next_interval;
v_cdr.destination_fee:=i_destination_fee;
v_cdr.destination_rate_policy_id:=i_destination_rate_policy_id;

v_cdr.dialpeer_initial_rate:=i_dialpeer_initial_rate::numeric;
v_cdr.dialpeer_next_rate:=i_dialpeer_next_rate::numeric;
v_cdr.dialpeer_initial_interval:=i_dialpeer_initial_interval;
v_cdr.dialpeer_next_interval:=i_dialpeer_next_interval;
v_cdr.dialpeer_fee:=i_dialpeer_fee;


/* sockets addresses */
v_cdr.sign_orig_ip:=i_legA_remote_ip;
v_cdr.sign_orig_port=i_legA_remote_port;
v_cdr.sign_orig_local_ip:=i_legA_local_ip;
v_cdr.sign_orig_local_port=i_legA_local_port;
v_cdr.sign_term_ip:=i_legB_remote_ip;
v_cdr.sign_term_port:=NULLIF(i_legB_remote_port,0);
v_cdr.sign_term_local_ip:=i_legB_local_ip;
v_cdr.sign_term_local_port:=NULLIF(i_legB_local_port,0);

v_cdr.local_tag=i_local_tag;

/* Call time data */
v_cdr.time_start:=to_timestamp(v_time_data.time_start);
v_cdr.time_limit:=v_time_data.time_limit;

if v_time_data.time_connect is not null then
    v_cdr.time_connect:=to_timestamp(v_time_data.time_connect);
    v_cdr.duration:=switch.round(v_time_data.time_end-v_time_data.time_connect); -- rounding
    v_nozerolen:=true;
    v_cdr.success=true;
else
    v_cdr.time_connect:=NULL;
    v_cdr.duration:=0;
    v_nozerolen:=false;
    v_cdr.success=false;
end if;
v_cdr.routing_delay=(v_time_data.leg_b_time-v_time_data.time_start)::real;
v_cdr.pdd=(coalesce(v_time_data.time_18x,v_time_data.time_connect)-v_time_data.time_start)::real;
v_cdr.rtt=(coalesce(v_time_data.time_1xx,v_time_data.time_18x,v_time_data.time_connect)-v_time_data.leg_b_time)::real;
v_cdr.early_media_present=i_early_media_present;

v_cdr.time_end:=to_timestamp(v_time_data.time_end);

-- DC processing
v_cdr.legb_disconnect_code:=i_legb_disconnect_code;
v_cdr.legb_disconnect_reason:=i_legb_disconnect_reason;
v_cdr.disconnect_initiator_id:=i_disconnect_initiator;
v_cdr.internal_disconnect_code:=i_internal_disconnect_code;
v_cdr.internal_disconnect_reason:=i_internal_disconnect_reason;
v_cdr.lega_disconnect_code:=i_lega_disconnect_code;
v_cdr.lega_disconnect_reason:=i_lega_disconnect_reason;

v_cdr.src_prefix_in:=i_src_prefix_in;
v_cdr.src_prefix_out:=i_src_prefix_out;
v_cdr.dst_prefix_in:=i_dst_prefix_in;
v_cdr.dst_prefix_out:=i_dst_prefix_out;

v_cdr.orig_call_id=i_orig_call_id;
v_cdr.term_call_id=i_term_call_id;

/* removed */
--v_cdr.dump_file:=i_msg_logger_path;

v_cdr.dump_level_id:=i_dump_level_id;
v_cdr.audio_recorded:=i_audio_recorded;

v_cdr.auth_orig_ip:=i_auth_orig_ip;
v_cdr.auth_orig_port:=i_auth_orig_port;


v_rtp_stats_data:=json_populate_record(null::switch.rtp_stats_data_ty, i_rtp_stats_data);

v_cdr.lega_rx_payloads:=v_rtp_stats_data.lega_rx_payloads;
v_cdr.lega_tx_payloads:=v_rtp_stats_data.lega_tx_payloads;
v_cdr.legb_rx_payloads:=v_rtp_stats_data.legb_rx_payloads;
v_cdr.legb_tx_payloads:=v_rtp_stats_data.legb_tx_payloads;

v_cdr.lega_rx_bytes:=v_rtp_stats_data.lega_rx_bytes;
v_cdr.lega_tx_bytes:=v_rtp_stats_data.lega_tx_bytes;
v_cdr.legb_rx_bytes:=v_rtp_stats_data.legb_rx_bytes;
v_cdr.legb_tx_bytes:=v_rtp_stats_data.legb_tx_bytes;

v_cdr.lega_rx_decode_errs:=v_rtp_stats_data.lega_rx_decode_errs;
v_cdr.lega_rx_no_buf_errs:=v_rtp_stats_data.lega_rx_no_buf_errs;
v_cdr.lega_rx_parse_errs:=v_rtp_stats_data.lega_rx_parse_errs;
v_cdr.legb_rx_decode_errs:=v_rtp_stats_data.legb_rx_decode_errs;
v_cdr.legb_rx_no_buf_errs:=v_rtp_stats_data.legb_rx_no_buf_errs;
v_cdr.legb_rx_parse_errs:=v_rtp_stats_data.legb_rx_parse_errs;

v_cdr.global_tag=i_global_tag;

v_cdr.dst_country_id=i_dst_country_id;
v_cdr.dst_network_id=i_dst_network_id;
v_cdr.dst_prefix_routing=i_dst_prefix_routing;
v_cdr.src_prefix_routing=i_src_prefix_routing;
v_cdr.routing_plan_id=i_routing_plan_id;
v_cdr.lrn=i_lrn;
v_cdr.lnp_database_id=i_lnp_database_id;


    v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
    v_cdr:=billing.bill_cdr(v_cdr);

    perform stats.update_rt_stats(v_cdr);


    v_billing_event.id=v_cdr.id;
    v_billing_event.customer_id=v_cdr.customer_id;
    v_billing_event.vendor_id=v_cdr.vendor_id;
    v_billing_event.customer_acc_id=v_cdr.customer_acc_id;
    v_billing_event.vendor_acc_id=v_cdr.vendor_acc_id;
    v_billing_event.customer_auth_id=v_cdr.customer_auth_id;
    v_billing_event.destination_id=v_cdr.destination_id;
    v_billing_event.dialpeer_id=v_cdr.dialpeer_id;
    v_billing_event.orig_gw_id=v_cdr.orig_gw_id;
    v_billing_event.term_gw_id=v_cdr.term_gw_id;
    v_billing_event.routing_group_id=v_cdr.routing_group_id;
    v_billing_event.rateplan_id=v_cdr.rateplan_id;
    v_billing_event.destination_next_rate=v_cdr.destination_next_rate;
    v_billing_event.destination_fee=v_cdr.destination_fee;
    v_billing_event.dialpeer_next_rate=v_cdr.dialpeer_next_rate;
    v_billing_event.dialpeer_fee=v_cdr.dialpeer_fee;
    v_billing_event.internal_disconnect_code=v_cdr.internal_disconnect_code;
    v_billing_event.internal_disconnect_reason=v_cdr.internal_disconnect_reason;
    v_billing_event.disconnect_initiator_id=v_cdr.disconnect_initiator_id;
    v_billing_event.customer_price=v_cdr.customer_price;
    v_billing_event.vendor_price=v_cdr.vendor_price;
    v_billing_event.duration=v_cdr.duration;
    v_billing_event.success=v_cdr.success;
    v_billing_event.profit=v_cdr.profit;
    v_billing_event.time_start=v_cdr.time_start;
    v_billing_event.time_connect=v_cdr.time_connect;
    v_billing_event.time_end=v_cdr.time_end;
    v_billing_event.lega_disconnect_code=v_cdr.lega_disconnect_code;
    v_billing_event.lega_disconnect_reason=v_cdr.lega_disconnect_reason;
    v_billing_event.legb_disconnect_code=v_cdr.legb_disconnect_code;
    v_billing_event.legb_disconnect_reason=v_cdr.legb_disconnect_reason;

        -- generate event to routing engine
    perform event.billing_insert_event('cdr_full',v_billing_event);
    INSERT INTO cdr.cdr VALUES( v_cdr.*);
    RETURN 0;
END;
$$;


--
-- Name: writecdr(boolean, integer, integer, integer, boolean, character varying, integer, character varying, integer, character varying, integer, character varying, integer, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, integer, boolean, json, character varying, character varying, json, smallint, bigint, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, inet, integer, integer, integer, character varying, character varying, integer, character varying, smallint); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id integer, i_audio_recorded boolean, i_rtp_stats_data json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_customer_id character varying, i_vendor_id character varying, i_customer_acc_id character varying, i_vendor_acc_id character varying, i_customer_auth_id character varying, i_destination_id character varying, i_destination_prefix character varying, i_dialpeer_id character varying, i_dialpeer_prefix character varying, i_orig_gw_id character varying, i_term_gw_id character varying, i_routing_group_id character varying, i_rateplan_id character varying, i_destination_initial_rate character varying, i_destination_next_rate character varying, i_destination_initial_interval integer, i_destination_next_interval integer, i_destination_rate_policy_id integer, i_dialpeer_initial_interval integer, i_dialpeer_next_interval integer, i_dialpeer_next_rate character varying, i_destination_fee character varying, i_dialpeer_initial_rate character varying, i_dialpeer_fee character varying, i_dst_prefix_in character varying, i_dst_prefix_out character varying, i_src_prefix_in character varying, i_src_prefix_out character varying, i_src_name_in character varying, i_src_name_out character varying, i_diversion_in character varying, i_diversion_out character varying, i_auth_orig_ip inet, i_auth_orig_port integer, i_dst_country_id integer, i_dst_network_id integer, i_dst_prefix_routing character varying, i_src_prefix_routing character varying, i_routing_plan_id integer, i_lrn character varying, i_lnp_database_id smallint) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_cdr cdr.cdr%rowtype;
  v_billing_event billing.cdr_v2;

  v_rtp_stats_data switch.rtp_stats_data_ty;
  v_time_data switch.time_data_ty;


  v_nozerolen boolean;
BEGIN

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);


  v_cdr.pop_id=i_pop_id;
  v_cdr.node_id=i_node_id;

  v_cdr.src_name_in:=i_src_name_in;
  v_cdr.src_name_out:=i_src_name_out;

  v_cdr.diversion_in:=i_diversion_in;
  v_cdr.diversion_out:=i_diversion_out;

  v_cdr.customer_id:=i_customer_id;
  v_cdr.vendor_id:=i_vendor_id;
  v_cdr.customer_acc_id:=i_customer_acc_id;
  v_cdr.vendor_acc_id:=i_vendor_acc_id;
  v_cdr.customer_auth_id:=i_customer_auth_id;

  v_cdr.destination_id:=i_destination_id;
  v_cdr.destination_prefix:=i_destination_prefix;
  v_cdr.dialpeer_id:=i_dialpeer_id;
  v_cdr.dialpeer_prefix:=i_dialpeer_prefix;

  v_cdr.orig_gw_id:=i_orig_gw_id;
  v_cdr.term_gw_id:=i_term_gw_id;
  v_cdr.routing_group_id:=i_routing_group_id;
  v_cdr.rateplan_id:=i_rateplan_id;

  v_cdr.routing_attempt=i_routing_attempt;
  v_cdr.is_last_cdr=i_is_last_cdr;

  v_cdr.destination_initial_rate:=i_destination_initial_rate::numeric;
  v_cdr.destination_next_rate:=i_destination_next_rate::numeric;
  v_cdr.destination_initial_interval:=i_destination_initial_interval;
  v_cdr.destination_next_interval:=i_destination_next_interval;
  v_cdr.destination_fee:=i_destination_fee;
  v_cdr.destination_rate_policy_id:=i_destination_rate_policy_id;

  v_cdr.dialpeer_initial_rate:=i_dialpeer_initial_rate::numeric;
  v_cdr.dialpeer_next_rate:=i_dialpeer_next_rate::numeric;
  v_cdr.dialpeer_initial_interval:=i_dialpeer_initial_interval;
  v_cdr.dialpeer_next_interval:=i_dialpeer_next_interval;
  v_cdr.dialpeer_fee:=i_dialpeer_fee;


  /* sockets addresses */
  v_cdr.sign_orig_ip:=i_legA_remote_ip;
  v_cdr.sign_orig_port=i_legA_remote_port;
  v_cdr.sign_orig_local_ip:=i_legA_local_ip;
  v_cdr.sign_orig_local_port=i_legA_local_port;
  v_cdr.sign_term_ip:=i_legB_remote_ip;
  v_cdr.sign_term_port:=NULLIF(i_legB_remote_port,0);
  v_cdr.sign_term_local_ip:=i_legB_local_ip;
  v_cdr.sign_term_local_port:=NULLIF(i_legB_local_port,0);

  v_cdr.local_tag=i_local_tag;

  /* Call time data */
  v_cdr.time_start:=to_timestamp(v_time_data.time_start);
  v_cdr.time_limit:=v_time_data.time_limit;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect:=to_timestamp(v_time_data.time_connect);
    v_cdr.duration:=switch.round(v_time_data.time_end-v_time_data.time_connect); -- rounding
    v_nozerolen:=true;
    v_cdr.success=true;
  else
    v_cdr.time_connect:=NULL;
    v_cdr.duration:=0;
    v_nozerolen:=false;
    v_cdr.success=false;
  end if;
  v_cdr.routing_delay=(v_time_data.leg_b_time-v_time_data.time_start)::real;
  v_cdr.pdd=(coalesce(v_time_data.time_18x,v_time_data.time_connect)-v_time_data.time_start)::real;
  v_cdr.rtt=(coalesce(v_time_data.time_1xx,v_time_data.time_18x,v_time_data.time_connect)-v_time_data.leg_b_time)::real;
  v_cdr.early_media_present=i_early_media_present;

  v_cdr.time_end:=to_timestamp(v_time_data.time_end);

  -- DC processing
  v_cdr.legb_disconnect_code:=i_legb_disconnect_code;
  v_cdr.legb_disconnect_reason:=i_legb_disconnect_reason;
  v_cdr.disconnect_initiator_id:=i_disconnect_initiator;
  v_cdr.internal_disconnect_code:=i_internal_disconnect_code;
  v_cdr.internal_disconnect_reason:=i_internal_disconnect_reason;
  v_cdr.lega_disconnect_code:=i_lega_disconnect_code;
  v_cdr.lega_disconnect_reason:=i_lega_disconnect_reason;

  v_cdr.src_prefix_in:=i_src_prefix_in;
  v_cdr.src_prefix_out:=i_src_prefix_out;
  v_cdr.dst_prefix_in:=i_dst_prefix_in;
  v_cdr.dst_prefix_out:=i_dst_prefix_out;

  v_cdr.orig_call_id=i_orig_call_id;
  v_cdr.term_call_id=i_term_call_id;

  /* removed */
  --v_cdr.dump_file:=i_msg_logger_path;

  v_cdr.dump_level_id:=i_dump_level_id;
  v_cdr.audio_recorded:=i_audio_recorded;

  v_cdr.auth_orig_ip:=i_auth_orig_ip;
  v_cdr.auth_orig_port:=i_auth_orig_port;


  v_rtp_stats_data:=json_populate_record(null::switch.rtp_stats_data_ty, i_rtp_stats_data);

  v_cdr.lega_rx_payloads:=v_rtp_stats_data.lega_rx_payloads;
  v_cdr.lega_tx_payloads:=v_rtp_stats_data.lega_tx_payloads;
  v_cdr.legb_rx_payloads:=v_rtp_stats_data.legb_rx_payloads;
  v_cdr.legb_tx_payloads:=v_rtp_stats_data.legb_tx_payloads;

  v_cdr.lega_rx_bytes:=v_rtp_stats_data.lega_rx_bytes;
  v_cdr.lega_tx_bytes:=v_rtp_stats_data.lega_tx_bytes;
  v_cdr.legb_rx_bytes:=v_rtp_stats_data.legb_rx_bytes;
  v_cdr.legb_tx_bytes:=v_rtp_stats_data.legb_tx_bytes;

  v_cdr.lega_rx_decode_errs:=v_rtp_stats_data.lega_rx_decode_errs;
  v_cdr.lega_rx_no_buf_errs:=v_rtp_stats_data.lega_rx_no_buf_errs;
  v_cdr.lega_rx_parse_errs:=v_rtp_stats_data.lega_rx_parse_errs;
  v_cdr.legb_rx_decode_errs:=v_rtp_stats_data.legb_rx_decode_errs;
  v_cdr.legb_rx_no_buf_errs:=v_rtp_stats_data.legb_rx_no_buf_errs;
  v_cdr.legb_rx_parse_errs:=v_rtp_stats_data.legb_rx_parse_errs;

  v_cdr.global_tag=i_global_tag;

  v_cdr.dst_country_id=i_dst_country_id;
  v_cdr.dst_network_id=i_dst_network_id;
  v_cdr.dst_prefix_routing=i_dst_prefix_routing;
  v_cdr.src_prefix_routing=i_src_prefix_routing;
  v_cdr.routing_plan_id=i_routing_plan_id;
  v_cdr.lrn=i_lrn;
  v_cdr.lnp_database_id=i_lnp_database_id;


  v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
  v_cdr:=billing.bill_cdr(v_cdr);

  perform stats.update_rt_stats(v_cdr);


  v_billing_event.id=v_cdr.id;
  v_billing_event.customer_id=v_cdr.customer_id;
  v_billing_event.vendor_id=v_cdr.vendor_id;
  v_billing_event.customer_acc_id=v_cdr.customer_acc_id;
  v_billing_event.vendor_acc_id=v_cdr.vendor_acc_id;
  v_billing_event.customer_auth_id=v_cdr.customer_auth_id;
  v_billing_event.destination_id=v_cdr.destination_id;
  v_billing_event.dialpeer_id=v_cdr.dialpeer_id;
  v_billing_event.orig_gw_id=v_cdr.orig_gw_id;
  v_billing_event.term_gw_id=v_cdr.term_gw_id;
  v_billing_event.routing_group_id=v_cdr.routing_group_id;
  v_billing_event.rateplan_id=v_cdr.rateplan_id;
  v_billing_event.destination_next_rate=v_cdr.destination_next_rate;
  v_billing_event.destination_fee=v_cdr.destination_fee;
  v_billing_event.dialpeer_next_rate=v_cdr.dialpeer_next_rate;
  v_billing_event.dialpeer_fee=v_cdr.dialpeer_fee;
  v_billing_event.internal_disconnect_code=v_cdr.internal_disconnect_code;
  v_billing_event.internal_disconnect_reason=v_cdr.internal_disconnect_reason;
  v_billing_event.disconnect_initiator_id=v_cdr.disconnect_initiator_id;
  v_billing_event.customer_price=v_cdr.customer_price;
  v_billing_event.vendor_price=v_cdr.vendor_price;
  v_billing_event.duration=v_cdr.duration;
  v_billing_event.success=v_cdr.success;
  v_billing_event.profit=v_cdr.profit;
  v_billing_event.time_start=v_cdr.time_start;
  v_billing_event.time_connect=v_cdr.time_connect;
  v_billing_event.time_end=v_cdr.time_end;
  v_billing_event.lega_disconnect_code=v_cdr.lega_disconnect_code;
  v_billing_event.lega_disconnect_reason=v_cdr.lega_disconnect_reason;
  v_billing_event.legb_disconnect_code=v_cdr.legb_disconnect_code;
  v_billing_event.legb_disconnect_reason=v_cdr.legb_disconnect_reason;

  -- generate event to routing engine
  perform event.billing_insert_event('cdr_full',v_billing_event);
  INSERT INTO cdr.cdr VALUES( v_cdr.*);
  RETURN 0;
END;
$$;


--
-- Name: writecdr(boolean, integer, integer, integer, boolean, character varying, integer, character varying, integer, character varying, integer, character varying, integer, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, integer, boolean, json, character varying, character varying, json, smallint, bigint, json, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, inet, integer, integer, integer, character varying, character varying, integer, character varying, smallint); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id integer, i_audio_recorded boolean, i_rtp_stats_data json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_customer_id character varying, i_vendor_id character varying, i_customer_acc_id character varying, i_vendor_acc_id character varying, i_customer_auth_id character varying, i_destination_id character varying, i_destination_prefix character varying, i_dialpeer_id character varying, i_dialpeer_prefix character varying, i_orig_gw_id character varying, i_term_gw_id character varying, i_routing_group_id character varying, i_rateplan_id character varying, i_destination_initial_rate character varying, i_destination_next_rate character varying, i_destination_initial_interval integer, i_destination_next_interval integer, i_destination_rate_policy_id integer, i_dialpeer_initial_interval integer, i_dialpeer_next_interval integer, i_dialpeer_next_rate character varying, i_destination_fee character varying, i_dialpeer_initial_rate character varying, i_dialpeer_fee character varying, i_dst_prefix_in character varying, i_dst_prefix_out character varying, i_src_prefix_in character varying, i_src_prefix_out character varying, i_src_name_in character varying, i_src_name_out character varying, i_diversion_in character varying, i_diversion_out character varying, i_auth_orig_ip inet, i_auth_orig_port integer, i_dst_country_id integer, i_dst_network_id integer, i_dst_prefix_routing character varying, i_src_prefix_routing character varying, i_routing_plan_id integer, i_lrn character varying, i_lnp_database_id smallint) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_cdr cdr.cdr%rowtype;
  v_billing_event billing.cdr_v2;

  v_rtp_stats_data switch.rtp_stats_data_ty;
  v_time_data switch.time_data_ty;


  v_nozerolen boolean;
BEGIN

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);


  v_cdr.pop_id=i_pop_id;
  v_cdr.node_id=i_node_id;

  v_cdr.src_name_in:=i_src_name_in;
  v_cdr.src_name_out:=i_src_name_out;

  v_cdr.diversion_in:=i_diversion_in;
  v_cdr.diversion_out:=i_diversion_out;

  v_cdr.customer_id:=i_customer_id;
  v_cdr.vendor_id:=i_vendor_id;
  v_cdr.customer_acc_id:=i_customer_acc_id;
  v_cdr.vendor_acc_id:=i_vendor_acc_id;
  v_cdr.customer_auth_id:=i_customer_auth_id;

  v_cdr.destination_id:=i_destination_id;
  v_cdr.destination_prefix:=i_destination_prefix;
  v_cdr.dialpeer_id:=i_dialpeer_id;
  v_cdr.dialpeer_prefix:=i_dialpeer_prefix;

  v_cdr.orig_gw_id:=i_orig_gw_id;
  v_cdr.term_gw_id:=i_term_gw_id;
  v_cdr.routing_group_id:=i_routing_group_id;
  v_cdr.rateplan_id:=i_rateplan_id;

  v_cdr.routing_attempt=i_routing_attempt;
  v_cdr.is_last_cdr=i_is_last_cdr;

  v_cdr.destination_initial_rate:=i_destination_initial_rate::numeric;
  v_cdr.destination_next_rate:=i_destination_next_rate::numeric;
  v_cdr.destination_initial_interval:=i_destination_initial_interval;
  v_cdr.destination_next_interval:=i_destination_next_interval;
  v_cdr.destination_fee:=i_destination_fee;
  v_cdr.destination_rate_policy_id:=i_destination_rate_policy_id;

  v_cdr.dialpeer_initial_rate:=i_dialpeer_initial_rate::numeric;
  v_cdr.dialpeer_next_rate:=i_dialpeer_next_rate::numeric;
  v_cdr.dialpeer_initial_interval:=i_dialpeer_initial_interval;
  v_cdr.dialpeer_next_interval:=i_dialpeer_next_interval;
  v_cdr.dialpeer_fee:=i_dialpeer_fee;


  /* sockets addresses */
  v_cdr.sign_orig_ip:=i_legA_remote_ip;
  v_cdr.sign_orig_port=i_legA_remote_port;
  v_cdr.sign_orig_local_ip:=i_legA_local_ip;
  v_cdr.sign_orig_local_port=i_legA_local_port;
  v_cdr.sign_term_ip:=i_legB_remote_ip;
  v_cdr.sign_term_port:=NULLIF(i_legB_remote_port,0);
  v_cdr.sign_term_local_ip:=i_legB_local_ip;
  v_cdr.sign_term_local_port:=NULLIF(i_legB_local_port,0);

  v_cdr.local_tag=i_local_tag;

  /* Call time data */
  v_cdr.time_start:=to_timestamp(v_time_data.time_start);
  v_cdr.time_limit:=v_time_data.time_limit;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect:=to_timestamp(v_time_data.time_connect);
    v_cdr.duration:=switch.round(v_time_data.time_end-v_time_data.time_connect); -- rounding
    v_nozerolen:=true;
    v_cdr.success=true;
  else
    v_cdr.time_connect:=NULL;
    v_cdr.duration:=0;
    v_nozerolen:=false;
    v_cdr.success=false;
  end if;
  v_cdr.routing_delay=(v_time_data.leg_b_time-v_time_data.time_start)::real;
  v_cdr.pdd=(coalesce(v_time_data.time_18x,v_time_data.time_connect)-v_time_data.time_start)::real;
  v_cdr.rtt=(coalesce(v_time_data.time_1xx,v_time_data.time_18x,v_time_data.time_connect)-v_time_data.leg_b_time)::real;
  v_cdr.early_media_present=i_early_media_present;

  v_cdr.time_end:=to_timestamp(v_time_data.time_end);

  -- DC processing
  v_cdr.legb_disconnect_code:=i_legb_disconnect_code;
  v_cdr.legb_disconnect_reason:=i_legb_disconnect_reason;
  v_cdr.disconnect_initiator_id:=i_disconnect_initiator;
  v_cdr.internal_disconnect_code:=i_internal_disconnect_code;
  v_cdr.internal_disconnect_reason:=i_internal_disconnect_reason;
  v_cdr.lega_disconnect_code:=i_lega_disconnect_code;
  v_cdr.lega_disconnect_reason:=i_lega_disconnect_reason;

  v_cdr.src_prefix_in:=i_src_prefix_in;
  v_cdr.src_prefix_out:=i_src_prefix_out;
  v_cdr.dst_prefix_in:=i_dst_prefix_in;
  v_cdr.dst_prefix_out:=i_dst_prefix_out;

  v_cdr.orig_call_id=i_orig_call_id;
  v_cdr.term_call_id=i_term_call_id;

  /* removed */
  --v_cdr.dump_file:=i_msg_logger_path;

  v_cdr.dump_level_id:=i_dump_level_id;
  v_cdr.audio_recorded:=i_audio_recorded;

  v_cdr.auth_orig_ip:=i_auth_orig_ip;
  v_cdr.auth_orig_port:=i_auth_orig_port;


  v_rtp_stats_data:=json_populate_record(null::switch.rtp_stats_data_ty, i_rtp_stats_data);

  v_cdr.lega_rx_payloads:=v_rtp_stats_data.lega_rx_payloads;
  v_cdr.lega_tx_payloads:=v_rtp_stats_data.lega_tx_payloads;
  v_cdr.legb_rx_payloads:=v_rtp_stats_data.legb_rx_payloads;
  v_cdr.legb_tx_payloads:=v_rtp_stats_data.legb_tx_payloads;

  v_cdr.lega_rx_bytes:=v_rtp_stats_data.lega_rx_bytes;
  v_cdr.lega_tx_bytes:=v_rtp_stats_data.lega_tx_bytes;
  v_cdr.legb_rx_bytes:=v_rtp_stats_data.legb_rx_bytes;
  v_cdr.legb_tx_bytes:=v_rtp_stats_data.legb_tx_bytes;

  v_cdr.lega_rx_decode_errs:=v_rtp_stats_data.lega_rx_decode_errs;
  v_cdr.lega_rx_no_buf_errs:=v_rtp_stats_data.lega_rx_no_buf_errs;
  v_cdr.lega_rx_parse_errs:=v_rtp_stats_data.lega_rx_parse_errs;
  v_cdr.legb_rx_decode_errs:=v_rtp_stats_data.legb_rx_decode_errs;
  v_cdr.legb_rx_no_buf_errs:=v_rtp_stats_data.legb_rx_no_buf_errs;
  v_cdr.legb_rx_parse_errs:=v_rtp_stats_data.legb_rx_parse_errs;

  v_cdr.global_tag=i_global_tag;

  v_cdr.dst_country_id=i_dst_country_id;
  v_cdr.dst_network_id=i_dst_network_id;
  v_cdr.dst_prefix_routing=i_dst_prefix_routing;
  v_cdr.src_prefix_routing=i_src_prefix_routing;
  v_cdr.routing_plan_id=i_routing_plan_id;
  v_cdr.lrn=i_lrn;
  v_cdr.lnp_database_id=i_lnp_database_id;


  v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
  v_cdr:=billing.bill_cdr(v_cdr);

  perform stats.update_rt_stats(v_cdr);


  v_billing_event.id=v_cdr.id;
  v_billing_event.customer_id=v_cdr.customer_id;
  v_billing_event.vendor_id=v_cdr.vendor_id;
  v_billing_event.customer_acc_id=v_cdr.customer_acc_id;
  v_billing_event.vendor_acc_id=v_cdr.vendor_acc_id;
  v_billing_event.customer_auth_id=v_cdr.customer_auth_id;
  v_billing_event.destination_id=v_cdr.destination_id;
  v_billing_event.dialpeer_id=v_cdr.dialpeer_id;
  v_billing_event.orig_gw_id=v_cdr.orig_gw_id;
  v_billing_event.term_gw_id=v_cdr.term_gw_id;
  v_billing_event.routing_group_id=v_cdr.routing_group_id;
  v_billing_event.rateplan_id=v_cdr.rateplan_id;
  v_billing_event.destination_next_rate=v_cdr.destination_next_rate;
  v_billing_event.destination_fee=v_cdr.destination_fee;
  v_billing_event.dialpeer_next_rate=v_cdr.dialpeer_next_rate;
  v_billing_event.dialpeer_fee=v_cdr.dialpeer_fee;
  v_billing_event.internal_disconnect_code=v_cdr.internal_disconnect_code;
  v_billing_event.internal_disconnect_reason=v_cdr.internal_disconnect_reason;
  v_billing_event.disconnect_initiator_id=v_cdr.disconnect_initiator_id;
  v_billing_event.customer_price=v_cdr.customer_price;
  v_billing_event.vendor_price=v_cdr.vendor_price;
  v_billing_event.duration=v_cdr.duration;
  v_billing_event.success=v_cdr.success;
  v_billing_event.profit=v_cdr.profit;
  v_billing_event.time_start=v_cdr.time_start;
  v_billing_event.time_connect=v_cdr.time_connect;
  v_billing_event.time_end=v_cdr.time_end;
  v_billing_event.lega_disconnect_code=v_cdr.lega_disconnect_code;
  v_billing_event.lega_disconnect_reason=v_cdr.lega_disconnect_reason;
  v_billing_event.legb_disconnect_code=v_cdr.legb_disconnect_code;
  v_billing_event.legb_disconnect_reason=v_cdr.legb_disconnect_reason;

  -- generate event to routing engine
  perform event.billing_insert_event('cdr_full',v_billing_event);
  INSERT INTO cdr.cdr VALUES( v_cdr.*);
  RETURN 0;
END;
$$;


--
-- Name: writecdr(boolean, integer, integer, integer, boolean, character varying, integer, character varying, integer, character varying, integer, character varying, integer, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, integer, boolean, json, character varying, character varying, json, smallint, bigint, json, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, inet, integer, integer, integer, character varying, character varying, integer, character varying, smallint, character varying, character varying, character varying); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id integer, i_audio_recorded boolean, i_rtp_stats_data json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_customer_id character varying, i_vendor_id character varying, i_customer_acc_id character varying, i_vendor_acc_id character varying, i_customer_auth_id character varying, i_destination_id character varying, i_destination_prefix character varying, i_dialpeer_id character varying, i_dialpeer_prefix character varying, i_orig_gw_id character varying, i_term_gw_id character varying, i_routing_group_id character varying, i_rateplan_id character varying, i_destination_initial_rate character varying, i_destination_next_rate character varying, i_destination_initial_interval integer, i_destination_next_interval integer, i_destination_rate_policy_id integer, i_dialpeer_initial_interval integer, i_dialpeer_next_interval integer, i_dialpeer_next_rate character varying, i_destination_fee character varying, i_dialpeer_initial_rate character varying, i_dialpeer_fee character varying, i_dst_prefix_in character varying, i_dst_prefix_out character varying, i_src_prefix_in character varying, i_src_prefix_out character varying, i_src_name_in character varying, i_src_name_out character varying, i_diversion_in character varying, i_diversion_out character varying, i_auth_orig_ip inet, i_auth_orig_port integer, i_dst_country_id integer, i_dst_network_id integer, i_dst_prefix_routing character varying, i_src_prefix_routing character varying, i_routing_plan_id integer, i_lrn character varying, i_lnp_database_id smallint, i_from_domain character varying, i_to_domain character varying, i_ruri_domain character varying) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_cdr cdr.cdr%rowtype;
  v_billing_event billing.cdr_v2;

  v_rtp_stats_data switch.rtp_stats_data_ty;
  v_time_data switch.time_data_ty;


  v_nozerolen boolean;
BEGIN
--  raise warning 'type: % id: %', i_failed_resource_type_id, i_failed_resource_id;
--  RAISE warning 'DTMF: %', i_dtmf_events;

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);


  v_cdr.pop_id=i_pop_id;
  v_cdr.node_id=i_node_id;

  v_cdr.src_name_in:=i_src_name_in;
  v_cdr.src_name_out:=i_src_name_out;

  v_cdr.diversion_in:=i_diversion_in;
  v_cdr.diversion_out:=i_diversion_out;

  v_cdr.customer_id:=i_customer_id;
  v_cdr.vendor_id:=i_vendor_id;
  v_cdr.customer_acc_id:=i_customer_acc_id;
  v_cdr.vendor_acc_id:=i_vendor_acc_id;
  v_cdr.customer_auth_id:=i_customer_auth_id;

  v_cdr.destination_id:=i_destination_id;
  v_cdr.destination_prefix:=i_destination_prefix;
  v_cdr.dialpeer_id:=i_dialpeer_id;
  v_cdr.dialpeer_prefix:=i_dialpeer_prefix;

  v_cdr.orig_gw_id:=i_orig_gw_id;
  v_cdr.term_gw_id:=i_term_gw_id;
  v_cdr.routing_group_id:=i_routing_group_id;
  v_cdr.rateplan_id:=i_rateplan_id;

  v_cdr.routing_attempt=i_routing_attempt;
  v_cdr.is_last_cdr=i_is_last_cdr;

  v_cdr.destination_initial_rate:=i_destination_initial_rate::numeric;
  v_cdr.destination_next_rate:=i_destination_next_rate::numeric;
  v_cdr.destination_initial_interval:=i_destination_initial_interval;
  v_cdr.destination_next_interval:=i_destination_next_interval;
  v_cdr.destination_fee:=i_destination_fee;
  v_cdr.destination_rate_policy_id:=i_destination_rate_policy_id;

  v_cdr.dialpeer_initial_rate:=i_dialpeer_initial_rate::numeric;
  v_cdr.dialpeer_next_rate:=i_dialpeer_next_rate::numeric;
  v_cdr.dialpeer_initial_interval:=i_dialpeer_initial_interval;
  v_cdr.dialpeer_next_interval:=i_dialpeer_next_interval;
  v_cdr.dialpeer_fee:=i_dialpeer_fee;


  /* sockets addresses */
  v_cdr.sign_orig_ip:=i_legA_remote_ip;
  v_cdr.sign_orig_port=i_legA_remote_port;
  v_cdr.sign_orig_local_ip:=i_legA_local_ip;
  v_cdr.sign_orig_local_port=i_legA_local_port;
  v_cdr.sign_term_ip:=i_legB_remote_ip;
  v_cdr.sign_term_port:=NULLIF(i_legB_remote_port,0);
  v_cdr.sign_term_local_ip:=i_legB_local_ip;
  v_cdr.sign_term_local_port:=NULLIF(i_legB_local_port,0);

  v_cdr.local_tag=i_local_tag;

  /* Call time data */
  v_cdr.time_start:=to_timestamp(v_time_data.time_start);
  v_cdr.time_limit:=v_time_data.time_limit;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect:=to_timestamp(v_time_data.time_connect);
    v_cdr.duration:=switch.round(v_time_data.time_end-v_time_data.time_connect); -- rounding
    v_nozerolen:=true;
    v_cdr.success=true;
  else
    v_cdr.time_connect:=NULL;
    v_cdr.duration:=0;
    v_nozerolen:=false;
    v_cdr.success=false;
  end if;
  v_cdr.routing_delay=(v_time_data.leg_b_time-v_time_data.time_start)::real;
  v_cdr.pdd=(coalesce(v_time_data.time_18x,v_time_data.time_connect)-v_time_data.time_start)::real;
  v_cdr.rtt=(coalesce(v_time_data.time_1xx,v_time_data.time_18x,v_time_data.time_connect)-v_time_data.leg_b_time)::real;
  v_cdr.early_media_present=i_early_media_present;

  v_cdr.time_end:=to_timestamp(v_time_data.time_end);

  -- DC processing
  v_cdr.legb_disconnect_code:=i_legb_disconnect_code;
  v_cdr.legb_disconnect_reason:=i_legb_disconnect_reason;
  v_cdr.disconnect_initiator_id:=i_disconnect_initiator;
  v_cdr.internal_disconnect_code:=i_internal_disconnect_code;
  v_cdr.internal_disconnect_reason:=i_internal_disconnect_reason;
  v_cdr.lega_disconnect_code:=i_lega_disconnect_code;
  v_cdr.lega_disconnect_reason:=i_lega_disconnect_reason;

  v_cdr.src_prefix_in:=i_src_prefix_in;
  v_cdr.src_prefix_out:=i_src_prefix_out;
  v_cdr.dst_prefix_in:=i_dst_prefix_in;
  v_cdr.dst_prefix_out:=i_dst_prefix_out;

  v_cdr.orig_call_id=i_orig_call_id;
  v_cdr.term_call_id=i_term_call_id;

  /* removed */
  --v_cdr.dump_file:=i_msg_logger_path;

  v_cdr.dump_level_id:=i_dump_level_id;
  v_cdr.audio_recorded:=i_audio_recorded;

  v_cdr.auth_orig_ip:=i_auth_orig_ip;
  v_cdr.auth_orig_port:=i_auth_orig_port;


  v_rtp_stats_data:=json_populate_record(null::switch.rtp_stats_data_ty, i_rtp_stats_data);

  v_cdr.lega_rx_payloads:=v_rtp_stats_data.lega_rx_payloads;
  v_cdr.lega_tx_payloads:=v_rtp_stats_data.lega_tx_payloads;
  v_cdr.legb_rx_payloads:=v_rtp_stats_data.legb_rx_payloads;
  v_cdr.legb_tx_payloads:=v_rtp_stats_data.legb_tx_payloads;

  v_cdr.lega_rx_bytes:=v_rtp_stats_data.lega_rx_bytes;
  v_cdr.lega_tx_bytes:=v_rtp_stats_data.lega_tx_bytes;
  v_cdr.legb_rx_bytes:=v_rtp_stats_data.legb_rx_bytes;
  v_cdr.legb_tx_bytes:=v_rtp_stats_data.legb_tx_bytes;

  v_cdr.lega_rx_decode_errs:=v_rtp_stats_data.lega_rx_decode_errs;
  v_cdr.lega_rx_no_buf_errs:=v_rtp_stats_data.lega_rx_no_buf_errs;
  v_cdr.lega_rx_parse_errs:=v_rtp_stats_data.lega_rx_parse_errs;
  v_cdr.legb_rx_decode_errs:=v_rtp_stats_data.legb_rx_decode_errs;
  v_cdr.legb_rx_no_buf_errs:=v_rtp_stats_data.legb_rx_no_buf_errs;
  v_cdr.legb_rx_parse_errs:=v_rtp_stats_data.legb_rx_parse_errs;

  v_cdr.global_tag=i_global_tag;

  v_cdr.dst_country_id=i_dst_country_id;
  v_cdr.dst_network_id=i_dst_network_id;
  v_cdr.dst_prefix_routing=i_dst_prefix_routing;
  v_cdr.src_prefix_routing=i_src_prefix_routing;
  v_cdr.routing_plan_id=i_routing_plan_id;
  v_cdr.lrn=i_lrn;
  v_cdr.lnp_database_id=i_lnp_database_id;

  v_cdr.ruri_domain=i_ruri_domain;
  v_cdr.to_domain=i_to_domain;
  v_cdr.from_domain=i_from_domain;


  v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
  v_cdr:=billing.bill_cdr(v_cdr);

  perform stats.update_rt_stats(v_cdr);


  v_billing_event.id=v_cdr.id;
  v_billing_event.customer_id=v_cdr.customer_id;
  v_billing_event.vendor_id=v_cdr.vendor_id;
  v_billing_event.customer_acc_id=v_cdr.customer_acc_id;
  v_billing_event.vendor_acc_id=v_cdr.vendor_acc_id;
  v_billing_event.customer_auth_id=v_cdr.customer_auth_id;
  v_billing_event.destination_id=v_cdr.destination_id;
  v_billing_event.dialpeer_id=v_cdr.dialpeer_id;
  v_billing_event.orig_gw_id=v_cdr.orig_gw_id;
  v_billing_event.term_gw_id=v_cdr.term_gw_id;
  v_billing_event.routing_group_id=v_cdr.routing_group_id;
  v_billing_event.rateplan_id=v_cdr.rateplan_id;
  v_billing_event.destination_next_rate=v_cdr.destination_next_rate;
  v_billing_event.destination_fee=v_cdr.destination_fee;
  v_billing_event.dialpeer_next_rate=v_cdr.dialpeer_next_rate;
  v_billing_event.dialpeer_fee=v_cdr.dialpeer_fee;
  v_billing_event.internal_disconnect_code=v_cdr.internal_disconnect_code;
  v_billing_event.internal_disconnect_reason=v_cdr.internal_disconnect_reason;
  v_billing_event.disconnect_initiator_id=v_cdr.disconnect_initiator_id;
  v_billing_event.customer_price=v_cdr.customer_price;
  v_billing_event.vendor_price=v_cdr.vendor_price;
  v_billing_event.duration=v_cdr.duration;
  v_billing_event.success=v_cdr.success;
  v_billing_event.profit=v_cdr.profit;
  v_billing_event.time_start=v_cdr.time_start;
  v_billing_event.time_connect=v_cdr.time_connect;
  v_billing_event.time_end=v_cdr.time_end;
  v_billing_event.lega_disconnect_code=v_cdr.lega_disconnect_code;
  v_billing_event.lega_disconnect_reason=v_cdr.lega_disconnect_reason;
  v_billing_event.legb_disconnect_code=v_cdr.legb_disconnect_code;
  v_billing_event.legb_disconnect_reason=v_cdr.legb_disconnect_reason;

  -- generate event to routing engine
  perform event.billing_insert_event('cdr_full',v_billing_event);
  INSERT INTO cdr.cdr VALUES( v_cdr.*);
  RETURN 0;
END;
$$;


--
-- Name: writecdr(boolean, integer, integer, integer, boolean, character varying, integer, character varying, integer, character varying, integer, character varying, integer, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, integer, boolean, json, character varying, character varying, json, smallint, bigint, json, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, inet, integer, integer, integer, character varying, character varying, integer, character varying, smallint, character varying, character varying, character varying, integer, integer, smallint); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id integer, i_audio_recorded boolean, i_rtp_stats_data json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_customer_id character varying, i_vendor_id character varying, i_customer_acc_id character varying, i_vendor_acc_id character varying, i_customer_auth_id character varying, i_destination_id character varying, i_destination_prefix character varying, i_dialpeer_id character varying, i_dialpeer_prefix character varying, i_orig_gw_id character varying, i_term_gw_id character varying, i_routing_group_id character varying, i_rateplan_id character varying, i_destination_initial_rate character varying, i_destination_next_rate character varying, i_destination_initial_interval integer, i_destination_next_interval integer, i_destination_rate_policy_id integer, i_dialpeer_initial_interval integer, i_dialpeer_next_interval integer, i_dialpeer_next_rate character varying, i_destination_fee character varying, i_dialpeer_initial_rate character varying, i_dialpeer_fee character varying, i_dst_prefix_in character varying, i_dst_prefix_out character varying, i_src_prefix_in character varying, i_src_prefix_out character varying, i_src_name_in character varying, i_src_name_out character varying, i_diversion_in character varying, i_diversion_out character varying, i_auth_orig_ip inet, i_auth_orig_port integer, i_dst_country_id integer, i_dst_network_id integer, i_dst_prefix_routing character varying, i_src_prefix_routing character varying, i_routing_plan_id integer, i_lrn character varying, i_lnp_database_id smallint, i_from_domain character varying, i_to_domain character varying, i_ruri_domain character varying, i_src_area_id integer, i_dst_area_id integer, i_routing_tag_id smallint) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_cdr cdr.cdr%rowtype;
  v_billing_event billing.cdr_v2;

  v_rtp_stats_data switch.rtp_stats_data_ty;
  v_time_data switch.time_data_ty;


  v_nozerolen boolean;
BEGIN
  --  raise warning 'type: % id: %', i_failed_resource_type_id, i_failed_resource_id;
  --  RAISE warning 'DTMF: %', i_dtmf_events;

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);


  v_cdr.pop_id=i_pop_id;
  v_cdr.node_id=i_node_id;

  v_cdr.src_name_in:=i_src_name_in;
  v_cdr.src_name_out:=i_src_name_out;

  v_cdr.diversion_in:=i_diversion_in;
  v_cdr.diversion_out:=i_diversion_out;

  v_cdr.customer_id:=i_customer_id;
  v_cdr.vendor_id:=i_vendor_id;
  v_cdr.customer_acc_id:=i_customer_acc_id;
  v_cdr.vendor_acc_id:=i_vendor_acc_id;
  v_cdr.customer_auth_id:=i_customer_auth_id;

  v_cdr.destination_id:=i_destination_id;
  v_cdr.destination_prefix:=i_destination_prefix;
  v_cdr.dialpeer_id:=i_dialpeer_id;
  v_cdr.dialpeer_prefix:=i_dialpeer_prefix;

  v_cdr.orig_gw_id:=i_orig_gw_id;
  v_cdr.term_gw_id:=i_term_gw_id;
  v_cdr.routing_group_id:=i_routing_group_id;
  v_cdr.rateplan_id:=i_rateplan_id;

  v_cdr.routing_attempt=i_routing_attempt;
  v_cdr.is_last_cdr=i_is_last_cdr;

  v_cdr.destination_initial_rate:=i_destination_initial_rate::numeric;
  v_cdr.destination_next_rate:=i_destination_next_rate::numeric;
  v_cdr.destination_initial_interval:=i_destination_initial_interval;
  v_cdr.destination_next_interval:=i_destination_next_interval;
  v_cdr.destination_fee:=i_destination_fee;
  v_cdr.destination_rate_policy_id:=i_destination_rate_policy_id;

  v_cdr.dialpeer_initial_rate:=i_dialpeer_initial_rate::numeric;
  v_cdr.dialpeer_next_rate:=i_dialpeer_next_rate::numeric;
  v_cdr.dialpeer_initial_interval:=i_dialpeer_initial_interval;
  v_cdr.dialpeer_next_interval:=i_dialpeer_next_interval;
  v_cdr.dialpeer_fee:=i_dialpeer_fee;


  /* sockets addresses */
  v_cdr.sign_orig_ip:=i_legA_remote_ip;
  v_cdr.sign_orig_port=i_legA_remote_port;
  v_cdr.sign_orig_local_ip:=i_legA_local_ip;
  v_cdr.sign_orig_local_port=i_legA_local_port;
  v_cdr.sign_term_ip:=i_legB_remote_ip;
  v_cdr.sign_term_port:=NULLIF(i_legB_remote_port,0);
  v_cdr.sign_term_local_ip:=i_legB_local_ip;
  v_cdr.sign_term_local_port:=NULLIF(i_legB_local_port,0);

  v_cdr.local_tag=i_local_tag;

  /* Call time data */
  v_cdr.time_start:=to_timestamp(v_time_data.time_start);
  v_cdr.time_limit:=v_time_data.time_limit;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect:=to_timestamp(v_time_data.time_connect);
    v_cdr.duration:=switch.round(v_time_data.time_end-v_time_data.time_connect); -- rounding
    v_nozerolen:=true;
    v_cdr.success=true;
  else
    v_cdr.time_connect:=NULL;
    v_cdr.duration:=0;
    v_nozerolen:=false;
    v_cdr.success=false;
  end if;
  v_cdr.routing_delay=(v_time_data.leg_b_time-v_time_data.time_start)::real;
  v_cdr.pdd=(coalesce(v_time_data.time_18x,v_time_data.time_connect)-v_time_data.time_start)::real;
  v_cdr.rtt=(coalesce(v_time_data.time_1xx,v_time_data.time_18x,v_time_data.time_connect)-v_time_data.leg_b_time)::real;
  v_cdr.early_media_present=i_early_media_present;

  v_cdr.time_end:=to_timestamp(v_time_data.time_end);

  -- DC processing
  v_cdr.legb_disconnect_code:=i_legb_disconnect_code;
  v_cdr.legb_disconnect_reason:=i_legb_disconnect_reason;
  v_cdr.disconnect_initiator_id:=i_disconnect_initiator;
  v_cdr.internal_disconnect_code:=i_internal_disconnect_code;
  v_cdr.internal_disconnect_reason:=i_internal_disconnect_reason;
  v_cdr.lega_disconnect_code:=i_lega_disconnect_code;
  v_cdr.lega_disconnect_reason:=i_lega_disconnect_reason;

  v_cdr.src_prefix_in:=i_src_prefix_in;
  v_cdr.src_prefix_out:=i_src_prefix_out;
  v_cdr.dst_prefix_in:=i_dst_prefix_in;
  v_cdr.dst_prefix_out:=i_dst_prefix_out;

  v_cdr.orig_call_id=i_orig_call_id;
  v_cdr.term_call_id=i_term_call_id;

  /* removed */
  --v_cdr.dump_file:=i_msg_logger_path;

  v_cdr.dump_level_id:=i_dump_level_id;
  v_cdr.audio_recorded:=i_audio_recorded;

  v_cdr.auth_orig_ip:=i_auth_orig_ip;
  v_cdr.auth_orig_port:=i_auth_orig_port;


  v_rtp_stats_data:=json_populate_record(null::switch.rtp_stats_data_ty, i_rtp_stats_data);

  v_cdr.lega_rx_payloads:=v_rtp_stats_data.lega_rx_payloads;
  v_cdr.lega_tx_payloads:=v_rtp_stats_data.lega_tx_payloads;
  v_cdr.legb_rx_payloads:=v_rtp_stats_data.legb_rx_payloads;
  v_cdr.legb_tx_payloads:=v_rtp_stats_data.legb_tx_payloads;

  v_cdr.lega_rx_bytes:=v_rtp_stats_data.lega_rx_bytes;
  v_cdr.lega_tx_bytes:=v_rtp_stats_data.lega_tx_bytes;
  v_cdr.legb_rx_bytes:=v_rtp_stats_data.legb_rx_bytes;
  v_cdr.legb_tx_bytes:=v_rtp_stats_data.legb_tx_bytes;

  v_cdr.lega_rx_decode_errs:=v_rtp_stats_data.lega_rx_decode_errs;
  v_cdr.lega_rx_no_buf_errs:=v_rtp_stats_data.lega_rx_no_buf_errs;
  v_cdr.lega_rx_parse_errs:=v_rtp_stats_data.lega_rx_parse_errs;
  v_cdr.legb_rx_decode_errs:=v_rtp_stats_data.legb_rx_decode_errs;
  v_cdr.legb_rx_no_buf_errs:=v_rtp_stats_data.legb_rx_no_buf_errs;
  v_cdr.legb_rx_parse_errs:=v_rtp_stats_data.legb_rx_parse_errs;

  v_cdr.global_tag=i_global_tag;

  v_cdr.dst_country_id=i_dst_country_id;
  v_cdr.dst_network_id=i_dst_network_id;
  v_cdr.dst_prefix_routing=i_dst_prefix_routing;
  v_cdr.src_prefix_routing=i_src_prefix_routing;
  v_cdr.routing_plan_id=i_routing_plan_id;
  v_cdr.lrn=i_lrn;
  v_cdr.lnp_database_id=i_lnp_database_id;

  v_cdr.ruri_domain=i_ruri_domain;
  v_cdr.to_domain=i_to_domain;
  v_cdr.from_domain=i_from_domain;

  v_cdr.src_area_id=i_src_area_id;
  v_cdr.dst_area_id=i_dst_area_id;
  v_cdr.routing_tag_id=i_routing_tag_id;


  v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
  v_cdr:=billing.bill_cdr(v_cdr);

  perform stats.update_rt_stats(v_cdr);


  v_billing_event.id=v_cdr.id;
  v_billing_event.customer_id=v_cdr.customer_id;
  v_billing_event.vendor_id=v_cdr.vendor_id;
  v_billing_event.customer_acc_id=v_cdr.customer_acc_id;
  v_billing_event.vendor_acc_id=v_cdr.vendor_acc_id;
  v_billing_event.customer_auth_id=v_cdr.customer_auth_id;
  v_billing_event.destination_id=v_cdr.destination_id;
  v_billing_event.dialpeer_id=v_cdr.dialpeer_id;
  v_billing_event.orig_gw_id=v_cdr.orig_gw_id;
  v_billing_event.term_gw_id=v_cdr.term_gw_id;
  v_billing_event.routing_group_id=v_cdr.routing_group_id;
  v_billing_event.rateplan_id=v_cdr.rateplan_id;
  v_billing_event.destination_next_rate=v_cdr.destination_next_rate;
  v_billing_event.destination_fee=v_cdr.destination_fee;
  v_billing_event.dialpeer_next_rate=v_cdr.dialpeer_next_rate;
  v_billing_event.dialpeer_fee=v_cdr.dialpeer_fee;
  v_billing_event.internal_disconnect_code=v_cdr.internal_disconnect_code;
  v_billing_event.internal_disconnect_reason=v_cdr.internal_disconnect_reason;
  v_billing_event.disconnect_initiator_id=v_cdr.disconnect_initiator_id;
  v_billing_event.customer_price=v_cdr.customer_price;
  v_billing_event.vendor_price=v_cdr.vendor_price;
  v_billing_event.duration=v_cdr.duration;
  v_billing_event.success=v_cdr.success;
  v_billing_event.profit=v_cdr.profit;
  v_billing_event.time_start=v_cdr.time_start;
  v_billing_event.time_connect=v_cdr.time_connect;
  v_billing_event.time_end=v_cdr.time_end;
  v_billing_event.lega_disconnect_code=v_cdr.lega_disconnect_code;
  v_billing_event.lega_disconnect_reason=v_cdr.lega_disconnect_reason;
  v_billing_event.legb_disconnect_code=v_cdr.legb_disconnect_code;
  v_billing_event.legb_disconnect_reason=v_cdr.legb_disconnect_reason;

  -- generate event to routing engine
  perform event.billing_insert_event('cdr_full',v_billing_event);
  INSERT INTO cdr.cdr VALUES( v_cdr.*);
  RETURN 0;
END;
$$;


--
-- Name: writecdr(boolean, integer, integer, integer, boolean, smallint, character varying, integer, character varying, integer, smallint, character varying, integer, character varying, integer, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, integer, boolean, json, character varying, character varying, json, smallint, bigint, json, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, smallint, inet, integer, integer, integer, character varying, character varying, integer, character varying, smallint, character varying, character varying, character varying, integer, integer, smallint); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_transport_protocol_id smallint, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_transport_protocol_id smallint, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id integer, i_audio_recorded boolean, i_rtp_stats_data json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_customer_id character varying, i_vendor_id character varying, i_customer_acc_id character varying, i_vendor_acc_id character varying, i_customer_auth_id character varying, i_destination_id character varying, i_destination_prefix character varying, i_dialpeer_id character varying, i_dialpeer_prefix character varying, i_orig_gw_id character varying, i_term_gw_id character varying, i_routing_group_id character varying, i_rateplan_id character varying, i_destination_initial_rate character varying, i_destination_next_rate character varying, i_destination_initial_interval integer, i_destination_next_interval integer, i_destination_rate_policy_id integer, i_dialpeer_initial_interval integer, i_dialpeer_next_interval integer, i_dialpeer_next_rate character varying, i_destination_fee character varying, i_dialpeer_initial_rate character varying, i_dialpeer_fee character varying, i_dst_prefix_in character varying, i_dst_prefix_out character varying, i_src_prefix_in character varying, i_src_prefix_out character varying, i_src_name_in character varying, i_src_name_out character varying, i_diversion_in character varying, i_diversion_out character varying, i_auth_orig_protocol_id smallint, i_auth_orig_ip inet, i_auth_orig_port integer, i_dst_country_id integer, i_dst_network_id integer, i_dst_prefix_routing character varying, i_src_prefix_routing character varying, i_routing_plan_id integer, i_lrn character varying, i_lnp_database_id smallint, i_from_domain character varying, i_to_domain character varying, i_ruri_domain character varying, i_src_area_id integer, i_dst_area_id integer, i_routing_tag_id smallint) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_cdr cdr.cdr%rowtype;
  v_billing_event billing.cdr_v2;

  v_rtp_stats_data switch.rtp_stats_data_ty;
  v_time_data switch.time_data_ty;


  v_nozerolen boolean;
BEGIN
  --  raise warning 'type: % id: %', i_failed_resource_type_id, i_failed_resource_id;
  --  RAISE warning 'DTMF: %', i_dtmf_events;

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);


  v_cdr.pop_id=i_pop_id;
  v_cdr.node_id=i_node_id;

  v_cdr.src_name_in:=i_src_name_in;
  v_cdr.src_name_out:=i_src_name_out;

  v_cdr.diversion_in:=i_diversion_in;
  v_cdr.diversion_out:=i_diversion_out;

  v_cdr.customer_id:=i_customer_id;
  v_cdr.vendor_id:=i_vendor_id;
  v_cdr.customer_acc_id:=i_customer_acc_id;
  v_cdr.vendor_acc_id:=i_vendor_acc_id;
  v_cdr.customer_auth_id:=i_customer_auth_id;

  v_cdr.destination_id:=i_destination_id;
  v_cdr.destination_prefix:=i_destination_prefix;
  v_cdr.dialpeer_id:=i_dialpeer_id;
  v_cdr.dialpeer_prefix:=i_dialpeer_prefix;

  v_cdr.orig_gw_id:=i_orig_gw_id;
  v_cdr.term_gw_id:=i_term_gw_id;
  v_cdr.routing_group_id:=i_routing_group_id;
  v_cdr.rateplan_id:=i_rateplan_id;

  v_cdr.routing_attempt=i_routing_attempt;
  v_cdr.is_last_cdr=i_is_last_cdr;

  v_cdr.destination_initial_rate:=i_destination_initial_rate::numeric;
  v_cdr.destination_next_rate:=i_destination_next_rate::numeric;
  v_cdr.destination_initial_interval:=i_destination_initial_interval;
  v_cdr.destination_next_interval:=i_destination_next_interval;
  v_cdr.destination_fee:=i_destination_fee;
  v_cdr.destination_rate_policy_id:=i_destination_rate_policy_id;

  v_cdr.dialpeer_initial_rate:=i_dialpeer_initial_rate::numeric;
  v_cdr.dialpeer_next_rate:=i_dialpeer_next_rate::numeric;
  v_cdr.dialpeer_initial_interval:=i_dialpeer_initial_interval;
  v_cdr.dialpeer_next_interval:=i_dialpeer_next_interval;
  v_cdr.dialpeer_fee:=i_dialpeer_fee;


  /* sockets addresses */
  v_cdr.sign_orig_transport_protocol_id=i_lega_transport_protocol_id;
  v_cdr.sign_orig_ip:=i_legA_remote_ip;
  v_cdr.sign_orig_port=i_legA_remote_port;
  v_cdr.sign_orig_local_ip:=i_legA_local_ip;
  v_cdr.sign_orig_local_port=i_legA_local_port;

  v_cdr.sign_term_transport_protocol_id=i_legb_transport_protocol_id;
  v_cdr.sign_term_ip:=i_legB_remote_ip;
  v_cdr.sign_term_port:=NULLIF(i_legB_remote_port,0);
  v_cdr.sign_term_local_ip:=i_legB_local_ip;
  v_cdr.sign_term_local_port:=NULLIF(i_legB_local_port,0);

  v_cdr.local_tag=i_local_tag;

  /* Call time data */
  v_cdr.time_start:=to_timestamp(v_time_data.time_start);
  v_cdr.time_limit:=v_time_data.time_limit;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect:=to_timestamp(v_time_data.time_connect);
    v_cdr.duration:=switch.round(v_time_data.time_end-v_time_data.time_connect); -- rounding
    v_nozerolen:=true;
    v_cdr.success=true;
  else
    v_cdr.time_connect:=NULL;
    v_cdr.duration:=0;
    v_nozerolen:=false;
    v_cdr.success=false;
  end if;
  v_cdr.routing_delay=(v_time_data.leg_b_time-v_time_data.time_start)::real;
  v_cdr.pdd=(coalesce(v_time_data.time_18x,v_time_data.time_connect)-v_time_data.time_start)::real;
  v_cdr.rtt=(coalesce(v_time_data.time_1xx,v_time_data.time_18x,v_time_data.time_connect)-v_time_data.leg_b_time)::real;
  v_cdr.early_media_present=i_early_media_present;

  v_cdr.time_end:=to_timestamp(v_time_data.time_end);

  -- DC processing
  v_cdr.legb_disconnect_code:=i_legb_disconnect_code;
  v_cdr.legb_disconnect_reason:=i_legb_disconnect_reason;
  v_cdr.disconnect_initiator_id:=i_disconnect_initiator;
  v_cdr.internal_disconnect_code:=i_internal_disconnect_code;
  v_cdr.internal_disconnect_reason:=i_internal_disconnect_reason;
  v_cdr.lega_disconnect_code:=i_lega_disconnect_code;
  v_cdr.lega_disconnect_reason:=i_lega_disconnect_reason;

  v_cdr.src_prefix_in:=i_src_prefix_in;
  v_cdr.src_prefix_out:=i_src_prefix_out;
  v_cdr.dst_prefix_in:=i_dst_prefix_in;
  v_cdr.dst_prefix_out:=i_dst_prefix_out;

  v_cdr.orig_call_id=i_orig_call_id;
  v_cdr.term_call_id=i_term_call_id;

  /* removed */
  --v_cdr.dump_file:=i_msg_logger_path;

  v_cdr.dump_level_id:=i_dump_level_id;
  v_cdr.audio_recorded:=i_audio_recorded;

  v_cdr.auth_orig_transport_protocol_id=i_auth_orig_protocol_id;
  v_cdr.auth_orig_ip:=i_auth_orig_ip;
  v_cdr.auth_orig_ip:=i_auth_orig_ip;
  v_cdr.auth_orig_port:=i_auth_orig_port;


  v_rtp_stats_data:=json_populate_record(null::switch.rtp_stats_data_ty, i_rtp_stats_data);

  v_cdr.lega_rx_payloads:=v_rtp_stats_data.lega_rx_payloads;
  v_cdr.lega_tx_payloads:=v_rtp_stats_data.lega_tx_payloads;
  v_cdr.legb_rx_payloads:=v_rtp_stats_data.legb_rx_payloads;
  v_cdr.legb_tx_payloads:=v_rtp_stats_data.legb_tx_payloads;

  v_cdr.lega_rx_bytes:=v_rtp_stats_data.lega_rx_bytes;
  v_cdr.lega_tx_bytes:=v_rtp_stats_data.lega_tx_bytes;
  v_cdr.legb_rx_bytes:=v_rtp_stats_data.legb_rx_bytes;
  v_cdr.legb_tx_bytes:=v_rtp_stats_data.legb_tx_bytes;

  v_cdr.lega_rx_decode_errs:=v_rtp_stats_data.lega_rx_decode_errs;
  v_cdr.lega_rx_no_buf_errs:=v_rtp_stats_data.lega_rx_no_buf_errs;
  v_cdr.lega_rx_parse_errs:=v_rtp_stats_data.lega_rx_parse_errs;
  v_cdr.legb_rx_decode_errs:=v_rtp_stats_data.legb_rx_decode_errs;
  v_cdr.legb_rx_no_buf_errs:=v_rtp_stats_data.legb_rx_no_buf_errs;
  v_cdr.legb_rx_parse_errs:=v_rtp_stats_data.legb_rx_parse_errs;

  v_cdr.global_tag=i_global_tag;

  v_cdr.dst_country_id=i_dst_country_id;
  v_cdr.dst_network_id=i_dst_network_id;
  v_cdr.dst_prefix_routing=i_dst_prefix_routing;
  v_cdr.src_prefix_routing=i_src_prefix_routing;
  v_cdr.routing_plan_id=i_routing_plan_id;
  v_cdr.lrn=i_lrn;
  v_cdr.lnp_database_id=i_lnp_database_id;

  v_cdr.ruri_domain=i_ruri_domain;
  v_cdr.to_domain=i_to_domain;
  v_cdr.from_domain=i_from_domain;

  v_cdr.src_area_id=i_src_area_id;
  v_cdr.dst_area_id=i_dst_area_id;
  v_cdr.routing_tag_id=i_routing_tag_id;


  v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
  v_cdr:=billing.bill_cdr(v_cdr);

  perform stats.update_rt_stats(v_cdr);


  v_billing_event.id=v_cdr.id;
  v_billing_event.customer_id=v_cdr.customer_id;
  v_billing_event.vendor_id=v_cdr.vendor_id;
  v_billing_event.customer_acc_id=v_cdr.customer_acc_id;
  v_billing_event.vendor_acc_id=v_cdr.vendor_acc_id;
  v_billing_event.customer_auth_id=v_cdr.customer_auth_id;
  v_billing_event.destination_id=v_cdr.destination_id;
  v_billing_event.dialpeer_id=v_cdr.dialpeer_id;
  v_billing_event.orig_gw_id=v_cdr.orig_gw_id;
  v_billing_event.term_gw_id=v_cdr.term_gw_id;
  v_billing_event.routing_group_id=v_cdr.routing_group_id;
  v_billing_event.rateplan_id=v_cdr.rateplan_id;
  v_billing_event.destination_next_rate=v_cdr.destination_next_rate;
  v_billing_event.destination_fee=v_cdr.destination_fee;
  v_billing_event.dialpeer_next_rate=v_cdr.dialpeer_next_rate;
  v_billing_event.dialpeer_fee=v_cdr.dialpeer_fee;
  v_billing_event.internal_disconnect_code=v_cdr.internal_disconnect_code;
  v_billing_event.internal_disconnect_reason=v_cdr.internal_disconnect_reason;
  v_billing_event.disconnect_initiator_id=v_cdr.disconnect_initiator_id;
  v_billing_event.customer_price=v_cdr.customer_price;
  v_billing_event.vendor_price=v_cdr.vendor_price;
  v_billing_event.duration=v_cdr.duration;
  v_billing_event.success=v_cdr.success;
  v_billing_event.profit=v_cdr.profit;
  v_billing_event.time_start=v_cdr.time_start;
  v_billing_event.time_connect=v_cdr.time_connect;
  v_billing_event.time_end=v_cdr.time_end;
  v_billing_event.lega_disconnect_code=v_cdr.lega_disconnect_code;
  v_billing_event.lega_disconnect_reason=v_cdr.lega_disconnect_reason;
  v_billing_event.legb_disconnect_code=v_cdr.legb_disconnect_code;
  v_billing_event.legb_disconnect_reason=v_cdr.legb_disconnect_reason;

  -- generate event to routing engine
  perform event.billing_insert_event('cdr_full',v_billing_event);
  INSERT INTO cdr.cdr VALUES( v_cdr.*);
  RETURN 0;
END;
$$;


--
-- Name: writecdr(boolean, integer, integer, integer, boolean, smallint, character varying, integer, character varying, integer, smallint, character varying, integer, character varying, integer, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, integer, boolean, json, character varying, character varying, json, smallint, bigint, json, json, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, smallint, inet, integer, integer, integer, character varying, character varying, integer, character varying, smallint, character varying, character varying, character varying, integer, integer, smallint); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_transport_protocol_id smallint, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_transport_protocol_id smallint, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id integer, i_audio_recorded boolean, i_rtp_stats_data json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_versions json, i_customer_id character varying, i_vendor_id character varying, i_customer_acc_id character varying, i_vendor_acc_id character varying, i_customer_auth_id character varying, i_destination_id character varying, i_destination_prefix character varying, i_dialpeer_id character varying, i_dialpeer_prefix character varying, i_orig_gw_id character varying, i_term_gw_id character varying, i_routing_group_id character varying, i_rateplan_id character varying, i_destination_initial_rate character varying, i_destination_next_rate character varying, i_destination_initial_interval integer, i_destination_next_interval integer, i_destination_rate_policy_id integer, i_dialpeer_initial_interval integer, i_dialpeer_next_interval integer, i_dialpeer_next_rate character varying, i_destination_fee character varying, i_dialpeer_initial_rate character varying, i_dialpeer_fee character varying, i_dst_prefix_in character varying, i_dst_prefix_out character varying, i_src_prefix_in character varying, i_src_prefix_out character varying, i_src_name_in character varying, i_src_name_out character varying, i_diversion_in character varying, i_diversion_out character varying, i_auth_orig_protocol_id smallint, i_auth_orig_ip inet, i_auth_orig_port integer, i_dst_country_id integer, i_dst_network_id integer, i_dst_prefix_routing character varying, i_src_prefix_routing character varying, i_routing_plan_id integer, i_lrn character varying, i_lnp_database_id smallint, i_from_domain character varying, i_to_domain character varying, i_ruri_domain character varying, i_src_area_id integer, i_dst_area_id integer, i_routing_tag_id smallint) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_cdr cdr.cdr%rowtype;
  v_billing_event billing.cdr_v2;

  v_rtp_stats_data switch.rtp_stats_data_ty;
  v_time_data switch.time_data_ty;
  v_version_data switch.versions_ty;


  v_nozerolen boolean;
BEGIN
  --  raise warning 'type: % id: %', i_failed_resource_type_id, i_failed_resource_id;
  --  RAISE warning 'DTMF: %', i_dtmf_events;

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);
  v_version_data:=json_populate_record(null::switch.versions_ty, i_versions);

  v_cdr.core_version=v_version_data.core;
  v_cdr.yeti_version=v_version_data.yeti;
  v_cdr.lega_user_agent=v_version_data.aleg;
  v_cdr.legb_user_agent=v_version_data.bleg;

  v_cdr.pop_id=i_pop_id;
  v_cdr.node_id=i_node_id;

  v_cdr.src_name_in:=i_src_name_in;
  v_cdr.src_name_out:=i_src_name_out;

  v_cdr.diversion_in:=i_diversion_in;
  v_cdr.diversion_out:=i_diversion_out;

  v_cdr.customer_id:=i_customer_id;
  v_cdr.vendor_id:=i_vendor_id;
  v_cdr.customer_acc_id:=i_customer_acc_id;
  v_cdr.vendor_acc_id:=i_vendor_acc_id;
  v_cdr.customer_auth_id:=i_customer_auth_id;

  v_cdr.destination_id:=i_destination_id;
  v_cdr.destination_prefix:=i_destination_prefix;
  v_cdr.dialpeer_id:=i_dialpeer_id;
  v_cdr.dialpeer_prefix:=i_dialpeer_prefix;

  v_cdr.orig_gw_id:=i_orig_gw_id;
  v_cdr.term_gw_id:=i_term_gw_id;
  v_cdr.routing_group_id:=i_routing_group_id;
  v_cdr.rateplan_id:=i_rateplan_id;

  v_cdr.routing_attempt=i_routing_attempt;
  v_cdr.is_last_cdr=i_is_last_cdr;

  v_cdr.destination_initial_rate:=i_destination_initial_rate::numeric;
  v_cdr.destination_next_rate:=i_destination_next_rate::numeric;
  v_cdr.destination_initial_interval:=i_destination_initial_interval;
  v_cdr.destination_next_interval:=i_destination_next_interval;
  v_cdr.destination_fee:=i_destination_fee;
  v_cdr.destination_rate_policy_id:=i_destination_rate_policy_id;

  v_cdr.dialpeer_initial_rate:=i_dialpeer_initial_rate::numeric;
  v_cdr.dialpeer_next_rate:=i_dialpeer_next_rate::numeric;
  v_cdr.dialpeer_initial_interval:=i_dialpeer_initial_interval;
  v_cdr.dialpeer_next_interval:=i_dialpeer_next_interval;
  v_cdr.dialpeer_fee:=i_dialpeer_fee;


  /* sockets addresses */
  v_cdr.sign_orig_transport_protocol_id=i_lega_transport_protocol_id;
  v_cdr.sign_orig_ip:=i_legA_remote_ip;
  v_cdr.sign_orig_port=i_legA_remote_port;
  v_cdr.sign_orig_local_ip:=i_legA_local_ip;
  v_cdr.sign_orig_local_port=i_legA_local_port;

  v_cdr.sign_term_transport_protocol_id=i_legb_transport_protocol_id;
  v_cdr.sign_term_ip:=i_legB_remote_ip;
  v_cdr.sign_term_port:=NULLIF(i_legB_remote_port,0);
  v_cdr.sign_term_local_ip:=i_legB_local_ip;
  v_cdr.sign_term_local_port:=NULLIF(i_legB_local_port,0);

  v_cdr.local_tag=i_local_tag;

  /* Call time data */
  v_cdr.time_start:=to_timestamp(v_time_data.time_start);
  v_cdr.time_limit:=v_time_data.time_limit;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect:=to_timestamp(v_time_data.time_connect);
    v_cdr.duration:=switch.round(v_time_data.time_end-v_time_data.time_connect); -- rounding
    v_nozerolen:=true;
    v_cdr.success=true;
  else
    v_cdr.time_connect:=NULL;
    v_cdr.duration:=0;
    v_nozerolen:=false;
    v_cdr.success=false;
  end if;
  v_cdr.routing_delay=(v_time_data.leg_b_time-v_time_data.time_start)::real;
  v_cdr.pdd=(coalesce(v_time_data.time_18x,v_time_data.time_connect)-v_time_data.time_start)::real;
  v_cdr.rtt=(coalesce(v_time_data.time_1xx,v_time_data.time_18x,v_time_data.time_connect)-v_time_data.leg_b_time)::real;
  v_cdr.early_media_present=i_early_media_present;

  v_cdr.time_end:=to_timestamp(v_time_data.time_end);

  -- DC processing
  v_cdr.legb_disconnect_code:=i_legb_disconnect_code;
  v_cdr.legb_disconnect_reason:=i_legb_disconnect_reason;
  v_cdr.disconnect_initiator_id:=i_disconnect_initiator;
  v_cdr.internal_disconnect_code:=i_internal_disconnect_code;
  v_cdr.internal_disconnect_reason:=i_internal_disconnect_reason;
  v_cdr.lega_disconnect_code:=i_lega_disconnect_code;
  v_cdr.lega_disconnect_reason:=i_lega_disconnect_reason;

  v_cdr.src_prefix_in:=i_src_prefix_in;
  v_cdr.src_prefix_out:=i_src_prefix_out;
  v_cdr.dst_prefix_in:=i_dst_prefix_in;
  v_cdr.dst_prefix_out:=i_dst_prefix_out;

  v_cdr.orig_call_id=i_orig_call_id;
  v_cdr.term_call_id=i_term_call_id;

  /* removed */
  --v_cdr.dump_file:=i_msg_logger_path;

  v_cdr.dump_level_id:=i_dump_level_id;
  v_cdr.audio_recorded:=i_audio_recorded;

  v_cdr.auth_orig_transport_protocol_id=i_auth_orig_protocol_id;
  v_cdr.auth_orig_ip:=i_auth_orig_ip;
  v_cdr.auth_orig_ip:=i_auth_orig_ip;
  v_cdr.auth_orig_port:=i_auth_orig_port;


  v_rtp_stats_data:=json_populate_record(null::switch.rtp_stats_data_ty, i_rtp_stats_data);

  v_cdr.lega_rx_payloads:=v_rtp_stats_data.lega_rx_payloads;
  v_cdr.lega_tx_payloads:=v_rtp_stats_data.lega_tx_payloads;
  v_cdr.legb_rx_payloads:=v_rtp_stats_data.legb_rx_payloads;
  v_cdr.legb_tx_payloads:=v_rtp_stats_data.legb_tx_payloads;

  v_cdr.lega_rx_bytes:=v_rtp_stats_data.lega_rx_bytes;
  v_cdr.lega_tx_bytes:=v_rtp_stats_data.lega_tx_bytes;
  v_cdr.legb_rx_bytes:=v_rtp_stats_data.legb_rx_bytes;
  v_cdr.legb_tx_bytes:=v_rtp_stats_data.legb_tx_bytes;

  v_cdr.lega_rx_decode_errs:=v_rtp_stats_data.lega_rx_decode_errs;
  v_cdr.lega_rx_no_buf_errs:=v_rtp_stats_data.lega_rx_no_buf_errs;
  v_cdr.lega_rx_parse_errs:=v_rtp_stats_data.lega_rx_parse_errs;
  v_cdr.legb_rx_decode_errs:=v_rtp_stats_data.legb_rx_decode_errs;
  v_cdr.legb_rx_no_buf_errs:=v_rtp_stats_data.legb_rx_no_buf_errs;
  v_cdr.legb_rx_parse_errs:=v_rtp_stats_data.legb_rx_parse_errs;

  v_cdr.global_tag=i_global_tag;

  v_cdr.dst_country_id=i_dst_country_id;
  v_cdr.dst_network_id=i_dst_network_id;
  v_cdr.dst_prefix_routing=i_dst_prefix_routing;
  v_cdr.src_prefix_routing=i_src_prefix_routing;
  v_cdr.routing_plan_id=i_routing_plan_id;
  v_cdr.lrn=i_lrn;
  v_cdr.lnp_database_id=i_lnp_database_id;

  v_cdr.ruri_domain=i_ruri_domain;
  v_cdr.to_domain=i_to_domain;
  v_cdr.from_domain=i_from_domain;

  v_cdr.src_area_id=i_src_area_id;
  v_cdr.dst_area_id=i_dst_area_id;
  v_cdr.routing_tag_id=i_routing_tag_id;


  v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
  v_cdr:=billing.bill_cdr(v_cdr);

  perform stats.update_rt_stats(v_cdr);


  v_billing_event.id=v_cdr.id;
  v_billing_event.customer_id=v_cdr.customer_id;
  v_billing_event.vendor_id=v_cdr.vendor_id;
  v_billing_event.customer_acc_id=v_cdr.customer_acc_id;
  v_billing_event.vendor_acc_id=v_cdr.vendor_acc_id;
  v_billing_event.customer_auth_id=v_cdr.customer_auth_id;
  v_billing_event.destination_id=v_cdr.destination_id;
  v_billing_event.dialpeer_id=v_cdr.dialpeer_id;
  v_billing_event.orig_gw_id=v_cdr.orig_gw_id;
  v_billing_event.term_gw_id=v_cdr.term_gw_id;
  v_billing_event.routing_group_id=v_cdr.routing_group_id;
  v_billing_event.rateplan_id=v_cdr.rateplan_id;
  v_billing_event.destination_next_rate=v_cdr.destination_next_rate;
  v_billing_event.destination_fee=v_cdr.destination_fee;
  v_billing_event.dialpeer_next_rate=v_cdr.dialpeer_next_rate;
  v_billing_event.dialpeer_fee=v_cdr.dialpeer_fee;
  v_billing_event.internal_disconnect_code=v_cdr.internal_disconnect_code;
  v_billing_event.internal_disconnect_reason=v_cdr.internal_disconnect_reason;
  v_billing_event.disconnect_initiator_id=v_cdr.disconnect_initiator_id;
  v_billing_event.customer_price=v_cdr.customer_price;
  v_billing_event.vendor_price=v_cdr.vendor_price;
  v_billing_event.duration=v_cdr.duration;
  v_billing_event.success=v_cdr.success;
  v_billing_event.profit=v_cdr.profit;
  v_billing_event.time_start=v_cdr.time_start;
  v_billing_event.time_connect=v_cdr.time_connect;
  v_billing_event.time_end=v_cdr.time_end;
  v_billing_event.lega_disconnect_code=v_cdr.lega_disconnect_code;
  v_billing_event.lega_disconnect_reason=v_cdr.lega_disconnect_reason;
  v_billing_event.legb_disconnect_code=v_cdr.legb_disconnect_code;
  v_billing_event.legb_disconnect_reason=v_cdr.legb_disconnect_reason;
  v_billing_event.src_prefix_in=v_cdr.src_prefix_in;
  v_billing_event.src_prefix_out=v_cdr.src_prefix_out;
  v_billing_event.dst_prefix_in=v_cdr.dst_prefix_in;
  v_billing_event.dst_prefix_out=v_cdr.dst_prefix_out;
  v_billing_event.destination_initial_interval=v_cdr.destination_initial_interval;
  v_billing_event.destination_next_interval=v_cdr.destination_next_interval;
  v_billing_event.destination_initial_rate=v_cdr.destination_initial_rate;
  v_billing_event.orig_call_id=v_cdr.orig_call_id;
  v_billing_event.term_call_id=v_cdr.term_call_id;
  v_billing_event.local_tag=v_cdr.local_tag;
  v_billing_event.from_domain=v_cdr.from_domain;

  -- generate event to routing engine
  perform event.billing_insert_event('cdr_full',v_billing_event);
  INSERT INTO cdr.cdr VALUES( v_cdr.*);
  RETURN 0;
END;
$$;


--
-- Name: writecdr(boolean, integer, integer, integer, boolean, smallint, character varying, integer, character varying, integer, smallint, character varying, integer, character varying, integer, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, integer, boolean, json, character varying, character varying, json, smallint, bigint, json, json, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, smallint, inet, integer, integer, integer, character varying, character varying, integer, character varying, smallint, character varying, character varying, character varying, integer, integer, smallint, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_transport_protocol_id smallint, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_transport_protocol_id smallint, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id integer, i_audio_recorded boolean, i_rtp_stats_data json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_versions json, i_customer_id character varying, i_vendor_id character varying, i_customer_acc_id character varying, i_vendor_acc_id character varying, i_customer_auth_id character varying, i_destination_id character varying, i_destination_prefix character varying, i_dialpeer_id character varying, i_dialpeer_prefix character varying, i_orig_gw_id character varying, i_term_gw_id character varying, i_routing_group_id character varying, i_rateplan_id character varying, i_destination_initial_rate character varying, i_destination_next_rate character varying, i_destination_initial_interval integer, i_destination_next_interval integer, i_destination_rate_policy_id integer, i_dialpeer_initial_interval integer, i_dialpeer_next_interval integer, i_dialpeer_next_rate character varying, i_destination_fee character varying, i_dialpeer_initial_rate character varying, i_dialpeer_fee character varying, i_dst_prefix_in character varying, i_dst_prefix_out character varying, i_src_prefix_in character varying, i_src_prefix_out character varying, i_src_name_in character varying, i_src_name_out character varying, i_diversion_in character varying, i_diversion_out character varying, i_auth_orig_protocol_id smallint, i_auth_orig_ip inet, i_auth_orig_port integer, i_dst_country_id integer, i_dst_network_id integer, i_dst_prefix_routing character varying, i_src_prefix_routing character varying, i_routing_plan_id integer, i_lrn character varying, i_lnp_database_id smallint, i_from_domain character varying, i_to_domain character varying, i_ruri_domain character varying, i_src_area_id integer, i_dst_area_id integer, i_routing_tag_id smallint, i_pai_in character varying, i_ppi_in character varying, i_privacy_in character varying, i_rpid_in character varying, i_rpid_privacy_in character varying, i_pai_out character varying, i_ppi_out character varying, i_privacy_out character varying, i_rpid_out character varying, i_rpid_privacy_out character varying) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_cdr cdr.cdr%rowtype;
  v_billing_event billing.cdr_v2;

  v_rtp_stats_data switch.rtp_stats_data_ty;
  v_time_data switch.time_data_ty;
  v_version_data switch.versions_ty;


  v_nozerolen boolean;
BEGIN
  --  raise warning 'type: % id: %', i_failed_resource_type_id, i_failed_resource_id;
  --  RAISE warning 'DTMF: %', i_dtmf_events;

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);
  v_version_data:=json_populate_record(null::switch.versions_ty, i_versions);

  v_cdr.core_version=v_version_data.core;
  v_cdr.yeti_version=v_version_data.yeti;
  v_cdr.lega_user_agent=v_version_data.aleg;
  v_cdr.legb_user_agent=v_version_data.bleg;

  v_cdr.pop_id=i_pop_id;
  v_cdr.node_id=i_node_id;

  v_cdr.src_name_in:=i_src_name_in;
  v_cdr.src_name_out:=i_src_name_out;

  v_cdr.diversion_in:=i_diversion_in;
  v_cdr.diversion_out:=i_diversion_out;

  v_cdr.customer_id:=i_customer_id;
  v_cdr.vendor_id:=i_vendor_id;
  v_cdr.customer_acc_id:=i_customer_acc_id;
  v_cdr.vendor_acc_id:=i_vendor_acc_id;
  v_cdr.customer_auth_id:=i_customer_auth_id;

  v_cdr.destination_id:=i_destination_id;
  v_cdr.destination_prefix:=i_destination_prefix;
  v_cdr.dialpeer_id:=i_dialpeer_id;
  v_cdr.dialpeer_prefix:=i_dialpeer_prefix;

  v_cdr.orig_gw_id:=i_orig_gw_id;
  v_cdr.term_gw_id:=i_term_gw_id;
  v_cdr.routing_group_id:=i_routing_group_id;
  v_cdr.rateplan_id:=i_rateplan_id;

  v_cdr.routing_attempt=i_routing_attempt;
  v_cdr.is_last_cdr=i_is_last_cdr;

  v_cdr.destination_initial_rate:=i_destination_initial_rate::numeric;
  v_cdr.destination_next_rate:=i_destination_next_rate::numeric;
  v_cdr.destination_initial_interval:=i_destination_initial_interval;
  v_cdr.destination_next_interval:=i_destination_next_interval;
  v_cdr.destination_fee:=i_destination_fee;
  v_cdr.destination_rate_policy_id:=i_destination_rate_policy_id;

  v_cdr.dialpeer_initial_rate:=i_dialpeer_initial_rate::numeric;
  v_cdr.dialpeer_next_rate:=i_dialpeer_next_rate::numeric;
  v_cdr.dialpeer_initial_interval:=i_dialpeer_initial_interval;
  v_cdr.dialpeer_next_interval:=i_dialpeer_next_interval;
  v_cdr.dialpeer_fee:=i_dialpeer_fee;


  /* sockets addresses */
  v_cdr.sign_orig_transport_protocol_id=i_lega_transport_protocol_id;
  v_cdr.sign_orig_ip:=i_legA_remote_ip;
  v_cdr.sign_orig_port=i_legA_remote_port;
  v_cdr.sign_orig_local_ip:=i_legA_local_ip;
  v_cdr.sign_orig_local_port=i_legA_local_port;

  v_cdr.sign_term_transport_protocol_id=i_legb_transport_protocol_id;
  v_cdr.sign_term_ip:=i_legB_remote_ip;
  v_cdr.sign_term_port:=NULLIF(i_legB_remote_port,0);
  v_cdr.sign_term_local_ip:=i_legB_local_ip;
  v_cdr.sign_term_local_port:=NULLIF(i_legB_local_port,0);

  v_cdr.local_tag=i_local_tag;

  /* Call time data */
  v_cdr.time_start:=to_timestamp(v_time_data.time_start);
  v_cdr.time_limit:=v_time_data.time_limit;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect:=to_timestamp(v_time_data.time_connect);
    v_cdr.duration:=switch.round(v_time_data.time_end-v_time_data.time_connect); -- rounding
    v_nozerolen:=true;
    v_cdr.success=true;
  else
    v_cdr.time_connect:=NULL;
    v_cdr.duration:=0;
    v_nozerolen:=false;
    v_cdr.success=false;
  end if;
  v_cdr.routing_delay=(v_time_data.leg_b_time-v_time_data.time_start)::real;
  v_cdr.pdd=(coalesce(v_time_data.time_18x,v_time_data.time_connect)-v_time_data.time_start)::real;
  v_cdr.rtt=(coalesce(v_time_data.time_1xx,v_time_data.time_18x,v_time_data.time_connect)-v_time_data.leg_b_time)::real;
  v_cdr.early_media_present=i_early_media_present;

  v_cdr.time_end:=to_timestamp(v_time_data.time_end);

  -- DC processing
  v_cdr.legb_disconnect_code:=i_legb_disconnect_code;
  v_cdr.legb_disconnect_reason:=i_legb_disconnect_reason;
  v_cdr.disconnect_initiator_id:=i_disconnect_initiator;
  v_cdr.internal_disconnect_code:=i_internal_disconnect_code;
  v_cdr.internal_disconnect_reason:=i_internal_disconnect_reason;
  v_cdr.lega_disconnect_code:=i_lega_disconnect_code;
  v_cdr.lega_disconnect_reason:=i_lega_disconnect_reason;

  v_cdr.src_prefix_in:=i_src_prefix_in;
  v_cdr.src_prefix_out:=i_src_prefix_out;
  v_cdr.dst_prefix_in:=i_dst_prefix_in;
  v_cdr.dst_prefix_out:=i_dst_prefix_out;

  v_cdr.orig_call_id=i_orig_call_id;
  v_cdr.term_call_id=i_term_call_id;

  /* removed */
  --v_cdr.dump_file:=i_msg_logger_path;

  v_cdr.dump_level_id:=i_dump_level_id;
  v_cdr.audio_recorded:=i_audio_recorded;

  v_cdr.auth_orig_transport_protocol_id=i_auth_orig_protocol_id;
  v_cdr.auth_orig_ip:=i_auth_orig_ip;
  v_cdr.auth_orig_ip:=i_auth_orig_ip;
  v_cdr.auth_orig_port:=i_auth_orig_port;


  v_rtp_stats_data:=json_populate_record(null::switch.rtp_stats_data_ty, i_rtp_stats_data);

  v_cdr.lega_rx_payloads:=v_rtp_stats_data.lega_rx_payloads;
  v_cdr.lega_tx_payloads:=v_rtp_stats_data.lega_tx_payloads;
  v_cdr.legb_rx_payloads:=v_rtp_stats_data.legb_rx_payloads;
  v_cdr.legb_tx_payloads:=v_rtp_stats_data.legb_tx_payloads;

  v_cdr.lega_rx_bytes:=v_rtp_stats_data.lega_rx_bytes;
  v_cdr.lega_tx_bytes:=v_rtp_stats_data.lega_tx_bytes;
  v_cdr.legb_rx_bytes:=v_rtp_stats_data.legb_rx_bytes;
  v_cdr.legb_tx_bytes:=v_rtp_stats_data.legb_tx_bytes;

  v_cdr.lega_rx_decode_errs:=v_rtp_stats_data.lega_rx_decode_errs;
  v_cdr.lega_rx_no_buf_errs:=v_rtp_stats_data.lega_rx_no_buf_errs;
  v_cdr.lega_rx_parse_errs:=v_rtp_stats_data.lega_rx_parse_errs;
  v_cdr.legb_rx_decode_errs:=v_rtp_stats_data.legb_rx_decode_errs;
  v_cdr.legb_rx_no_buf_errs:=v_rtp_stats_data.legb_rx_no_buf_errs;
  v_cdr.legb_rx_parse_errs:=v_rtp_stats_data.legb_rx_parse_errs;

  v_cdr.global_tag=i_global_tag;

  v_cdr.dst_country_id=i_dst_country_id;
  v_cdr.dst_network_id=i_dst_network_id;
  v_cdr.dst_prefix_routing=i_dst_prefix_routing;
  v_cdr.src_prefix_routing=i_src_prefix_routing;
  v_cdr.routing_plan_id=i_routing_plan_id;
  v_cdr.lrn=i_lrn;
  v_cdr.lnp_database_id=i_lnp_database_id;

  v_cdr.ruri_domain=i_ruri_domain;
  v_cdr.to_domain=i_to_domain;
  v_cdr.from_domain=i_from_domain;

  v_cdr.src_area_id=i_src_area_id;
  v_cdr.dst_area_id=i_dst_area_id;
  v_cdr.routing_tag_id=i_routing_tag_id;


  v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
  v_cdr.uuid:=public.uuid_generate_v1();

  v_cdr.pai_in=i_pai_in;
  v_cdr.ppi_in=i_ppi_in;
  v_cdr.privacy_in=i_privacy_in;
  v_cdr.rpid_in=i_rpid_in;
  v_cdr.rpid_privacy_in=i_rpid_privacy_in;
  v_cdr.pai_out=i_pai_out;
  v_cdr.ppi_out=i_ppi_out;
  v_cdr.privacy_out=i_privacy_out;
  v_cdr.rpid_out=i_rpid_out;
  v_cdr.rpid_privacy_out=i_rpid_privacy_out;


  v_cdr:=billing.bill_cdr(v_cdr);

  perform stats.update_rt_stats(v_cdr);

  v_billing_event.id=v_cdr.id;
  v_billing_event.customer_id=v_cdr.customer_id;
  v_billing_event.vendor_id=v_cdr.vendor_id;
  v_billing_event.customer_acc_id=v_cdr.customer_acc_id;
  v_billing_event.vendor_acc_id=v_cdr.vendor_acc_id;
  v_billing_event.customer_auth_id=v_cdr.customer_auth_id;
  v_billing_event.destination_id=v_cdr.destination_id;
  v_billing_event.dialpeer_id=v_cdr.dialpeer_id;
  v_billing_event.orig_gw_id=v_cdr.orig_gw_id;
  v_billing_event.term_gw_id=v_cdr.term_gw_id;
  v_billing_event.routing_group_id=v_cdr.routing_group_id;
  v_billing_event.rateplan_id=v_cdr.rateplan_id;
  v_billing_event.destination_next_rate=v_cdr.destination_next_rate;
  v_billing_event.destination_fee=v_cdr.destination_fee;
  v_billing_event.dialpeer_next_rate=v_cdr.dialpeer_next_rate;
  v_billing_event.dialpeer_fee=v_cdr.dialpeer_fee;
  v_billing_event.internal_disconnect_code=v_cdr.internal_disconnect_code;
  v_billing_event.internal_disconnect_reason=v_cdr.internal_disconnect_reason;
  v_billing_event.disconnect_initiator_id=v_cdr.disconnect_initiator_id;
  v_billing_event.customer_price=v_cdr.customer_price;
  v_billing_event.vendor_price=v_cdr.vendor_price;
  v_billing_event.duration=v_cdr.duration;
  v_billing_event.success=v_cdr.success;
  v_billing_event.profit=v_cdr.profit;
  v_billing_event.time_start=v_cdr.time_start;
  v_billing_event.time_connect=v_cdr.time_connect;
  v_billing_event.time_end=v_cdr.time_end;
  v_billing_event.lega_disconnect_code=v_cdr.lega_disconnect_code;
  v_billing_event.lega_disconnect_reason=v_cdr.lega_disconnect_reason;
  v_billing_event.legb_disconnect_code=v_cdr.legb_disconnect_code;
  v_billing_event.legb_disconnect_reason=v_cdr.legb_disconnect_reason;
  v_billing_event.src_prefix_in=v_cdr.src_prefix_in;
  v_billing_event.src_prefix_out=v_cdr.src_prefix_out;
  v_billing_event.dst_prefix_in=v_cdr.dst_prefix_in;
  v_billing_event.dst_prefix_out=v_cdr.dst_prefix_out;
  v_billing_event.destination_initial_interval=v_cdr.destination_initial_interval;
  v_billing_event.destination_next_interval=v_cdr.destination_next_interval;
  v_billing_event.destination_initial_rate=v_cdr.destination_initial_rate;
  v_billing_event.orig_call_id=v_cdr.orig_call_id;
  v_billing_event.term_call_id=v_cdr.term_call_id;
  v_billing_event.local_tag=v_cdr.local_tag;
  v_billing_event.from_domain=v_cdr.from_domain;

  -- generate event to routing engine
  perform event.billing_insert_event('cdr_full',v_billing_event);
  INSERT INTO cdr.cdr VALUES( v_cdr.*);
  RETURN 0;
END;
$$;


--
-- Name: writecdr(boolean, integer, integer, integer, boolean, smallint, character varying, integer, character varying, integer, smallint, character varying, integer, character varying, integer, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, integer, boolean, json, character varying, character varying, json, smallint, bigint, json, json, boolean, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, smallint, inet, integer, integer, integer, character varying, character varying, integer, character varying, smallint, character varying, character varying, character varying, integer, integer, smallint, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, boolean, boolean, boolean); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_transport_protocol_id smallint, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_transport_protocol_id smallint, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id integer, i_audio_recorded boolean, i_rtp_stats_data json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_versions json, i_is_redirected boolean, i_customer_id character varying, i_vendor_id character varying, i_customer_acc_id character varying, i_vendor_acc_id character varying, i_customer_auth_id character varying, i_destination_id character varying, i_destination_prefix character varying, i_dialpeer_id character varying, i_dialpeer_prefix character varying, i_orig_gw_id character varying, i_term_gw_id character varying, i_routing_group_id character varying, i_rateplan_id character varying, i_destination_initial_rate character varying, i_destination_next_rate character varying, i_destination_initial_interval integer, i_destination_next_interval integer, i_destination_rate_policy_id integer, i_dialpeer_initial_interval integer, i_dialpeer_next_interval integer, i_dialpeer_next_rate character varying, i_destination_fee character varying, i_dialpeer_initial_rate character varying, i_dialpeer_fee character varying, i_dst_prefix_in character varying, i_dst_prefix_out character varying, i_src_prefix_in character varying, i_src_prefix_out character varying, i_src_name_in character varying, i_src_name_out character varying, i_diversion_in character varying, i_diversion_out character varying, i_auth_orig_protocol_id smallint, i_auth_orig_ip inet, i_auth_orig_port integer, i_dst_country_id integer, i_dst_network_id integer, i_dst_prefix_routing character varying, i_src_prefix_routing character varying, i_routing_plan_id integer, i_lrn character varying, i_lnp_database_id smallint, i_from_domain character varying, i_to_domain character varying, i_ruri_domain character varying, i_src_area_id integer, i_dst_area_id integer, i_routing_tag_id smallint, i_pai_in character varying, i_ppi_in character varying, i_privacy_in character varying, i_rpid_in character varying, i_rpid_privacy_in character varying, i_pai_out character varying, i_ppi_out character varying, i_privacy_out character varying, i_rpid_out character varying, i_rpid_privacy_out character varying, i_customer_acc_check_balance boolean, i_destination_reverse_billing boolean, i_dialpeer_reverse_billing boolean) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_cdr cdr.cdr%rowtype;
  v_billing_event billing.cdr_v2;

  v_rtp_stats_data switch.rtp_stats_data_ty;
  v_time_data switch.time_data_ty;
  v_version_data switch.versions_ty;


  v_nozerolen boolean;
BEGIN
  --  raise warning 'type: % id: %', i_failed_resource_type_id, i_failed_resource_id;
  --  RAISE warning 'DTMF: %', i_dtmf_events;

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);
  v_version_data:=json_populate_record(null::switch.versions_ty, i_versions);

  v_cdr.core_version=v_version_data.core;
  v_cdr.yeti_version=v_version_data.yeti;
  v_cdr.lega_user_agent=v_version_data.aleg;
  v_cdr.legb_user_agent=v_version_data.bleg;

  v_cdr.pop_id=i_pop_id;
  v_cdr.node_id=i_node_id;

  v_cdr.src_name_in:=i_src_name_in;
  v_cdr.src_name_out:=i_src_name_out;

  v_cdr.diversion_in:=i_diversion_in;
  v_cdr.diversion_out:=i_diversion_out;

  v_cdr.customer_id:=i_customer_id;
  v_cdr.customer_account_check_balance=i_customer_acc_check_balance;

  v_cdr.vendor_id:=i_vendor_id;
  v_cdr.customer_acc_id:=i_customer_acc_id;
  v_cdr.vendor_acc_id:=i_vendor_acc_id;
  v_cdr.customer_auth_id:=i_customer_auth_id;

  v_cdr.destination_id:=i_destination_id;
  v_cdr.destination_prefix:=i_destination_prefix;
  v_cdr.dialpeer_id:=i_dialpeer_id;
  v_cdr.dialpeer_prefix:=i_dialpeer_prefix;

  v_cdr.orig_gw_id:=i_orig_gw_id;
  v_cdr.term_gw_id:=i_term_gw_id;
  v_cdr.routing_group_id:=i_routing_group_id;
  v_cdr.rateplan_id:=i_rateplan_id;

  v_cdr.routing_attempt=i_routing_attempt;
  v_cdr.is_last_cdr=i_is_last_cdr;

  v_cdr.destination_initial_rate:=i_destination_initial_rate::numeric;
  v_cdr.destination_next_rate:=i_destination_next_rate::numeric;
  v_cdr.destination_initial_interval:=i_destination_initial_interval;
  v_cdr.destination_next_interval:=i_destination_next_interval;
  v_cdr.destination_fee:=i_destination_fee;
  v_cdr.destination_rate_policy_id:=i_destination_rate_policy_id;
  v_cdr.destination_reverse_billing=i_destination_reverse_billing;

  v_cdr.dialpeer_initial_rate:=i_dialpeer_initial_rate::numeric;
  v_cdr.dialpeer_next_rate:=i_dialpeer_next_rate::numeric;
  v_cdr.dialpeer_initial_interval:=i_dialpeer_initial_interval;
  v_cdr.dialpeer_next_interval:=i_dialpeer_next_interval;
  v_cdr.dialpeer_fee:=i_dialpeer_fee;
  v_cdr.dialpeer_reverse_billing=i_dialpeer_reverse_billing;

  /* sockets addresses */
  v_cdr.sign_orig_transport_protocol_id=i_lega_transport_protocol_id;
  v_cdr.sign_orig_ip:=i_legA_remote_ip;
  v_cdr.sign_orig_port=i_legA_remote_port;
  v_cdr.sign_orig_local_ip:=i_legA_local_ip;
  v_cdr.sign_orig_local_port=i_legA_local_port;

  v_cdr.sign_term_transport_protocol_id=i_legb_transport_protocol_id;
  v_cdr.sign_term_ip:=i_legB_remote_ip;
  v_cdr.sign_term_port:=NULLIF(i_legB_remote_port,0);
  v_cdr.sign_term_local_ip:=i_legB_local_ip;
  v_cdr.sign_term_local_port:=NULLIF(i_legB_local_port,0);

  v_cdr.local_tag=i_local_tag;

  v_cdr.is_redirected=i_is_redirected;

  /* Call time data */
  v_cdr.time_start:=to_timestamp(v_time_data.time_start);
  v_cdr.time_limit:=v_time_data.time_limit;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect:=to_timestamp(v_time_data.time_connect);
    v_cdr.duration:=switch.round(v_time_data.time_end-v_time_data.time_connect); -- rounding
    v_nozerolen:=true;
    v_cdr.success=true;
  else
    v_cdr.time_connect:=NULL;
    v_cdr.duration:=0;
    v_nozerolen:=false;
    v_cdr.success=false;
  end if;
  v_cdr.routing_delay=(v_time_data.leg_b_time-v_time_data.time_start)::real;
  v_cdr.pdd=(coalesce(v_time_data.time_18x,v_time_data.time_connect)-v_time_data.time_start)::real;
  v_cdr.rtt=(coalesce(v_time_data.time_1xx,v_time_data.time_18x,v_time_data.time_connect)-v_time_data.leg_b_time)::real;
  v_cdr.early_media_present=i_early_media_present;

  v_cdr.time_end:=to_timestamp(v_time_data.time_end);

  -- DC processing
  v_cdr.legb_disconnect_code:=i_legb_disconnect_code;
  v_cdr.legb_disconnect_reason:=i_legb_disconnect_reason;
  v_cdr.disconnect_initiator_id:=i_disconnect_initiator;
  v_cdr.internal_disconnect_code:=i_internal_disconnect_code;
  v_cdr.internal_disconnect_reason:=i_internal_disconnect_reason;
  v_cdr.lega_disconnect_code:=i_lega_disconnect_code;
  v_cdr.lega_disconnect_reason:=i_lega_disconnect_reason;

  v_cdr.src_prefix_in:=i_src_prefix_in;
  v_cdr.src_prefix_out:=i_src_prefix_out;
  v_cdr.dst_prefix_in:=i_dst_prefix_in;
  v_cdr.dst_prefix_out:=i_dst_prefix_out;

  v_cdr.orig_call_id=i_orig_call_id;
  v_cdr.term_call_id=i_term_call_id;

  /* removed */
  --v_cdr.dump_file:=i_msg_logger_path;

  v_cdr.dump_level_id:=i_dump_level_id;
  v_cdr.audio_recorded:=i_audio_recorded;

  v_cdr.auth_orig_transport_protocol_id=i_auth_orig_protocol_id;
  v_cdr.auth_orig_ip:=i_auth_orig_ip;
  v_cdr.auth_orig_ip:=i_auth_orig_ip;
  v_cdr.auth_orig_port:=i_auth_orig_port;


  v_rtp_stats_data:=json_populate_record(null::switch.rtp_stats_data_ty, i_rtp_stats_data);

  v_cdr.lega_rx_payloads:=v_rtp_stats_data.lega_rx_payloads;
  v_cdr.lega_tx_payloads:=v_rtp_stats_data.lega_tx_payloads;
  v_cdr.legb_rx_payloads:=v_rtp_stats_data.legb_rx_payloads;
  v_cdr.legb_tx_payloads:=v_rtp_stats_data.legb_tx_payloads;

  v_cdr.lega_rx_bytes:=v_rtp_stats_data.lega_rx_bytes;
  v_cdr.lega_tx_bytes:=v_rtp_stats_data.lega_tx_bytes;
  v_cdr.legb_rx_bytes:=v_rtp_stats_data.legb_rx_bytes;
  v_cdr.legb_tx_bytes:=v_rtp_stats_data.legb_tx_bytes;

  v_cdr.lega_rx_decode_errs:=v_rtp_stats_data.lega_rx_decode_errs;
  v_cdr.lega_rx_no_buf_errs:=v_rtp_stats_data.lega_rx_no_buf_errs;
  v_cdr.lega_rx_parse_errs:=v_rtp_stats_data.lega_rx_parse_errs;
  v_cdr.legb_rx_decode_errs:=v_rtp_stats_data.legb_rx_decode_errs;
  v_cdr.legb_rx_no_buf_errs:=v_rtp_stats_data.legb_rx_no_buf_errs;
  v_cdr.legb_rx_parse_errs:=v_rtp_stats_data.legb_rx_parse_errs;

  v_cdr.global_tag=i_global_tag;

  v_cdr.dst_country_id=i_dst_country_id;
  v_cdr.dst_network_id=i_dst_network_id;
  v_cdr.dst_prefix_routing=i_dst_prefix_routing;
  v_cdr.src_prefix_routing=i_src_prefix_routing;
  v_cdr.routing_plan_id=i_routing_plan_id;
  v_cdr.lrn=i_lrn;
  v_cdr.lnp_database_id=i_lnp_database_id;

  v_cdr.ruri_domain=i_ruri_domain;
  v_cdr.to_domain=i_to_domain;
  v_cdr.from_domain=i_from_domain;

  v_cdr.src_area_id=i_src_area_id;
  v_cdr.dst_area_id=i_dst_area_id;
  v_cdr.routing_tag_id=i_routing_tag_id;


  v_cdr.id:=nextval('cdr.cdr_id_seq'::regclass);
  v_cdr.uuid:=public.uuid_generate_v1();

  v_cdr.pai_in=i_pai_in;
  v_cdr.ppi_in=i_ppi_in;
  v_cdr.privacy_in=i_privacy_in;
  v_cdr.rpid_in=i_rpid_in;
  v_cdr.rpid_privacy_in=i_rpid_privacy_in;
  v_cdr.pai_out=i_pai_out;
  v_cdr.ppi_out=i_ppi_out;
  v_cdr.privacy_out=i_privacy_out;
  v_cdr.rpid_out=i_rpid_out;
  v_cdr.rpid_privacy_out=i_rpid_privacy_out;


  v_cdr:=billing.bill_cdr(v_cdr);

  perform stats.update_rt_stats(v_cdr);

  v_billing_event.id=v_cdr.id;
  v_billing_event.customer_id=v_cdr.customer_id;
  v_billing_event.vendor_id=v_cdr.vendor_id;
  v_billing_event.customer_acc_id=v_cdr.customer_acc_id;
  v_billing_event.vendor_acc_id=v_cdr.vendor_acc_id;
  v_billing_event.customer_auth_id=v_cdr.customer_auth_id;
  v_billing_event.destination_id=v_cdr.destination_id;
  v_billing_event.dialpeer_id=v_cdr.dialpeer_id;
  v_billing_event.orig_gw_id=v_cdr.orig_gw_id;
  v_billing_event.term_gw_id=v_cdr.term_gw_id;
  v_billing_event.routing_group_id=v_cdr.routing_group_id;
  v_billing_event.rateplan_id=v_cdr.rateplan_id;

  v_billing_event.destination_next_rate=v_cdr.destination_next_rate;
  v_billing_event.destination_fee=v_cdr.destination_fee;
  v_billing_event.destination_initial_interval=v_cdr.destination_initial_interval;
  v_billing_event.destination_next_interval=v_cdr.destination_next_interval;
  v_billing_event.destination_initial_rate=v_cdr.destination_initial_rate;
  v_billing_event.destination_reverse_billing=v_cdr.destination_reverse_billing;

  v_billing_event.dialpeer_next_rate=v_cdr.dialpeer_next_rate;
  v_billing_event.dialpeer_fee=v_cdr.dialpeer_fee;
  v_billing_event.dialpeer_reverse_billing=v_cdr.dialpeer_reverse_billing;

  v_billing_event.internal_disconnect_code=v_cdr.internal_disconnect_code;
  v_billing_event.internal_disconnect_reason=v_cdr.internal_disconnect_reason;
  v_billing_event.disconnect_initiator_id=v_cdr.disconnect_initiator_id;
  v_billing_event.customer_price=v_cdr.customer_price;
  v_billing_event.vendor_price=v_cdr.vendor_price;
  v_billing_event.duration=v_cdr.duration;
  v_billing_event.success=v_cdr.success;
  v_billing_event.profit=v_cdr.profit;
  v_billing_event.time_start=v_cdr.time_start;
  v_billing_event.time_connect=v_cdr.time_connect;
  v_billing_event.time_end=v_cdr.time_end;
  v_billing_event.lega_disconnect_code=v_cdr.lega_disconnect_code;
  v_billing_event.lega_disconnect_reason=v_cdr.lega_disconnect_reason;
  v_billing_event.legb_disconnect_code=v_cdr.legb_disconnect_code;
  v_billing_event.legb_disconnect_reason=v_cdr.legb_disconnect_reason;
  v_billing_event.src_prefix_in=v_cdr.src_prefix_in;
  v_billing_event.src_prefix_out=v_cdr.src_prefix_out;
  v_billing_event.dst_prefix_in=v_cdr.dst_prefix_in;
  v_billing_event.dst_prefix_out=v_cdr.dst_prefix_out;
  v_billing_event.orig_call_id=v_cdr.orig_call_id;
  v_billing_event.term_call_id=v_cdr.term_call_id;
  v_billing_event.local_tag=v_cdr.local_tag;
  v_billing_event.from_domain=v_cdr.from_domain;

  -- generate event to routing engine
  perform event.billing_insert_event('cdr_full',v_billing_event);
  INSERT INTO cdr.cdr VALUES( v_cdr.*);
  RETURN 0;
END;
$$;


SET search_path = sys, pg_catalog;

--
-- Name: cdr_createtable(integer); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION cdr_createtable(i_offset integer) RETURNS void
    LANGUAGE plpgsql COST 10000
    AS $$
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
$$;


--
-- Name: cdr_export_data(character varying); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION cdr_export_data(i_tbname character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_file varchar:='/var/spool/yeti-rs/';
BEGIN
    v_file:=v_file||i_tbname||'-'||now()::varchar;
    execute 'COPY '||i_tbname||' TO '''||v_file||''' WITH CSV HEADER QUOTE AS ''"'' FORCE QUOTE *';
END;
$$;


--
-- Name: cdr_export_data(character varying, character varying); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION cdr_export_data(i_tbname character varying, i_dir character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_file varchar;
BEGIN
    v_file:=i_dir||'/'||i_tbname||'-'||now()::varchar;
    execute 'COPY '||i_tbname||' TO '''||v_file||''' WITH CSV HEADER QUOTE AS ''"'' FORCE QUOTE *';
END;
$$;


--
-- Name: cdr_reindex(character varying, character varying); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION cdr_reindex(i_schema character varying, i_tbname character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
v_c integer;
v_sql varchar;
v_indname varchar;
BEGIN
        SELECT into v_c count(*) from pg_tables where schemaname=i_schema and tablename=i_tbname;
        IF v_c=0 THEN
                RAISE EXCEPTION 'sys.cdr_reindex: table % not exist',i_tbname;
        ELSE
                -- CHECK primary key
                SELECT into v_indname conname from pg_catalog.pg_constraint  where conname like i_tbname||'_pkey%';
                IF NOT FOUND THEN
                        v_sql:='ALTER TABLE '||i_tbname||' ADD PRIMARY KEY (id);';
                        EXECUTE v_sql;
                        RAISE NOTICE 'sys.cdr_reindex: % add primary key' ,i_tbname;
                END IF;
/*
                -- UNIQUE index on out_call_id;
                SELECT into v_indname indexname FROM pg_catalog.pg_indexes WHERE schemaname=i_schemae AND tablename=i_tbname AND indexdef LIKE '%(out_call_id)%';
                IF NOT FOUND THEN
                        v_sql:='CREATE UNIQUE INDEX ON '||i_schemae||'.'||i_tbname||' USING btree (out_call_id);';
                        RAISE NOTICE 'sys.cdr_reindex: % add index out_call_id' ,i_tbname;
                        EXECUTE v_sql;
                ELSE
                        v_sql:='CREATE UNIQUE INDEX ON '||i_schemae||'.'||i_tbname||' USING btree (out_call_id);';
                        EXECUTE v_sql;
                        v_sql:='DROP INDEX cdrs.'||v_indname;
                        EXECUTE v_sql;
                        RAISE NOTICE 'sys.cdr_reindex: % reindex out_call_id' ,i_tbname;
                END IF;
*/
                -- index on time_inviteprocessed;
                SELECT into v_indname indexname FROM pg_catalog.pg_indexes WHERE schemaname=i_schema AND tablename=i_tbname AND indexdef LIKE '%(time_start)%';
                IF NOT FOUND THEN
                        v_sql:='CREATE INDEX ON '||i_schema||'.'||i_tbname||' USING btree (time_start);';
                        EXECUTE v_sql;
                        RAISE NOTICE 'sys.cdr_reindex: % add index time_start' ,i_tbname;
                ELSE
                        v_sql:='CREATE INDEX ON '||i_schema||'.'||i_tbname||' USING btree (time_start);';
                        EXECUTE v_sql;
                        v_sql:='DROP INDEX '||i_schema||'.'||v_indname;
                        EXECUTE v_sql;
                        RAISE NOTICE 'sys.cdr_reindex: % reindex time_invite' ,i_tbname;
                END IF;

        END IF;
        RETURN ;
END;
$$;


--
-- Name: cdrtable_tgr_reload(); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION cdrtable_tgr_reload() RETURNS void
    LANGUAGE plpgsql
    AS $_$
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
$_$;


SET search_path = billing, pg_catalog;

--
-- Name: invoice_destinations; Type: TABLE; Schema: billing; Owner: -; Tablespace: 
--

CREATE TABLE invoice_destinations (
    id bigint NOT NULL,
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
    first_successful_call_at timestamp with time zone,
    last_successful_call_at timestamp with time zone
);


--
-- Name: invoice_destinations_id_seq; Type: SEQUENCE; Schema: billing; Owner: -
--

CREATE SEQUENCE invoice_destinations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_destinations_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: -
--

ALTER SEQUENCE invoice_destinations_id_seq OWNED BY invoice_destinations.id;


--
-- Name: invoice_documents; Type: TABLE; Schema: billing; Owner: -; Tablespace: 
--

CREATE TABLE invoice_documents (
    id integer NOT NULL,
    invoice_id integer NOT NULL,
    data bytea,
    filename character varying NOT NULL,
    pdf_data bytea,
    csv_data bytea,
    xls_data bytea
);


--
-- Name: invoice_documents_id_seq; Type: SEQUENCE; Schema: billing; Owner: -
--

CREATE SEQUENCE invoice_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: -
--

ALTER SEQUENCE invoice_documents_id_seq OWNED BY invoice_documents.id;


--
-- Name: invoice_networks; Type: TABLE; Schema: billing; Owner: -; Tablespace: 
--

CREATE TABLE invoice_networks (
    id bigint NOT NULL,
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
    first_successful_call_at timestamp with time zone,
    last_successful_call_at timestamp with time zone
);


--
-- Name: invoice_networks_id_seq; Type: SEQUENCE; Schema: billing; Owner: -
--

CREATE SEQUENCE invoice_networks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_networks_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: -
--

ALTER SEQUENCE invoice_networks_id_seq OWNED BY invoice_networks.id;


--
-- Name: invoice_states; Type: TABLE; Schema: billing; Owner: -; Tablespace: 
--

CREATE TABLE invoice_states (
    id smallint NOT NULL,
    name character varying NOT NULL
);


--
-- Name: invoice_types; Type: TABLE; Schema: billing; Owner: -; Tablespace: 
--

CREATE TABLE invoice_types (
    id smallint NOT NULL,
    name character varying NOT NULL
);


--
-- Name: invoices; Type: TABLE; Schema: billing; Owner: -; Tablespace: 
--

CREATE TABLE invoices (
    id integer NOT NULL,
    account_id integer NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL,
    amount numeric NOT NULL,
    vendor_invoice boolean DEFAULT false NOT NULL,
    calls_count bigint NOT NULL,
    first_call_at timestamp with time zone,
    last_call_at timestamp with time zone,
    contractor_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    calls_duration bigint NOT NULL,
    state_id smallint DEFAULT 1 NOT NULL,
    first_successful_call_at timestamp with time zone,
    last_successful_call_at timestamp with time zone,
    successful_calls_count bigint,
    type_id smallint NOT NULL
);


--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: billing; Owner: -
--

CREATE SEQUENCE invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: -
--

ALTER SEQUENCE invoices_id_seq OWNED BY invoices.id;


SET search_path = cdr, pg_catalog;

--
-- Name: cdr_201408; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr_201408 (
    CONSTRAINT cdr_201408_time_start_check CHECK (((time_start >= '2014-08-01'::date) AND (time_start < '2014-09-01'::date)))
)
INHERITS (cdr);


--
-- Name: cdr_201409; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr_201409 (
    CONSTRAINT cdr_201409_time_start_check CHECK (((time_start >= '2014-09-01'::date) AND (time_start < '2014-10-01'::date)))
)
INHERITS (cdr);


--
-- Name: cdr_201410; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr_201410 (
    CONSTRAINT cdr_201410_time_start_check CHECK (((time_start >= '2014-10-01'::date) AND (time_start < '2014-11-01'::date)))
)
INHERITS (cdr);


--
-- Name: cdr_201411; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr_201411 (
    CONSTRAINT cdr_201411_time_start_check CHECK (((time_start >= '2014-11-01'::date) AND (time_start < '2014-12-01'::date)))
)
INHERITS (cdr);


--
-- Name: cdr_201708; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr_201708 (
    CONSTRAINT cdr_201708_time_start_check CHECK (((time_start >= '2017-08-01'::date) AND (time_start < '2017-09-01'::date)))
)
INHERITS (cdr);


--
-- Name: cdr_201709; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr_201709 (
    CONSTRAINT cdr_201709_time_start_check CHECK (((time_start >= '2017-09-01'::date) AND (time_start < '2017-10-01'::date)))
)
INHERITS (cdr);


--
-- Name: cdr_201710; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr_201710 (
    CONSTRAINT cdr_201710_time_start_check CHECK (((time_start >= '2017-10-01'::date) AND (time_start < '2017-11-01'::date)))
)
INHERITS (cdr);


--
-- Name: cdr_201712; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr_201712 (
    CONSTRAINT cdr_201712_time_start_check CHECK (((time_start >= '2017-12-01 02:00:00+02'::timestamp with time zone) AND (time_start < '2018-01-01 02:00:00+02'::timestamp with time zone)))
)
INHERITS (cdr);


--
-- Name: cdr_201801; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr_201801 (
    CONSTRAINT cdr_201801_time_start_check CHECK (((time_start >= '2018-01-01 02:00:00+02'::timestamp with time zone) AND (time_start < '2018-02-01 02:00:00+02'::timestamp with time zone)))
)
INHERITS (cdr);


--
-- Name: cdr_201802; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr_201802 (
    CONSTRAINT cdr_201802_time_start_check CHECK (((time_start >= '2018-02-01 02:00:00+02'::timestamp with time zone) AND (time_start < '2018-03-01 02:00:00+02'::timestamp with time zone)))
)
INHERITS (cdr);


--
-- Name: cdr_201803; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr_201803 (
    CONSTRAINT cdr_201803_time_start_check CHECK (((time_start >= '2018-03-01 02:00:00+02'::timestamp with time zone) AND (time_start < '2018-04-01 03:00:00+03'::timestamp with time zone)))
)
INHERITS (cdr);


--
-- Name: cdr_201804; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr_201804 (
    CONSTRAINT cdr_201804_time_start_check CHECK (((time_start >= '2018-04-01 03:00:00+03'::timestamp with time zone) AND (time_start < '2018-05-01 03:00:00+03'::timestamp with time zone)))
)
INHERITS (cdr);


--
-- Name: cdr_archive; Type: TABLE; Schema: cdr; Owner: -; Tablespace: 
--

CREATE TABLE cdr_archive (
    id bigint,
    customer_id integer,
    vendor_id integer,
    customer_acc_id integer,
    vendor_acc_id integer,
    customer_auth_id integer,
    destination_id integer,
    dialpeer_id integer,
    orig_gw_id integer,
    term_gw_id integer,
    routing_group_id integer,
    rateplan_id integer,
    destination_next_rate numeric,
    destination_fee numeric,
    dialpeer_next_rate numeric,
    dialpeer_fee numeric,
    time_limit character varying,
    internal_disconnect_code integer,
    internal_disconnect_reason character varying,
    disconnect_initiator_id integer,
    customer_price numeric,
    vendor_price numeric,
    duration integer,
    success boolean,
    profit numeric,
    dst_prefix_in character varying,
    dst_prefix_out character varying,
    src_prefix_in character varying,
    src_prefix_out character varying,
    time_start timestamp with time zone,
    time_connect timestamp with time zone,
    time_end timestamp with time zone,
    sign_orig_ip character varying,
    sign_orig_port integer,
    sign_orig_local_ip character varying,
    sign_orig_local_port integer,
    sign_term_ip character varying,
    sign_term_port integer,
    sign_term_local_ip character varying,
    sign_term_local_port integer,
    orig_call_id character varying,
    term_call_id character varying,
    vendor_invoice_id integer,
    customer_invoice_id integer,
    local_tag character varying,
    destination_initial_rate numeric,
    dialpeer_initial_rate numeric,
    destination_initial_interval integer,
    destination_next_interval integer,
    dialpeer_initial_interval integer,
    dialpeer_next_interval integer,
    destination_rate_policy_id integer,
    routing_attempt integer,
    is_last_cdr boolean,
    lega_disconnect_code integer,
    lega_disconnect_reason character varying,
    pop_id integer,
    node_id integer,
    src_name_in character varying,
    src_name_out character varying,
    diversion_in character varying,
    diversion_out character varying,
    lega_rx_payloads character varying,
    lega_tx_payloads character varying,
    legb_rx_payloads character varying,
    legb_tx_payloads character varying,
    legb_disconnect_code integer,
    legb_disconnect_reason character varying,
    dump_level_id integer,
    auth_orig_ip inet,
    auth_orig_port integer,
    lega_rx_bytes integer,
    lega_tx_bytes integer,
    legb_rx_bytes integer,
    legb_tx_bytes integer,
    global_tag character varying,
    dst_country_id integer,
    dst_network_id integer,
    lega_rx_decode_errs integer,
    lega_rx_no_buf_errs integer,
    lega_rx_parse_errs integer,
    legb_rx_decode_errs integer,
    legb_rx_no_buf_errs integer,
    legb_rx_parse_errs integer,
    src_prefix_routing character varying,
    dst_prefix_routing character varying,
    routing_plan_id integer,
    routing_delay double precision,
    pdd double precision,
    rtt double precision,
    early_media_present boolean,
    lnp_database_id smallint,
    lrn character varying,
    destination_prefix character varying,
    dialpeer_prefix character varying,
    audio_recorded boolean,
    ruri_domain character varying,
    to_domain character varying,
    from_domain character varying,
    routing_tag_id smallint,
    src_area_id integer,
    dst_area_id integer,
    auth_orig_transport_protocol_id smallint,
    sign_orig_transport_protocol_id smallint,
    sign_term_transport_protocol_id smallint,
    core_version character varying,
    yeti_version character varying,
    lega_user_agent character varying,
    legb_user_agent character varying,
    uuid uuid,
    pai_in character varying,
    ppi_in character varying,
    privacy_in character varying,
    rpid_in character varying,
    rpid_privacy_in character varying,
    pai_out character varying,
    ppi_out character varying,
    privacy_out character varying,
    rpid_out character varying,
    rpid_privacy_out character varying,
    destination_reverse_billing boolean,
    dialpeer_reverse_billing boolean,
    is_redirected boolean,
    customer_account_check_balance boolean,
    customer_external_id bigint,
    customer_auth_external_id bigint,
    customer_acc_vat numeric,
    customer_acc_external_id bigint,
    routing_tag_ids smallint[],
    vendor_external_id bigint,
    vendor_acc_external_id bigint,
    orig_gw_external_id bigint,
    term_gw_external_id bigint,
    failed_resource_type_id smallint,
    failed_resource_id bigint,
    customer_price_no_vat numeric,
    customer_duration integer,
    vendor_duration integer
);


--
-- Name: cdr_id_seq; Type: SEQUENCE; Schema: cdr; Owner: -
--

CREATE SEQUENCE cdr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cdr_id_seq; Type: SEQUENCE OWNED BY; Schema: cdr; Owner: -
--

ALTER SEQUENCE cdr_id_seq OWNED BY cdr.id;


SET search_path = public, pg_catalog;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


SET search_path = reports, pg_catalog;

--
-- Name: cdr_custom_report; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE cdr_custom_report (
    id integer NOT NULL,
    date_start timestamp with time zone,
    date_end timestamp with time zone,
    filter character varying,
    group_by character varying,
    created_at timestamp with time zone,
    customer_id integer
);


--
-- Name: cdr_custom_report_data; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE cdr_custom_report_data (
    customer_id integer,
    vendor_id integer,
    customer_acc_id integer,
    vendor_acc_id integer,
    customer_auth_id integer,
    destination_id integer,
    dialpeer_id integer,
    orig_gw_id integer,
    term_gw_id integer,
    routing_group_id integer,
    rateplan_id integer,
    destination_next_rate numeric,
    destination_fee numeric,
    dialpeer_next_rate numeric,
    dialpeer_fee numeric,
    time_limit character varying,
    internal_disconnect_code integer,
    internal_disconnect_reason character varying,
    disconnect_initiator_id integer,
    customer_price numeric,
    vendor_price numeric,
    duration integer,
    success boolean,
    vendor_billed boolean,
    customer_billed boolean,
    profit numeric,
    dst_prefix_in character varying,
    dst_prefix_out character varying,
    src_prefix_in character varying,
    src_prefix_out character varying,
    time_start timestamp with time zone,
    time_connect timestamp with time zone,
    time_end timestamp with time zone,
    sign_orig_ip character varying,
    sign_orig_port integer,
    sign_orig_local_ip character varying,
    sign_orig_local_port integer,
    sign_term_ip character varying,
    sign_term_port integer,
    sign_term_local_ip character varying,
    sign_term_local_port integer,
    orig_call_id character varying,
    term_call_id character varying,
    vendor_invoice_id integer,
    customer_invoice_id integer,
    local_tag character varying,
    log_sip boolean,
    log_rtp boolean,
    dump_file character varying,
    destination_initial_rate numeric,
    dialpeer_initial_rate numeric,
    destination_initial_interval integer,
    destination_next_interval integer,
    dialpeer_initial_interval integer,
    dialpeer_next_interval integer,
    destination_rate_policy_id integer,
    routing_attempt integer,
    is_last_cdr boolean,
    lega_disconnect_code integer,
    lega_disconnect_reason character varying,
    pop_id integer,
    node_id integer,
    src_name_in character varying,
    src_name_out character varying,
    diversion_in character varying,
    diversion_out character varying,
    dst_country_id integer,
    dst_network_id integer,
    id bigint NOT NULL,
    report_id integer NOT NULL,
    agg_calls_count bigint,
    agg_calls_duration bigint,
    agg_calls_acd numeric,
    agg_asr_origination numeric,
    agg_asr_termination numeric,
    agg_vendor_price numeric,
    agg_customer_price numeric,
    agg_profit numeric,
    legb_disconnect_code integer,
    legb_disconnect_reason character varying
);


--
-- Name: cdr_custom_report_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE cdr_custom_report_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cdr_custom_report_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE cdr_custom_report_data_id_seq OWNED BY cdr_custom_report_data.id;


--
-- Name: cdr_custom_report_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE cdr_custom_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cdr_custom_report_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE cdr_custom_report_id_seq OWNED BY cdr_custom_report.id;


--
-- Name: cdr_custom_report_schedulers; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE cdr_custom_report_schedulers (
    id integer NOT NULL,
    created_at timestamp with time zone,
    period_id integer NOT NULL,
    filter character varying,
    group_by character varying[],
    send_to integer[],
    last_run_at timestamp with time zone,
    next_run_at timestamp with time zone,
    customer_id integer
);


--
-- Name: cdr_custom_report_schedulers_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE cdr_custom_report_schedulers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cdr_custom_report_schedulers_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE cdr_custom_report_schedulers_id_seq OWNED BY cdr_custom_report_schedulers.id;


--
-- Name: cdr_interval_report; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE cdr_interval_report (
    id integer NOT NULL,
    date_start timestamp with time zone NOT NULL,
    date_end timestamp with time zone NOT NULL,
    filter character varying,
    group_by character varying,
    created_at timestamp with time zone NOT NULL,
    interval_length integer NOT NULL,
    aggregator_id integer NOT NULL,
    aggregate_by character varying NOT NULL
);


--
-- Name: cdr_interval_report_aggrerator; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE cdr_interval_report_aggrerator (
    id integer NOT NULL,
    name character varying NOT NULL
);


--
-- Name: cdr_interval_report_data; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE cdr_interval_report_data (
    customer_id integer,
    vendor_id integer,
    customer_acc_id integer,
    vendor_acc_id integer,
    customer_auth_id integer,
    destination_id integer,
    dialpeer_id integer,
    orig_gw_id integer,
    term_gw_id integer,
    routing_group_id integer,
    rateplan_id integer,
    destination_next_rate numeric,
    destination_fee numeric,
    dialpeer_next_rate numeric,
    dialpeer_fee numeric,
    time_limit character varying,
    internal_disconnect_code integer,
    internal_disconnect_reason character varying,
    disconnect_initiator_id integer,
    customer_price numeric,
    vendor_price numeric,
    duration integer,
    success boolean,
    vendor_billed boolean,
    customer_billed boolean,
    profit numeric,
    dst_prefix_in character varying,
    dst_prefix_out character varying,
    src_prefix_in character varying,
    src_prefix_out character varying,
    time_start timestamp with time zone,
    time_connect timestamp with time zone,
    time_end timestamp with time zone,
    sign_orig_ip character varying,
    sign_orig_port integer,
    sign_orig_local_ip character varying,
    sign_orig_local_port integer,
    sign_term_ip character varying,
    sign_term_port integer,
    sign_term_local_ip character varying,
    sign_term_local_port integer,
    orig_call_id character varying,
    term_call_id character varying,
    vendor_invoice_id integer,
    customer_invoice_id integer,
    local_tag character varying,
    log_sip boolean,
    log_rtp boolean,
    dump_file character varying,
    destination_initial_rate numeric,
    dialpeer_initial_rate numeric,
    destination_initial_interval integer,
    destination_next_interval integer,
    dialpeer_initial_interval integer,
    dialpeer_next_interval integer,
    destination_rate_policy_id integer,
    routing_attempt integer,
    is_last_cdr boolean,
    lega_disconnect_code integer,
    lega_disconnect_reason character varying,
    pop_id integer,
    node_id integer,
    src_name_in character varying,
    src_name_out character varying,
    diversion_in character varying,
    diversion_out character varying,
    dst_country_id integer,
    dst_network_id integer,
    legb_disconnect_code integer,
    legb_disconnect_reason character varying,
    id bigint NOT NULL,
    report_id integer NOT NULL,
    "timestamp" timestamp with time zone,
    aggregated_value numeric
);


--
-- Name: cdr_interval_report_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE cdr_interval_report_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cdr_interval_report_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE cdr_interval_report_data_id_seq OWNED BY cdr_interval_report_data.id;


--
-- Name: cdr_interval_report_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE cdr_interval_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cdr_interval_report_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE cdr_interval_report_id_seq OWNED BY cdr_interval_report.id;


--
-- Name: cdr_interval_report_schedulers; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE cdr_interval_report_schedulers (
    id integer NOT NULL,
    created_at timestamp with time zone,
    period_id integer NOT NULL,
    filter character varying,
    group_by character varying[],
    interval_length integer,
    aggregator_id integer,
    aggregate_by character varying,
    send_to integer[],
    last_run_at timestamp with time zone,
    next_run_at timestamp with time zone
);


--
-- Name: cdr_interval_report_schedulers_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE cdr_interval_report_schedulers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cdr_interval_report_schedulers_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE cdr_interval_report_schedulers_id_seq OWNED BY cdr_interval_report_schedulers.id;


--
-- Name: customer_traffic_report; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE customer_traffic_report (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    date_start timestamp with time zone,
    date_end timestamp with time zone,
    customer_id integer NOT NULL
);


--
-- Name: customer_traffic_report_data_by_destination; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE customer_traffic_report_data_by_destination (
    id bigint NOT NULL,
    report_id integer NOT NULL,
    destination_prefix character varying,
    dst_country_id integer,
    dst_network_id integer,
    calls_count bigint NOT NULL,
    calls_duration bigint NOT NULL,
    acd real,
    asr real,
    origination_cost numeric,
    termination_cost numeric,
    profit numeric,
    success_calls_count bigint,
    first_call_at timestamp with time zone,
    last_call_at timestamp with time zone,
    short_calls_count bigint NOT NULL
);


--
-- Name: customer_traffic_report_data_by_destination_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE customer_traffic_report_data_by_destination_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_traffic_report_data_by_destination_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE customer_traffic_report_data_by_destination_id_seq OWNED BY customer_traffic_report_data_by_destination.id;


--
-- Name: customer_traffic_report_data_by_vendor; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE customer_traffic_report_data_by_vendor (
    id bigint NOT NULL,
    report_id integer NOT NULL,
    vendor_id integer,
    calls_count bigint,
    calls_duration bigint,
    acd real,
    asr real,
    origination_cost numeric,
    termination_cost numeric,
    profit numeric,
    success_calls_count bigint,
    first_call_at timestamp with time zone,
    last_call_at timestamp with time zone,
    short_calls_count bigint
);


--
-- Name: customer_traffic_report_data_full; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE customer_traffic_report_data_full (
    id bigint NOT NULL,
    report_id integer NOT NULL,
    vendor_id integer,
    destination_prefix character varying,
    dst_country_id integer,
    dst_network_id integer,
    calls_count bigint NOT NULL,
    calls_duration bigint NOT NULL,
    acd real,
    asr real,
    origination_cost numeric,
    termination_cost numeric,
    profit numeric,
    success_calls_count bigint,
    first_call_at timestamp with time zone,
    last_call_at timestamp with time zone,
    short_calls_count bigint NOT NULL
);


--
-- Name: customer_traffic_report_data_full_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE customer_traffic_report_data_full_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_traffic_report_data_full_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE customer_traffic_report_data_full_id_seq OWNED BY customer_traffic_report_data_full.id;


--
-- Name: customer_traffic_report_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE customer_traffic_report_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_traffic_report_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE customer_traffic_report_data_id_seq OWNED BY customer_traffic_report_data_by_vendor.id;


--
-- Name: customer_traffic_report_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE customer_traffic_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_traffic_report_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE customer_traffic_report_id_seq OWNED BY customer_traffic_report.id;


--
-- Name: customer_traffic_report_schedulers; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE customer_traffic_report_schedulers (
    id integer NOT NULL,
    created_at timestamp with time zone,
    period_id integer NOT NULL,
    customer_id integer NOT NULL,
    send_to integer[],
    last_run_at timestamp with time zone,
    next_run_at timestamp with time zone
);


--
-- Name: customer_traffic_report_schedulers_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE customer_traffic_report_schedulers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_traffic_report_schedulers_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE customer_traffic_report_schedulers_id_seq OWNED BY customer_traffic_report_schedulers.id;


--
-- Name: report_vendors; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE report_vendors (
    id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL
);


--
-- Name: report_vendors_data; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE report_vendors_data (
    id bigint NOT NULL,
    report_id integer NOT NULL,
    calls_count bigint
);


--
-- Name: report_vendors_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE report_vendors_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: report_vendors_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE report_vendors_data_id_seq OWNED BY report_vendors_data.id;


--
-- Name: report_vendors_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE report_vendors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: report_vendors_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE report_vendors_id_seq OWNED BY report_vendors.id;


--
-- Name: scheduler_periods; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE scheduler_periods (
    id smallint NOT NULL,
    name character varying NOT NULL
);


--
-- Name: vendor_traffic_report; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE vendor_traffic_report (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    date_start timestamp with time zone,
    date_end timestamp with time zone,
    vendor_id integer NOT NULL
);


--
-- Name: vendor_traffic_report_data; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE vendor_traffic_report_data (
    id bigint NOT NULL,
    report_id integer NOT NULL,
    customer_id integer,
    calls_count bigint,
    calls_duration bigint,
    acd real,
    asr real,
    origination_cost numeric,
    termination_cost numeric,
    profit numeric,
    success_calls_count bigint,
    first_call_at timestamp with time zone,
    last_call_at timestamp with time zone,
    short_calls_count bigint
);


--
-- Name: vendor_traffic_report_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE vendor_traffic_report_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vendor_traffic_report_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE vendor_traffic_report_data_id_seq OWNED BY vendor_traffic_report_data.id;


--
-- Name: vendor_traffic_report_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE vendor_traffic_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vendor_traffic_report_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE vendor_traffic_report_id_seq OWNED BY vendor_traffic_report.id;


--
-- Name: vendor_traffic_report_schedulers; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE vendor_traffic_report_schedulers (
    id integer NOT NULL,
    created_at timestamp with time zone,
    period_id integer NOT NULL,
    vendor_id integer NOT NULL,
    send_to integer[],
    last_run_at timestamp with time zone,
    next_run_at timestamp with time zone
);


--
-- Name: vendor_traffic_report_schedulers_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE vendor_traffic_report_schedulers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vendor_traffic_report_schedulers_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE vendor_traffic_report_schedulers_id_seq OWNED BY vendor_traffic_report_schedulers.id;


SET search_path = stats, pg_catalog;

--
-- Name: active_call_customer_accounts; Type: TABLE; Schema: stats; Owner: -; Tablespace: 
--

CREATE TABLE active_call_customer_accounts (
    id bigint NOT NULL,
    account_id integer NOT NULL,
    count integer NOT NULL,
    created_at timestamp with time zone
);


--
-- Name: active_call_customer_accounts_hourly; Type: TABLE; Schema: stats; Owner: -; Tablespace: 
--

CREATE TABLE active_call_customer_accounts_hourly (
    id bigint NOT NULL,
    account_id integer NOT NULL,
    max_count integer NOT NULL,
    avg_count real NOT NULL,
    min_count integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    calls_time timestamp with time zone NOT NULL
);


--
-- Name: active_call_customer_accounts_hourly_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE active_call_customer_accounts_hourly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_call_customer_accounts_hourly_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE active_call_customer_accounts_hourly_id_seq OWNED BY active_call_customer_accounts_hourly.id;


--
-- Name: active_call_customer_accounts_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE active_call_customer_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_call_customer_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE active_call_customer_accounts_id_seq OWNED BY active_call_customer_accounts.id;


--
-- Name: active_call_orig_gateways; Type: TABLE; Schema: stats; Owner: -; Tablespace: 
--

CREATE TABLE active_call_orig_gateways (
    id bigint NOT NULL,
    gateway_id integer NOT NULL,
    count integer NOT NULL,
    created_at timestamp with time zone
);


--
-- Name: active_call_orig_gateways_hourly; Type: TABLE; Schema: stats; Owner: -; Tablespace: 
--

CREATE TABLE active_call_orig_gateways_hourly (
    id bigint NOT NULL,
    gateway_id integer NOT NULL,
    max_count integer NOT NULL,
    avg_count real NOT NULL,
    min_count integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    calls_time timestamp with time zone NOT NULL
);


--
-- Name: active_call_orig_gateways_hourly_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE active_call_orig_gateways_hourly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_call_orig_gateways_hourly_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE active_call_orig_gateways_hourly_id_seq OWNED BY active_call_orig_gateways_hourly.id;


--
-- Name: active_call_orig_gateways_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE active_call_orig_gateways_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_call_orig_gateways_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE active_call_orig_gateways_id_seq OWNED BY active_call_orig_gateways.id;


--
-- Name: active_call_term_gateways; Type: TABLE; Schema: stats; Owner: -; Tablespace: 
--

CREATE TABLE active_call_term_gateways (
    id bigint NOT NULL,
    gateway_id integer NOT NULL,
    count integer NOT NULL,
    created_at timestamp with time zone
);


--
-- Name: active_call_term_gateways_hourly; Type: TABLE; Schema: stats; Owner: -; Tablespace: 
--

CREATE TABLE active_call_term_gateways_hourly (
    id bigint NOT NULL,
    gateway_id integer NOT NULL,
    max_count integer NOT NULL,
    avg_count real NOT NULL,
    min_count integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    calls_time timestamp with time zone NOT NULL
);


--
-- Name: active_call_term_gateways_hourly_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE active_call_term_gateways_hourly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_call_term_gateways_hourly_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE active_call_term_gateways_hourly_id_seq OWNED BY active_call_term_gateways_hourly.id;


--
-- Name: active_call_term_gateways_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE active_call_term_gateways_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_call_term_gateways_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE active_call_term_gateways_id_seq OWNED BY active_call_term_gateways.id;


--
-- Name: active_call_vendor_accounts; Type: TABLE; Schema: stats; Owner: -; Tablespace: 
--

CREATE TABLE active_call_vendor_accounts (
    id bigint NOT NULL,
    account_id integer NOT NULL,
    count integer NOT NULL,
    created_at timestamp with time zone
);


--
-- Name: active_call_vendor_accounts_hourly; Type: TABLE; Schema: stats; Owner: -; Tablespace: 
--

CREATE TABLE active_call_vendor_accounts_hourly (
    id bigint NOT NULL,
    account_id integer NOT NULL,
    max_count integer NOT NULL,
    avg_count real NOT NULL,
    min_count integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    calls_time timestamp with time zone NOT NULL
);


--
-- Name: active_call_vendor_accounts_hourly_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE active_call_vendor_accounts_hourly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_call_vendor_accounts_hourly_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE active_call_vendor_accounts_hourly_id_seq OWNED BY active_call_vendor_accounts_hourly.id;


--
-- Name: active_call_vendor_accounts_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE active_call_vendor_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_call_vendor_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE active_call_vendor_accounts_id_seq OWNED BY active_call_vendor_accounts.id;


--
-- Name: active_calls; Type: TABLE; Schema: stats; Owner: -; Tablespace: 
--

CREATE TABLE active_calls (
    id bigint NOT NULL,
    node_id integer NOT NULL,
    count integer NOT NULL,
    created_at timestamp with time zone
);


--
-- Name: active_calls_hourly; Type: TABLE; Schema: stats; Owner: -; Tablespace: 
--

CREATE TABLE active_calls_hourly (
    id bigint NOT NULL,
    node_id integer NOT NULL,
    max_count integer NOT NULL,
    avg_count real NOT NULL,
    min_count integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    calls_time timestamp with time zone NOT NULL
);


--
-- Name: active_calls_hourly_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE active_calls_hourly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_calls_hourly_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE active_calls_hourly_id_seq OWNED BY active_calls_hourly.id;


--
-- Name: active_calls_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE active_calls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_calls_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE active_calls_id_seq OWNED BY active_calls.id;


--
-- Name: termination_quality_stats; Type: TABLE; Schema: stats; Owner: -; Tablespace: 
--

CREATE TABLE termination_quality_stats (
    id bigint NOT NULL,
    dialpeer_id bigint,
    gateway_id integer,
    time_start timestamp with time zone NOT NULL,
    success boolean NOT NULL,
    duration bigint NOT NULL,
    pdd real,
    early_media_present boolean,
    destination_id bigint
);


--
-- Name: termination_quality_stats_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE termination_quality_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: termination_quality_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE termination_quality_stats_id_seq OWNED BY termination_quality_stats.id;


--
-- Name: traffic_customer_accounts; Type: TABLE; Schema: stats; Owner: -; Tablespace: 
--

CREATE TABLE traffic_customer_accounts (
    id bigint NOT NULL,
    account_id integer NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    duration bigint NOT NULL,
    count bigint NOT NULL,
    amount numeric,
    profit numeric
);


--
-- Name: traffic_customer_accounts_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE traffic_customer_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: traffic_customer_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE traffic_customer_accounts_id_seq OWNED BY traffic_customer_accounts.id;


--
-- Name: traffic_vendor_accounts; Type: TABLE; Schema: stats; Owner: -; Tablespace: 
--

CREATE TABLE traffic_vendor_accounts (
    id bigint NOT NULL,
    account_id integer NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    duration bigint NOT NULL,
    count bigint NOT NULL,
    amount numeric,
    profit numeric
);


--
-- Name: traffic_vendor_accounts_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE traffic_vendor_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: traffic_vendor_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE traffic_vendor_accounts_id_seq OWNED BY traffic_vendor_accounts.id;


SET search_path = sys, pg_catalog;

--
-- Name: call_duration_round_modes; Type: TABLE; Schema: sys; Owner: -; Tablespace: 
--

CREATE TABLE call_duration_round_modes (
    id smallint NOT NULL,
    name character varying NOT NULL
);


--
-- Name: cdr_tables; Type: TABLE; Schema: sys; Owner: -; Tablespace: 
--

CREATE TABLE cdr_tables (
    id integer NOT NULL,
    name character varying NOT NULL,
    readable boolean DEFAULT true NOT NULL,
    writable boolean DEFAULT false NOT NULL,
    date_start character varying NOT NULL,
    date_stop character varying NOT NULL,
    active boolean DEFAULT true NOT NULL
);


--
-- Name: cdr_tables_id_seq; Type: SEQUENCE; Schema: sys; Owner: -
--

CREATE SEQUENCE cdr_tables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cdr_tables_id_seq; Type: SEQUENCE OWNED BY; Schema: sys; Owner: -
--

ALTER SEQUENCE cdr_tables_id_seq OWNED BY cdr_tables.id;


--
-- Name: config; Type: TABLE; Schema: sys; Owner: -; Tablespace: 
--

CREATE TABLE config (
    id smallint NOT NULL,
    call_duration_round_mode_id smallint DEFAULT 1 NOT NULL
);


SET search_path = billing, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: billing; Owner: -
--

ALTER TABLE ONLY invoice_destinations ALTER COLUMN id SET DEFAULT nextval('invoice_destinations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: billing; Owner: -
--

ALTER TABLE ONLY invoice_documents ALTER COLUMN id SET DEFAULT nextval('invoice_documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: billing; Owner: -
--

ALTER TABLE ONLY invoice_networks ALTER COLUMN id SET DEFAULT nextval('invoice_networks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: billing; Owner: -
--

ALTER TABLE ONLY invoices ALTER COLUMN id SET DEFAULT nextval('invoices_id_seq'::regclass);


SET search_path = cdr, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201408 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201408 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201409 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201409 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201410 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201410 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201411 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201411 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201708 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201708 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201709 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201709 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201710 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201710 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201712 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201712 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201801 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201801 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201802 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201802 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201803 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201803 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201804 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr_201804 ALTER COLUMN dump_level_id SET DEFAULT 0;


SET search_path = reports, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_custom_report ALTER COLUMN id SET DEFAULT nextval('cdr_custom_report_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_custom_report_data ALTER COLUMN id SET DEFAULT nextval('cdr_custom_report_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_custom_report_schedulers ALTER COLUMN id SET DEFAULT nextval('cdr_custom_report_schedulers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_interval_report ALTER COLUMN id SET DEFAULT nextval('cdr_interval_report_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_interval_report_data ALTER COLUMN id SET DEFAULT nextval('cdr_interval_report_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_interval_report_schedulers ALTER COLUMN id SET DEFAULT nextval('cdr_interval_report_schedulers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY customer_traffic_report ALTER COLUMN id SET DEFAULT nextval('customer_traffic_report_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY customer_traffic_report_data_by_destination ALTER COLUMN id SET DEFAULT nextval('customer_traffic_report_data_by_destination_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY customer_traffic_report_data_by_vendor ALTER COLUMN id SET DEFAULT nextval('customer_traffic_report_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY customer_traffic_report_data_full ALTER COLUMN id SET DEFAULT nextval('customer_traffic_report_data_full_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY customer_traffic_report_schedulers ALTER COLUMN id SET DEFAULT nextval('customer_traffic_report_schedulers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY report_vendors ALTER COLUMN id SET DEFAULT nextval('report_vendors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY report_vendors_data ALTER COLUMN id SET DEFAULT nextval('report_vendors_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY vendor_traffic_report ALTER COLUMN id SET DEFAULT nextval('vendor_traffic_report_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY vendor_traffic_report_data ALTER COLUMN id SET DEFAULT nextval('vendor_traffic_report_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY vendor_traffic_report_schedulers ALTER COLUMN id SET DEFAULT nextval('vendor_traffic_report_schedulers_id_seq'::regclass);


SET search_path = stats, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY active_call_customer_accounts ALTER COLUMN id SET DEFAULT nextval('active_call_customer_accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY active_call_customer_accounts_hourly ALTER COLUMN id SET DEFAULT nextval('active_call_customer_accounts_hourly_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY active_call_orig_gateways ALTER COLUMN id SET DEFAULT nextval('active_call_orig_gateways_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY active_call_orig_gateways_hourly ALTER COLUMN id SET DEFAULT nextval('active_call_orig_gateways_hourly_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY active_call_term_gateways ALTER COLUMN id SET DEFAULT nextval('active_call_term_gateways_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY active_call_term_gateways_hourly ALTER COLUMN id SET DEFAULT nextval('active_call_term_gateways_hourly_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY active_call_vendor_accounts ALTER COLUMN id SET DEFAULT nextval('active_call_vendor_accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY active_call_vendor_accounts_hourly ALTER COLUMN id SET DEFAULT nextval('active_call_vendor_accounts_hourly_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY active_calls ALTER COLUMN id SET DEFAULT nextval('active_calls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY active_calls_hourly ALTER COLUMN id SET DEFAULT nextval('active_calls_hourly_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY termination_quality_stats ALTER COLUMN id SET DEFAULT nextval('termination_quality_stats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY traffic_customer_accounts ALTER COLUMN id SET DEFAULT nextval('traffic_customer_accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY traffic_vendor_accounts ALTER COLUMN id SET DEFAULT nextval('traffic_vendor_accounts_id_seq'::regclass);


SET search_path = sys, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: sys; Owner: -
--

ALTER TABLE ONLY cdr_tables ALTER COLUMN id SET DEFAULT nextval('cdr_tables_id_seq'::regclass);


SET search_path = billing, pg_catalog;

--
-- Name: invoice_destinations_pkey; Type: CONSTRAINT; Schema: billing; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invoice_destinations
    ADD CONSTRAINT invoice_destinations_pkey PRIMARY KEY (id);


--
-- Name: invoice_documents_pkey; Type: CONSTRAINT; Schema: billing; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invoice_documents
    ADD CONSTRAINT invoice_documents_pkey PRIMARY KEY (id);


--
-- Name: invoice_networks_pkey; Type: CONSTRAINT; Schema: billing; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invoice_networks
    ADD CONSTRAINT invoice_networks_pkey PRIMARY KEY (id);


--
-- Name: invoice_states_name_key; Type: CONSTRAINT; Schema: billing; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invoice_states
    ADD CONSTRAINT invoice_states_name_key UNIQUE (name);


--
-- Name: invoice_states_pkey; Type: CONSTRAINT; Schema: billing; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invoice_states
    ADD CONSTRAINT invoice_states_pkey PRIMARY KEY (id);


--
-- Name: invoice_types_name_key; Type: CONSTRAINT; Schema: billing; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invoice_types
    ADD CONSTRAINT invoice_types_name_key UNIQUE (name);


--
-- Name: invoice_types_pkey; Type: CONSTRAINT; Schema: billing; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invoice_types
    ADD CONSTRAINT invoice_types_pkey PRIMARY KEY (id);


--
-- Name: invoices_pkey; Type: CONSTRAINT; Schema: billing; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


SET search_path = cdr, pg_catalog;

--
-- Name: cdr_201408_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_201408
    ADD CONSTRAINT cdr_201408_pkey PRIMARY KEY (id);


--
-- Name: cdr_201409_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_201409
    ADD CONSTRAINT cdr_201409_pkey PRIMARY KEY (id);


--
-- Name: cdr_201410_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_201410
    ADD CONSTRAINT cdr_201410_pkey PRIMARY KEY (id);


--
-- Name: cdr_201411_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_201411
    ADD CONSTRAINT cdr_201411_pkey PRIMARY KEY (id);


--
-- Name: cdr_201708_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_201708
    ADD CONSTRAINT cdr_201708_pkey PRIMARY KEY (id);


--
-- Name: cdr_201709_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_201709
    ADD CONSTRAINT cdr_201709_pkey PRIMARY KEY (id);


--
-- Name: cdr_201710_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_201710
    ADD CONSTRAINT cdr_201710_pkey PRIMARY KEY (id);


--
-- Name: cdr_201712_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_201712
    ADD CONSTRAINT cdr_201712_pkey PRIMARY KEY (id);


--
-- Name: cdr_201801_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_201801
    ADD CONSTRAINT cdr_201801_pkey PRIMARY KEY (id);


--
-- Name: cdr_201802_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_201802
    ADD CONSTRAINT cdr_201802_pkey PRIMARY KEY (id);


--
-- Name: cdr_201803_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_201803
    ADD CONSTRAINT cdr_201803_pkey PRIMARY KEY (id);


--
-- Name: cdr_201804_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_201804
    ADD CONSTRAINT cdr_201804_pkey PRIMARY KEY (id);


--
-- Name: cdr_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr
    ADD CONSTRAINT cdr_pkey PRIMARY KEY (id);


SET search_path = reports, pg_catalog;

--
-- Name: cdr_custom_report_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_custom_report_data
    ADD CONSTRAINT cdr_custom_report_data_pkey PRIMARY KEY (id);


--
-- Name: cdr_custom_report_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_custom_report
    ADD CONSTRAINT cdr_custom_report_pkey PRIMARY KEY (id);


--
-- Name: cdr_custom_report_schedulers_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_custom_report_schedulers
    ADD CONSTRAINT cdr_custom_report_schedulers_pkey PRIMARY KEY (id);


--
-- Name: cdr_interval_report_aggrerator_name_key; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_interval_report_aggrerator
    ADD CONSTRAINT cdr_interval_report_aggrerator_name_key UNIQUE (name);


--
-- Name: cdr_interval_report_aggrerator_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_interval_report_aggrerator
    ADD CONSTRAINT cdr_interval_report_aggrerator_pkey PRIMARY KEY (id);


--
-- Name: cdr_interval_report_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_interval_report_data
    ADD CONSTRAINT cdr_interval_report_data_pkey PRIMARY KEY (id);


--
-- Name: cdr_interval_report_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_interval_report
    ADD CONSTRAINT cdr_interval_report_pkey PRIMARY KEY (id);


--
-- Name: cdr_interval_report_schedulers_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_interval_report_schedulers
    ADD CONSTRAINT cdr_interval_report_schedulers_pkey PRIMARY KEY (id);


--
-- Name: customer_traffic_report_data_by_destination_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY customer_traffic_report_data_by_destination
    ADD CONSTRAINT customer_traffic_report_data_by_destination_pkey PRIMARY KEY (id);


--
-- Name: customer_traffic_report_data_full_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY customer_traffic_report_data_full
    ADD CONSTRAINT customer_traffic_report_data_full_pkey PRIMARY KEY (id);


--
-- Name: customer_traffic_report_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY customer_traffic_report_data_by_vendor
    ADD CONSTRAINT customer_traffic_report_data_pkey PRIMARY KEY (id);


--
-- Name: customer_traffic_report_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY customer_traffic_report
    ADD CONSTRAINT customer_traffic_report_pkey PRIMARY KEY (id);


--
-- Name: customer_traffic_report_schedulers_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY customer_traffic_report_schedulers
    ADD CONSTRAINT customer_traffic_report_schedulers_pkey PRIMARY KEY (id);


--
-- Name: report_vendors_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY report_vendors_data
    ADD CONSTRAINT report_vendors_data_pkey PRIMARY KEY (id);


--
-- Name: report_vendors_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY report_vendors
    ADD CONSTRAINT report_vendors_pkey PRIMARY KEY (id);


--
-- Name: scheduler_periods_name_key; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scheduler_periods
    ADD CONSTRAINT scheduler_periods_name_key UNIQUE (name);


--
-- Name: scheduler_periods_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scheduler_periods
    ADD CONSTRAINT scheduler_periods_pkey PRIMARY KEY (id);


--
-- Name: vendor_traffic_report_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vendor_traffic_report_data
    ADD CONSTRAINT vendor_traffic_report_data_pkey PRIMARY KEY (id);


--
-- Name: vendor_traffic_report_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vendor_traffic_report
    ADD CONSTRAINT vendor_traffic_report_pkey PRIMARY KEY (id);


--
-- Name: vendor_traffic_report_schedulers_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vendor_traffic_report_schedulers
    ADD CONSTRAINT vendor_traffic_report_schedulers_pkey PRIMARY KEY (id);


SET search_path = stats, pg_catalog;

--
-- Name: active_call_customer_accounts_hourly_pkey; Type: CONSTRAINT; Schema: stats; Owner: -; Tablespace: 
--

ALTER TABLE ONLY active_call_customer_accounts_hourly
    ADD CONSTRAINT active_call_customer_accounts_hourly_pkey PRIMARY KEY (id);


--
-- Name: active_call_customer_accounts_pkey; Type: CONSTRAINT; Schema: stats; Owner: -; Tablespace: 
--

ALTER TABLE ONLY active_call_customer_accounts
    ADD CONSTRAINT active_call_customer_accounts_pkey PRIMARY KEY (id);


--
-- Name: active_call_orig_gateways_hourly_pkey; Type: CONSTRAINT; Schema: stats; Owner: -; Tablespace: 
--

ALTER TABLE ONLY active_call_orig_gateways_hourly
    ADD CONSTRAINT active_call_orig_gateways_hourly_pkey PRIMARY KEY (id);


--
-- Name: active_call_orig_gateways_pkey; Type: CONSTRAINT; Schema: stats; Owner: -; Tablespace: 
--

ALTER TABLE ONLY active_call_orig_gateways
    ADD CONSTRAINT active_call_orig_gateways_pkey PRIMARY KEY (id);


--
-- Name: active_call_term_gateways_hourly_pkey; Type: CONSTRAINT; Schema: stats; Owner: -; Tablespace: 
--

ALTER TABLE ONLY active_call_term_gateways_hourly
    ADD CONSTRAINT active_call_term_gateways_hourly_pkey PRIMARY KEY (id);


--
-- Name: active_call_term_gateways_pkey; Type: CONSTRAINT; Schema: stats; Owner: -; Tablespace: 
--

ALTER TABLE ONLY active_call_term_gateways
    ADD CONSTRAINT active_call_term_gateways_pkey PRIMARY KEY (id);


--
-- Name: active_call_vendor_accounts_hourly_pkey; Type: CONSTRAINT; Schema: stats; Owner: -; Tablespace: 
--

ALTER TABLE ONLY active_call_vendor_accounts_hourly
    ADD CONSTRAINT active_call_vendor_accounts_hourly_pkey PRIMARY KEY (id);


--
-- Name: active_call_vendor_accounts_pkey; Type: CONSTRAINT; Schema: stats; Owner: -; Tablespace: 
--

ALTER TABLE ONLY active_call_vendor_accounts
    ADD CONSTRAINT active_call_vendor_accounts_pkey PRIMARY KEY (id);


--
-- Name: active_calls_hourly_pkey; Type: CONSTRAINT; Schema: stats; Owner: -; Tablespace: 
--

ALTER TABLE ONLY active_calls_hourly
    ADD CONSTRAINT active_calls_hourly_pkey PRIMARY KEY (id);


--
-- Name: active_calls_pkey; Type: CONSTRAINT; Schema: stats; Owner: -; Tablespace: 
--

ALTER TABLE ONLY active_calls
    ADD CONSTRAINT active_calls_pkey PRIMARY KEY (id);


--
-- Name: termination_quality_stats_pkey; Type: CONSTRAINT; Schema: stats; Owner: -; Tablespace: 
--

ALTER TABLE ONLY termination_quality_stats
    ADD CONSTRAINT termination_quality_stats_pkey PRIMARY KEY (id);


--
-- Name: traffic_customer_accounts_pkey; Type: CONSTRAINT; Schema: stats; Owner: -; Tablespace: 
--

ALTER TABLE ONLY traffic_customer_accounts
    ADD CONSTRAINT traffic_customer_accounts_pkey PRIMARY KEY (id);


--
-- Name: traffic_vendor_accounts_pkey; Type: CONSTRAINT; Schema: stats; Owner: -; Tablespace: 
--

ALTER TABLE ONLY traffic_vendor_accounts
    ADD CONSTRAINT traffic_vendor_accounts_pkey PRIMARY KEY (id);


SET search_path = sys, pg_catalog;

--
-- Name: call_duration_round_modes_name_key; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_duration_round_modes
    ADD CONSTRAINT call_duration_round_modes_name_key UNIQUE (name);


--
-- Name: call_duration_round_modes_pkey; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY call_duration_round_modes
    ADD CONSTRAINT call_duration_round_modes_pkey PRIMARY KEY (id);


--
-- Name: cdr_tables_pkey; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_tables
    ADD CONSTRAINT cdr_tables_pkey PRIMARY KEY (id);


--
-- Name: config_pkey; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY config
    ADD CONSTRAINT config_pkey PRIMARY KEY (id);


SET search_path = billing, pg_catalog;

--
-- Name: invoice_destinations_invoice_id_idx; Type: INDEX; Schema: billing; Owner: -; Tablespace: 
--

CREATE INDEX invoice_destinations_invoice_id_idx ON invoice_destinations USING btree (invoice_id);


--
-- Name: invoice_documents_invoice_id_idx; Type: INDEX; Schema: billing; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX invoice_documents_invoice_id_idx ON invoice_documents USING btree (invoice_id);


SET search_path = cdr, pg_catalog;

--
-- Name: cdr_201408_time_start_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_201408_time_start_idx ON cdr_201408 USING btree (time_start);


--
-- Name: cdr_201409_time_start_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_201409_time_start_idx ON cdr_201409 USING btree (time_start);


--
-- Name: cdr_201410_time_start_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_201410_time_start_idx ON cdr_201410 USING btree (time_start);


--
-- Name: cdr_201411_time_start_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_201411_time_start_idx ON cdr_201411 USING btree (time_start);


--
-- Name: cdr_201708_time_start_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_201708_time_start_idx ON cdr_201708 USING btree (time_start);


--
-- Name: cdr_201709_time_start_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_201709_time_start_idx ON cdr_201709 USING btree (time_start);


--
-- Name: cdr_201710_time_start_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_201710_time_start_idx ON cdr_201710 USING btree (time_start);


--
-- Name: cdr_201712_time_start_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_201712_time_start_idx ON cdr_201712 USING btree (time_start);


--
-- Name: cdr_201801_time_start_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_201801_time_start_idx ON cdr_201801 USING btree (time_start);


--
-- Name: cdr_201802_time_start_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_201802_time_start_idx ON cdr_201802 USING btree (time_start);


--
-- Name: cdr_201803_time_start_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_201803_time_start_idx ON cdr_201803 USING btree (time_start);


--
-- Name: cdr_201804_time_start_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_201804_time_start_idx ON cdr_201804 USING btree (time_start);


--
-- Name: cdr_time_start_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_time_start_idx ON cdr USING btree (time_start);


--
-- Name: cdr_vendor_invoice_id_idx; Type: INDEX; Schema: cdr; Owner: -; Tablespace: 
--

CREATE INDEX cdr_vendor_invoice_id_idx ON cdr USING btree (vendor_invoice_id);


SET search_path = public, pg_catalog;

--
-- Name: unique_public.schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX "unique_public.schema_migrations" ON schema_migrations USING btree (version);


SET search_path = reports, pg_catalog;

--
-- Name: cdr_custom_report_id_idx; Type: INDEX; Schema: reports; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX cdr_custom_report_id_idx ON cdr_custom_report USING btree (id) WHERE (id IS NOT NULL);


--
-- Name: customer_traffic_report_data_report_id_idx; Type: INDEX; Schema: reports; Owner: -; Tablespace: 
--

CREATE INDEX customer_traffic_report_data_report_id_idx ON customer_traffic_report_data_by_vendor USING btree (report_id);


--
-- Name: vendor_traffic_report_data_report_id_idx; Type: INDEX; Schema: reports; Owner: -; Tablespace: 
--

CREATE INDEX vendor_traffic_report_data_report_id_idx ON vendor_traffic_report_data USING btree (report_id);


SET search_path = stats, pg_catalog;

--
-- Name: termination_quality_stats_dialpeer_id_idx; Type: INDEX; Schema: stats; Owner: -; Tablespace: 
--

CREATE INDEX termination_quality_stats_dialpeer_id_idx ON termination_quality_stats USING btree (dialpeer_id);


--
-- Name: termination_quality_stats_gateway_id_idx; Type: INDEX; Schema: stats; Owner: -; Tablespace: 
--

CREATE INDEX termination_quality_stats_gateway_id_idx ON termination_quality_stats USING btree (gateway_id);


--
-- Name: traffic_customer_accounts_account_id_timestamp_idx; Type: INDEX; Schema: stats; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX traffic_customer_accounts_account_id_timestamp_idx ON traffic_customer_accounts USING btree (account_id, "timestamp");


--
-- Name: traffic_vendor_accounts_account_id_timestamp_idx; Type: INDEX; Schema: stats; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX traffic_vendor_accounts_account_id_timestamp_idx ON traffic_vendor_accounts USING btree (account_id, "timestamp");


SET search_path = cdr, pg_catalog;

--
-- Name: cdr_i; Type: TRIGGER; Schema: cdr; Owner: -
--

CREATE TRIGGER cdr_i BEFORE INSERT ON cdr FOR EACH ROW EXECUTE PROCEDURE cdr_i_tgf();


SET search_path = billing, pg_catalog;

--
-- Name: invoice_destinations_invoice_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY invoice_destinations
    ADD CONSTRAINT invoice_destinations_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES invoices(id);


--
-- Name: invoice_documents_invoice_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY invoice_documents
    ADD CONSTRAINT invoice_documents_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES invoices(id);


--
-- Name: invoice_networks_invoice_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY invoice_networks
    ADD CONSTRAINT invoice_networks_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES invoices(id);


--
-- Name: invoices_state_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY invoices
    ADD CONSTRAINT invoices_state_id_fkey FOREIGN KEY (state_id) REFERENCES invoice_states(id);


--
-- Name: invoices_type_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY invoices
    ADD CONSTRAINT invoices_type_id_fkey FOREIGN KEY (type_id) REFERENCES invoice_types(id);


SET search_path = reports, pg_catalog;

--
-- Name: cdr_custom_report_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_custom_report_data
    ADD CONSTRAINT cdr_custom_report_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES cdr_custom_report(id);


--
-- Name: cdr_custom_report_schedulers_period_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_custom_report_schedulers
    ADD CONSTRAINT cdr_custom_report_schedulers_period_id_fkey FOREIGN KEY (period_id) REFERENCES scheduler_periods(id);


--
-- Name: cdr_interval_report_aggregator_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_interval_report
    ADD CONSTRAINT cdr_interval_report_aggregator_id_fkey FOREIGN KEY (aggregator_id) REFERENCES cdr_interval_report_aggrerator(id);


--
-- Name: cdr_interval_report_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_interval_report_data
    ADD CONSTRAINT cdr_interval_report_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES cdr_interval_report(id);


--
-- Name: cdr_interval_report_schedulers_period_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_interval_report_schedulers
    ADD CONSTRAINT cdr_interval_report_schedulers_period_id_fkey FOREIGN KEY (period_id) REFERENCES scheduler_periods(id);


--
-- Name: customer_traffic_report_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY customer_traffic_report_data_by_vendor
    ADD CONSTRAINT customer_traffic_report_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES customer_traffic_report(id);


--
-- Name: customer_traffic_report_schedulers_period_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY customer_traffic_report_schedulers
    ADD CONSTRAINT customer_traffic_report_schedulers_period_id_fkey FOREIGN KEY (period_id) REFERENCES scheduler_periods(id);


--
-- Name: report_vendors_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY report_vendors_data
    ADD CONSTRAINT report_vendors_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES report_vendors(id);


--
-- Name: vendor_traffic_report_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY vendor_traffic_report_data
    ADD CONSTRAINT vendor_traffic_report_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES vendor_traffic_report(id);


--
-- Name: vendor_traffic_report_schedulers_period_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY vendor_traffic_report_schedulers
    ADD CONSTRAINT vendor_traffic_report_schedulers_period_id_fkey FOREIGN KEY (period_id) REFERENCES scheduler_periods(id);


SET search_path = sys, pg_catalog;

--
-- Name: config_call_duration_round_mode_id_fkey; Type: FK CONSTRAINT; Schema: sys; Owner: -
--

ALTER TABLE ONLY config
    ADD CONSTRAINT config_call_duration_round_mode_id_fkey FOREIGN KEY (call_duration_round_mode_id) REFERENCES call_duration_round_modes(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO cdr, reports, billing;

INSERT INTO public.schema_migrations (version) VALUES ('20170907204350');

INSERT INTO public.schema_migrations (version) VALUES ('20170911172650');

INSERT INTO public.schema_migrations (version) VALUES ('20171104162958');

INSERT INTO public.schema_migrations (version) VALUES ('20180228200703');

