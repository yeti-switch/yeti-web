--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.6
-- Dumped by pg_dump version 9.3.9
-- Started on 2015-07-04 23:06:02 EEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 14 (class 2615 OID 17001)
-- Name: billing; Type: SCHEMA; Schema: -; Owner: cdr
--

CREATE SCHEMA billing;


ALTER SCHEMA billing OWNER TO cdr;

--
-- TOC entry 12 (class 2615 OID 16998)
-- Name: cdr; Type: SCHEMA; Schema: -; Owner: cdr
--

CREATE SCHEMA cdr;


ALTER SCHEMA cdr OWNER TO cdr;

--
-- TOC entry 13 (class 2615 OID 16999)
-- Name: event; Type: SCHEMA; Schema: -; Owner: cdr
--

CREATE SCHEMA event;


ALTER SCHEMA event OWNER TO cdr;

--
-- TOC entry 7 (class 2615 OID 16645)
-- Name: pgq; Type: SCHEMA; Schema: -; Owner: cdr
--

CREATE SCHEMA pgq;


ALTER SCHEMA pgq OWNER TO cdr;

--
-- TOC entry 10 (class 2615 OID 16947)
-- Name: pgq_coop; Type: SCHEMA; Schema: -; Owner: cdr
--

CREATE SCHEMA pgq_coop;


ALTER SCHEMA pgq_coop OWNER TO cdr;

--
-- TOC entry 8 (class 2615 OID 16798)
-- Name: pgq_ext; Type: SCHEMA; Schema: -; Owner: cdr
--

CREATE SCHEMA pgq_ext;


ALTER SCHEMA pgq_ext OWNER TO cdr;

--
-- TOC entry 9 (class 2615 OID 16849)
-- Name: pgq_node; Type: SCHEMA; Schema: -; Owner: cdr
--

CREATE SCHEMA pgq_node;


ALTER SCHEMA pgq_node OWNER TO cdr;

--
-- TOC entry 16 (class 2615 OID 17798)
-- Name: reports; Type: SCHEMA; Schema: -; Owner: cdr
--

CREATE SCHEMA reports;


ALTER SCHEMA reports OWNER TO cdr;

--
-- TOC entry 17 (class 2615 OID 18537)
-- Name: stats; Type: SCHEMA; Schema: -; Owner: cdr
--

CREATE SCHEMA stats;


ALTER SCHEMA stats OWNER TO cdr;

--
-- TOC entry 11 (class 2615 OID 16995)
-- Name: switch; Type: SCHEMA; Schema: -; Owner: cdr
--

CREATE SCHEMA switch;


ALTER SCHEMA switch OWNER TO cdr;

--
-- TOC entry 15 (class 2615 OID 17044)
-- Name: sys; Type: SCHEMA; Schema: -; Owner: cdr
--

CREATE SCHEMA sys;


ALTER SCHEMA sys OWNER TO cdr;

--
-- TOC entry 297 (class 3079 OID 11756)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2821 (class 0 OID 0)
-- Dependencies: 297
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = billing, pg_catalog;

--
-- TOC entry 929 (class 1247 OID 17264)
-- Name: cdr_v2; Type: TYPE; Schema: billing; Owner: cdr
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
	legb_disconnect_reason character varying
);


ALTER TYPE billing.cdr_v2 OWNER TO cdr;

--
-- TOC entry 872 (class 1247 OID 17004)
-- Name: interval_billing_data; Type: TYPE; Schema: billing; Owner: cdr
--

CREATE TYPE interval_billing_data AS (
	duration numeric,
	amount numeric
);


ALTER TYPE billing.interval_billing_data OWNER TO cdr;

SET search_path = switch, pg_catalog;

--
-- TOC entry 856 (class 1247 OID 18078)
-- Name: rtp_stats_data_ty; Type: TYPE; Schema: switch; Owner: cdr
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


ALTER TYPE switch.rtp_stats_data_ty OWNER TO cdr;

--
-- TOC entry 1076 (class 1247 OID 20241)
-- Name: time_data_ty; Type: TYPE; Schema: switch; Owner: cdr
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


ALTER TYPE switch.time_data_ty OWNER TO cdr;

SET search_path = cdr, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 201 (class 1259 OID 17025)
-- Name: cdr; Type: TABLE; Schema: cdr; Owner: cdr; Tablespace: 
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
    routing_delay real,
    pdd real,
    rtt real,
    early_media_present boolean,
    lnp_database_id smallint,
    lrn character varying,
    destination_prefix character varying,
    dialpeer_prefix character varying
);


ALTER TABLE cdr.cdr OWNER TO cdr;

SET search_path = billing, pg_catalog;

--
-- TOC entry 418 (class 1255 OID 17069)
-- Name: bill_cdr(cdr.cdr); Type: FUNCTION; Schema: billing; Owner: cdr
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
            0);
         i_cdr.customer_price=_v.amount;
         
         _v=billing.interval_billing(
            i_cdr.duration,
            i_cdr.dialpeer_fee,
            i_cdr.dialpeer_initial_rate,
            i_cdr.dialpeer_next_rate,
            i_cdr.dialpeer_initial_interval,
            i_cdr.dialpeer_next_interval,
            0);
         i_cdr.vendor_price=_v.amount;
         i_cdr.profit=i_cdr.customer_price-i_cdr.vendor_price;
    else
        i_cdr.customer_price=0;
        i_cdr.vendor_price=0;
        i_cdr.profit=0;
    end if;
    RETURN i_cdr;
END;
$$;


ALTER FUNCTION billing.bill_cdr(i_cdr cdr.cdr) OWNER TO cdr;

--
-- TOC entry 413 (class 1255 OID 17005)
-- Name: interval_billing(numeric, numeric, numeric, numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: billing; Owner: cdr
--

CREATE FUNCTION interval_billing(i_duration numeric, i_connection_fee numeric, i_initial_rate numeric, i_next_rate numeric, i_initial_interval numeric, i_next_interval numeric, i_vat numeric DEFAULT 0) RETURNS interval_billing_data
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    _v billing.interval_billing_data%rowtype;
BEGIN
    i_vat=COALESCE(i_vat,0);
    _v.amount=i_connection_fee+
            i_initial_interval*i_initial_rate::numeric/60 + -- initial interval billing
            (i_duration>i_initial_interval)::boolean::integer * -- next interval billing enabled
            CEIL((i_duration-i_initial_interval)::numeric/i_next_interval) *-- next interval count
            i_next_interval * --interval len
            i_next_rate::numeric/60; -- next interval rate per second

    _v.duration=i_initial_interval+(i_duration>i_initial_interval)::boolean::integer * CEIL((i_duration-i_initial_interval)::numeric/i_next_interval) *i_next_interval;

    RETURN _v;
END;
$$;


ALTER FUNCTION billing.interval_billing(i_duration numeric, i_connection_fee numeric, i_initial_rate numeric, i_next_rate numeric, i_initial_interval numeric, i_next_interval numeric, i_vat numeric) OWNER TO cdr;

--
-- TOC entry 430 (class 1255 OID 20299)
-- Name: invoice_generate(integer); Type: FUNCTION; Schema: billing; Owner: cdr
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


ALTER FUNCTION billing.invoice_generate(i_id integer) OWNER TO cdr;

--
-- TOC entry 428 (class 1255 OID 20194)
-- Name: invoice_generate(integer, integer, boolean, timestamp with time zone, timestamp with time zone); Type: FUNCTION; Schema: billing; Owner: cdr
--

CREATE FUNCTION invoice_generate(i_contractor_id integer, i_account_id integer, i_vendor_flag boolean, i_startdate timestamp with time zone, i_enddate timestamp with time zone) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION billing.invoice_generate(i_contractor_id integer, i_account_id integer, i_vendor_flag boolean, i_startdate timestamp with time zone, i_enddate timestamp with time zone) OWNER TO cdr;

SET search_path = cdr, pg_catalog;

--
-- TOC entry 431 (class 1255 OID 17022)
-- Name: cdr_i_tgf(); Type: FUNCTION; Schema: cdr; Owner: cdr
--

CREATE FUNCTION cdr_i_tgf() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
BEGIN  IF ( NEW.time_start >= '2015-01-01 00:00:00+00' AND NEW.time_start < '2015-02-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201501 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2015-02-01 00:00:00+00' AND NEW.time_start < '2015-03-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201502 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2015-03-01 00:00:00+00' AND NEW.time_start < '2015-04-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201503 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2015-04-01 00:00:00+00' AND NEW.time_start < '2015-05-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201504 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2015-05-01 00:00:00+00' AND NEW.time_start < '2015-06-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201505 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2015-06-01 00:00:00+00' AND NEW.time_start < '2015-07-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201506 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2015-07-01 00:00:00+00' AND NEW.time_start < '2015-08-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201507 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2015-08-01 00:00:00+00' AND NEW.time_start < '2015-09-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201508 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2015-09-01 00:00:00+00' AND NEW.time_start < '2015-10-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201509 VALUES (NEW.*);
ELSIF ( NEW.time_start >= '2015-10-01 00:00:00+00' AND NEW.time_start < '2015-11-01 00:00:00+00' ) THEN INSERT INTO cdr.cdr_201510 VALUES (NEW.*);
 ELSE 
 RAISE EXCEPTION 'cdr.cdr_i_tg: time_start out of range.'; 
 END IF;  
RETURN NULL; 
END; $$;


ALTER FUNCTION cdr.cdr_i_tgf() OWNER TO cdr;

SET search_path = event, pg_catalog;

--
-- TOC entry 409 (class 1255 OID 17000)
-- Name: billing_insert_event(text, anyelement); Type: FUNCTION; Schema: event; Owner: cdr
--

CREATE FUNCTION billing_insert_event(ev_type text, ev_data anyelement) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
begin
    return pgq.insert_event('cdr_billing', ev_type, event.serialize(ev_data), null, null, null, null);
end;
$$;


ALTER FUNCTION event.billing_insert_event(ev_type text, ev_data anyelement) OWNER TO cdr;

--
-- TOC entry 417 (class 1255 OID 17072)
-- Name: serialize(anyelement); Type: FUNCTION; Schema: event; Owner: cdr
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


ALTER FUNCTION event.serialize(i_data anyelement) OWNER TO cdr;

SET search_path = pgq, pg_catalog;

--
-- TOC entry 331 (class 1255 OID 16762)
-- Name: _grant_perms_from(text, text, text, text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION _grant_perms_from(src_schema text, src_table text, dst_schema text, dst_table text) RETURNS integer
    LANGUAGE plpgsql STRICT
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.grant_perms_from(1)
--
--      Copy grants from one table to another.
--      Workaround for missing GRANTS option for CREATE TABLE LIKE.
-- ----------------------------------------------------------------------
declare
    fq_table text;
    sql text;
    g record;
    q_grantee text;
begin
    fq_table := quote_ident(dst_schema) || '.' || quote_ident(dst_table);

    for g in
        select grantor, grantee, privilege_type, is_grantable
            from information_schema.table_privileges
            where table_schema = src_schema
                and table_name = src_table
    loop
        if g.grantee = 'PUBLIC' then
            q_grantee = 'public';
        else
            q_grantee = quote_ident(g.grantee);
        end if;
        sql := 'grant ' || g.privilege_type || ' on ' || fq_table
            || ' to ' || q_grantee;
        if g.is_grantable = 'YES' then
            sql := sql || ' with grant option';
        end if;
        execute sql;
    end loop;

    return 1;
end;
$$;


ALTER FUNCTION pgq._grant_perms_from(src_schema text, src_table text, dst_schema text, dst_table text) OWNER TO cdr;

--
-- TOC entry 323 (class 1255 OID 16747)
-- Name: batch_event_sql(bigint); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION batch_event_sql(x_batch_id bigint) RETURNS text
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.batch_event_sql(1)
--      Creates SELECT statement that fetches events for this batch.
--
-- Parameters:
--      x_batch_id    - ID of a active batch.
--
-- Returns:
--      SQL statement.
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Algorithm description:
--      Given 2 snapshots, sn1 and sn2 with sn1 having xmin1, xmax1
--      and sn2 having xmin2, xmax2 create expression that filters
--      right txid's from event table.
--
--      Simplest solution would be
--      > WHERE ev_txid >= xmin1 AND ev_txid <= xmax2
--      >   AND NOT txid_visible_in_snapshot(ev_txid, sn1)
--      >   AND txid_visible_in_snapshot(ev_txid, sn2)
--
--      The simple solution has a problem with long transactions (xmin1 very low).
--      All the batches that happen when the long tx is active will need
--      to scan all events in that range.  Here is 2 optimizations used:
--
--      1)  Use [xmax1..xmax2] for range scan.  That limits the range to
--      txids that actually happened between two snapshots.  For txids
--      in the range [xmin1..xmax1] look which ones were actually
--      committed between snapshots and search for them using exact
--      values using IN (..) list.
--
--      2) As most TX are short, there could be lot of them that were
--      just below xmax1, but were committed before xmax2.  So look
--      if there are ID's near xmax1 and lower the range to include
--      them, thus decresing size of IN (..) list.
-- ----------------------------------------------------------------------
declare
    rec             record;
    sql             text;
    tbl             text;
    arr             text;
    part            text;
    select_fields   text;
    retry_expr      text;
    batch           record;
begin
    select s.sub_last_tick, s.sub_next_tick, s.sub_id, s.sub_queue,
           txid_snapshot_xmax(last.tick_snapshot) as tx_start,
           txid_snapshot_xmax(cur.tick_snapshot) as tx_end,
           last.tick_snapshot as last_snapshot,
           cur.tick_snapshot as cur_snapshot
        into batch
        from pgq.subscription s, pgq.tick last, pgq.tick cur
        where s.sub_batch = x_batch_id
          and last.tick_queue = s.sub_queue
          and last.tick_id = s.sub_last_tick
          and cur.tick_queue = s.sub_queue
          and cur.tick_id = s.sub_next_tick;
    if not found then
        raise exception 'batch not found';
    end if;

    -- load older transactions
    arr := '';
    for rec in
        -- active tx-es in prev_snapshot that were committed in cur_snapshot
        select id1 from
            txid_snapshot_xip(batch.last_snapshot) id1 left join
            txid_snapshot_xip(batch.cur_snapshot) id2 on (id1 = id2)
        where id2 is null
        order by 1 desc
    loop
        -- try to avoid big IN expression, so try to include nearby
        -- tx'es into range
        if batch.tx_start - 100 <= rec.id1 then
            batch.tx_start := rec.id1;
        else
            if arr = '' then
                arr := rec.id1::text;
            else
                arr := arr || ',' || rec.id1::text;
            end if;
        end if;
    end loop;

    -- must match pgq.event_template
    select_fields := 'select ev_id, ev_time, ev_txid, ev_retry, ev_type,'
        || ' ev_data, ev_extra1, ev_extra2, ev_extra3, ev_extra4';
    retry_expr :=  ' and (ev_owner is null or ev_owner = '
        || batch.sub_id::text || ')';

    -- now generate query that goes over all potential tables
    sql := '';
    for rec in
        select xtbl from pgq.batch_event_tables(x_batch_id) xtbl
    loop
        tbl := pgq.quote_fqname(rec.xtbl);
        -- this gets newer queries that definitely are not in prev_snapshot
        part := select_fields
            || ' from pgq.tick cur, pgq.tick last, ' || tbl || ' ev '
            || ' where cur.tick_id = ' || batch.sub_next_tick::text
            || ' and cur.tick_queue = ' || batch.sub_queue::text
            || ' and last.tick_id = ' || batch.sub_last_tick::text
            || ' and last.tick_queue = ' || batch.sub_queue::text
            || ' and ev.ev_txid >= ' || batch.tx_start::text
            || ' and ev.ev_txid <= ' || batch.tx_end::text
            || ' and txid_visible_in_snapshot(ev.ev_txid, cur.tick_snapshot)'
            || ' and not txid_visible_in_snapshot(ev.ev_txid, last.tick_snapshot)'
            || retry_expr;
        -- now include older tx-es, that were ongoing
        -- at the time of prev_snapshot
        if arr <> '' then
            part := part || ' union all '
                || select_fields || ' from ' || tbl || ' ev '
                || ' where ev.ev_txid in (' || arr || ')'
                || retry_expr;
        end if;
        if sql = '' then
            sql := part;
        else
            sql := sql || ' union all ' || part;
        end if;
    end loop;
    if sql = '' then
        raise exception 'could not construct sql for batch %', x_batch_id;
    end if;
    return sql || ' order by 1';
end;
$$;


ALTER FUNCTION pgq.batch_event_sql(x_batch_id bigint) OWNER TO cdr;

--
-- TOC entry 324 (class 1255 OID 16749)
-- Name: batch_event_tables(bigint); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION batch_event_tables(x_batch_id bigint) RETURNS SETOF text
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.batch_event_tables(1)
--
--     Returns set of table names where this batch events may reside.
--
-- Parameters:
--     x_batch_id    - ID of a active batch.
-- ----------------------------------------------------------------------
declare
    nr                    integer;
    tbl                   text;
    use_prev              integer;
    use_next              integer;
    batch                 record;
begin
    select
           txid_snapshot_xmin(last.tick_snapshot) as tx_min, -- absolute minimum
           txid_snapshot_xmax(cur.tick_snapshot) as tx_max, -- absolute maximum
           q.queue_data_pfx, q.queue_ntables,
           q.queue_cur_table, q.queue_switch_step1, q.queue_switch_step2
        into batch
        from pgq.tick last, pgq.tick cur, pgq.subscription s, pgq.queue q
        where cur.tick_id = s.sub_next_tick
          and cur.tick_queue = s.sub_queue
          and last.tick_id = s.sub_last_tick
          and last.tick_queue = s.sub_queue
          and s.sub_batch = x_batch_id
          and q.queue_id = s.sub_queue;
    if not found then
        raise exception 'Cannot find data for batch %', x_batch_id;
    end if;

    -- if its definitely not in one or other, look into both
    if batch.tx_max < batch.queue_switch_step1 then
        use_prev := 1;
        use_next := 0;
    elsif batch.queue_switch_step2 is not null
      and (batch.tx_min > batch.queue_switch_step2)
    then
        use_prev := 0;
        use_next := 1;
    else
        use_prev := 1;
        use_next := 1;
    end if;

    if use_prev then
        nr := batch.queue_cur_table - 1;
        if nr < 0 then
            nr := batch.queue_ntables - 1;
        end if;
        tbl := batch.queue_data_pfx || '_' || nr::text;
        return next tbl;
    end if;

    if use_next then
        tbl := batch.queue_data_pfx || '_' || batch.queue_cur_table::text;
        return next tbl;
    end if;

    return;
end;
$$;


ALTER FUNCTION pgq.batch_event_tables(x_batch_id bigint) OWNER TO cdr;

--
-- TOC entry 356 (class 1255 OID 16787)
-- Name: batch_retry(bigint, integer); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION batch_retry(i_batch_id bigint, i_retry_seconds integer) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.batch_retry(2)
--
--     Put whole batch into retry queue, to be processed again later.
--
-- Parameters:
--      i_batch_id      - ID of active batch.
--      i_retry_time    - Time when the event should be put back into queue
--
-- Returns:
--     number of events inserted
-- Calls:
--      None
-- Tables directly manipulated:
--      pgq.retry_queue
-- ----------------------------------------------------------------------
declare
    _retry timestamptz;
    _cnt   integer;
    _s     record;
begin
    _retry := current_timestamp + ((i_retry_seconds::text || ' seconds')::interval);

    select * into _s from pgq.subscription where sub_batch = i_batch_id;
    if not found then
        raise exception 'batch_retry: batch % not found', i_batch_id;
    end if;

    insert into pgq.retry_queue (ev_retry_after, ev_queue,
        ev_id, ev_time, ev_txid, ev_owner, ev_retry,
        ev_type, ev_data, ev_extra1, ev_extra2,
        ev_extra3, ev_extra4)
    select distinct _retry, _s.sub_queue,
           b.ev_id, b.ev_time, NULL::int8, _s.sub_id, coalesce(b.ev_retry, 0) + 1,
           b.ev_type, b.ev_data, b.ev_extra1, b.ev_extra2,
           b.ev_extra3, b.ev_extra4
      from pgq.get_batch_events(i_batch_id) b
           left join pgq.retry_queue rq
                  on (rq.ev_id = b.ev_id
                      and rq.ev_owner = _s.sub_id
                      and rq.ev_queue = _s.sub_queue)
      where rq.ev_id is null;

    GET DIAGNOSTICS _cnt = ROW_COUNT;
    return _cnt;
end;
$$;


ALTER FUNCTION pgq.batch_retry(i_batch_id bigint, i_retry_seconds integer) OWNER TO cdr;

--
-- TOC entry 338 (class 1255 OID 16768)
-- Name: create_queue(text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION create_queue(i_queue_name text) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.create_queue(1)
--
--      Creates new queue with given name.
--
-- Returns:
--      0 - queue already exists
--      1 - queue created
-- Calls:
--      pgq.grant_perms(i_queue_name);
--      pgq.ticker(i_queue_name);
--      pgq.tune_storage(i_queue_name);
-- Tables directly manipulated:
--      insert - pgq.queue
--      create - pgq.event_N () inherits (pgq.event_template)
--      create - pgq.event_N_0 .. pgq.event_N_M () inherits (pgq.event_N)
-- ----------------------------------------------------------------------
declare
    tblpfx   text;
    tblname  text;
    idxpfx   text;
    idxname  text;
    sql      text;
    id       integer;
    tick_seq text;
    ev_seq text;
    n_tables integer;
begin
    if i_queue_name is null then
        raise exception 'Invalid NULL value';
    end if;

    -- check if exists
    perform 1 from pgq.queue where queue_name = i_queue_name;
    if found then
        return 0;
    end if;

    -- insert event
    id := nextval('pgq.queue_queue_id_seq');
    tblpfx := 'pgq.event_' || id::text;
    idxpfx := 'event_' || id::text;
    tick_seq := 'pgq.event_' || id::text || '_tick_seq';
    ev_seq := 'pgq.event_' || id::text || '_id_seq';
    insert into pgq.queue (queue_id, queue_name,
            queue_data_pfx, queue_event_seq, queue_tick_seq)
        values (id, i_queue_name, tblpfx, ev_seq, tick_seq);

    select queue_ntables into n_tables from pgq.queue
        where queue_id = id;

    -- create seqs
    execute 'CREATE SEQUENCE ' || pgq.quote_fqname(tick_seq);
    execute 'CREATE SEQUENCE ' || pgq.quote_fqname(ev_seq);

    -- create data tables
    execute 'CREATE TABLE ' || pgq.quote_fqname(tblpfx) || ' () '
            || ' INHERITS (pgq.event_template)';
    for i in 0 .. (n_tables - 1) loop
        tblname := tblpfx || '_' || i::text;
        idxname := idxpfx || '_' || i::text || '_txid_idx';
        execute 'CREATE TABLE ' || pgq.quote_fqname(tblname) || ' () '
                || ' INHERITS (' || pgq.quote_fqname(tblpfx) || ')';
        execute 'ALTER TABLE ' || pgq.quote_fqname(tblname) || ' ALTER COLUMN ev_id '
                || ' SET DEFAULT nextval(' || quote_literal(ev_seq) || ')';
        execute 'create index ' || quote_ident(idxname) || ' on '
                || pgq.quote_fqname(tblname) || ' (ev_txid)';
    end loop;

    perform pgq.grant_perms(i_queue_name);

    perform pgq.ticker(i_queue_name);

    perform pgq.tune_storage(i_queue_name);

    return 1;
end;
$$;


ALTER FUNCTION pgq.create_queue(i_queue_name text) OWNER TO cdr;

--
-- TOC entry 345 (class 1255 OID 16774)
-- Name: current_event_table(text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION current_event_table(x_queue_name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.current_event_table(1)
--
--      Return active event table for particular queue.
--      Event can be added to it without going via functions,
--      e.g. by COPY.
--
--      If queue is disabled and GUC session_replication_role <> 'replica'
--      then raises exception.
--
--      or expressed in a different way - an even table of a disabled queue
--      is returned only on replica
--
-- Note:
--      The result is valid only during current transaction.
--
-- Permissions:
--      Actual insertion requires superuser access.
--
-- Parameters:
--      x_queue_name    - Queue name.
-- ----------------------------------------------------------------------
declare
    res text;
    disabled boolean;
begin
    select queue_data_pfx || '_' || queue_cur_table::text,
           queue_disable_insert
        into res, disabled
        from pgq.queue where queue_name = x_queue_name;
    if not found then
        raise exception 'Event queue not found';
    end if;
    if disabled then
        if current_setting('session_replication_role') <> 'replica' then
            raise exception 'Writing to queue disabled';
        end if;
    end if;
    return res;
end;
$$;


ALTER FUNCTION pgq.current_event_table(x_queue_name text) OWNER TO cdr;

--
-- TOC entry 340 (class 1255 OID 16770)
-- Name: drop_queue(text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION drop_queue(x_queue_name text) RETURNS integer
    LANGUAGE plpgsql STRICT
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.drop_queue(1)
--
--     Drop queue and all associated tables.
--     No consumers must be listening on the queue.
--
-- ----------------------------------------------------------------------
begin
    return pgq.drop_queue(x_queue_name, false);
end;
$$;


ALTER FUNCTION pgq.drop_queue(x_queue_name text) OWNER TO cdr;

--
-- TOC entry 339 (class 1255 OID 16769)
-- Name: drop_queue(text, boolean); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION drop_queue(x_queue_name text, x_force boolean) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.drop_queue(2)
--
--     Drop queue and all associated tables.
--
-- Parameters:
--      x_queue_name    - queue name
--      x_force         - ignore (drop) existing consumers
-- Returns:
--      1 - success
-- Calls:
--      pgq.unregister_consumer(queue_name, consumer_name)
--      perform pgq.ticker(i_queue_name);
--      perform pgq.tune_storage(i_queue_name);
-- Tables directly manipulated:
--      delete - pgq.queue
--      drop - pgq.event_N (), pgq.event_N_0 .. pgq.event_N_M 
-- ----------------------------------------------------------------------
declare
    tblname  text;
    q record;
    num integer;
begin
    -- check if exists
    select * into q from pgq.queue
        where queue_name = x_queue_name
        for update;
    if not found then
        raise exception 'No such event queue';
    end if;

    if x_force then
        perform pgq.unregister_consumer(queue_name, consumer_name)
           from pgq.get_consumer_info(x_queue_name);
    else
        -- check if no consumers
        select count(*) into num from pgq.subscription
            where sub_queue = q.queue_id;
        if num > 0 then
            raise exception 'cannot drop queue, consumers still attached';
        end if;
    end if;

    -- drop data tables
    for i in 0 .. (q.queue_ntables - 1) loop
        tblname := q.queue_data_pfx || '_' || i::text;
        execute 'DROP TABLE ' || pgq.quote_fqname(tblname);
    end loop;
    execute 'DROP TABLE ' || pgq.quote_fqname(q.queue_data_pfx);

    -- delete ticks
    delete from pgq.tick where tick_queue = q.queue_id;

    -- drop seqs
    -- FIXME: any checks needed here?
    execute 'DROP SEQUENCE ' || pgq.quote_fqname(q.queue_tick_seq);
    execute 'DROP SEQUENCE ' || pgq.quote_fqname(q.queue_event_seq);

    -- delete event
    delete from pgq.queue
        where queue_name = x_queue_name;

    return 1;
end;
$$;


ALTER FUNCTION pgq.drop_queue(x_queue_name text, x_force boolean) OWNER TO cdr;

--
-- TOC entry 355 (class 1255 OID 16786)
-- Name: event_retry(bigint, bigint, integer); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION event_retry(x_batch_id bigint, x_event_id bigint, x_retry_seconds integer) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.event_retry(3b)
--
--     Put the event into retry queue, to be processed later again.
--
-- Parameters:
--      x_batch_id      - ID of active batch.
--      x_event_id      - event id
--      x_retry_seconds - Time when the event should be put back into queue
--
-- Returns:
--     1 - success
--     0 - event already in retry queue
-- Calls:
--      pgq.event_retry(3a)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
declare
    new_retry  timestamptz;
begin
    new_retry := current_timestamp + ((x_retry_seconds::text || ' seconds')::interval);
    return pgq.event_retry(x_batch_id, x_event_id, new_retry);
end;
$$;


ALTER FUNCTION pgq.event_retry(x_batch_id bigint, x_event_id bigint, x_retry_seconds integer) OWNER TO cdr;

--
-- TOC entry 354 (class 1255 OID 16785)
-- Name: event_retry(bigint, bigint, timestamp with time zone); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION event_retry(x_batch_id bigint, x_event_id bigint, x_retry_time timestamp with time zone) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.event_retry(3a)
--
--     Put the event into retry queue, to be processed again later.
--
-- Parameters:
--      x_batch_id      - ID of active batch.
--      x_event_id      - event id
--      x_retry_time    - Time when the event should be put back into queue
--
-- Returns:
--     1 - success
--     0 - event already in retry queue
-- Calls:
--      None
-- Tables directly manipulated:
--      insert - pgq.retry_queue
-- ----------------------------------------------------------------------
begin
    insert into pgq.retry_queue (ev_retry_after, ev_queue,
        ev_id, ev_time, ev_txid, ev_owner, ev_retry, ev_type, ev_data,
        ev_extra1, ev_extra2, ev_extra3, ev_extra4)
    select x_retry_time, sub_queue,
           ev_id, ev_time, NULL, sub_id, coalesce(ev_retry, 0) + 1,
           ev_type, ev_data, ev_extra1, ev_extra2, ev_extra3, ev_extra4
      from pgq.get_batch_events(x_batch_id),
           pgq.subscription
     where sub_batch = x_batch_id
       and ev_id = x_event_id;
    if not found then
        raise exception 'event not found';
    end if;
    return 1;

-- dont worry if the event is already in queue
exception
    when unique_violation then
        return 0;
end;
$$;


ALTER FUNCTION pgq.event_retry(x_batch_id bigint, x_event_id bigint, x_retry_time timestamp with time zone) OWNER TO cdr;

--
-- TOC entry 325 (class 1255 OID 16750)
-- Name: event_retry_raw(text, text, timestamp with time zone, bigint, timestamp with time zone, integer, text, text, text, text, text, text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION event_retry_raw(x_queue text, x_consumer text, x_retry_after timestamp with time zone, x_ev_id bigint, x_ev_time timestamp with time zone, x_ev_retry integer, x_ev_type text, x_ev_data text, x_ev_extra1 text, x_ev_extra2 text, x_ev_extra3 text, x_ev_extra4 text) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.event_retry_raw(12)
--
--      Allows full control over what goes to retry queue.
--
-- Parameters:
--      x_queue         - name of the queue
--      x_consumer      - name of the consumer
--      x_retry_after   - when the event should be processed again
--      x_ev_id         - event id
--      x_ev_time       - creation time
--      x_ev_retry      - retry count
--      x_ev_type       - user data
--      x_ev_data       - user data
--      x_ev_extra1     - user data
--      x_ev_extra2     - user data
--      x_ev_extra3     - user data
--      x_ev_extra4     - user data
--
-- Returns:
--      Event ID.
-- ----------------------------------------------------------------------
declare
    q record;
    id bigint;
begin
    select sub_id, queue_event_seq, sub_queue into q
      from pgq.consumer, pgq.queue, pgq.subscription
     where queue_name = x_queue
       and co_name = x_consumer
       and sub_consumer = co_id
       and sub_queue = queue_id;
    if not found then
        raise exception 'consumer not registered';
    end if;

    id := x_ev_id;
    if id is null then
        id := nextval(q.queue_event_seq);
    end if;

    insert into pgq.retry_queue (ev_retry_after, ev_queue,
            ev_id, ev_time, ev_owner, ev_retry,
            ev_type, ev_data, ev_extra1, ev_extra2, ev_extra3, ev_extra4)
    values (x_retry_after, q.sub_queue,
            id, x_ev_time, q.sub_id, x_ev_retry,
            x_ev_type, x_ev_data, x_ev_extra1, x_ev_extra2,
            x_ev_extra3, x_ev_extra4);

    return id;
end;
$$;


ALTER FUNCTION pgq.event_retry_raw(x_queue text, x_consumer text, x_retry_after timestamp with time zone, x_ev_id bigint, x_ev_time timestamp with time zone, x_ev_retry integer, x_ev_type text, x_ev_data text, x_ev_extra1 text, x_ev_extra2 text, x_ev_extra3 text, x_ev_extra4 text) OWNER TO cdr;

--
-- TOC entry 326 (class 1255 OID 16751)
-- Name: find_tick_helper(integer, bigint, timestamp with time zone, bigint, bigint, interval); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION find_tick_helper(i_queue_id integer, i_prev_tick_id bigint, i_prev_tick_time timestamp with time zone, i_prev_tick_seq bigint, i_min_count bigint, i_min_interval interval, OUT next_tick_id bigint, OUT next_tick_time timestamp with time zone, OUT next_tick_seq bigint) RETURNS record
    LANGUAGE plpgsql STABLE
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.find_tick_helper(6)
--
--      Helper function for pgq.next_batch_custom() to do extended tick search.
-- ----------------------------------------------------------------------
declare
    sure    boolean;
    can_set boolean;
    t       record;
    cnt     int8;
    ival    interval;
begin
    -- first, fetch last tick of the queue
    select tick_id, tick_time, tick_event_seq into t
        from pgq.tick
        where tick_queue = i_queue_id
          and tick_id > i_prev_tick_id
        order by tick_queue desc, tick_id desc
        limit 1;
    if not found then
        return;
    end if;
    
    -- check whether batch would end up within reasonable limits
    sure := true;
    can_set := false;
    if i_min_count is not null then
        cnt = t.tick_event_seq - i_prev_tick_seq;
        if cnt >= i_min_count then
            can_set := true;
        end if;
        if cnt > i_min_count * 2 then
            sure := false;
        end if;
    end if;
    if i_min_interval is not null then
        ival = t.tick_time - i_prev_tick_time;
        if ival >= i_min_interval then
            can_set := true;
        end if;
        if ival > i_min_interval * 2 then
            sure := false;
        end if;
    end if;

    -- if last tick too far away, do large scan
    if not sure then
        select tick_id, tick_time, tick_event_seq into t
            from pgq.tick
            where tick_queue = i_queue_id
              and tick_id > i_prev_tick_id
              and ((i_min_count is not null and (tick_event_seq - i_prev_tick_seq) >= i_min_count)
                  or
                   (i_min_interval is not null and (tick_time - i_prev_tick_time) >= i_min_interval))
            order by tick_queue asc, tick_id asc
            limit 1;
        can_set := true;
    end if;
    if can_set then
        next_tick_id := t.tick_id;
        next_tick_time := t.tick_time;
        next_tick_seq := t.tick_event_seq;
    end if;
    return;
end;
$$;


ALTER FUNCTION pgq.find_tick_helper(i_queue_id integer, i_prev_tick_id bigint, i_prev_tick_time timestamp with time zone, i_prev_tick_seq bigint, i_min_count bigint, i_min_interval interval, OUT next_tick_id bigint, OUT next_tick_time timestamp with time zone, OUT next_tick_seq bigint) OWNER TO cdr;

--
-- TOC entry 357 (class 1255 OID 16788)
-- Name: finish_batch(bigint); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION finish_batch(x_batch_id bigint) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.finish_batch(1)
--
--      Closes a batch.  No more operations can be done with events
--      of this batch.
--
-- Parameters:
--      x_batch_id      - id of batch.
--
-- Returns:
--      1 if batch was found, 0 otherwise.
-- Calls:
--      None
-- Tables directly manipulated:
--      update - pgq.subscription
-- ----------------------------------------------------------------------
begin
    update pgq.subscription
        set sub_active = now(),
            sub_last_tick = sub_next_tick,
            sub_next_tick = null,
            sub_batch = null
        where sub_batch = x_batch_id;
    if not found then
        raise warning 'finish_batch: batch % not found', x_batch_id;
        return 0;
    end if;

    return 1;
end;
$$;


ALTER FUNCTION pgq.finish_batch(x_batch_id bigint) OWNER TO cdr;

--
-- TOC entry 333 (class 1255 OID 16764)
-- Name: force_tick(text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION force_tick(i_queue_name text) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.force_tick(2)
--
--      Simulate lots of events happening to force ticker to tick.
--
--      Should be called in loop, with some delay until last tick
--      changes or too much time is passed.
--
--      Such function is needed because paraller calls of pgq.ticker() are
--      dangerous, and cannot be protected with locks as snapshot
--      is taken before locking.
--
-- Parameters:
--      i_queue_name     - Name of the queue
--
-- Returns:
--      Currently last tick id.
-- ----------------------------------------------------------------------
declare
    q  record;
    t  record;
begin
    -- bump seq and get queue id
    select queue_id,
           setval(queue_event_seq, nextval(queue_event_seq)
                                   + queue_ticker_max_count * 2 + 1000) as tmp
      into q from pgq.queue
     where queue_name = i_queue_name
       and not queue_external_ticker
       and not queue_ticker_paused;

    --if not found then
    --    raise notice 'queue not found or ticks not allowed';
    --end if;

    -- return last tick id
    select tick_id into t
      from pgq.tick, pgq.queue
     where tick_queue = queue_id and queue_name = i_queue_name
     order by tick_queue desc, tick_id desc limit 1;

    return t.tick_id;
end;
$$;


ALTER FUNCTION pgq.force_tick(i_queue_name text) OWNER TO cdr;

--
-- TOC entry 353 (class 1255 OID 16784)
-- Name: get_batch_cursor(bigint, text, integer); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION get_batch_cursor(i_batch_id bigint, i_cursor_name text, i_quick_limit integer, OUT ev_id bigint, OUT ev_time timestamp with time zone, OUT ev_txid bigint, OUT ev_retry integer, OUT ev_type text, OUT ev_data text, OUT ev_extra1 text, OUT ev_extra2 text, OUT ev_extra3 text, OUT ev_extra4 text) RETURNS SETOF record
    LANGUAGE plpgsql STRICT
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_batch_cursor(3)
--
--      Get events in batch using a cursor.
--
-- Parameters:
--      i_batch_id      - ID of active batch.
--      i_cursor_name   - Name for new cursor
--      i_quick_limit   - Number of events to return immediately
--
-- Returns:
--      List of events.
-- Calls:
--      pgq.get_batch_cursor(4)
-- ----------------------------------------------------------------------
begin
    for ev_id, ev_time, ev_txid, ev_retry, ev_type, ev_data,
        ev_extra1, ev_extra2, ev_extra3, ev_extra4
    in
        select * from pgq.get_batch_cursor(i_batch_id,
            i_cursor_name, i_quick_limit, null)
    loop
        return next;
    end loop;
    return;
end;
$$;


ALTER FUNCTION pgq.get_batch_cursor(i_batch_id bigint, i_cursor_name text, i_quick_limit integer, OUT ev_id bigint, OUT ev_time timestamp with time zone, OUT ev_txid bigint, OUT ev_retry integer, OUT ev_type text, OUT ev_data text, OUT ev_extra1 text, OUT ev_extra2 text, OUT ev_extra3 text, OUT ev_extra4 text) OWNER TO cdr;

--
-- TOC entry 352 (class 1255 OID 16783)
-- Name: get_batch_cursor(bigint, text, integer, text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION get_batch_cursor(i_batch_id bigint, i_cursor_name text, i_quick_limit integer, i_extra_where text, OUT ev_id bigint, OUT ev_time timestamp with time zone, OUT ev_txid bigint, OUT ev_retry integer, OUT ev_type text, OUT ev_data text, OUT ev_extra1 text, OUT ev_extra2 text, OUT ev_extra3 text, OUT ev_extra4 text) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_batch_cursor(4)
--
--      Get events in batch using a cursor.
--
-- Parameters:
--      i_batch_id      - ID of active batch.
--      i_cursor_name   - Name for new cursor
--      i_quick_limit   - Number of events to return immediately
--      i_extra_where   - optional where clause to filter events
--
-- Returns:
--      List of events.
-- Calls:
--      pgq.batch_event_sql(i_batch_id) - internal function which generates SQL optimised specially for getting events in this batch
-- ----------------------------------------------------------------------
declare
    _cname  text;
    _sql    text;
begin
    if i_batch_id is null or i_cursor_name is null or i_quick_limit is null then
        return;
    end if;

    _cname := quote_ident(i_cursor_name);
    _sql := pgq.batch_event_sql(i_batch_id);

    -- apply extra where
    if i_extra_where is not null then
        _sql := replace(_sql, ' order by 1', '');
        _sql := 'select * from (' || _sql
            || ') _evs where ' || i_extra_where
            || ' order by 1';
    end if;

    -- create cursor
    execute 'declare ' || _cname || ' no scroll cursor for ' || _sql;

    -- if no events wanted, don't bother with execute
    if i_quick_limit <= 0 then
        return;
    end if;

    -- return first block of events
    for ev_id, ev_time, ev_txid, ev_retry, ev_type, ev_data,
        ev_extra1, ev_extra2, ev_extra3, ev_extra4
        in execute 'fetch ' || i_quick_limit::text || ' from ' || _cname
    loop
        return next;
    end loop;

    return;
end;
$$;


ALTER FUNCTION pgq.get_batch_cursor(i_batch_id bigint, i_cursor_name text, i_quick_limit integer, i_extra_where text, OUT ev_id bigint, OUT ev_time timestamp with time zone, OUT ev_txid bigint, OUT ev_retry integer, OUT ev_type text, OUT ev_data text, OUT ev_extra1 text, OUT ev_extra2 text, OUT ev_extra3 text, OUT ev_extra4 text) OWNER TO cdr;

--
-- TOC entry 351 (class 1255 OID 16782)
-- Name: get_batch_events(bigint); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION get_batch_events(x_batch_id bigint, OUT ev_id bigint, OUT ev_time timestamp with time zone, OUT ev_txid bigint, OUT ev_retry integer, OUT ev_type text, OUT ev_data text, OUT ev_extra1 text, OUT ev_extra2 text, OUT ev_extra3 text, OUT ev_extra4 text) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_batch_events(1)
--
--      Get all events in batch.
--
-- Parameters:
--      x_batch_id      - ID of active batch.
--
-- Returns:
--      List of events.
-- ----------------------------------------------------------------------
declare
    sql text;
begin
    sql := pgq.batch_event_sql(x_batch_id);
    for ev_id, ev_time, ev_txid, ev_retry, ev_type, ev_data,
        ev_extra1, ev_extra2, ev_extra3, ev_extra4
        in execute sql
    loop
        return next;
    end loop;
    return;
end;
$$;


ALTER FUNCTION pgq.get_batch_events(x_batch_id bigint, OUT ev_id bigint, OUT ev_time timestamp with time zone, OUT ev_txid bigint, OUT ev_retry integer, OUT ev_type text, OUT ev_data text, OUT ev_extra1 text, OUT ev_extra2 text, OUT ev_extra3 text, OUT ev_extra4 text) OWNER TO cdr;

--
-- TOC entry 364 (class 1255 OID 16795)
-- Name: get_batch_info(bigint); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION get_batch_info(x_batch_id bigint, OUT queue_name text, OUT consumer_name text, OUT batch_start timestamp with time zone, OUT batch_end timestamp with time zone, OUT prev_tick_id bigint, OUT tick_id bigint, OUT lag interval, OUT seq_start bigint, OUT seq_end bigint) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_batch_info(1)
--
--      Returns detailed info about a batch.
--
-- Parameters:
--      x_batch_id      - id of a active batch.
--
-- Returns: ??? pls check
--      queue_name      - which queue this batch came from
--      consumer_name   - batch processed by
--      batch_start     - start time of batch
--      batch_end       - end time of batch
--      prev_tick_id    - start tick for this batch
--      tick_id         - end tick for this batch
--      lag             - now() - tick_id.time 
--      seq_start       - start event id for batch
--      seq_end         - end event id for batch
-- ----------------------------------------------------------------------
begin
    select q.queue_name, c.co_name,
           prev.tick_time, cur.tick_time,
           s.sub_last_tick, s.sub_next_tick,
           current_timestamp - cur.tick_time,
           prev.tick_event_seq, cur.tick_event_seq
        into queue_name, consumer_name, batch_start, batch_end,
             prev_tick_id, tick_id, lag, seq_start, seq_end
        from pgq.subscription s, pgq.tick cur, pgq.tick prev,
             pgq.queue q, pgq.consumer c
        where s.sub_batch = x_batch_id
          and prev.tick_id = s.sub_last_tick
          and prev.tick_queue = s.sub_queue
          and cur.tick_id = s.sub_next_tick
          and cur.tick_queue = s.sub_queue
          and q.queue_id = s.sub_queue
          and c.co_id = s.sub_consumer;
    return;
end;
$$;


ALTER FUNCTION pgq.get_batch_info(x_batch_id bigint, OUT queue_name text, OUT consumer_name text, OUT batch_start timestamp with time zone, OUT batch_end timestamp with time zone, OUT prev_tick_id bigint, OUT tick_id bigint, OUT lag interval, OUT seq_start bigint, OUT seq_end bigint) OWNER TO cdr;

--
-- TOC entry 360 (class 1255 OID 16791)
-- Name: get_consumer_info(); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION get_consumer_info(OUT queue_name text, OUT consumer_name text, OUT lag interval, OUT last_seen interval, OUT last_tick bigint, OUT current_batch bigint, OUT next_tick bigint, OUT pending_events bigint) RETURNS SETOF record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_consumer_info(0)
--
--      Returns info about all consumers on all queues.
--
-- Returns:
--      See pgq.get_consumer_info(2)
-- ----------------------------------------------------------------------
begin
    for queue_name, consumer_name, lag, last_seen,
        last_tick, current_batch, next_tick, pending_events
    in
        select f.queue_name, f.consumer_name, f.lag, f.last_seen,
               f.last_tick, f.current_batch, f.next_tick, f.pending_events
            from pgq.get_consumer_info(null, null) f
    loop
        return next;
    end loop;
    return;
end;
$$;


ALTER FUNCTION pgq.get_consumer_info(OUT queue_name text, OUT consumer_name text, OUT lag interval, OUT last_seen interval, OUT last_tick bigint, OUT current_batch bigint, OUT next_tick bigint, OUT pending_events bigint) OWNER TO cdr;

--
-- TOC entry 361 (class 1255 OID 16792)
-- Name: get_consumer_info(text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION get_consumer_info(i_queue_name text, OUT queue_name text, OUT consumer_name text, OUT lag interval, OUT last_seen interval, OUT last_tick bigint, OUT current_batch bigint, OUT next_tick bigint, OUT pending_events bigint) RETURNS SETOF record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_consumer_info(1)
--
--      Returns info about all consumers on single queue.
--
-- Returns:
--      See pgq.get_consumer_info(2)
-- ----------------------------------------------------------------------
begin
    for queue_name, consumer_name, lag, last_seen,
        last_tick, current_batch, next_tick, pending_events
    in
        select f.queue_name, f.consumer_name, f.lag, f.last_seen,
               f.last_tick, f.current_batch, f.next_tick, f.pending_events
            from pgq.get_consumer_info(i_queue_name, null) f
    loop
        return next;
    end loop;
    return;
end;
$$;


ALTER FUNCTION pgq.get_consumer_info(i_queue_name text, OUT queue_name text, OUT consumer_name text, OUT lag interval, OUT last_seen interval, OUT last_tick bigint, OUT current_batch bigint, OUT next_tick bigint, OUT pending_events bigint) OWNER TO cdr;

--
-- TOC entry 362 (class 1255 OID 16793)
-- Name: get_consumer_info(text, text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION get_consumer_info(i_queue_name text, i_consumer_name text, OUT queue_name text, OUT consumer_name text, OUT lag interval, OUT last_seen interval, OUT last_tick bigint, OUT current_batch bigint, OUT next_tick bigint, OUT pending_events bigint) RETURNS SETOF record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_consumer_info(2)
--
--      Get info about particular consumer on particular queue.
--
-- Parameters:
--      i_queue_name        - name of a queue. (null = all)
--      i_consumer_name     - name of a consumer (null = all)
--
-- Returns:
--      queue_name          - Queue name
--      consumer_name       - Consumer name
--      lag                 - How old are events the consumer is processing
--      last_seen           - When the consumer seen by pgq
--      last_tick           - Tick ID of last processed tick
--      current_batch       - Current batch ID, if one is active or NULL
--      next_tick           - If batch is active, then its final tick.
-- ----------------------------------------------------------------------
declare
    _pending_events bigint;
    _queue_id bigint;
begin
    for queue_name, consumer_name, lag, last_seen,
        last_tick, current_batch, next_tick, _pending_events, _queue_id
    in
        select q.queue_name, c.co_name,
               current_timestamp - t.tick_time,
               current_timestamp - s.sub_active,
               s.sub_last_tick, s.sub_batch, s.sub_next_tick,
               t.tick_event_seq, q.queue_id
          from pgq.queue q,
               pgq.consumer c,
               pgq.subscription s
               left join pgq.tick t
                 on (t.tick_queue = s.sub_queue and t.tick_id = s.sub_last_tick)
         where q.queue_id = s.sub_queue
           and c.co_id = s.sub_consumer
           and (i_queue_name is null or q.queue_name = i_queue_name)
           and (i_consumer_name is null or c.co_name = i_consumer_name)
         order by 1,2
    loop
        select t.tick_event_seq - _pending_events
            into pending_events
            from pgq.tick t
            where t.tick_queue = _queue_id
            order by t.tick_queue desc, t.tick_id desc
            limit 1;
        return next;
    end loop;
    return;
end;
$$;


ALTER FUNCTION pgq.get_consumer_info(i_queue_name text, i_consumer_name text, OUT queue_name text, OUT consumer_name text, OUT lag interval, OUT last_seen interval, OUT last_tick bigint, OUT current_batch bigint, OUT next_tick bigint, OUT pending_events bigint) OWNER TO cdr;

--
-- TOC entry 358 (class 1255 OID 16789)
-- Name: get_queue_info(); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION get_queue_info(OUT queue_name text, OUT queue_ntables integer, OUT queue_cur_table integer, OUT queue_rotation_period interval, OUT queue_switch_time timestamp with time zone, OUT queue_external_ticker boolean, OUT queue_ticker_paused boolean, OUT queue_ticker_max_count integer, OUT queue_ticker_max_lag interval, OUT queue_ticker_idle_period interval, OUT ticker_lag interval, OUT ev_per_sec double precision, OUT ev_new bigint, OUT last_tick_id bigint) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_queue_info(0)
--
--      Get info about all queues.
--
-- Returns:
--      List of pgq.ret_queue_info records.
--     queue_name                  - queue name
--     queue_ntables               - number of tables in this queue
--     queue_cur_table             - ???
--     queue_rotation_period       - how often the event_N_M tables in this queue are rotated
--     queue_switch_time           - ??? when was this queue last rotated
--     queue_external_ticker       - ???
--     queue_ticker_paused         - ??? is ticker paused in this queue
--     queue_ticker_max_count      - max number of events before a tick is issued
--     queue_ticker_max_lag        - maks time without a tick
--     queue_ticker_idle_period    - how often the ticker should check this queue
--     ticker_lag                  - time from last tick
--     ev_per_sec                  - how many events per second this queue serves
--     ev_new                      - ???
--     last_tick_id                - last tick id for this queue
--
-- ----------------------------------------------------------------------
begin
    for queue_name, queue_ntables, queue_cur_table, queue_rotation_period,
        queue_switch_time, queue_external_ticker, queue_ticker_paused,
        queue_ticker_max_count, queue_ticker_max_lag, queue_ticker_idle_period,
        ticker_lag, ev_per_sec, ev_new, last_tick_id
    in select
        f.queue_name, f.queue_ntables, f.queue_cur_table, f.queue_rotation_period,
        f.queue_switch_time, f.queue_external_ticker, f.queue_ticker_paused,
        f.queue_ticker_max_count, f.queue_ticker_max_lag, f.queue_ticker_idle_period,
        f.ticker_lag, f.ev_per_sec, f.ev_new, f.last_tick_id
        from pgq.get_queue_info(null) f
    loop
        return next;
    end loop;
    return;
end;
$$;


ALTER FUNCTION pgq.get_queue_info(OUT queue_name text, OUT queue_ntables integer, OUT queue_cur_table integer, OUT queue_rotation_period interval, OUT queue_switch_time timestamp with time zone, OUT queue_external_ticker boolean, OUT queue_ticker_paused boolean, OUT queue_ticker_max_count integer, OUT queue_ticker_max_lag interval, OUT queue_ticker_idle_period interval, OUT ticker_lag interval, OUT ev_per_sec double precision, OUT ev_new bigint, OUT last_tick_id bigint) OWNER TO cdr;

--
-- TOC entry 359 (class 1255 OID 16790)
-- Name: get_queue_info(text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION get_queue_info(i_queue_name text, OUT queue_name text, OUT queue_ntables integer, OUT queue_cur_table integer, OUT queue_rotation_period interval, OUT queue_switch_time timestamp with time zone, OUT queue_external_ticker boolean, OUT queue_ticker_paused boolean, OUT queue_ticker_max_count integer, OUT queue_ticker_max_lag interval, OUT queue_ticker_idle_period interval, OUT ticker_lag interval, OUT ev_per_sec double precision, OUT ev_new bigint, OUT last_tick_id bigint) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.get_queue_info(1)
--
--      Get info about particular queue.
--
-- Returns:
--      One pgq.ret_queue_info record.
--      contente same as forpgq.get_queue_info() 
-- ----------------------------------------------------------------------
declare
    _ticker_lag interval;
    _top_tick_id bigint;
    _ht_tick_id bigint;
    _top_tick_time timestamptz;
    _top_tick_event_seq bigint;
    _ht_tick_time timestamptz;
    _ht_tick_event_seq bigint;
    _queue_id integer;
    _queue_event_seq text;
begin
    for queue_name, queue_ntables, queue_cur_table, queue_rotation_period,
        queue_switch_time, queue_external_ticker, queue_ticker_paused,
        queue_ticker_max_count, queue_ticker_max_lag, queue_ticker_idle_period,
        _queue_id, _queue_event_seq
    in select
        q.queue_name, q.queue_ntables, q.queue_cur_table,
        q.queue_rotation_period, q.queue_switch_time,
        q.queue_external_ticker, q.queue_ticker_paused,
        q.queue_ticker_max_count, q.queue_ticker_max_lag,
        q.queue_ticker_idle_period,
        q.queue_id, q.queue_event_seq
        from pgq.queue q
        where (i_queue_name is null or q.queue_name = i_queue_name)
        order by q.queue_name
    loop
        -- most recent tick
        select (current_timestamp - t.tick_time),
               tick_id, t.tick_time, t.tick_event_seq
            into ticker_lag, _top_tick_id, _top_tick_time, _top_tick_event_seq
            from pgq.tick t
            where t.tick_queue = _queue_id
            order by t.tick_queue desc, t.tick_id desc
            limit 1;
        -- slightly older tick
        select ht.tick_id, ht.tick_time, ht.tick_event_seq
            into _ht_tick_id, _ht_tick_time, _ht_tick_event_seq
            from pgq.tick ht
            where ht.tick_queue = _queue_id
             and ht.tick_id >= _top_tick_id - 20
            order by ht.tick_queue asc, ht.tick_id asc
            limit 1;
        if _ht_tick_time < _top_tick_time then
            ev_per_sec = (_top_tick_event_seq - _ht_tick_event_seq) / extract(epoch from (_top_tick_time - _ht_tick_time));
        else
            ev_per_sec = null;
        end if;
        ev_new = pgq.seq_getval(_queue_event_seq) - _top_tick_event_seq;
        last_tick_id = _top_tick_id;
        return next;
    end loop;
    return;
end;
$$;


ALTER FUNCTION pgq.get_queue_info(i_queue_name text, OUT queue_name text, OUT queue_ntables integer, OUT queue_cur_table integer, OUT queue_rotation_period interval, OUT queue_switch_time timestamp with time zone, OUT queue_external_ticker boolean, OUT queue_ticker_paused boolean, OUT queue_ticker_max_count integer, OUT queue_ticker_max_lag interval, OUT queue_ticker_idle_period interval, OUT ticker_lag interval, OUT ev_per_sec double precision, OUT ev_new bigint, OUT last_tick_id bigint) OWNER TO cdr;

--
-- TOC entry 330 (class 1255 OID 16761)
-- Name: grant_perms(text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION grant_perms(x_queue_name text) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.grant_perms(1)
--
--      Make event tables readable by public.
--
-- Parameters:
--      x_queue_name        - Name of the queue.
--
-- Returns:
--      nothing
-- ----------------------------------------------------------------------
declare
    q           record;
    i           integer;
    pos         integer;
    tbl_perms   text;
    seq_perms   text;
    dst_schema  text;
    dst_table   text;
    part_table  text;
begin
    select * from pgq.queue into q
        where queue_name = x_queue_name;
    if not found then
        raise exception 'Queue not found';
    end if;

    -- split data table name to components
    pos := position('.' in q.queue_data_pfx);
    if pos > 0 then
        dst_schema := substring(q.queue_data_pfx for pos - 1);
        dst_table := substring(q.queue_data_pfx from pos + 1);
    else
        dst_schema := 'public';
        dst_table := q.queue_data_pfx;
    end if;

    -- tick seq, normal users don't need to modify it
    execute 'grant select on ' || pgq.quote_fqname(q.queue_tick_seq) || ' to public';

    -- event seq
    execute 'grant select on ' || pgq.quote_fqname(q.queue_event_seq) || ' to public';
    
    -- set grants on parent table
    perform pgq._grant_perms_from('pgq', 'event_template', dst_schema, dst_table);

    -- set grants on real event tables
    for i in 0 .. q.queue_ntables - 1 loop
        part_table := dst_table  || '_' || i::text;
        perform pgq._grant_perms_from('pgq', 'event_template', dst_schema, part_table);
    end loop;

    return 1;
end;
$$;


ALTER FUNCTION pgq.grant_perms(x_queue_name text) OWNER TO cdr;

--
-- TOC entry 342 (class 1255 OID 16772)
-- Name: insert_event(text, text, text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION insert_event(queue_name text, ev_type text, ev_data text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.insert_event(3)
--
--      Insert a event into queue.
--
-- Parameters:
--      queue_name      - Name of the queue
--      ev_type         - User-specified type for the event
--      ev_data         - User data for the event
--
-- Returns:
--      Event ID
-- Calls:
--      pgq.insert_event(7)
-- ----------------------------------------------------------------------
begin
    return pgq.insert_event(queue_name, ev_type, ev_data, null, null, null, null);
end;
$$;


ALTER FUNCTION pgq.insert_event(queue_name text, ev_type text, ev_data text) OWNER TO cdr;

--
-- TOC entry 344 (class 1255 OID 16773)
-- Name: insert_event(text, text, text, text, text, text, text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION insert_event(queue_name text, ev_type text, ev_data text, ev_extra1 text, ev_extra2 text, ev_extra3 text, ev_extra4 text) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.insert_event(7)
--
--      Insert a event into queue with all the extra fields.
--
-- Parameters:
--      queue_name      - Name of the queue
--      ev_type         - User-specified type for the event
--      ev_data         - User data for the event
--      ev_extra1       - Extra data field for the event
--      ev_extra2       - Extra data field for the event
--      ev_extra3       - Extra data field for the event
--      ev_extra4       - Extra data field for the event
--
-- Returns:
--      Event ID
-- Calls:
--      pgq.insert_event_raw(11)
-- Tables directly manipulated:
--      insert - pgq.insert_event_raw(11), a C function, inserts into current event_N_M table
-- ----------------------------------------------------------------------
begin
    return pgq.insert_event_raw(queue_name, null, now(), null, null,
            ev_type, ev_data, ev_extra1, ev_extra2, ev_extra3, ev_extra4);
end;
$$;


ALTER FUNCTION pgq.insert_event(queue_name text, ev_type text, ev_data text, ev_extra1 text, ev_extra2 text, ev_extra3 text, ev_extra4 text) OWNER TO cdr;

--
-- TOC entry 327 (class 1255 OID 16752)
-- Name: insert_event_raw(text, bigint, timestamp with time zone, integer, integer, text, text, text, text, text, text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION insert_event_raw(queue_name text, ev_id bigint, ev_time timestamp with time zone, ev_owner integer, ev_retry integer, ev_type text, ev_data text, ev_extra1 text, ev_extra2 text, ev_extra3 text, ev_extra4 text) RETURNS bigint
    LANGUAGE c
    AS '$libdir/pgq_lowlevel', 'pgq_insert_event_raw';


ALTER FUNCTION pgq.insert_event_raw(queue_name text, ev_id bigint, ev_time timestamp with time zone, ev_owner integer, ev_retry integer, ev_type text, ev_data text, ev_extra1 text, ev_extra2 text, ev_extra3 text, ev_extra4 text) OWNER TO cdr;

--
-- TOC entry 366 (class 1255 OID 16797)
-- Name: logutriga(); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION logutriga() RETURNS trigger
    LANGUAGE c
    AS '$libdir/pgq_triggers', 'pgq_logutriga';


ALTER FUNCTION pgq.logutriga() OWNER TO cdr;

--
-- TOC entry 321 (class 1255 OID 16760)
-- Name: maint_operations(); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION maint_operations(OUT func_name text, OUT func_arg text) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.maint_operations(0)
--
--      Returns list of functions to call for maintenance.
--
--      The goal is to avoid hardcoding them into maintenance process.
--
-- Function signature:
--      Function should take either 1 or 0 arguments and return 1 if it wants
--      to be called immediately again, 0 if not.
--
-- Returns:
--      func_name   - Function to call
--      func_arg    - Optional argument to function (queue name)
-- ----------------------------------------------------------------------
declare
    ops text[];
    nrot int4;
begin
    -- rotate step 1
    nrot := 0;
    func_name := 'pgq.maint_rotate_tables_step1';
    for func_arg in
        select queue_name from pgq.queue
            where queue_rotation_period is not null
                and queue_switch_step2 is not null
                and queue_switch_time + queue_rotation_period < current_timestamp
            order by 1
    loop
        nrot := nrot + 1;
        return next;
    end loop;

    -- rotate step 2
    if nrot = 0 then
        select count(1) from pgq.queue
            where queue_rotation_period is not null
                and queue_switch_step2 is null
            into nrot;
    end if;
    if nrot > 0 then
        func_name := 'pgq.maint_rotate_tables_step2';
        func_arg := NULL;
        return next;
    end if;

    -- check if extra field exists
    perform 1 from pg_attribute
      where attrelid = 'pgq.queue'::regclass
        and attname = 'queue_extra_maint';
    if found then
        -- add extra ops
        for func_arg, ops in
            select q.queue_name, queue_extra_maint from pgq.queue q
             where queue_extra_maint is not null
             order by 1
        loop
            for i in array_lower(ops, 1) .. array_upper(ops, 1)
            loop
                func_name = ops[i];
                return next;
            end loop;
        end loop;
    end if;

    -- vacuum tables
    func_name := 'vacuum';
    for func_arg in
        select * from pgq.maint_tables_to_vacuum()
    loop
        return next;
    end loop;

    --
    -- pgq_node & londiste
    --
    -- although they belong to queue_extra_maint, they are
    -- common enough so its more effective to handle them here.
    --

    perform 1 from pg_proc p, pg_namespace n
      where p.pronamespace = n.oid
        and n.nspname = 'pgq_node'
        and p.proname = 'maint_watermark';
    if found then
        func_name := 'pgq_node.maint_watermark';
        for func_arg in
            select n.queue_name
              from pgq_node.node_info n
              where n.node_type = 'root'
        loop
            return next;
        end loop;

    end if;

    perform 1 from pg_proc p, pg_namespace n
      where p.pronamespace = n.oid
        and n.nspname = 'londiste'
        and p.proname = 'root_check_seqs';
    if found then
        func_name := 'londiste.root_check_seqs';
        for func_arg in
            select distinct s.queue_name
              from londiste.seq_info s, pgq_node.node_info n
              where s.local
                and n.node_type = 'root'
                and n.queue_name = s.queue_name
        loop
            return next;
        end loop;
    end if;

    perform 1 from pg_proc p, pg_namespace n
      where p.pronamespace = n.oid
        and n.nspname = 'londiste'
        and p.proname = 'periodic_maintenance';
    if found then
        func_name := 'londiste.periodic_maintenance';
        func_arg := NULL;
        return next;
    end if;

    return;
end;
$$;


ALTER FUNCTION pgq.maint_operations(OUT func_name text, OUT func_arg text) OWNER TO cdr;

--
-- TOC entry 317 (class 1255 OID 16756)
-- Name: maint_retry_events(); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION maint_retry_events() RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.maint_retry_events(0)
--
--      Moves retry events back to main queue.
--
--      It moves small amount at a time.  It should be called
--      until it returns 0
--
-- Returns:
--      Number of events processed.
-- ----------------------------------------------------------------------
declare
    cnt    integer;
    rec    record;
begin
    cnt := 0;

    -- allow only single event mover at a time, without affecting inserts
    lock table pgq.retry_queue in share update exclusive mode;

    for rec in
        select queue_name,
               ev_id, ev_time, ev_owner, ev_retry, ev_type, ev_data,
               ev_extra1, ev_extra2, ev_extra3, ev_extra4
          from pgq.retry_queue, pgq.queue
         where ev_retry_after <= current_timestamp
           and queue_id = ev_queue
         order by ev_retry_after
         limit 10
    loop
        cnt := cnt + 1;
        perform pgq.insert_event_raw(rec.queue_name,
                    rec.ev_id, rec.ev_time, rec.ev_owner, rec.ev_retry,
                    rec.ev_type, rec.ev_data, rec.ev_extra1, rec.ev_extra2,
                    rec.ev_extra3, rec.ev_extra4);
        delete from pgq.retry_queue
         where ev_owner = rec.ev_owner
           and ev_id = rec.ev_id;
    end loop;
    return cnt;
end;
$$;


ALTER FUNCTION pgq.maint_retry_events() OWNER TO cdr;

--
-- TOC entry 318 (class 1255 OID 16757)
-- Name: maint_rotate_tables_step1(text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION maint_rotate_tables_step1(i_queue_name text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.maint_rotate_tables_step1(1)
--
--      Rotate tables for one queue.
--
-- Parameters:
--      i_queue_name        - Name of the queue
--
-- Returns:
--      0
-- ----------------------------------------------------------------------
declare
    badcnt          integer;
    cf              record;
    nr              integer;
    tbl             text;
    lowest_tick_id  int8;
    lowest_xmin     int8;
begin
    -- check if needed and load record
    select * from pgq.queue into cf
        where queue_name = i_queue_name
          and queue_rotation_period is not null
          and queue_switch_step2 is not null
          and queue_switch_time + queue_rotation_period < current_timestamp
        for update;
    if not found then
        return 0;
    end if;

    -- if DB is in invalid state, stop
    if txid_current() < cf.queue_switch_step1 then
        raise exception 'queue % maint failure: step1=%, current=%',
                i_queue_name, cf.queue_switch_step1, txid_current();
    end if;

    -- find lowest tick for that queue
    select min(sub_last_tick) into lowest_tick_id
      from pgq.subscription
     where sub_queue = cf.queue_id;

    -- if some consumer exists
    if lowest_tick_id is not null then
        -- is the slowest one still on previous table?
        select txid_snapshot_xmin(tick_snapshot) into lowest_xmin
          from pgq.tick
         where tick_queue = cf.queue_id
           and tick_id = lowest_tick_id;
        if not found then
            raise exception 'queue % maint failure: tick % not found', i_queue_name, lowest_tick_id;
        end if;
        if lowest_xmin <= cf.queue_switch_step2 then
            return 0; -- skip rotation then
        end if;
    end if;

    -- nobody on previous table, we can rotate
    
    -- calc next table number and name
    nr := cf.queue_cur_table + 1;
    if nr = cf.queue_ntables then
        nr := 0;
    end if;
    tbl := cf.queue_data_pfx || '_' || nr::text;

    -- there may be long lock on the table from pg_dump,
    -- detect it and skip rotate then
    begin
        execute 'lock table ' || pgq.quote_fqname(tbl) || ' nowait';
        execute 'truncate ' || pgq.quote_fqname(tbl);
    exception
        when lock_not_available then
            -- cannot truncate, skipping rotate
            return 0;
    end;

    -- remember the moment
    update pgq.queue
        set queue_cur_table = nr,
            queue_switch_time = current_timestamp,
            queue_switch_step1 = txid_current(),
            queue_switch_step2 = NULL
        where queue_id = cf.queue_id;

    -- Clean ticks by using step2 txid from previous rotation.
    -- That should keep all ticks for all batches that are completely
    -- in old table.  This keeps them for longer than needed, but:
    -- 1. we want the pgq.tick table to be big, to avoid Postgres
    --    accitentally switching to seqscans on that.
    -- 2. that way we guarantee to consumers that they an be moved
    --    back on the queue at least for one rotation_period.
    --    (may help in disaster recovery)
    delete from pgq.tick
        where tick_queue = cf.queue_id
          and txid_snapshot_xmin(tick_snapshot) < cf.queue_switch_step2;

    return 0;
end;
$$;


ALTER FUNCTION pgq.maint_rotate_tables_step1(i_queue_name text) OWNER TO cdr;

--
-- TOC entry 319 (class 1255 OID 16758)
-- Name: maint_rotate_tables_step2(); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION maint_rotate_tables_step2() RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.maint_rotate_tables_step2(0)
--
--      Stores the txid when the rotation was visible.  It should be
--      called in separate transaction than pgq.maint_rotate_tables_step1()
-- ----------------------------------------------------------------------
begin
    update pgq.queue
       set queue_switch_step2 = txid_current()
     where queue_switch_step2 is null;
    return 0;
end;
$$;


ALTER FUNCTION pgq.maint_rotate_tables_step2() OWNER TO cdr;

--
-- TOC entry 320 (class 1255 OID 16759)
-- Name: maint_tables_to_vacuum(); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION maint_tables_to_vacuum() RETURNS SETOF text
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.maint_tables_to_vacuum(0)
--
--      Returns list of tablenames that need frequent vacuuming.
--
--      The goal is to avoid hardcoding them into maintenance process.
--
-- Returns:
--      List of table names.
-- ----------------------------------------------------------------------
declare
    scm text;
    tbl text;
    fqname text;
begin
    -- assume autovacuum handles them fine
    if current_setting('autovacuum') = 'on' then
        return;
    end if;

    for scm, tbl in values
        ('pgq', 'subscription'),
        ('pgq', 'consumer'),
        ('pgq', 'queue'),
        ('pgq', 'tick'),
        ('pgq', 'retry_queue'),
        ('pgq_ext', 'completed_tick'),
        ('pgq_ext', 'completed_batch'),
        ('pgq_ext', 'completed_event'),
        ('pgq_ext', 'partial_batch'),
        --('pgq_node', 'node_location'),
        --('pgq_node', 'node_info'),
        ('pgq_node', 'local_state'),
        --('pgq_node', 'subscriber_info'),
        --('londiste', 'table_info'),
        ('londiste', 'seq_info'),
        --('londiste', 'applied_execute'),
        --('londiste', 'pending_fkeys'),
        ('txid', 'epoch'),
        ('londiste', 'completed')
    loop
        select n.nspname || '.' || t.relname into fqname
            from pg_class t, pg_namespace n
            where n.oid = t.relnamespace
                and n.nspname = scm
                and t.relname = tbl;
        if found then
            return next fqname;
        end if;
    end loop;
    return;
end;
$$;


ALTER FUNCTION pgq.maint_tables_to_vacuum() OWNER TO cdr;

--
-- TOC entry 335 (class 1255 OID 16779)
-- Name: next_batch(text, text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION next_batch(i_queue_name text, i_consumer_name text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.next_batch(2)
--
--      Old function that returns just batch_id.
--
-- Parameters:
--      i_queue_name        - Name of the queue
--      i_consumer_name     - Name of the consumer
--
-- Returns:
--      Batch ID or NULL if there are no more events available.
-- ----------------------------------------------------------------------
declare
    res int8;
begin
    select batch_id into res
        from pgq.next_batch_info(i_queue_name, i_consumer_name);
    return res;
end;
$$;


ALTER FUNCTION pgq.next_batch(i_queue_name text, i_consumer_name text) OWNER TO cdr;

--
-- TOC entry 343 (class 1255 OID 16780)
-- Name: next_batch_custom(text, text, interval, integer, interval); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION next_batch_custom(i_queue_name text, i_consumer_name text, i_min_lag interval, i_min_count integer, i_min_interval interval, OUT batch_id bigint, OUT cur_tick_id bigint, OUT prev_tick_id bigint, OUT cur_tick_time timestamp with time zone, OUT prev_tick_time timestamp with time zone, OUT cur_tick_event_seq bigint, OUT prev_tick_event_seq bigint) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.next_batch_custom(5)
--
--      Makes next block of events active.  Block size can be tuned
--      with i_min_count, i_min_interval parameters.  Events age can
--      be tuned with i_min_lag.
--
--      If it returns NULL, there is no events available in queue.
--      Consumer should sleep then.
--
--      The values from event_id sequence may give hint how big the
--      batch may be.  But they are inexact, they do not give exact size.
--      Client *MUST NOT* use them to detect whether the batch contains any
--      events at all - the values are unfit for that purpose.
--
-- Note:
--      i_min_lag together with i_min_interval/i_min_count is inefficient.
--
-- Parameters:
--      i_queue_name        - Name of the queue
--      i_consumer_name     - Name of the consumer
--      i_min_lag           - Consumer wants events older than that
--      i_min_count         - Consumer wants batch to contain at least this many events
--      i_min_interval      - Consumer wants batch to cover at least this much time
--
-- Returns:
--      batch_id            - Batch ID or NULL if there are no more events available.
--      cur_tick_id         - End tick id.
--      cur_tick_time       - End tick time.
--      cur_tick_event_seq  - Value from event id sequence at the time tick was issued.
--      prev_tick_id        - Start tick id.
--      prev_tick_time      - Start tick time.
--      prev_tick_event_seq - value from event id sequence at the time tick was issued.
-- Calls:
--      pgq.insert_event_raw(11)
-- Tables directly manipulated:
--      update - pgq.subscription
-- ----------------------------------------------------------------------
declare
    errmsg          text;
    queue_id        integer;
    sub_id          integer;
    cons_id         integer;
begin
    select s.sub_queue, s.sub_consumer, s.sub_id, s.sub_batch,
            t1.tick_id, t1.tick_time, t1.tick_event_seq,
            t2.tick_id, t2.tick_time, t2.tick_event_seq
        into queue_id, cons_id, sub_id, batch_id,
             prev_tick_id, prev_tick_time, prev_tick_event_seq,
             cur_tick_id, cur_tick_time, cur_tick_event_seq
        from pgq.consumer c,
             pgq.queue q,
             pgq.subscription s
             left join pgq.tick t1
                on (t1.tick_queue = s.sub_queue
                    and t1.tick_id = s.sub_last_tick)
             left join pgq.tick t2
                on (t2.tick_queue = s.sub_queue
                    and t2.tick_id = s.sub_next_tick)
        where q.queue_name = i_queue_name
          and c.co_name = i_consumer_name
          and s.sub_queue = q.queue_id
          and s.sub_consumer = c.co_id;
    if not found then
        errmsg := 'Not subscriber to queue: '
            || coalesce(i_queue_name, 'NULL')
            || '/'
            || coalesce(i_consumer_name, 'NULL');
        raise exception '%', errmsg;
    end if;

    -- sanity check
    if prev_tick_id is null then
        raise exception 'PgQ corruption: Consumer % on queue % does not see tick %', i_consumer_name, i_queue_name, prev_tick_id;
    end if;

    -- has already active batch
    if batch_id is not null then
        return;
    end if;

    if i_min_interval is null and i_min_count is null then
        -- find next tick
        select tick_id, tick_time, tick_event_seq
            into cur_tick_id, cur_tick_time, cur_tick_event_seq
            from pgq.tick
            where tick_id > prev_tick_id
              and tick_queue = queue_id
            order by tick_queue asc, tick_id asc
            limit 1;
    else
        -- find custom tick
        select next_tick_id, next_tick_time, next_tick_seq
          into cur_tick_id, cur_tick_time, cur_tick_event_seq
          from pgq.find_tick_helper(queue_id, prev_tick_id,
                                    prev_tick_time, prev_tick_event_seq,
                                    i_min_count, i_min_interval);
    end if;

    if i_min_lag is not null then
        -- enforce min lag
        if now() - cur_tick_time < i_min_lag then
            cur_tick_id := NULL;
            cur_tick_time := NULL;
            cur_tick_event_seq := NULL;
        end if;
    end if;

    if cur_tick_id is null then
        -- nothing to do
        prev_tick_id := null;
        prev_tick_time := null;
        prev_tick_event_seq := null;
        return;
    end if;

    -- get next batch
    batch_id := nextval('pgq.batch_id_seq');
    update pgq.subscription
        set sub_batch = batch_id,
            sub_next_tick = cur_tick_id,
            sub_active = now()
        where sub_queue = queue_id
          and sub_consumer = cons_id;
    return;
end;
$$;


ALTER FUNCTION pgq.next_batch_custom(i_queue_name text, i_consumer_name text, i_min_lag interval, i_min_count integer, i_min_interval interval, OUT batch_id bigint, OUT cur_tick_id bigint, OUT prev_tick_id bigint, OUT cur_tick_time timestamp with time zone, OUT prev_tick_time timestamp with time zone, OUT cur_tick_event_seq bigint, OUT prev_tick_event_seq bigint) OWNER TO cdr;

--
-- TOC entry 349 (class 1255 OID 16778)
-- Name: next_batch_info(text, text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION next_batch_info(i_queue_name text, i_consumer_name text, OUT batch_id bigint, OUT cur_tick_id bigint, OUT prev_tick_id bigint, OUT cur_tick_time timestamp with time zone, OUT prev_tick_time timestamp with time zone, OUT cur_tick_event_seq bigint, OUT prev_tick_event_seq bigint) RETURNS record
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.next_batch_info(2)
--
--      Makes next block of events active.
--
--      If it returns NULL, there is no events available in queue.
--      Consumer should sleep then.
--
--      The values from event_id sequence may give hint how big the
--      batch may be.  But they are inexact, they do not give exact size.
--      Client *MUST NOT* use them to detect whether the batch contains any
--      events at all - the values are unfit for that purpose.
--
-- Parameters:
--      i_queue_name        - Name of the queue
--      i_consumer_name     - Name of the consumer
--
-- Returns:
--      batch_id            - Batch ID or NULL if there are no more events available.
--      cur_tick_id         - End tick id.
--      cur_tick_time       - End tick time.
--      cur_tick_event_seq  - Value from event id sequence at the time tick was issued.
--      prev_tick_id        - Start tick id.
--      prev_tick_time      - Start tick time.
--      prev_tick_event_seq - value from event id sequence at the time tick was issued.
-- Calls:
--      pgq.next_batch_custom(5)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    select f.batch_id, f.cur_tick_id, f.prev_tick_id,
           f.cur_tick_time, f.prev_tick_time,
           f.cur_tick_event_seq, f.prev_tick_event_seq
        into batch_id, cur_tick_id, prev_tick_id, cur_tick_time, prev_tick_time,
             cur_tick_event_seq, prev_tick_event_seq
        from pgq.next_batch_custom(i_queue_name, i_consumer_name, NULL, NULL, NULL) f;
    return;
end;
$$;


ALTER FUNCTION pgq.next_batch_info(i_queue_name text, i_consumer_name text, OUT batch_id bigint, OUT cur_tick_id bigint, OUT prev_tick_id bigint, OUT cur_tick_time timestamp with time zone, OUT prev_tick_time timestamp with time zone, OUT cur_tick_event_seq bigint, OUT prev_tick_event_seq bigint) OWNER TO cdr;

--
-- TOC entry 337 (class 1255 OID 16767)
-- Name: quote_fqname(text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION quote_fqname(i_name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.quote_fqname(1)
--
--      Quete fully-qualified object name for SQL.
--
--      First dot is taken as schema separator.
--
--      If schema is missing, 'public' is assumed.
--
-- Parameters:
--      i_name  - fully qualified object name.
--
-- Returns:
--      Quoted name.
-- ----------------------------------------------------------------------
declare
    res     text;
    pos     integer;
    s       text;
    n       text;
begin
    pos := position('.' in i_name);
    if pos > 0 then
        s := substring(i_name for pos - 1);
        n := substring(i_name from pos + 1);
    else
        s := 'public';
        n := i_name;
    end if;
    return quote_ident(s) || '.' || quote_ident(n);
end;
$$;


ALTER FUNCTION pgq.quote_fqname(i_name text) OWNER TO cdr;

--
-- TOC entry 346 (class 1255 OID 16775)
-- Name: register_consumer(text, text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION register_consumer(x_queue_name text, x_consumer_id text) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.register_consumer(2)
--
--      Subscribe consumer on a queue.
--
--      From this moment forward, consumer will see all events in the queue.
--
-- Parameters:
--      x_queue_name        - Name of queue
--      x_consumer_name     - Name of consumer
--
-- Returns:
--      0  - if already registered
--      1  - if new registration
-- Calls:
--      pgq.register_consumer_at(3)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq.register_consumer_at(x_queue_name, x_consumer_id, NULL);
end;
$$;


ALTER FUNCTION pgq.register_consumer(x_queue_name text, x_consumer_id text) OWNER TO cdr;

--
-- TOC entry 347 (class 1255 OID 16776)
-- Name: register_consumer_at(text, text, bigint); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION register_consumer_at(x_queue_name text, x_consumer_name text, x_tick_pos bigint) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.register_consumer_at(3)
--
--      Extended registration, allows to specify tick_id.
--
-- Note:
--      For usage in special situations.
--
-- Parameters:
--      x_queue_name        - Name of a queue
--      x_consumer_name     - Name of consumer
--      x_tick_pos          - Tick ID
--
-- Returns:
--      0/1 whether consumer has already registered.
-- Calls:
--      None
-- Tables directly manipulated:
--      update/insert - pgq.subscription
-- ----------------------------------------------------------------------
declare
    tmp         text;
    last_tick   bigint;
    x_queue_id          integer;
    x_consumer_id integer;
    queue integer;
    sub record;
begin
    select queue_id into x_queue_id from pgq.queue
        where queue_name = x_queue_name;
    if not found then
        raise exception 'Event queue not created yet';
    end if;

    -- get consumer and create if new
    select co_id into x_consumer_id from pgq.consumer
        where co_name = x_consumer_name;
    if not found then
        insert into pgq.consumer (co_name) values (x_consumer_name);
        x_consumer_id := currval('pgq.consumer_co_id_seq');
    end if;

    -- if particular tick was requested, check if it exists
    if x_tick_pos is not null then
        perform 1 from pgq.tick
            where tick_queue = x_queue_id
              and tick_id = x_tick_pos;
        if not found then
            raise exception 'cannot reposition, tick not found: %', x_tick_pos;
        end if;
    end if;

    -- check if already registered
    select sub_last_tick, sub_batch into sub
        from pgq.subscription
        where sub_consumer = x_consumer_id
          and sub_queue  = x_queue_id;
    if found then
        if x_tick_pos is not null then
            -- if requested, update tick pos and drop partial batch
            update pgq.subscription
                set sub_last_tick = x_tick_pos,
                    sub_batch = null,
                    sub_next_tick = null,
                    sub_active = now()
                where sub_consumer = x_consumer_id
                  and sub_queue = x_queue_id;
        end if;
        -- already registered
        return 0;
    end if;

    --  new registration
    if x_tick_pos is null then
        -- start from current tick
        select tick_id into last_tick from pgq.tick
            where tick_queue = x_queue_id
            order by tick_queue desc, tick_id desc
            limit 1;
        if not found then
            raise exception 'No ticks for this queue.  Please run ticker on database.';
        end if;
    else
        last_tick := x_tick_pos;
    end if;

    -- register
    insert into pgq.subscription (sub_queue, sub_consumer, sub_last_tick)
        values (x_queue_id, x_consumer_id, last_tick);
    return 1;
end;
$$;


ALTER FUNCTION pgq.register_consumer_at(x_queue_name text, x_consumer_name text, x_tick_pos bigint) OWNER TO cdr;

--
-- TOC entry 334 (class 1255 OID 16765)
-- Name: seq_getval(text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION seq_getval(i_seq_name text) RETURNS bigint
    LANGUAGE plpgsql STRICT
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.seq_getval(1)
--
--      Read current last_val from seq, without affecting it.
--
-- Parameters:
--      i_seq_name     - Name of the sequence
--
-- Returns:
--      last value.
-- ----------------------------------------------------------------------
declare
    res     int8;
    fqname  text;
    pos     integer;
    s       text;
    n       text;
begin
    pos := position('.' in i_seq_name);
    if pos > 0 then
        s := substring(i_seq_name for pos - 1);
        n := substring(i_seq_name from pos + 1);
    else
        s := 'public';
        n := i_seq_name;
    end if;
    fqname := quote_ident(s) || '.' || quote_ident(n);

    execute 'select last_value from ' || fqname into res;
    return res;
end;
$$;


ALTER FUNCTION pgq.seq_getval(i_seq_name text) OWNER TO cdr;

--
-- TOC entry 336 (class 1255 OID 16766)
-- Name: seq_setval(text, bigint); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION seq_setval(i_seq_name text, i_new_value bigint) RETURNS bigint
    LANGUAGE plpgsql STRICT
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.seq_setval(2)
--
--      Like setval() but does not allow going back.
--
-- Parameters:
--      i_seq_name      - Name of the sequence
--      i_new_value     - new value
--
-- Returns:
--      current last value.
-- ----------------------------------------------------------------------
declare
    res     int8;
    fqname  text;
begin
    fqname := pgq.quote_fqname(i_seq_name);

    res := pgq.seq_getval(i_seq_name);
    if res < i_new_value then
        perform setval(fqname, i_new_value);
        return i_new_value;
    end if;
    return res;
end;
$$;


ALTER FUNCTION pgq.seq_setval(i_seq_name text, i_new_value bigint) OWNER TO cdr;

--
-- TOC entry 341 (class 1255 OID 16771)
-- Name: set_queue_config(text, text, text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION set_queue_config(x_queue_name text, x_param_name text, x_param_value text) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.set_queue_config(3)
--
--
--     Set configuration for specified queue.
--
-- Parameters:
--      x_queue_name    - Name of the queue to configure.
--      x_param_name    - Configuration parameter name.
--      x_param_value   - Configuration parameter value.
--  
-- Returns:
--     0 if event was already in queue, 1 otherwise.
-- Calls:
--      None
-- Tables directly manipulated:
--      update - pgq.queue
-- ----------------------------------------------------------------------
declare
    v_param_name    text;
begin
    -- discard NULL input
    if x_queue_name is null or x_param_name is null then
        raise exception 'Invalid NULL value';
    end if;

    -- check if queue exists
    perform 1 from pgq.queue where queue_name = x_queue_name;
    if not found then
        raise exception 'No such event queue';
    end if;

    -- check if valid parameter name
    v_param_name := 'queue_' || x_param_name;
    if v_param_name not in (
        'queue_ticker_max_count',
        'queue_ticker_max_lag',
        'queue_ticker_idle_period',
        'queue_ticker_paused',
        'queue_rotation_period',
        'queue_external_ticker')
    then
        raise exception 'cannot change parameter "%s"', x_param_name;
    end if;

    execute 'update pgq.queue set ' 
        || v_param_name || ' = ' || quote_literal(x_param_value)
        || ' where queue_name = ' || quote_literal(x_queue_name);

    return 1;
end;
$$;


ALTER FUNCTION pgq.set_queue_config(x_queue_name text, x_param_name text, x_param_value text) OWNER TO cdr;

--
-- TOC entry 365 (class 1255 OID 16796)
-- Name: sqltriga(); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION sqltriga() RETURNS trigger
    LANGUAGE c
    AS '$libdir/pgq_triggers', 'pgq_sqltriga';


ALTER FUNCTION pgq.sqltriga() OWNER TO cdr;

--
-- TOC entry 316 (class 1255 OID 16755)
-- Name: ticker(); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION ticker() RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.ticker(0)
--
--     Creates ticks for all unpaused queues which dont have external ticker.
--
-- Returns:
--     Number of queues that were processed.
-- ----------------------------------------------------------------------
declare
    res bigint;
    q record;
begin
    res := 0;
    for q in
        select queue_name from pgq.queue
            where not queue_external_ticker
                  and not queue_ticker_paused
            order by queue_name
    loop
        if pgq.ticker(q.queue_name) > 0 then
            res := res + 1;
        end if;
    end loop;
    return res;
end;
$$;


ALTER FUNCTION pgq.ticker() OWNER TO cdr;

--
-- TOC entry 329 (class 1255 OID 16754)
-- Name: ticker(text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION ticker(i_queue_name text) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.ticker(1)
--
--     Check if tick is needed for the queue and insert it.
--
--     For pgqadm usage.
--
-- Parameters:
--     i_queue_name     - Name of the queue
--
-- Returns:
--     Tick id or NULL if no tick was done.
-- ----------------------------------------------------------------------
declare
    res bigint;
    q record;
    state record;
    last2 record;
begin
    select queue_id, queue_tick_seq, queue_external_ticker,
            queue_ticker_max_count, queue_ticker_max_lag,
            queue_ticker_idle_period, queue_event_seq,
            pgq.seq_getval(queue_event_seq) as event_seq,
            queue_ticker_paused
        into q
        from pgq.queue where queue_name = i_queue_name;
    if not found then
        raise exception 'no such queue';
    end if;

    if q.queue_external_ticker then
        raise exception 'This queue has external tick source.';
    end if;

    if q.queue_ticker_paused then
        raise exception 'Ticker has been paused for this queue';
    end if;

    -- load state from last tick
    select now() - tick_time as lag,
           q.event_seq - tick_event_seq as new_events,
           tick_id, tick_time, tick_event_seq,
           txid_snapshot_xmax(tick_snapshot) as sxmax,
           txid_snapshot_xmin(tick_snapshot) as sxmin
        into state
        from pgq.tick
        where tick_queue = q.queue_id
        order by tick_queue desc, tick_id desc
        limit 1;

    if found then
        if state.sxmin > txid_current() then
            raise exception 'Invalid PgQ state: old xmin=%, old xmax=%, cur txid=%',
                            state.sxmin, state.sxmax, txid_current();
        end if;
        if state.new_events < 0 then
            raise warning 'Negative new_events?  old=% cur=%', state.tick_event_seq, q.event_seq;
        end if;
        if state.sxmax > txid_current() then
            raise warning 'Dubious PgQ state: old xmax=%, cur txid=%', state.sxmax, txid_current();
        end if;

        if state.new_events > 0 then
            -- there are new events, should we wait a bit?
            if state.new_events < q.queue_ticker_max_count
                and state.lag < q.queue_ticker_max_lag
            then
                return NULL;
            end if;
        else
            -- no new events, should we apply idle period?
            -- check previous event from the last one.
            select state.tick_time - tick_time as lag
                into last2
                from pgq.tick
                where tick_queue = q.queue_id
                    and tick_id < state.tick_id
                order by tick_queue desc, tick_id desc
                limit 1;
            if found then
                -- gradually decrease the tick frequency
                if (state.lag < q.queue_ticker_max_lag / 2)
                    or
                   (state.lag < last2.lag * 2
                    and state.lag < q.queue_ticker_idle_period)
                then
                    return NULL;
                end if;
            end if;
        end if;
    end if;

    insert into pgq.tick (tick_queue, tick_id, tick_event_seq)
        values (q.queue_id, nextval(q.queue_tick_seq), q.event_seq);

    return currval(q.queue_tick_seq);
end;
$$;


ALTER FUNCTION pgq.ticker(i_queue_name text) OWNER TO cdr;

--
-- TOC entry 328 (class 1255 OID 16753)
-- Name: ticker(text, bigint, timestamp with time zone, bigint); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION ticker(i_queue_name text, i_tick_id bigint, i_orig_timestamp timestamp with time zone, i_event_seq bigint) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.ticker(3)
--
--     External ticker: Insert a tick with a particular tick_id and timestamp.
--
-- Parameters:
--     i_queue_name     - Name of the queue
--     i_tick_id        - Id of new tick.
--
-- Returns:
--     Tick id.
-- ----------------------------------------------------------------------
begin
    insert into pgq.tick (tick_queue, tick_id, tick_time, tick_event_seq)
    select queue_id, i_tick_id, i_orig_timestamp, i_event_seq
        from pgq.queue
        where queue_name = i_queue_name
          and queue_external_ticker
          and not queue_ticker_paused;
    if not found then
        raise exception 'queue not found or ticker disabled: %', i_queue_name;
    end if;

    -- make sure seqs stay current
    perform pgq.seq_setval(queue_tick_seq, i_tick_id),
            pgq.seq_setval(queue_event_seq, i_event_seq)
        from pgq.queue
        where queue_name = i_queue_name;

    return i_tick_id;
end;
$$;


ALTER FUNCTION pgq.ticker(i_queue_name text, i_tick_id bigint, i_orig_timestamp timestamp with time zone, i_event_seq bigint) OWNER TO cdr;

--
-- TOC entry 332 (class 1255 OID 16763)
-- Name: tune_storage(text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION tune_storage(i_queue_name text) RETURNS integer
    LANGUAGE plpgsql STRICT
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.tune_storage(1)
--
--      Tunes storage settings for queue data tables
-- ----------------------------------------------------------------------
declare
    tbl  text;
    tbloid oid;
    q record;
    i int4;
    sql text;
    pgver int4;
begin
    pgver := current_setting('server_version_num');

    select * into q
      from pgq.queue where queue_name = i_queue_name;
    if not found then
        return 0;
    end if;

    for i in 0 .. (q.queue_ntables - 1) loop
        tbl := q.queue_data_pfx || '_' || i::text;

        -- set fillfactor
        sql := 'alter table ' || tbl || ' set (fillfactor = 100';

        -- autovacuum for 8.4+
        if pgver >= 80400 then
            sql := sql || ', autovacuum_enabled=off, toast.autovacuum_enabled =off';
        end if;
        sql := sql || ')';
        execute sql;

        -- autovacuum for 8.3
        if pgver < 80400 then
            tbloid := tbl::regclass::oid;
            delete from pg_catalog.pg_autovacuum where vacrelid = tbloid;
            insert into pg_catalog.pg_autovacuum values (tbloid, false, -1,-1,-1,-1,-1,-1,-1,-1);
        end if;
    end loop;

    return 1;
end;
$$;


ALTER FUNCTION pgq.tune_storage(i_queue_name text) OWNER TO cdr;

--
-- TOC entry 348 (class 1255 OID 16777)
-- Name: unregister_consumer(text, text); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION unregister_consumer(x_queue_name text, x_consumer_name text) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.unregister_consumer(2)
--
--      Unsubscriber consumer from the queue.  Also consumer's
--      retry events are deleted.
--
-- Parameters:
--      x_queue_name        - Name of the queue
--      x_consumer_name     - Name of the consumer
--
-- Returns:
--      number of (sub)consumers unregistered
-- Calls:
--      None
-- Tables directly manipulated:
--      delete - pgq.retry_queue
--      delete - pgq.subscription
-- ----------------------------------------------------------------------
declare
    x_sub_id integer;
    _sub_id_cnt integer;
    _consumer_id integer;
    _is_subconsumer boolean;
begin
    select s.sub_id, c.co_id,
           -- subconsumers can only have both null or both not null - main consumer for subconsumers has only one not null
           (s.sub_last_tick IS NULL AND s.sub_next_tick IS NULL) OR (s.sub_last_tick IS NOT NULL AND s.sub_next_tick IS NOT NULL)
      into x_sub_id, _consumer_id, _is_subconsumer
      from pgq.subscription s, pgq.consumer c, pgq.queue q
     where s.sub_queue = q.queue_id
       and s.sub_consumer = c.co_id
       and q.queue_name = x_queue_name
       and c.co_name = x_consumer_name
       for update of s;
    if not found then
        return 0;
    end if;

    -- consumer + subconsumer count
    select count(*) into _sub_id_cnt
        from pgq.subscription
       where sub_id = x_sub_id;

    -- delete only one subconsumer
    if _sub_id_cnt > 1 and _is_subconsumer then
        delete from pgq.subscription
              where sub_id = x_sub_id
                and sub_consumer = _consumer_id;

        return 1;
    else
        -- delete main consumer (including possible subconsumers)

        -- retry events
        delete from pgq.retry_queue
            where ev_owner = x_sub_id;

        -- this will drop subconsumers too
        delete from pgq.subscription
            where sub_id = x_sub_id;
    
        return _sub_id_cnt;
    end if;

end;
$$;


ALTER FUNCTION pgq.unregister_consumer(x_queue_name text, x_consumer_name text) OWNER TO cdr;

--
-- TOC entry 322 (class 1255 OID 16743)
-- Name: upgrade_schema(); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION upgrade_schema() RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- updates table structure if necessary
declare
    cnt int4 = 0;
begin

    -- pgq.subscription.sub_last_tick: NOT NULL -> NULL
    perform 1 from information_schema.columns
      where table_schema = 'pgq'
        and table_name = 'subscription'
        and column_name ='sub_last_tick'
        and is_nullable = 'NO';
    if found then
        alter table pgq.subscription
            alter column sub_last_tick
            drop not null;
        cnt := cnt + 1;
    end if;

    -- create roles
    perform 1 from pg_catalog.pg_roles where rolname = 'pgq_reader';
    if not found then
        create role pgq_reader;
        cnt := cnt + 1;
    end if;
    perform 1 from pg_catalog.pg_roles where rolname = 'pgq_writer';
    if not found then
        create role pgq_writer;
        cnt := cnt + 1;
    end if;
    perform 1 from pg_catalog.pg_roles where rolname = 'pgq_admin';
    if not found then
        create role pgq_admin in role pgq_reader, pgq_writer;
        cnt := cnt + 1;
    end if;

    return cnt;
end;
$$;


ALTER FUNCTION pgq.upgrade_schema() OWNER TO cdr;

--
-- TOC entry 363 (class 1255 OID 16794)
-- Name: version(); Type: FUNCTION; Schema: pgq; Owner: cdr
--

CREATE FUNCTION version() RETURNS text
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq.version(0)
--
--      Returns version string for pgq.  ATM it is based on SkyTools version
--      and only bumped when database code changes.
-- ----------------------------------------------------------------------
begin
    return '3.1.3';
end;
$$;


ALTER FUNCTION pgq.version() OWNER TO cdr;

SET search_path = pgq_coop, pg_catalog;

--
-- TOC entry 411 (class 1255 OID 16954)
-- Name: finish_batch(bigint); Type: FUNCTION; Schema: pgq_coop; Owner: cdr
--

CREATE FUNCTION finish_batch(i_batch_id bigint) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.finish_batch(1)
--
--	Closes a batch.
--
-- Parameters:
--	i_batch_id	- id of the batch to be closed
--
-- Returns:
--	1 if success (batch was found), 0 otherwise
-- Calls:
--      None
-- Tables directly manipulated:
--      update - pgq.subscription
-- ----------------------------------------------------------------------
begin
    -- we are dealing with subconsumer, so nullify all tick info
    -- tick columns for master consumer contain adequate data
    update pgq.subscription
       set sub_active = now(),
           sub_last_tick = null,
           sub_next_tick = null,
           sub_batch = null
     where sub_batch = i_batch_id;
    if not found then
        raise warning 'coop_finish_batch: batch % not found', i_batch_id;
        return 0;
    else
        return 1;
    end if;
end;
$$;


ALTER FUNCTION pgq_coop.finish_batch(i_batch_id bigint) OWNER TO cdr;

--
-- TOC entry 406 (class 1255 OID 16950)
-- Name: next_batch(text, text, text); Type: FUNCTION; Schema: pgq_coop; Owner: cdr
--

CREATE FUNCTION next_batch(i_queue_name text, i_consumer_name text, i_subconsumer_name text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.next_batch(3)
--
--	Makes next block of events active
--
--	Result NULL means nothing to work with, for a moment
--
-- Parameters:
--	i_queue_name		- Name of the queue
--	i_consumer_name		- Name of the consumer
--	i_subconsumer_name	- Name of the subconsumer
--
-- Calls:
--      pgq.register_consumer(i_queue_name, i_consumer_name)
--      pgq.register_consumer(i_queue_name, _subcon_name);
--
-- Tables directly manipulated:
--      update - pgq.subscription
-- 
-- ----------------------------------------------------------------------
begin
    return pgq_coop.next_batch_custom(i_queue_name, i_consumer_name, i_subconsumer_name, NULL, NULL, NULL, NULL);
end;
$$;


ALTER FUNCTION pgq_coop.next_batch(i_queue_name text, i_consumer_name text, i_subconsumer_name text) OWNER TO cdr;

--
-- TOC entry 407 (class 1255 OID 16951)
-- Name: next_batch(text, text, text, interval); Type: FUNCTION; Schema: pgq_coop; Owner: cdr
--

CREATE FUNCTION next_batch(i_queue_name text, i_consumer_name text, i_subconsumer_name text, i_dead_interval interval) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.next_batch(4)
--
--	Makes next block of events active
--
--      If i_dead_interval is set, other subconsumers are checked for
--      inactivity.  If some subconsumer has active batch, but has
--      been inactive more than i_dead_interval, the batch is taken over.
--
--	Result NULL means nothing to work with, for a moment
--
-- Parameters:
--	i_queue_name		- Name of the queue
--	i_consumer_name		- Name of the consumer
--	i_subconsumer_name	- Name of the subconsumer
--      i_dead_interval         - Take over other subconsumer batch if inactive
-- ----------------------------------------------------------------------
begin
    return pgq_coop.next_batch_custom(i_queue_name, i_consumer_name, i_subconsumer_name, NULL, NULL, NULL, i_dead_interval);
end;
$$;


ALTER FUNCTION pgq_coop.next_batch(i_queue_name text, i_consumer_name text, i_subconsumer_name text, i_dead_interval interval) OWNER TO cdr;

--
-- TOC entry 408 (class 1255 OID 16952)
-- Name: next_batch_custom(text, text, text, interval, integer, interval); Type: FUNCTION; Schema: pgq_coop; Owner: cdr
--

CREATE FUNCTION next_batch_custom(i_queue_name text, i_consumer_name text, i_subconsumer_name text, i_min_lag interval, i_min_count integer, i_min_interval interval) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.next_batch_custom(6)
--
--      Makes next block of events active.  Block size can be tuned
--      with i_min_count, i_min_interval parameters.  Events age can
--      be tuned with i_min_lag.
--
--	Result NULL means nothing to work with, for a moment
--
-- Parameters:
--	i_queue_name		- Name of the queue
--	i_consumer_name		- Name of the consumer
--	i_subconsumer_name	- Name of the subconsumer
--      i_min_lag           - Consumer wants events older than that
--      i_min_count         - Consumer wants batch to contain at least this many events
--      i_min_interval      - Consumer wants batch to cover at least this much time
-- ----------------------------------------------------------------------
begin
    return pgq_coop.next_batch_custom(i_queue_name, i_consumer_name, i_subconsumer_name,
                                      i_min_lag, i_min_count, i_min_interval, NULL);
end;
$$;


ALTER FUNCTION pgq_coop.next_batch_custom(i_queue_name text, i_consumer_name text, i_subconsumer_name text, i_min_lag interval, i_min_count integer, i_min_interval interval) OWNER TO cdr;

--
-- TOC entry 410 (class 1255 OID 16953)
-- Name: next_batch_custom(text, text, text, interval, integer, interval, interval); Type: FUNCTION; Schema: pgq_coop; Owner: cdr
--

CREATE FUNCTION next_batch_custom(i_queue_name text, i_consumer_name text, i_subconsumer_name text, i_min_lag interval, i_min_count integer, i_min_interval interval, i_dead_interval interval) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.next_batch_custom(7)
--
--      Makes next block of events active.  Block size can be tuned
--      with i_min_count, i_min_interval parameters.  Events age can
--      be tuned with i_min_lag.
--
--      If i_dead_interval is set, other subconsumers are checked for
--      inactivity.  If some subconsumer has active batch, but has
--      been inactive more than i_dead_interval, the batch is taken over.
--
--	Result NULL means nothing to work with, for a moment
--
-- Parameters:
--      i_queue_name        - Name of the queue
--      i_consumer_name     - Name of the consumer
--      i_subconsumer_name  - Name of the subconsumer
--      i_min_lag           - Consumer wants events older than that
--      i_min_count         - Consumer wants batch to contain at least this many events
--      i_min_interval      - Consumer wants batch to cover at least this much time
--      i_dead_interval     - Take over other subconsumer batch if inactive
-- Calls:
--      pgq.register_subconsumer(i_queue_name, i_consumer_name, i_subconsumer_name)
--      pgq.next_batch_custom(i_queue_name, i_consumer_name, i_min_lag, i_min_count, i_min_interval)
-- Tables directly manipulated:
--      update - pgq.subscription
-- ----------------------------------------------------------------------
declare
    _queue_id integer;
    _consumer_id integer;
    _subcon_id integer;
    _batch_id bigint;
    _prev_tick bigint;
    _cur_tick bigint;
    _sub_id integer;
    _dead record;
begin
    -- fetch master consumer details, lock the row
    select q.queue_id, c.co_id, s.sub_next_tick
        into _queue_id, _consumer_id, _cur_tick
        from pgq.queue q, pgq.consumer c, pgq.subscription s
        where q.queue_name = i_queue_name
          and c.co_name = i_consumer_name
          and s.sub_queue = q.queue_id
          and s.sub_consumer = c.co_id
        for update of s;
    if not found then
        perform pgq_coop.register_subconsumer(i_queue_name, i_consumer_name, i_subconsumer_name);
        -- fetch the data again
        select q.queue_id, c.co_id, s.sub_next_tick
            into _queue_id, _consumer_id, _cur_tick
            from pgq.queue q, pgq.consumer c, pgq.subscription s
            where q.queue_name = i_queue_name
              and c.co_name = i_consumer_name
              and s.sub_queue = q.queue_id
              and s.sub_consumer = c.co_id;
    end if;
    if _cur_tick is not null then
        raise exception 'main consumer has batch open?';
    end if;

    -- automatically register subconsumers
    perform 1 from pgq.subscription s, pgq.consumer c, pgq.queue q
        where q.queue_name = i_queue_name
          and s.sub_queue = q.queue_id
          and s.sub_consumer = c.co_id
          and c.co_name = i_consumer_name || '.' || i_subconsumer_name;
    if not found then
        perform pgq_coop.register_subconsumer(i_queue_name, i_consumer_name, i_subconsumer_name);
    end if;

    -- fetch subconsumer details
    select s.sub_batch, sc.co_id, s.sub_id
        into _batch_id, _subcon_id, _sub_id
        from pgq.subscription s, pgq.consumer sc
        where sub_queue = _queue_id
          and sub_consumer = sc.co_id
          and sc.co_name = i_consumer_name || '.' || i_subconsumer_name;
    if not found then
        raise exception 'subconsumer not found';
    end if;

    -- is there a batch already active
    if _batch_id is not null then
        update pgq.subscription set sub_active = now()
            where sub_queue = _queue_id
              and sub_consumer = _subcon_id;
        return _batch_id;
    end if;

    -- help dead comrade
    if i_dead_interval is not null then

        -- check if some other subconsumer has died
        select s.sub_batch, s.sub_consumer, s.sub_last_tick, s.sub_next_tick
            into _dead
            from pgq.subscription s
            where s.sub_queue = _queue_id
              and s.sub_id = _sub_id
              and s.sub_consumer <> _subcon_id
              and s.sub_consumer <> _consumer_id
              and sub_active < now() - i_dead_interval
            limit 1;

        if found then
            -- unregister old consumer
            delete from pgq.subscription
                where sub_queue = _queue_id
                  and sub_consumer = _dead.sub_consumer;

            -- if dead consumer had batch, copy it over and return
            if _dead.sub_batch is not null then
                update pgq.subscription
                    set sub_batch = _dead.sub_batch,
                        sub_last_tick = _dead.sub_last_tick,
                        sub_next_tick = _dead.sub_next_tick,
                        sub_active = now()
                    where sub_queue = _queue_id
                      and sub_consumer = _subcon_id;

                return _dead.sub_batch;
            end if;
        end if;
    end if;

    -- get a new batch for the main consumer
    select batch_id, cur_tick_id, prev_tick_id
        into _batch_id, _cur_tick, _prev_tick
        from pgq.next_batch_custom(i_queue_name, i_consumer_name, i_min_lag, i_min_count, i_min_interval);
    if _batch_id is null then
        return null;
    end if;

    -- close batch for main consumer
    update pgq.subscription
       set sub_batch = null,
           sub_active = now(),
           sub_last_tick = sub_next_tick,
           sub_next_tick = null
     where sub_queue = _queue_id
       and sub_consumer = _consumer_id;

    -- copy state into subconsumer row
    update pgq.subscription
        set sub_batch = _batch_id,
            sub_last_tick = _prev_tick,
            sub_next_tick = _cur_tick,
            sub_active = now()
        where sub_queue = _queue_id
          and sub_consumer = _subcon_id;

    return _batch_id;
end;
$$;


ALTER FUNCTION pgq_coop.next_batch_custom(i_queue_name text, i_consumer_name text, i_subconsumer_name text, i_min_lag interval, i_min_count integer, i_min_interval interval, i_dead_interval interval) OWNER TO cdr;

--
-- TOC entry 404 (class 1255 OID 16948)
-- Name: register_subconsumer(text, text, text); Type: FUNCTION; Schema: pgq_coop; Owner: cdr
--

CREATE FUNCTION register_subconsumer(i_queue_name text, i_consumer_name text, i_subconsumer_name text) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.register_subconsumer(3)
--
--	    Subscribe a subconsumer on a queue.
--
--      Subconsumer will be registered as another consumer on queue,
--      whose name will be i_consumer_name and i_subconsumer_name
--      combined.
--
-- Returns:
--	    0 - if already registered
--	    1 - if this is a new registration
--
-- Calls:
--      pgq.register_consumer(i_queue_name, i_consumer_name)
--      pgq.register_consumer(i_queue_name, _subcon_name);
--
-- Tables directly manipulated:
--      update - pgq.subscription
-- 
-- ----------------------------------------------------------------------
declare
    _subcon_name text; -- consumer + subconsumer
    _queue_id integer;
    _consumer_id integer;
    _subcon_id integer;
    _consumer_sub_id integer;
    _subcon_result integer;
    r record;
begin
    _subcon_name := i_consumer_name || '.' || i_subconsumer_name;

    -- make sure main consumer exists
    perform pgq.register_consumer(i_queue_name, i_consumer_name);

    -- just go and register the subconsumer as a regular consumer
    _subcon_result := pgq.register_consumer(i_queue_name, _subcon_name);

    -- if it is a new registration
    if _subcon_result = 1 then
        select q.queue_id, mainc.co_id as main_consumer_id,
               s.sub_id as main_consumer_sub_id,
               subc.co_id as sub_consumer_id
            into r
            from pgq.queue q, pgq.subscription s, pgq.consumer mainc, pgq.consumer subc
            where mainc.co_name = i_consumer_name
              and subc.co_name = _subcon_name
              and q.queue_name = i_queue_name
              and s.sub_queue = q.queue_id
              and s.sub_consumer = mainc.co_id;
        if not found then
            raise exception 'main consumer not found';
        end if;

        -- duplicate the sub_id of consumer to the subconsumer
        update pgq.subscription s
            set sub_id = r.main_consumer_sub_id,
                sub_last_tick = null,
                sub_next_tick = null
            where sub_queue = r.queue_id
              and sub_consumer = r.sub_consumer_id;
    end if;

    return _subcon_result;
end;
$$;


ALTER FUNCTION pgq_coop.register_subconsumer(i_queue_name text, i_consumer_name text, i_subconsumer_name text) OWNER TO cdr;

--
-- TOC entry 405 (class 1255 OID 16949)
-- Name: unregister_subconsumer(text, text, text, integer); Type: FUNCTION; Schema: pgq_coop; Owner: cdr
--

CREATE FUNCTION unregister_subconsumer(i_queue_name text, i_consumer_name text, i_subconsumer_name text, i_batch_handling integer) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.unregister_subconsumer(4)
--
--      Unregisters subconsumer from the queue.
--
--      If consumer has active batch, then behviour depends on
--      i_batch_handling parameter.
--
-- Values for i_batch_handling:
--      0 - Fail with an exception.
--      1 - Close the batch, ignoring the events.
--
-- Returns:
--	    0 - no consumer found
--      1 - consumer found and unregistered
--
-- Tables directly manipulated:
--      delete - pgq.subscription
--
-- ----------------------------------------------------------------------
declare
    _current_batch bigint;
    _queue_id integer;
    _subcon_id integer;
begin
    select q.queue_id, c.co_id, sub_batch
        into _queue_id, _subcon_id, _current_batch
        from pgq.queue q, pgq.consumer c, pgq.subscription s
        where c.co_name = i_consumer_name || '.' || i_subconsumer_name
          and q.queue_name = i_queue_name
          and s.sub_queue = q.queue_id
          and s.sub_consumer = c.co_id;
    if not found then
        return 0;
    end if;

    if _current_batch is not null then
        if i_batch_handling = 1 then
            -- ignore active batch
        else
            raise exception 'subconsumer has active batch';
        end if;
    end if;

    delete from pgq.subscription
        where sub_queue = _queue_id
          and sub_consumer = _subcon_id;

    return 1;
end;
$$;


ALTER FUNCTION pgq_coop.unregister_subconsumer(i_queue_name text, i_consumer_name text, i_subconsumer_name text, i_batch_handling integer) OWNER TO cdr;

--
-- TOC entry 412 (class 1255 OID 16955)
-- Name: version(); Type: FUNCTION; Schema: pgq_coop; Owner: cdr
--

CREATE FUNCTION version() RETURNS text
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_coop.version(0)
--
--      Returns version string for pgq_coop.  ATM it is based on SkyTools version
--      and only bumped when database code changes.
-- ----------------------------------------------------------------------
begin
    return '3.1.1';
end;
$$;


ALTER FUNCTION pgq_coop.version() OWNER TO cdr;

SET search_path = pgq_ext, pg_catalog;

--
-- TOC entry 373 (class 1255 OID 16841)
-- Name: get_last_tick(text); Type: FUNCTION; Schema: pgq_ext; Owner: cdr
--

CREATE FUNCTION get_last_tick(a_consumer text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.get_last_tick(1)
--
--	Gets last completed tick for this consumer 
--
-- Parameters:
--      a_consumer - consumer name
--
-- Returns:
--	    tick_id - last completed tick 
-- Calls:
--      pgq_ext.get_last_tick(2)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq_ext.get_last_tick(a_consumer, '');
end;
$$;


ALTER FUNCTION pgq_ext.get_last_tick(a_consumer text) OWNER TO cdr;

--
-- TOC entry 372 (class 1255 OID 16840)
-- Name: get_last_tick(text, text); Type: FUNCTION; Schema: pgq_ext; Owner: cdr
--

CREATE FUNCTION get_last_tick(a_consumer text, a_subconsumer text) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.get_last_tick(2)
--
--	Gets last completed tick for this consumer 
--
-- Parameters:
--      a_consumer - consumer name
--      a_subconsumer - subconsumer name
--
-- Returns:
--	    tick_id - last completed tick 
-- Calls:
--      None
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
declare
    res   int8;
begin
    select last_tick_id into res
      from pgq_ext.completed_tick
     where consumer_id = a_consumer
       and subconsumer_id = a_subconsumer;
    return res;
end;
$$;


ALTER FUNCTION pgq_ext.get_last_tick(a_consumer text, a_subconsumer text) OWNER TO cdr;

--
-- TOC entry 369 (class 1255 OID 16837)
-- Name: is_batch_done(text, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: cdr
--

CREATE FUNCTION is_batch_done(a_consumer text, a_batch_id bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.is_batch_done(2)
--
--	    Checks if a certain consumer has completed the batch 
--
-- Parameters:
--      a_consumer - consumer name
--      a_batch_id - a batch id
--
-- Returns:
--	    true if batch is done, else false 
-- Calls:
--      pgq_ext.is_batch_done(3)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq_ext.is_batch_done(a_consumer, '', a_batch_id);
end;
$$;


ALTER FUNCTION pgq_ext.is_batch_done(a_consumer text, a_batch_id bigint) OWNER TO cdr;

--
-- TOC entry 368 (class 1255 OID 16836)
-- Name: is_batch_done(text, text, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: cdr
--

CREATE FUNCTION is_batch_done(a_consumer text, a_subconsumer text, a_batch_id bigint) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.is_batch_done(3)
--
--	    Checks if a certain consumer and subconsumer have completed the batch 
--
-- Parameters:
--      a_consumer - consumer name
--      a_subconsumer - subconsumer name
--      a_batch_id - a batch id
--
-- Returns:
--	    true if batch is done, else false 
-- Calls:
--      None
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
declare
    res   boolean;
begin
    select last_batch_id = a_batch_id
      into res from pgq_ext.completed_batch
     where consumer_id = a_consumer
       and subconsumer_id = a_subconsumer;
    if not found then
        return false;
    end if;
    return res;
end;
$$;


ALTER FUNCTION pgq_ext.is_batch_done(a_consumer text, a_subconsumer text, a_batch_id bigint) OWNER TO cdr;

--
-- TOC entry 377 (class 1255 OID 16845)
-- Name: is_event_done(text, bigint, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: cdr
--

CREATE FUNCTION is_event_done(a_consumer text, a_batch_id bigint, a_event_id bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.is_event_done(3)
--
--	    Checks if a certain consumer has "done" and event
--      in a batch  
--
-- Parameters:
--      a_consumer - consumer name
--      a_batch_id - a batch id
--      a_event_id - an event id
--
-- Returns:
--	    true if event is done, else false 
-- Calls:
--      Nonpgq_ext.is_event_done(4)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq_ext.is_event_done(a_consumer, '', a_batch_id, a_event_id);
end;
$$;


ALTER FUNCTION pgq_ext.is_event_done(a_consumer text, a_batch_id bigint, a_event_id bigint) OWNER TO cdr;

--
-- TOC entry 376 (class 1255 OID 16844)
-- Name: is_event_done(text, text, bigint, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: cdr
--

CREATE FUNCTION is_event_done(a_consumer text, a_subconsumer text, a_batch_id bigint, a_event_id bigint) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.is_event_done(4)
--
--	    Checks if a certain consumer and subconsumer have "done" and event
--      in a batch  
--
-- Parameters:
--      a_consumer - consumer name
--      a_subconsumer - subconsumer name
--      a_batch_id - a batch id
--      a_event_id - an event id
--
-- Returns:
--	    true if event is done, else false 
-- Calls:
--      None
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
declare
    res   bigint;
begin
    perform 1 from pgq_ext.completed_event
     where consumer_id = a_consumer
       and subconsumer_id = a_subconsumer
       and batch_id = a_batch_id
       and event_id = a_event_id;
    return found;
end;
$$;


ALTER FUNCTION pgq_ext.is_event_done(a_consumer text, a_subconsumer text, a_batch_id bigint, a_event_id bigint) OWNER TO cdr;

--
-- TOC entry 371 (class 1255 OID 16839)
-- Name: set_batch_done(text, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: cdr
--

CREATE FUNCTION set_batch_done(a_consumer text, a_batch_id bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.set_batch_done(3)
--
--	    Marks a batch as "done"  for certain consumer 
--
-- Parameters:
--      a_consumer - consumer name
--      a_batch_id - a batch id
--
-- Returns:
--      false if it already was done
--	    true for successfully marking it as done 
-- Calls:
--      pgq_ext.set_batch_done(3)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq_ext.set_batch_done(a_consumer, '', a_batch_id);
end;
$$;


ALTER FUNCTION pgq_ext.set_batch_done(a_consumer text, a_batch_id bigint) OWNER TO cdr;

--
-- TOC entry 370 (class 1255 OID 16838)
-- Name: set_batch_done(text, text, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: cdr
--

CREATE FUNCTION set_batch_done(a_consumer text, a_subconsumer text, a_batch_id bigint) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.set_batch_done(3)
--
--	    Marks a batch as "done"  for certain consumer and subconsumer 
--
-- Parameters:
--      a_consumer - consumer name
--      a_subconsumer - subconsumer name
--      a_batch_id - a batch id
--
-- Returns:
--      false if it already was done
--	    true for successfully marking it as done 
-- Calls:
--      None
-- Tables directly manipulated:
--      update - pgq_ext.completed_batch
-- ----------------------------------------------------------------------
begin
    if pgq_ext.is_batch_done(a_consumer, a_subconsumer, a_batch_id) then
        return false;
    end if;

    if a_batch_id > 0 then
        update pgq_ext.completed_batch
           set last_batch_id = a_batch_id
         where consumer_id = a_consumer
           and subconsumer_id = a_subconsumer;
        if not found then
            insert into pgq_ext.completed_batch (consumer_id, subconsumer_id, last_batch_id)
                values (a_consumer, a_subconsumer, a_batch_id);
        end if;
    end if;

    return true;
end;
$$;


ALTER FUNCTION pgq_ext.set_batch_done(a_consumer text, a_subconsumer text, a_batch_id bigint) OWNER TO cdr;

--
-- TOC entry 379 (class 1255 OID 16847)
-- Name: set_event_done(text, bigint, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: cdr
--

CREATE FUNCTION set_event_done(a_consumer text, a_batch_id bigint, a_event_id bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.set_event_done(3)
--
--	    Marks and event done in a batch for a certain consumer and subconsumer
--
-- Parameters:
--      a_consumer - consumer name
--      a_batch_id - a batch id
--      a_event_id - an event id
--
-- Returns:
--      false if already done
--	    true on success 
-- Calls:
--      pgq_ext.set_event_done(4)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq_ext.set_event_done(a_consumer, '', a_batch_id, a_event_id);
end;
$$;


ALTER FUNCTION pgq_ext.set_event_done(a_consumer text, a_batch_id bigint, a_event_id bigint) OWNER TO cdr;

--
-- TOC entry 378 (class 1255 OID 16846)
-- Name: set_event_done(text, text, bigint, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: cdr
--

CREATE FUNCTION set_event_done(a_consumer text, a_subconsumer text, a_batch_id bigint, a_event_id bigint) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.set_event_done(4)
--
--	    Marks and event done in a batch for a certain consumer and subconsumer
--
-- Parameters:
--      a_consumer - consumer name
--      a_subconsumer - subconsumer name
--      a_batch_id - a batch id
--      a_event_id - an event id
--
-- Returns:
--      false if already done
--	    true on success 
-- Calls:
--      None
-- Tables directly manipulated:
--      insert - pgq_ext.partial_batch
--      delete - pgq_ext.completed_event
--      update - pgq_ext.partial_batch
--      insert - pgq_ext.completed_event
-- ----------------------------------------------------------------------
declare
    old_batch bigint;
begin
    -- check if done
    perform 1 from pgq_ext.completed_event
     where consumer_id = a_consumer
       and subconsumer_id = a_subconsumer
       and batch_id = a_batch_id
       and event_id = a_event_id;
    if found then
        return false;
    end if;

    -- if batch changed, do cleanup
    select cur_batch_id into old_batch
        from pgq_ext.partial_batch
        where consumer_id = a_consumer
          and subconsumer_id = a_subconsumer;
    if not found then
        -- first time here
        insert into pgq_ext.partial_batch
            (consumer_id, subconsumer_id, cur_batch_id)
            values (a_consumer, a_subconsumer, a_batch_id);
    elsif old_batch <> a_batch_id then
        -- batch changed, that means old is finished on queue db
        -- thus the tagged events are not needed anymore
        delete from pgq_ext.completed_event
            where consumer_id = a_consumer
              and subconsumer_id = a_subconsumer
              and batch_id = old_batch;
        -- remember current one
        update pgq_ext.partial_batch
            set cur_batch_id = a_batch_id
            where consumer_id = a_consumer
              and subconsumer_id = a_subconsumer;
    end if;

    -- tag as done
    insert into pgq_ext.completed_event
        (consumer_id, subconsumer_id, batch_id, event_id)
        values (a_consumer, a_subconsumer, a_batch_id, a_event_id);

    return true;
end;
$$;


ALTER FUNCTION pgq_ext.set_event_done(a_consumer text, a_subconsumer text, a_batch_id bigint, a_event_id bigint) OWNER TO cdr;

--
-- TOC entry 375 (class 1255 OID 16843)
-- Name: set_last_tick(text, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: cdr
--

CREATE FUNCTION set_last_tick(a_consumer text, a_tick_id bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.set_last_tick(2)
--
--	    records last completed tick for consumer,
--      removes row if a_tick_id is NULL 
--
-- Parameters:
--      a_consumer - consumer name
--      a_tick_id - a tick id
--
-- Returns:
--      1
-- Calls:
--      pgq_ext.set_last_tick(2)
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
begin
    return pgq_ext.set_last_tick(a_consumer, '', a_tick_id);
end;
$$;


ALTER FUNCTION pgq_ext.set_last_tick(a_consumer text, a_tick_id bigint) OWNER TO cdr;

--
-- TOC entry 374 (class 1255 OID 16842)
-- Name: set_last_tick(text, text, bigint); Type: FUNCTION; Schema: pgq_ext; Owner: cdr
--

CREATE FUNCTION set_last_tick(a_consumer text, a_subconsumer text, a_tick_id bigint) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.set_last_tick(3)
--
--	    records last completed tick for consumer,
--      removes row if a_tick_id is NULL 
--
-- Parameters:
--      a_consumer - consumer name
--      a_subconsumer - subconsumer name
--      a_tick_id - a tick id
--
-- Returns:
--      1
-- Calls:
--      None
-- Tables directly manipulated:
--      delete - pgq_ext.completed_tick
--      update - pgq_ext.completed_tick
--      insert - pgq_ext.completed_tick 
-- ----------------------------------------------------------------------
begin
    if a_tick_id is null then
        delete from pgq_ext.completed_tick
         where consumer_id = a_consumer
           and subconsumer_id = a_subconsumer;
    else   
        update pgq_ext.completed_tick
           set last_tick_id = a_tick_id
         where consumer_id = a_consumer
           and subconsumer_id = a_subconsumer;
        if not found then
            insert into pgq_ext.completed_tick
                (consumer_id, subconsumer_id, last_tick_id)
                values (a_consumer, a_subconsumer, a_tick_id);
        end if;
    end if;

    return 1;
end;
$$;


ALTER FUNCTION pgq_ext.set_last_tick(a_consumer text, a_subconsumer text, a_tick_id bigint) OWNER TO cdr;

--
-- TOC entry 367 (class 1255 OID 16831)
-- Name: upgrade_schema(); Type: FUNCTION; Schema: pgq_ext; Owner: cdr
--

CREATE FUNCTION upgrade_schema() RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- updates table structure if necessary
-- ----------------------------------------------------------------------
-- Function: pgq_ext.upgrade_schema()
--
--	    Upgrades tables to have column subconsumer_id 
--
-- Parameters:
--      None
--
-- Returns:
--	    number of tables updated 
-- Calls:
--      None
-- Tables directly manipulated:
--      alter - pgq_ext.completed_batch
--      alter - pgq_ext.completed_tick
--      alter - pgq_ext.partial_batch
--      alter - pgq_ext.completed_event
-- ----------------------------------------------------------------------
declare
    cnt int4 = 0;
    tbl text;
    sql text;
begin
    -- pgq_ext.completed_batch: subconsumer_id
    perform 1 from information_schema.columns
      where table_schema = 'pgq_ext'
        and table_name = 'completed_batch'
        and column_name = 'subconsumer_id';
    if not found then
        alter table pgq_ext.completed_batch
            add column subconsumer_id text;
        update pgq_ext.completed_batch
            set subconsumer_id = '';
        alter table pgq_ext.completed_batch
            alter column subconsumer_id set not null;
        alter table pgq_ext.completed_batch
            drop constraint completed_batch_pkey;
        alter table pgq_ext.completed_batch
            add constraint completed_batch_pkey
            primary key (consumer_id, subconsumer_id);
        cnt := cnt + 1;
    end if;

    -- pgq_ext.completed_tick: subconsumer_id
    perform 1 from information_schema.columns
      where table_schema = 'pgq_ext'
        and table_name = 'completed_tick'
        and column_name = 'subconsumer_id';
    if not found then
        alter table pgq_ext.completed_tick
            add column subconsumer_id text;
        update pgq_ext.completed_tick
            set subconsumer_id = '';
        alter table pgq_ext.completed_tick
            alter column subconsumer_id set not null;
        alter table pgq_ext.completed_tick
            drop constraint completed_tick_pkey;
        alter table pgq_ext.completed_tick
            add constraint completed_tick_pkey
            primary key (consumer_id, subconsumer_id);
        cnt := cnt + 1;
    end if;

    -- pgq_ext.partial_batch: subconsumer_id
    perform 1 from information_schema.columns
      where table_schema = 'pgq_ext'
        and table_name = 'partial_batch'
        and column_name = 'subconsumer_id';
    if not found then
        alter table pgq_ext.partial_batch
            add column subconsumer_id text;
        update pgq_ext.partial_batch
            set subconsumer_id = '';
        alter table pgq_ext.partial_batch
            alter column subconsumer_id set not null;
        alter table pgq_ext.partial_batch
            drop constraint partial_batch_pkey;
        alter table pgq_ext.partial_batch
            add constraint partial_batch_pkey
            primary key (consumer_id, subconsumer_id);
        cnt := cnt + 1;
    end if;

    -- pgq_ext.completed_event: subconsumer_id
    perform 1 from information_schema.columns
      where table_schema = 'pgq_ext'
        and table_name = 'completed_event'
        and column_name = 'subconsumer_id';
    if not found then
        alter table pgq_ext.completed_event
            add column subconsumer_id text;
        update pgq_ext.completed_event
            set subconsumer_id = '';
        alter table pgq_ext.completed_event
            alter column subconsumer_id set not null;
        alter table pgq_ext.completed_event
            drop constraint completed_event_pkey;
        alter table pgq_ext.completed_event
            add constraint completed_event_pkey
            primary key (consumer_id, subconsumer_id, batch_id, event_id);
        cnt := cnt + 1;
    end if;

    -- add default value to subconsumer_id column
    for tbl in
        select table_name
           from information_schema.columns
           where table_schema = 'pgq_ext'
             and table_name in ('completed_tick', 'completed_event', 'partial_batch', 'completed_batch')
             and column_name = 'subconsumer_id'
             and column_default is null
    loop
        sql := 'alter table pgq_ext.' || tbl
            || ' alter column subconsumer_id set default ' || quote_literal('');
        execute sql;
        cnt := cnt + 1;
    end loop;

    return cnt;
end;
$$;


ALTER FUNCTION pgq_ext.upgrade_schema() OWNER TO cdr;

--
-- TOC entry 350 (class 1255 OID 16848)
-- Name: version(); Type: FUNCTION; Schema: pgq_ext; Owner: cdr
--

CREATE FUNCTION version() RETURNS text
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_ext.version(0)
--
--      Returns version string for pgq_ext.  ATM it is based SkyTools version
--      only bumped when database code changes.
-- ----------------------------------------------------------------------
begin
    return '3.1';
end;
$$;


ALTER FUNCTION pgq_ext.version() OWNER TO cdr;

SET search_path = pgq_node, pg_catalog;

--
-- TOC entry 398 (class 1255 OID 16940)
-- Name: change_consumer_provider(text, text, text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION change_consumer_provider(i_queue_name text, i_consumer_name text, i_new_provider text, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.change_consumer_provider(3)
--
--      Change provider for this consumer.
--
-- Parameters:
--      i_queue_name  - queue name
--      i_consumer_name  - consumer name
--      i_new_provider - node name for new provider
-- Returns:
--      ret_code - error code
--      200 - ok
--      404 - no such consumer or new node
--      ret_note - description
-- ----------------------------------------------------------------------
begin
    perform 1 from pgq_node.node_location
      where queue_name = i_queue_name
        and node_name = i_new_provider;
    if not found then
        select 404, 'New node not found: ' || i_new_provider
          into ret_code, ret_note;
        return;
    end if;

    update pgq_node.local_state
       set provider_node = i_new_provider,
           uptodate = false
     where queue_name = i_queue_name
       and consumer_name = i_consumer_name;
    if not found then
        select 404, 'Unknown consumer: ' || i_queue_name || '/' || i_consumer_name
          into ret_code, ret_note;
        return;
    end if;
    select 200, 'Consumer provider node set to : ' || i_new_provider
      into ret_code, ret_note;
    return;
end;
$$;


ALTER FUNCTION pgq_node.change_consumer_provider(i_queue_name text, i_consumer_name text, i_new_provider text, OUT ret_code integer, OUT ret_note text) OWNER TO cdr;

--
-- TOC entry 314 (class 1255 OID 16921)
-- Name: create_node(text, text, text, text, text, bigint, text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION create_node(i_queue_name text, i_node_type text, i_node_name text, i_worker_name text, i_provider_name text, i_global_watermark bigint, i_combined_queue text, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.create_node(7)
--
--      Initialize node.
--
-- Parameters:
--      i_node_name - cascaded queue name
--      i_node_type - node type
--      i_node_name - node name
--      i_worker_name - worker consumer name
--      i_provider_name - provider node name for non-root nodes
--      i_global_watermark - global lowest tick_id
--      i_combined_queue - merge-leaf: target queue
--
-- Returns:
--      200 - Ok
--      401 - node already initialized
--      ???? - maybe we coud use more error codes ?
--
-- Node Types:
--      root - master node
--      branch - subscriber node that can be provider to others
--      leaf - subscriber node that cannot be provider to others
-- Calls:
--      None
-- Tables directly manipulated:
--      None
-- ----------------------------------------------------------------------
declare
    _wm_consumer text;
    _global_wm bigint;
begin
    perform 1 from pgq_node.node_info where queue_name = i_queue_name;
    if found then
        select 401, 'Node already initialized' into ret_code, ret_note;
        return;
    end if;

    _wm_consumer := '.global_watermark';

    if i_node_type = 'root' then
        if coalesce(i_provider_name, i_global_watermark::text,
                    i_combined_queue) is not null then
            select 401, 'unexpected args for '||i_node_type into ret_code, ret_note;
            return;
        end if;

        perform pgq.create_queue(i_queue_name);
        perform pgq.register_consumer(i_queue_name, _wm_consumer);
        _global_wm := (select last_tick from pgq.get_consumer_info(i_queue_name, _wm_consumer));
    elsif i_node_type = 'branch' then
        if i_provider_name is null then
            select 401, 'provider not set for '||i_node_type into ret_code, ret_note;
            return;
        end if;
        if i_global_watermark is null then
            select 401, 'global watermark not set for '||i_node_type into ret_code, ret_note;
            return;
        end if;
        perform pgq.create_queue(i_queue_name);
        update pgq.queue
            set queue_external_ticker = true,
                queue_disable_insert = true
            where queue_name = i_queue_name;
        if i_global_watermark > 1 then
            perform pgq.ticker(i_queue_name, i_global_watermark, now(), 1);
        end if;
        perform pgq.register_consumer_at(i_queue_name, _wm_consumer, i_global_watermark);
        _global_wm := i_global_watermark;
    elsif i_node_type = 'leaf' then
        _global_wm := i_global_watermark;
        if i_combined_queue is not null then
            perform 1 from pgq.get_queue_info(i_combined_queue);
            if not found then
                select 401, 'non-existing queue on leaf side: '||i_combined_queue
                into ret_code, ret_note;
                return;
            end if;
        end if;
    else
        select 401, 'bad node type: '||i_node_type
          into ret_code, ret_note;
    end if;

    insert into pgq_node.node_info
      (queue_name, node_type, node_name,
       worker_name, combined_queue)
    values (i_queue_name, i_node_type, i_node_name,
       i_worker_name, i_combined_queue);

    if i_node_type <> 'root' then
        select f.ret_code, f.ret_note into ret_code, ret_note
          from pgq_node.register_consumer(i_queue_name, i_worker_name,
                    i_provider_name, _global_wm) f;
    else
        select f.ret_code, f.ret_note into ret_code, ret_note
          from pgq_node.register_consumer(i_queue_name, i_worker_name,
                    i_node_name, _global_wm) f;
    end if;
        if ret_code <> 200 then
            return;
        end if;

    select 200, 'Node "' || i_node_name || '" initialized for queue "'
           || i_queue_name || '" with type "' || i_node_type || '"'
        into ret_code, ret_note;
    return;
end;
$$;


ALTER FUNCTION pgq_node.create_node(i_queue_name text, i_node_type text, i_node_name text, i_worker_name text, i_provider_name text, i_global_watermark bigint, i_combined_queue text, OUT ret_code integer, OUT ret_note text) OWNER TO cdr;

--
-- TOC entry 385 (class 1255 OID 16928)
-- Name: demote_root(text, integer, text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION demote_root(i_queue_name text, i_step integer, i_new_provider text, OUT ret_code integer, OUT ret_note text, OUT last_tick bigint) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.demote_root(3)
--
--      Multi-step root demotion to branch.
--
--      Must be be called for each step in sequence:
--
--      Step 1 - disable writing to queue.
--      Step 2 - wait until writers go away, do tick.
--      Step 3 - change type, register.
--
-- Parameters:
--      i_queue_name    - queue name
--      i_step          - step number
--      i_new_provider  - new provider node
-- Returns:
--      200 - success
--      404 - node not initialized for queue 
--      301 - node is not root
-- ----------------------------------------------------------------------
declare
    n_type      text;
    w_name      text;
    sql         text;
    ev_id       int8;
    ev_tbl      text;
begin
    select node_type, worker_name into n_type, w_name
        from pgq_node.node_info
        where queue_name = i_queue_name;
    if not found then
        select 404, 'Node not initialized for queue: ' || i_queue_name
          into ret_code, ret_note;
        return;
    end if;

    if n_type != 'root' then
        select 301, 'Node not root'
          into ret_code, ret_note;
        return;
    end if;
    if i_step > 1 then
        select queue_data_pfx
            into ev_tbl
            from pgq.queue
            where queue_name = i_queue_name
                and queue_disable_insert
                and queue_external_ticker;
        if not found then
            raise exception 'steps in wrong order';
        end if;
    end if;

    if i_step = 1 then
        update pgq.queue
            set queue_disable_insert = true,
                queue_external_ticker = true
            where queue_name = i_queue_name;
        if not found then
            select 404, 'Huh, no queue?: ' || i_queue_name
              into ret_code, ret_note;
            return;
        end if;
        select 200, 'Step 1: Writing disabled for: ' || i_queue_name
          into ret_code, ret_note;
    elsif i_step = 2 then
        set local session_replication_role = 'replica';

        -- lock parent table to stop updates, allow reading
        sql := 'lock table ' || ev_tbl || ' in exclusive mode';
        execute sql;
        

        select nextval(queue_tick_seq), nextval(queue_event_seq)
            into last_tick, ev_id
            from pgq.queue
            where queue_name = i_queue_name;

        perform pgq.ticker(i_queue_name, last_tick, now(), ev_id);

        select 200, 'Step 2: Inserted last tick: ' || i_queue_name
            into ret_code, ret_note;
    elsif i_step = 3 then
        -- change type, point worker to new provider
        select t.tick_id into last_tick
            from pgq.tick t, pgq.queue q
            where q.queue_name = i_queue_name
                and t.tick_queue = q.queue_id
            order by t.tick_queue desc, t.tick_id desc
            limit 1;
        update pgq_node.node_info
            set node_type = 'branch'
            where queue_name = i_queue_name;
        update pgq_node.local_state
            set provider_node = i_new_provider,
                last_tick_id = last_tick,
                uptodate = false
            where queue_name = i_queue_name
                and consumer_name = w_name;
        select 200, 'Step 3: Demoted root to branch: ' || i_queue_name
          into ret_code, ret_note;
    else
        raise exception 'incorrect step number';
    end if;
    return;
end;
$$;


ALTER FUNCTION pgq_node.demote_root(i_queue_name text, i_step integer, i_new_provider text, OUT ret_code integer, OUT ret_note text, OUT last_tick bigint) OWNER TO cdr;

--
-- TOC entry 315 (class 1255 OID 16922)
-- Name: drop_node(text, text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION drop_node(i_queue_name text, i_node_name text, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.drop_node(2)
--
--      Drop node. This needs to be run on all the members of a set
--      to properly get rid of the node.
--
-- Parameters:
--      i_queue_name - queue name
--      i_node_name - node_name
--
-- Returns:
--      ret_code - error code
--      ret_note - error description
--
-- Return Codes:
--      200 - Ok
--      304 - No such queue
--      406 - That is a provider
-- Calls:
--      None
-- Tables directly manipulated:
--      None
------------------------------------------------------------------------
declare
    _is_local   boolean;
    _is_prov    boolean;
begin
    select (n.node_name = i_node_name),
           (select s.provider_node = i_node_name
              from pgq_node.local_state s
              where s.queue_name = i_queue_name
                and s.consumer_name = n.worker_name)
        into _is_local, _is_prov
        from pgq_node.node_info n
        where n.queue_name = i_queue_name;

    if not found then
        -- proceed with cleaning anyway, as there schenarios
        -- where some data is left around
        _is_prov := false;
        _is_local := true;
    end if;

    -- drop local state
    if _is_local then
        delete from pgq_node.subscriber_info
         where queue_name = i_queue_name;

        delete from pgq_node.local_state
         where queue_name = i_queue_name;

        delete from pgq_node.node_info
         where queue_name = i_queue_name
            and node_name = i_node_name;

        perform pgq.drop_queue(queue_name, true)
           from pgq.queue where queue_name = i_queue_name;

        delete from pgq_node.node_location
         where queue_name = i_queue_name
           and node_name <> i_node_name;
    elsif _is_prov then
        select 405, 'Cannot drop provider node: ' || i_node_name into ret_code, ret_note;
        return;
    else
        perform pgq_node.unregister_subscriber(i_queue_name, i_node_name);
    end if;

    -- let the unregister_location send event if needed
    select f.ret_code, f.ret_note
        from pgq_node.unregister_location(i_queue_name, i_node_name) f
        into ret_code, ret_note;

    select 200, 'Node dropped: ' || i_node_name
        into ret_code, ret_note;
    return;
end;
$$;


ALTER FUNCTION pgq_node.drop_node(i_queue_name text, i_node_name text, OUT ret_code integer, OUT ret_note text) OWNER TO cdr;

--
-- TOC entry 384 (class 1255 OID 16927)
-- Name: get_consumer_info(text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION get_consumer_info(i_queue_name text, OUT consumer_name text, OUT provider_node text, OUT last_tick_id bigint, OUT paused boolean, OUT uptodate boolean, OUT cur_error text) RETURNS SETOF record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.get_consumer_info(1)
--
--      Get consumer list that work on the local node.
--
-- Parameters:
--      i_queue_name  - cascaded queue name
--
-- Returns:
--      consumer_name   - cascaded consumer name
--      provider_node   - node from where the consumer reads from
--      last_tick_id    - last committed tick
--      paused          - if consumer is paused
--      uptodate        - if consumer is uptodate
--      cur_error       - failure reason
-- ----------------------------------------------------------------------
begin
    for consumer_name, provider_node, last_tick_id, paused, uptodate, cur_error in
        select s.consumer_name, s.provider_node, s.last_tick_id,
               s.paused, s.uptodate, s.cur_error
            from pgq_node.local_state s
            where s.queue_name = i_queue_name
            order by 1
    loop
        return next;
    end loop;
    return;
end;
$$;


ALTER FUNCTION pgq_node.get_consumer_info(i_queue_name text, OUT consumer_name text, OUT provider_node text, OUT last_tick_id bigint, OUT paused boolean, OUT uptodate boolean, OUT cur_error text) OWNER TO cdr;

--
-- TOC entry 391 (class 1255 OID 16939)
-- Name: get_consumer_state(text, text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION get_consumer_state(i_queue_name text, i_consumer_name text, OUT ret_code integer, OUT ret_note text, OUT node_type text, OUT node_name text, OUT completed_tick bigint, OUT provider_node text, OUT provider_location text, OUT paused boolean, OUT uptodate boolean, OUT cur_error text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.get_consumer_state(2)
--
--      Get info for cascaded consumer that targets local node.
--
-- Parameters:
--      i_node_name  - cascaded queue name
--      i_consumer_name - cascaded consumer name
--
-- Returns:
--      node_type - local node type
--      node_name - local node name
--      completed_tick - last committed tick
--      provider_node - provider node name
--      provider_location - connect string to provider node
--      paused - this node should not do any work
--      uptodate - if consumer has loaded last changes
--      cur_error - failure reason
-- ----------------------------------------------------------------------
begin
    select n.node_type, n.node_name
      into node_type, node_name
      from pgq_node.node_info n
    where n.queue_name = i_queue_name;
    if not found then
        select 404, 'Unknown queue: ' || i_queue_name
          into ret_code, ret_note;
        return;
    end if;
    select s.last_tick_id, s.provider_node, s.paused, s.uptodate, s.cur_error
      into completed_tick, provider_node, paused, uptodate, cur_error
      from pgq_node.local_state s
     where s.queue_name = i_queue_name
       and s.consumer_name = i_consumer_name;
    if not found then
        select 404, 'Unknown consumer: ' || i_queue_name || '/' || i_consumer_name
          into ret_code, ret_note;
        return;
    end if;
    select 100, 'Ok', p.node_location
      into ret_code, ret_note, provider_location
      from pgq_node.node_location p
     where p.queue_name = i_queue_name
      and p.node_name = provider_node;
    if not found then
        select 404, 'Unknown provider node: ' || i_queue_name || '/' || provider_node
          into ret_code, ret_note;
        return;
    end if;
    return;
end;
$$;


ALTER FUNCTION pgq_node.get_consumer_state(i_queue_name text, i_consumer_name text, OUT ret_code integer, OUT ret_note text, OUT node_type text, OUT node_name text, OUT completed_tick bigint, OUT provider_node text, OUT provider_location text, OUT paused boolean, OUT uptodate boolean, OUT cur_error text) OWNER TO cdr;

--
-- TOC entry 380 (class 1255 OID 16923)
-- Name: get_node_info(text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION get_node_info(i_queue_name text, OUT ret_code integer, OUT ret_note text, OUT node_type text, OUT node_name text, OUT global_watermark bigint, OUT local_watermark bigint, OUT provider_node text, OUT provider_location text, OUT combined_queue text, OUT combined_type text, OUT worker_name text, OUT worker_paused boolean, OUT worker_uptodate boolean, OUT worker_last_tick bigint, OUT node_attrs text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.get_node_info(1)
--
--      Get local node info for cascaded queue.
--
-- Parameters:
--      i_queue_name  - cascaded queue name
--
-- Returns:
--      node_type - local node type
--      node_name - local node name
--      global_watermark - queue's global watermark
--      local_watermark - queue's local watermark, for this and below nodes
--      provider_node - provider node name
--      provider_location - provider connect string
--      combined_queue - queue name for target set
--      combined_type - node type of target set
--      worker_name - consumer name that maintains this node
--      worker_paused - is worker paused
--      worker_uptodate - is worker seen the changes
--      worker_last_tick - last committed tick_id by worker
--      node_attrs - urlencoded dict of random attrs for worker (eg. sync_watermark)
-- ----------------------------------------------------------------------
declare
    sql text;
begin
    select 100, 'Ok', n.node_type, n.node_name,
           c.node_type, c.queue_name, w.provider_node, l.node_location,
           n.worker_name, w.paused, w.uptodate, w.last_tick_id,
           n.node_attrs
      into ret_code, ret_note, node_type, node_name,
           combined_type, combined_queue, provider_node, provider_location,
           worker_name, worker_paused, worker_uptodate, worker_last_tick,
           node_attrs
      from pgq_node.node_info n
           left join pgq_node.node_info c on (c.queue_name = n.combined_queue)
           left join pgq_node.local_state w on (w.queue_name = n.queue_name and w.consumer_name = n.worker_name)
           left join pgq_node.node_location l on (l.queue_name = w.queue_name and l.node_name = w.provider_node)
      where n.queue_name = i_queue_name;
    if not found then
        select 404, 'Unknown queue: ' || i_queue_name into ret_code, ret_note;
        return;
    end if;

    if node_type in ('root', 'branch') then
        select min(case when consumer_name = '.global_watermark' then null else last_tick end),
               min(case when consumer_name = '.global_watermark' then last_tick else null end)
          into local_watermark, global_watermark
          from pgq.get_consumer_info(i_queue_name);
        if local_watermark is null then
            select t.tick_id into local_watermark
              from pgq.tick t, pgq.queue q
             where t.tick_queue = q.queue_id
               and q.queue_name = i_queue_name
             order by 1 desc
             limit 1;
        end if;
    else
        local_watermark := worker_last_tick;
    end if;

    if node_type = 'root' then
        select tick_id from pgq.tick t, pgq.queue q
         where q.queue_name = i_queue_name
           and t.tick_queue = q.queue_id
         order by t.tick_queue desc, t.tick_id desc
         limit 1
         into worker_last_tick;
    end if;

    return;
end;
$$;


ALTER FUNCTION pgq_node.get_node_info(i_queue_name text, OUT ret_code integer, OUT ret_note text, OUT node_type text, OUT node_name text, OUT global_watermark bigint, OUT local_watermark bigint, OUT provider_node text, OUT provider_location text, OUT combined_queue text, OUT combined_type text, OUT worker_name text, OUT worker_paused boolean, OUT worker_uptodate boolean, OUT worker_last_tick bigint, OUT node_attrs text) OWNER TO cdr;

--
-- TOC entry 313 (class 1255 OID 16920)
-- Name: get_queue_locations(text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION get_queue_locations(i_queue_name text, OUT node_name text, OUT node_location text, OUT dead boolean) RETURNS SETOF record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.get_queue_locations(1)
--
--      Get node list for the queue.
--
-- Parameters:
--      i_queue_name    - queue name
--
-- Returns:
--      node_name       - node name
--      node_location   - libpq connect string for the node
--      dead            - whether the node should be considered dead
-- ----------------------------------------------------------------------
begin
    for node_name, node_location, dead in
        select l.node_name, l.node_location, l.dead
          from pgq_node.node_location l
         where l.queue_name = i_queue_name
    loop
        return next;
    end loop;
    return;
end;
$$;


ALTER FUNCTION pgq_node.get_queue_locations(i_queue_name text, OUT node_name text, OUT node_location text, OUT dead boolean) OWNER TO cdr;

--
-- TOC entry 383 (class 1255 OID 16926)
-- Name: get_subscriber_info(text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION get_subscriber_info(i_queue_name text, OUT node_name text, OUT worker_name text, OUT node_watermark bigint) RETURNS SETOF record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.get_subscriber_info(1)
--
--      Get subscriber list for the local node.
--
--      It may be out-of-date, due to in-progress
--      administrative change.
--      Node's local provider info ( pgq_node.get_node_info() or pgq_node.get_worker_state(1) )
--      is the authoritative source.
--
-- Parameters:
--      i_queue_name  - cascaded queue name
--
-- Returns:
--      node_name       - node name that uses current node as provider
--      worker_name     - consumer that maintains remote node
--      local_watermark - lowest tick_id on subscriber
-- ----------------------------------------------------------------------
declare
    _watermark_name text;
begin
    for node_name, worker_name, _watermark_name in
        select s.subscriber_node, s.worker_name, s.watermark_name
          from pgq_node.subscriber_info s
         where s.queue_name = i_queue_name
         order by 1
    loop
        select last_tick into node_watermark
            from pgq.get_consumer_info(i_queue_name, _watermark_name);
        return next;
    end loop;
    return;
end;
$$;


ALTER FUNCTION pgq_node.get_subscriber_info(i_queue_name text, OUT node_name text, OUT worker_name text, OUT node_watermark bigint) OWNER TO cdr;

--
-- TOC entry 392 (class 1255 OID 16934)
-- Name: get_worker_state(text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION get_worker_state(i_queue_name text, OUT ret_code integer, OUT ret_note text, OUT node_type text, OUT node_name text, OUT completed_tick bigint, OUT provider_node text, OUT provider_location text, OUT paused boolean, OUT uptodate boolean, OUT cur_error text, OUT worker_name text, OUT global_watermark bigint, OUT local_watermark bigint, OUT local_queue_top bigint, OUT combined_queue text, OUT combined_type text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.get_worker_state(1)
--
--      Get info for consumer that maintains local node.
--
-- Parameters:
--      i_queue_name  - cascaded queue name
--
-- Returns:
--      node_type - local node type
--      node_name - local node name
--      completed_tick - last committed tick
--      provider_node - provider node name
--      provider_location - connect string to provider node
--      paused - this node should not do any work
--      uptodate - if consumer has loaded last changes
--      cur_error - failure reason

--      worker_name - consumer name that maintains this node
--      global_watermark - queue's global watermark
--      local_watermark - queue's local watermark, for this and below nodes
--      local_queue_top - last tick in local queue
--      combined_queue - queue name for target set
--      combined_type - node type of target setA
-- ----------------------------------------------------------------------
begin
    select n.node_type, n.node_name, n.worker_name, n.combined_queue
      into node_type, node_name, worker_name, combined_queue
      from pgq_node.node_info n
     where n.queue_name = i_queue_name;
    if not found then
        select 404, 'Unknown queue: ' || i_queue_name
          into ret_code, ret_note;
        return;
    end if;
    select s.last_tick_id, s.provider_node, s.paused, s.uptodate, s.cur_error
      into completed_tick, provider_node, paused, uptodate, cur_error
      from pgq_node.local_state s
     where s.queue_name = i_queue_name
       and s.consumer_name = worker_name;
    if not found then
        select 404, 'Unknown consumer: ' || i_queue_name || '/' || worker_name
          into ret_code, ret_note;
        return;
    end if;
    select 100, 'Ok', p.node_location
      into ret_code, ret_note, provider_location
      from pgq_node.node_location p
     where p.queue_name = i_queue_name
      and p.node_name = provider_node;
    if not found then
        select 404, 'Unknown provider node: ' || i_queue_name || '/' || provider_node
          into ret_code, ret_note;
        return;
    end if;

    if combined_queue is not null then
        select n.node_type into combined_type
          from pgq_node.node_info n
         where n.queue_name = get_worker_state.combined_queue;
        if not found then
            select 404, 'Combinde queue node not found: ' || combined_queue
              into ret_code, ret_note;
            return;
        end if;
    end if;

    if node_type in ('root', 'branch') then
        select min(case when consumer_name = '.global_watermark' then null else last_tick end),
               min(case when consumer_name = '.global_watermark' then last_tick else null end)
          into local_watermark, global_watermark
          from pgq.get_consumer_info(i_queue_name);
        if local_watermark is null then
            select t.tick_id into local_watermark
              from pgq.tick t, pgq.queue q
             where t.tick_queue = q.queue_id
               and q.queue_name = i_queue_name
             order by 1 desc
             limit 1;
        end if;

        select tick_id from pgq.tick t, pgq.queue q
         where q.queue_name = i_queue_name
           and t.tick_queue = q.queue_id
         order by t.tick_queue desc, t.tick_id desc
         limit 1 into local_queue_top;
    else
        local_watermark := completed_tick;
    end if;

    return;
end;
$$;


ALTER FUNCTION pgq_node.get_worker_state(i_queue_name text, OUT ret_code integer, OUT ret_note text, OUT node_type text, OUT node_name text, OUT completed_tick bigint, OUT provider_node text, OUT provider_location text, OUT paused boolean, OUT uptodate boolean, OUT cur_error text, OUT worker_name text, OUT global_watermark bigint, OUT local_watermark bigint, OUT local_queue_top bigint, OUT combined_queue text, OUT combined_type text) OWNER TO cdr;

--
-- TOC entry 382 (class 1255 OID 16925)
-- Name: is_leaf_node(text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION is_leaf_node(i_queue_name text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.is_leaf_node(1)
--
--      Checs if node is leaf.
--
-- Parameters:
--      i_queue_name  - queue name
-- Returns:
--      true - if this this the leaf node for queue 
-- ----------------------------------------------------------------------
declare
    res bool;
begin
    select n.node_type = 'leaf' into res
      from pgq_node.node_info n
      where n.queue_name = i_queue_name;
    if not found then
        raise exception 'queue does not exist: %', i_queue_name;
    end if;
    return res;
end;
$$;


ALTER FUNCTION pgq_node.is_leaf_node(i_queue_name text) OWNER TO cdr;

--
-- TOC entry 381 (class 1255 OID 16924)
-- Name: is_root_node(text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION is_root_node(i_queue_name text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.is_root_node(1)
--
--      Checs if node is root.
--
-- Parameters:
--      i_queue_name  - queue name
-- Returns:
--      true - if this this the root node for queue 
-- ----------------------------------------------------------------------
declare
    res bool;
begin
    select n.node_type = 'root' into res
      from pgq_node.node_info n
      where n.queue_name = i_queue_name;
    if not found then
        raise exception 'queue does not exist: %', i_queue_name;
    end if;
    return res;
end;
$$;


ALTER FUNCTION pgq_node.is_root_node(i_queue_name text) OWNER TO cdr;

--
-- TOC entry 403 (class 1255 OID 16945)
-- Name: maint_watermark(text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION maint_watermark(i_queue_name text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.maint_watermark(1)
--
--      Move global watermark on root node.
--
-- Returns:
--      0 - tells pgqd to call just once
-- ----------------------------------------------------------------------
declare
    _lag interval;
begin
    perform 1 from pgq_node.node_info
      where queue_name = i_queue_name
        and node_type = 'root'
      for update;
    if not found then
        return 0;
    end if;

    select lag into _lag from pgq.get_consumer_info(i_queue_name, '.global_watermark');
    if _lag >= '5 minutes'::interval then
        perform pgq_node.set_global_watermark(i_queue_name, NULL);
    end if;

    return 0;
end;
$$;


ALTER FUNCTION pgq_node.maint_watermark(i_queue_name text) OWNER TO cdr;

--
-- TOC entry 386 (class 1255 OID 16929)
-- Name: promote_branch(text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION promote_branch(i_queue_name text, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.promote_branch(1)
--
--      Promote branch node to root.
--
-- Parameters:
--      i_queue_name  - queue name
--
-- Returns:
--      200 - success
--      404 - node not initialized for queue 
--      301 - node is not branch
-- ----------------------------------------------------------------------
declare
    n_name      text;
    n_type      text;
    w_name      text;
    last_tick   bigint;
    sql         text;
begin
    select node_name, node_type, worker_name into n_name, n_type, w_name
        from pgq_node.node_info
        where queue_name = i_queue_name;
    if not found then
        select 404, 'Node not initialized for queue: ' || i_queue_name
          into ret_code, ret_note;
        return;
    end if;

    if n_type != 'branch' then
        select 301, 'Node not branch'
          into ret_code, ret_note;
        return;
    end if;

    update pgq.queue
        set queue_disable_insert = false,
            queue_external_ticker = false
        where queue_name = i_queue_name;

    -- change type, point worker to itself
    select t.tick_id into last_tick
        from pgq.tick t, pgq.queue q
        where q.queue_name = i_queue_name
            and t.tick_queue = q.queue_id
        order by t.tick_queue desc, t.tick_id desc
        limit 1;

    -- make tick seq larger than last tick
    perform pgq.seq_setval(queue_tick_seq, last_tick)
        from pgq.queue where queue_name = i_queue_name;

    update pgq_node.node_info
        set node_type = 'root'
        where queue_name = i_queue_name;

    update pgq_node.local_state
        set provider_node = n_name,
            last_tick_id = last_tick,
            uptodate = false
        where queue_name = i_queue_name
            and consumer_name = w_name;

    select 200, 'Branch node promoted to root'
      into ret_code, ret_note;

    return;
end;
$$;


ALTER FUNCTION pgq_node.promote_branch(i_queue_name text, OUT ret_code integer, OUT ret_note text) OWNER TO cdr;

--
-- TOC entry 395 (class 1255 OID 16937)
-- Name: register_consumer(text, text, text, bigint); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION register_consumer(i_queue_name text, i_consumer_name text, i_provider_node text, i_custom_tick_id bigint, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.register_consumer(4)
--
--      Subscribe plain cascaded consumer to a target node.
--      That means it's planning to read from remote node
--      and write to local node.
--
-- Parameters:
--      i_queue_name - set name
--      i_consumer_name - cascaded consumer name
--      i_provider_node - node name
--      i_custom_tick_id - tick id
--
-- Returns:
--      ret_code - error code
--      200 - ok
--      201 - already registered
--      401 - no such queue
--      ret_note - description
-- ----------------------------------------------------------------------
declare
    n record;
    node_wm_name text;
    node_pos bigint;
begin
    select node_type into n
      from pgq_node.node_info where queue_name = i_queue_name
       for update;
    if not found then
        select 404, 'Unknown queue: ' || i_queue_name into ret_code, ret_note;
        return;
    end if;
    perform 1 from pgq_node.local_state
      where queue_name = i_queue_name
        and consumer_name = i_consumer_name;
    if found then
        update pgq_node.local_state
           set provider_node = i_provider_node,
               last_tick_id = i_custom_tick_id
         where queue_name = i_queue_name
           and consumer_name = i_consumer_name;
        select 201, 'Consumer already registered: ' || i_queue_name
               || '/' || i_consumer_name  into ret_code, ret_note;
        return;
    end if;

    insert into pgq_node.local_state (queue_name, consumer_name, provider_node, last_tick_id)
           values (i_queue_name, i_consumer_name, i_provider_node, i_custom_tick_id);

    select 200, 'Consumer '||i_consumer_name||' registered on queue '||i_queue_name
        into ret_code, ret_note;
    return;
end;
$$;


ALTER FUNCTION pgq_node.register_consumer(i_queue_name text, i_consumer_name text, i_provider_node text, i_custom_tick_id bigint, OUT ret_code integer, OUT ret_note text) OWNER TO cdr;

--
-- TOC entry 311 (class 1255 OID 16918)
-- Name: register_location(text, text, text, boolean); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION register_location(i_queue_name text, i_node_name text, i_node_location text, i_dead boolean, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.register_location(4)
--
--      Add new node location.
--
-- Parameters:
--      i_queue_name - queue name
--      i_node_name - node name
--      i_node_location - node connect string
--      i_dead - dead flag for node
--
-- Returns:
--      ret_code - error code
--      ret_note - error description
--
-- Return Codes:
--      200 - Ok
-- ----------------------------------------------------------------------
declare
    node record;
begin
    select node_type = 'root' as is_root into node
      from pgq_node.node_info where queue_name = i_queue_name
       for update;
    -- may return 0 rows

    perform 1 from pgq_node.node_location
     where queue_name = i_queue_name
       and node_name = i_node_name;
    if found then
        update pgq_node.node_location
           set node_location = coalesce(i_node_location, node_location),
               dead = i_dead
         where queue_name = i_queue_name
           and node_name = i_node_name;
    elsif i_node_location is not null then
        insert into pgq_node.node_location (queue_name, node_name, node_location, dead)
        values (i_queue_name, i_node_name, i_node_location, i_dead);
    end if;

    if node.is_root then
        perform pgq.insert_event(i_queue_name, 'pgq.location-info',
                                 i_node_name, i_queue_name, i_node_location, i_dead::text, null)
           from pgq_node.node_info n
         where n.queue_name = i_queue_name;
    end if;

    select 200, 'Location registered' into ret_code, ret_note;
    return;
end;
$$;


ALTER FUNCTION pgq_node.register_location(i_queue_name text, i_node_name text, i_node_location text, i_dead boolean, OUT ret_code integer, OUT ret_note text) OWNER TO cdr;

--
-- TOC entry 388 (class 1255 OID 16931)
-- Name: register_subscriber(text, text, text, bigint); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION register_subscriber(i_queue_name text, i_remote_node_name text, i_remote_worker_name text, i_custom_tick_id bigint, OUT ret_code integer, OUT ret_note text, OUT global_watermark bigint) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.register_subscriber(4)
--
--      Subscribe remote node to local node at custom position.
--      Should be used when changing provider for existing node.
--
-- Parameters:
--      i_node_name - set name
--      i_remote_node_name - node name
--      i_remote_worker_name - consumer name
--      i_custom_tick_id - tick id [optional]
--
-- Returns:
--      ret_code - error code
--      ret_note - description
--      global_watermark - minimal watermark
-- ----------------------------------------------------------------------
declare
    n record;
    node_wm_name text;
    node_pos bigint;
begin
    select node_type into n
      from pgq_node.node_info where queue_name = i_queue_name
       for update;
    if not found then
        select 404, 'Unknown queue: ' || i_queue_name into ret_code, ret_note;
        return;
    end if;
    select last_tick into global_watermark
      from pgq.get_consumer_info(i_queue_name, '.global_watermark');

    if n.node_type not in ('root', 'branch') then
        select 401, 'Cannot subscribe to ' || n.node_type || ' node'
          into ret_code, ret_note;
        return;
    end if;

    node_wm_name := '.' || i_remote_node_name || '.watermark';
    node_pos := coalesce(i_custom_tick_id, global_watermark);

    perform pgq.register_consumer_at(i_queue_name, node_wm_name, global_watermark);

    perform pgq.register_consumer_at(i_queue_name, i_remote_worker_name, node_pos);

    insert into pgq_node.subscriber_info (queue_name, subscriber_node, worker_name, watermark_name)
        values (i_queue_name, i_remote_node_name, i_remote_worker_name, node_wm_name);

    select 200, 'Subscriber registered: '||i_remote_node_name into ret_code, ret_note;
    return;
end;
$$;


ALTER FUNCTION pgq_node.register_subscriber(i_queue_name text, i_remote_node_name text, i_remote_worker_name text, i_custom_tick_id bigint, OUT ret_code integer, OUT ret_note text, OUT global_watermark bigint) OWNER TO cdr;

--
-- TOC entry 401 (class 1255 OID 16943)
-- Name: set_consumer_completed(text, text, bigint); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION set_consumer_completed(i_queue_name text, i_consumer_name text, i_tick_id bigint, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.set_consumer_completed(3)
--
--      Set last completed tick id for the cascaded consumer
--      that it has committed to local node.
--
-- Parameters:
--      i_queue_name - cascaded queue name
--      i_consumer_name - cascaded consumer name
--      i_tick_id   - tick id
-- Returns:
--      200 - ok
--      404 - consumer not known
-- ----------------------------------------------------------------------
begin
    update pgq_node.local_state
       set last_tick_id = i_tick_id,
           cur_error = NULL
     where queue_name = i_queue_name
       and consumer_name = i_consumer_name;
    if found then
        select 100, 'Consumer ' || i_consumer_name || ' compleded tick = ' || i_tick_id::text
            into ret_code, ret_note;
    else
        select 404, 'Consumer not known: '
               || i_queue_name || '/' || i_consumer_name
          into ret_code, ret_note;
    end if;
    return;
end;
$$;


ALTER FUNCTION pgq_node.set_consumer_completed(i_queue_name text, i_consumer_name text, i_tick_id bigint, OUT ret_code integer, OUT ret_note text) OWNER TO cdr;

--
-- TOC entry 402 (class 1255 OID 16944)
-- Name: set_consumer_error(text, text, text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION set_consumer_error(i_queue_name text, i_consumer_name text, i_error_msg text, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.set_consumer_error(3)
--
--      If batch processing fails, consumer can store it's last error in db.
-- Returns:
--      100 - ok
--      101 - consumer not known
-- ----------------------------------------------------------------------
begin
    update pgq_node.local_state
       set cur_error = i_error_msg
     where queue_name = i_queue_name
       and consumer_name = i_consumer_name;
    if found then
        select 100, 'Consumer ' || i_consumer_name || ' error = ' || i_error_msg
            into ret_code, ret_note;
    else
        select 101, 'Consumer not known, ignoring: '
               || i_queue_name || '/' || i_consumer_name
          into ret_code, ret_note;
    end if;
    return;
end;
$$;


ALTER FUNCTION pgq_node.set_consumer_error(i_queue_name text, i_consumer_name text, i_error_msg text, OUT ret_code integer, OUT ret_note text) OWNER TO cdr;

--
-- TOC entry 400 (class 1255 OID 16942)
-- Name: set_consumer_paused(text, text, boolean); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION set_consumer_paused(i_queue_name text, i_consumer_name text, i_paused boolean, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.set_consumer_paused(3)
--
--      Set consumer paused flag.
--
-- Parameters:
--      i_queue_name - cascaded queue name
--      i_consumer_name - cascaded consumer name
--      i_paused   - new flag state
-- Returns:
--      200 - ok
--      201 - already paused
--      404 - consumer not found
-- ----------------------------------------------------------------------
declare
    old_flag    boolean;
    word        text;
begin
    if i_paused then
        word := 'paused';
    else
        word := 'resumed';
    end if;

    select paused into old_flag
        from pgq_node.local_state
        where queue_name = i_queue_name
          and consumer_name = i_consumer_name
        for update;
    if not found then
        select 404, 'Unknown consumer: ' || i_consumer_name
            into ret_code, ret_note;
    elsif old_flag = i_paused then
        select 201, 'Consumer ' || i_consumer_name || ' already ' || word
            into ret_code, ret_note;
    else
        update pgq_node.local_state
            set paused = i_paused,
                uptodate = false
            where queue_name = i_queue_name
            and consumer_name = i_consumer_name;

        select 200, 'Consumer '||i_consumer_name||' tagged as '||word into ret_code, ret_note;
    end if;
    return;

end;
$$;


ALTER FUNCTION pgq_node.set_consumer_paused(i_queue_name text, i_consumer_name text, i_paused boolean, OUT ret_code integer, OUT ret_note text) OWNER TO cdr;

--
-- TOC entry 399 (class 1255 OID 16941)
-- Name: set_consumer_uptodate(text, text, boolean); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION set_consumer_uptodate(i_queue_name text, i_consumer_name text, i_uptodate boolean, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.set_consumer_uptodate(3)
--
--      Set consumer uptodate flag.....
--
-- Parameters:
--      i_queue_name - queue name
--      i_consumer_name - consumer name
--      i_uptodate - new flag state
--
-- Returns:
--      200 - ok
--      404 - consumer not known
-- ----------------------------------------------------------------------
begin
    update pgq_node.local_state
       set uptodate = i_uptodate
     where queue_name = i_queue_name
       and consumer_name = i_consumer_name;
    if found then
        select 200, 'Consumer uptodate = ' || i_uptodate::int4::text
               into ret_code, ret_note;
    else
        select 404, 'Consumer not known: '
               || i_queue_name || '/' || i_consumer_name
          into ret_code, ret_note;
    end if;
    return;
end;
$$;


ALTER FUNCTION pgq_node.set_consumer_uptodate(i_queue_name text, i_consumer_name text, i_uptodate boolean, OUT ret_code integer, OUT ret_note text) OWNER TO cdr;

--
-- TOC entry 393 (class 1255 OID 16935)
-- Name: set_global_watermark(text, bigint); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION set_global_watermark(i_queue_name text, i_watermark bigint, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.set_global_watermark(2)
--
--      Move global watermark on branch/leaf, publish on root.
--
-- Parameters:
--      i_queue_name    - queue name
--      i_watermark     - global tick_id that is processed everywhere.
--                        NULL on root, then local wm is published.
-- ----------------------------------------------------------------------
declare
    this        record;
    _wm         bigint;
    wm_consumer text;
begin
    wm_consumer = '.global_watermark';

    select node_type, queue_name, worker_name into this
        from pgq_node.node_info
        where queue_name = i_queue_name
        for update;
    if not found then
        select 404, 'Queue' || i_queue_name || ' not found'
          into ret_code, ret_note;
        return;
    end if;

    _wm = i_watermark;
    if this.node_type = 'root' then
        if i_watermark is null then
            select f.ret_code, f.ret_note, f.local_watermark
                into ret_code, ret_note, _wm
                from pgq_node.get_node_info(i_queue_name) f;
            if ret_code >= 300 then
                return;
            end if;
            if _wm is null then
                raise exception 'local_watermark=NULL from get_node_info()?';
            end if;
        end if;

        -- move watermark
        perform pgq.register_consumer_at(i_queue_name, wm_consumer, _wm);

        -- send event downstream
        perform pgq.insert_event(i_queue_name, 'pgq.global-watermark', _wm::text,
                                 i_queue_name, null, null, null);
        -- update root workers pos to avoid it getting stale
        update pgq_node.local_state
            set last_tick_id = _wm
            where queue_name = i_queue_name
                and consumer_name = this.worker_name;
    elsif this.node_type = 'branch' then
        if i_watermark is null then
            select 500, 'bad usage: wm=null on branch node'
                into ret_code, ret_note;
            return;
        end if;

        -- tick can be missing if we are processing
        -- old batches that set watermark outside
        -- current range
        perform 1 from pgq.tick t, pgq.queue q
          where q.queue_name = i_queue_name
            and t.tick_queue = q.queue_id
            and t.tick_id = _wm;
        if not found then
            select 200, 'Skipping global watermark update to ' || _wm::text
                into ret_code, ret_note;
            return;
        end if;

        -- move watermark
        perform pgq.register_consumer_at(i_queue_name, wm_consumer, _wm);
    else
        select 100, 'Ignoring global watermark in leaf'
            into ret_code, ret_note;
        return;
    end if;

    select 200, 'Global watermark set to ' || _wm::text
        into ret_code, ret_note;
    return;
end;
$$;


ALTER FUNCTION pgq_node.set_global_watermark(i_queue_name text, i_watermark bigint, OUT ret_code integer, OUT ret_note text) OWNER TO cdr;

--
-- TOC entry 387 (class 1255 OID 16930)
-- Name: set_node_attrs(text, text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION set_node_attrs(i_queue_name text, i_node_attrs text, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.create_attrs(2)
--
--      Set node attributes.
--
-- Parameters:
--      i_node_name - cascaded queue name
--      i_node_attrs - urlencoded node attrs
--
-- Returns:
--      200 - ok
--      404 - node not found
-- ----------------------------------------------------------------------
begin
    update pgq_node.node_info
        set node_attrs = i_node_attrs
        where queue_name = i_queue_name;
    if not found then
        select 404, 'Node not found' into ret_code, ret_note;
        return;
    end if;

    select 200, 'Node attributes updated'
        into ret_code, ret_note;
    return;
end;
$$;


ALTER FUNCTION pgq_node.set_node_attrs(i_queue_name text, i_node_attrs text, OUT ret_code integer, OUT ret_note text) OWNER TO cdr;

--
-- TOC entry 394 (class 1255 OID 16936)
-- Name: set_partition_watermark(text, text, bigint); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION set_partition_watermark(i_combined_queue_name text, i_part_queue_name text, i_watermark bigint, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.set_partition_watermark(3)
--
--      Move merge-leaf position on combined-branch.
--
-- Parameters:
--      i_combined_queue_name - local combined queue name
--      i_part_queue_name     - local part queue name (merge-leaf)
--      i_watermark         - partition tick_id that came inside combined-root batch
--
-- Returns:
--      200 - success
--      201 - no partition queue
--      401 - worker registration not found
-- ----------------------------------------------------------------------
declare
    n record;
begin
    -- check if combined-branch exists
    select c.node_type, p.worker_name into n
        from pgq_node.node_info c, pgq_node.node_info p
        where p.queue_name = i_part_queue_name
          and c.queue_name = i_combined_queue_name
          and p.combined_queue = c.queue_name
          and p.node_type = 'leaf'
          and c.node_type = 'branch';
    if not found then
        select 201, 'Part-queue does not exist' into ret_code, ret_note;
        return;
    end if;

    update pgq_node.local_state
       set last_tick_id = i_watermark
     where queue_name = i_part_queue_name
       and consumer_name = n.worker_name;
    if not found then
        select 401, 'Worker registration not found' into ret_code, ret_note;
        return;
    end if;

    select 200, 'Ok' into ret_code, ret_note;
    return;
end;
$$;


ALTER FUNCTION pgq_node.set_partition_watermark(i_combined_queue_name text, i_part_queue_name text, i_watermark bigint, OUT ret_code integer, OUT ret_note text) OWNER TO cdr;

--
-- TOC entry 390 (class 1255 OID 16933)
-- Name: set_subscriber_watermark(text, text, bigint); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION set_subscriber_watermark(i_queue_name text, i_node_name text, i_watermark bigint, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.set_subscriber_watermark(3)
--
--      Notify provider about subscribers lowest watermark.
--
--      Called on provider at interval by each worker  
--
-- Parameters:
--      i_queue_name - cascaded queue name
--      i_node_name - subscriber node name
--      i_watermark - tick_id
--
-- Returns:
--      ret_code    - error code
--      ret_note    - description
-- ----------------------------------------------------------------------
declare
    n       record;
    wm_name text;
begin
    wm_name := '.' || i_node_name || '.watermark';
    select * into n from pgq.get_consumer_info(i_queue_name, wm_name);
    if not found then
        select 404, 'node '||i_node_name||' not subscribed to queue ', i_queue_name
            into ret_code, ret_note;
        return;
    end if;

    -- todo: check if wm sane?
    if i_watermark < n.last_tick then
        select 405, 'watermark must not be moved backwards'
            into ret_code, ret_note;
        return;
    elsif i_watermark = n.last_tick then
        select 100, 'watermark already set'
            into ret_code, ret_note;
        return;
    end if;

    perform pgq.register_consumer_at(i_queue_name, wm_name, i_watermark);

    select 200, wm_name || ' set to ' || i_watermark::text
        into ret_code, ret_note;
    return;
end;
$$;


ALTER FUNCTION pgq_node.set_subscriber_watermark(i_queue_name text, i_node_name text, i_watermark bigint, OUT ret_code integer, OUT ret_note text) OWNER TO cdr;

--
-- TOC entry 396 (class 1255 OID 16938)
-- Name: unregister_consumer(text, text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION unregister_consumer(i_queue_name text, i_consumer_name text, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.unregister_consumer(2)
--
--      Unregister cascaded consumer from local node.
--
-- Parameters:
--      i_queue_name - cascaded queue name
--      i_consumer_name - cascaded consumer name
--
-- Returns:
--      ret_code - error code
--      200 - ok
--      404 - no such queue
--      ret_note - description
-- ----------------------------------------------------------------------
begin
    perform 1 from pgq_node.node_info where queue_name = i_queue_name
       for update;
    if not found then
        select 404, 'Unknown queue: ' || i_queue_name into ret_code, ret_note;
        return;
    end if;

    delete from pgq_node.local_state
      where queue_name = i_queue_name
        and consumer_name = i_consumer_name;

    select 200, 'Consumer '||i_consumer_name||' unregistered from '||i_queue_name
        into ret_code, ret_note;
    return;
end;
$$;


ALTER FUNCTION pgq_node.unregister_consumer(i_queue_name text, i_consumer_name text, OUT ret_code integer, OUT ret_note text) OWNER TO cdr;

--
-- TOC entry 312 (class 1255 OID 16919)
-- Name: unregister_location(text, text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION unregister_location(i_queue_name text, i_node_name text, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.unregister_location(2)
--
--      Drop unreferenced node.
--
-- Parameters:
--      i_queue_name - queue name
--      i_node_name - node to drop
--
-- Returns:
--      ret_code - error code
--      ret_note - error description
--
-- Return Codes:
--      200 - Ok
--      301 - Location not found
--      403 - Cannot drop nodes own or parent location
-- ----------------------------------------------------------------------
declare
    _queue_name  text;
    _wm_consumer text;
    _global_wm   bigint;
    sub          record;
    node         record;
begin
    select n.node_name, n.node_type, s.provider_node
        into node
        from pgq_node.node_info n
        left join pgq_node.local_state s
        on (s.consumer_name = n.worker_name
            and s.queue_name = n.queue_name)
        where n.queue_name = i_queue_name;
    if found then
        if node.node_name = i_node_name then
            select 403, 'Cannot drop nodes own location' into ret_code, ret_note;
            return;
        end if;
        if node.provider_node = i_node_name then
            select 403, 'Cannot drop location of nodes parent' into ret_code, ret_note;
            return;
        end if;
    end if;

    --
    -- There may be obsolete subscriptions around
    -- drop them silently.
    --
    perform pgq_node.unregister_subscriber(i_queue_name, i_node_name);

    --
    -- Actual removal
    --
    delete from pgq_node.node_location
     where queue_name = i_queue_name
       and node_name = i_node_name;

    if found then
        select 200, 'Ok' into ret_code, ret_note;
    else
        select 301, 'Location not found: ' || i_queue_name || '/' || i_node_name
          into ret_code, ret_note;
    end if;

    if node.node_type = 'root' then
        perform pgq.insert_event(i_queue_name, 'pgq.unregister-location',
                                 i_node_name, i_queue_name, null, null, null)
           from pgq_node.node_info n
         where n.queue_name = i_queue_name;
    end if;

    return;
end;
$$;


ALTER FUNCTION pgq_node.unregister_location(i_queue_name text, i_node_name text, OUT ret_code integer, OUT ret_note text) OWNER TO cdr;

--
-- TOC entry 389 (class 1255 OID 16932)
-- Name: unregister_subscriber(text, text); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION unregister_subscriber(i_queue_name text, i_remote_node_name text, OUT ret_code integer, OUT ret_note text) RETURNS record
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.unregister_subscriber(2)
--
--      Unsubscribe remote node from local node.
--
-- Parameters:
--      i_queue_name - set name
--      i_remote_node_name - node name
--
-- Returns:
--      ret_code - error code
--      ret_note - description
-- ----------------------------------------------------------------------
declare
    n_wm_name text;
    worker_name text;
begin
    n_wm_name := '.' || i_remote_node_name || '.watermark';
    select s.worker_name into worker_name from pgq_node.subscriber_info s
        where queue_name = i_queue_name and subscriber_node = i_remote_node_name;
    if not found then
        select 304, 'Subscriber not found' into ret_code, ret_note;
        return;
    end if;

    perform pgq.unregister_consumer(i_queue_name, n_wm_name);
    perform pgq.unregister_consumer(i_queue_name, worker_name);

    delete from pgq_node.subscriber_info
        where queue_name = i_queue_name
            and subscriber_node = i_remote_node_name;

    select 200, 'Subscriber unregistered: '||i_remote_node_name
        into ret_code, ret_note;
    return;
end;
$$;


ALTER FUNCTION pgq_node.unregister_subscriber(i_queue_name text, i_remote_node_name text, OUT ret_code integer, OUT ret_note text) OWNER TO cdr;

--
-- TOC entry 310 (class 1255 OID 16917)
-- Name: upgrade_schema(); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION upgrade_schema() RETURNS integer
    LANGUAGE plpgsql
    AS $$
-- updates table structure if necessary
declare
    cnt int4 = 0;
begin
    -- node_info.node_attrs
    perform 1 from information_schema.columns
      where table_schema = 'pgq_node'
        and table_name = 'node_info'
        and column_name = 'node_attrs';
    if not found then
        alter table pgq_node.node_info add column node_attrs text;
        cnt := cnt + 1;
    end if;

    return cnt;
end;
$$;


ALTER FUNCTION pgq_node.upgrade_schema() OWNER TO cdr;

--
-- TOC entry 397 (class 1255 OID 16946)
-- Name: version(); Type: FUNCTION; Schema: pgq_node; Owner: cdr
--

CREATE FUNCTION version() RETURNS text
    LANGUAGE plpgsql
    AS $$
-- ----------------------------------------------------------------------
-- Function: pgq_node.version(0)
--
--      Returns version string for pgq_node.  ATM it is based on SkyTools version
--      and only bumped when database code changes.
-- ----------------------------------------------------------------------
begin
    return '3.1.3';
end;
$$;


ALTER FUNCTION pgq_node.version() OWNER TO cdr;

SET search_path = reports, pg_catalog;

--
-- TOC entry 426 (class 1255 OID 19995)
-- Name: cdr_custom_report(integer); Type: FUNCTION; Schema: reports; Owner: cdr
--

CREATE FUNCTION cdr_custom_report(i_id integer) RETURNS integer
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    v_rid integer;
    v_sql varchar;
    v_keys varchar:='';
    v_i integer:=0;
    v_field varchar;
    v_filter varchar;
    i_date_start timestamptz;
    i_date_end timestamptz;
    i_filter varchar;
    i_group_by varchar;
BEGIN
    --INSERT INTO reports.cdr_custom_report(created_at,date_start,date_end,filter,group_by)
      --  values(now(),i_date_start,i_date_end,i_filter,i_group_by) RETURNING id INTO v_rid;
    select into v_rid,i_date_start,i_date_end,i_filter,i_group_by id,date_start,date_end,filter,group_by from reports.cdr_custom_report where id=i_id;

    raise warning 'REPORT: % - % - % - % - % ',v_rid,i_date_start,i_date_end,i_filter,i_group_by ;
    
    For v_field in select * from regexp_split_to_table(i_group_by,',') LOOP
        v_i:=v_i+1;
        --IF regexp_match(v_field','w');
        v_keys:=v_keys||'key'||v_i::varchar||',';
    end loop;
    
    v_filter=COALESCE('AND '||NULLIF(i_filter,''),'');
    
    v_sql:='
        INSERT INTO cdr_custom_report_data(
        report_id,
        '||i_group_by||',
        agg_calls_count,
        agg_calls_duration,
        agg_customer_price,
        agg_vendor_price,
        agg_profit,
        agg_asr_origination,
        agg_asr_termination,
        agg_calls_acd) 
        SELECT '||v_rid::varchar||','||i_group_by::varchar||',
        count(id),
        sum(duration),
        sum(customer_price),
        sum(vendor_price),
        sum(profit),
        count(nullif(success AND is_last_cdr,false))::float/nullif(count(nullif(is_last_cdr,false)),0)::float,
        count(nullif(success,false))::float/nullif(count(id),0)::float,
        sum(duration)::float/nullif(count(nullif(success,false)),0)::float
            from cdr.cdr
            WHERE 
                time_start>='''||i_date_start::varchar||'''
                AND time_start<'''||i_date_end::varchar||''' '||v_filter||'
            GROUP BY '||i_group_by;
            
    RAISE WARNING 'SQL: %',v_sql;
    EXECUTE v_sql;
    RETURN v_rid;

END;
$$;


ALTER FUNCTION reports.cdr_custom_report(i_id integer) OWNER TO cdr;

--
-- TOC entry 425 (class 1255 OID 20010)
-- Name: cdr_interval_report(integer); Type: FUNCTION; Schema: reports; Owner: cdr
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


ALTER FUNCTION reports.cdr_interval_report(i_id integer) OWNER TO cdr;

--
-- TOC entry 424 (class 1255 OID 20011)
-- Name: customer_traffic_report(integer); Type: FUNCTION; Schema: reports; Owner: cdr
--

CREATE FUNCTION customer_traffic_report(i_id integer) RETURNS integer
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    v_rid integer;
    v_sql varchar;
    v_keys varchar:='';
    v_i integer:=0;
    v_field varchar;
    v_filter varchar;

    i_date_start timestamp without time zone;
    i_date_end timestamp without time zone;
    i_customer_id integer;

    
BEGIN
/*
    INSERT INTO reports.customer_traffic_report(created_at,c)
        values(now(),i_date_start,i_date_end,i_customer_id) RETURNING id INTO v_rid;
*/

    select into v_rid,i_date_start,i_date_end,i_customer_id 
        id,date_start,date_end,customer_id 
        from reports.customer_traffic_report where id=i_id;
    
    v_sql:='
        INSERT INTO reports.customer_traffic_report_data(report_id,vendor_id,calls_count,short_calls_count,success_calls_count,calls_duration,acd,asr,
        origination_cost,termination_cost,profit,first_call_at,last_call_at)
            SELECT '||v_rid::varchar||',vendor_id,
            count(id),
            count(nullif(duration>32,false)),
            count(nullif(success,false)),
            sum(duration),
            sum(duration)::float/nullif(count(nullif(success,false)),0)::float,
            count(nullif(success,false))::float/nullif(count(id),0)::float,
            sum(customer_price),sum(vendor_price),sum(profit),
            min(time_start),
            max(time_start)
            from cdr.cdr
            WHERE
                time_start>='''||i_date_start::varchar||'''
                AND time_start<'''||i_date_end::varchar||'''
                AND customer_id='''||i_customer_id||'''
            GROUP BY vendor_id';
    RAISE WARNING 'SQL: %',v_sql;
    EXECUTE v_sql;
    RETURN v_rid;

END;
$$;


ALTER FUNCTION reports.customer_traffic_report(i_id integer) OWNER TO cdr;

--
-- TOC entry 427 (class 1255 OID 20012)
-- Name: vendor_traffic_report(integer); Type: FUNCTION; Schema: reports; Owner: cdr
--

CREATE FUNCTION vendor_traffic_report(i_id integer) RETURNS integer
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    v_rid integer;
    v_sql varchar;
    v_keys varchar:='';
    v_i integer:=0;
    v_field varchar;
    v_filter varchar;

    i_date_start timestamp without time zone;
    i_date_end timestamp without time zone;
    i_vendor_id integer;
    
BEGIN
/*
    INSERT INTO reports.vendor_traffic_report(created_at,date_start,date_end,vendor_id)
        values(now(),i_date_start,i_date_end,i_vendor_id) RETURNING id INTO v_rid;
*/
    select into v_rid,i_date_start,i_date_end,i_vendor_id 
        id,date_start,date_end,vendor_id
        from reports.vendor_traffic_report where id=i_id;
        
    v_sql:='
        INSERT INTO reports.vendor_traffic_report_data(report_id,customer_id,calls_count,short_calls_count,success_calls_count,calls_duration,acd,asr,
        origination_cost,termination_cost,profit,first_call_at,last_call_at)
            SELECT '||v_rid::varchar||',customer_id,
            count(id),
            count(nullif(duration>32,false)),
            count(nullif(success,false)),
            sum(duration),
            sum(duration)::float/nullif(count(nullif(success,false)),0)::float,
            count(nullif(success,false))::float/nullif(count(id),0)::float,
            sum(customer_price),sum(vendor_price),sum(profit),
            min(time_start),
            max(time_start)
            from cdr.cdr
            WHERE
                time_start>='''||i_date_start::varchar||'''
                AND time_start<'''||i_date_end::varchar||'''
                AND vendor_id='''||i_vendor_id||'''
            GROUP BY customer_id';
    RAISE WARNING 'SQL: %',v_sql;
    EXECUTE v_sql;
    RETURN v_rid;

END;
$$;


ALTER FUNCTION reports.vendor_traffic_report(i_id integer) OWNER TO cdr;

SET search_path = stats, pg_catalog;

--
-- TOC entry 420 (class 1255 OID 18662)
-- Name: update_rt_stats(cdr.cdr); Type: FUNCTION; Schema: stats; Owner: cdr
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

    insert into stats.termination_quality_stats(dialpeer_id,gateway_id,time_start,success,duration,pdd,early_media_present)
        values(i_cdr.dialpeer_id, i_cdr.term_gw_id, i_cdr.time_start, i_cdr.success, i_cdr.duration, i_cdr.pdd, i_cdr.early_media_present);
    

    RETURN ;
END;
$$;


ALTER FUNCTION stats.update_rt_stats(i_cdr cdr.cdr) OWNER TO cdr;

SET search_path = switch, pg_catalog;

--
-- TOC entry 421 (class 1255 OID 19960)
-- Name: round(double precision); Type: FUNCTION; Schema: switch; Owner: cdr
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


ALTER FUNCTION switch.round(i_duration double precision) OWNER TO cdr;

--
-- TOC entry 429 (class 1255 OID 20242)
-- Name: writecdr(boolean, integer, integer, integer, boolean, character varying, integer, character varying, integer, character varying, integer, character varying, integer, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, integer, json, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, inet, integer, integer, integer, character varying, character varying, integer, character varying, smallint); Type: FUNCTION; Schema: switch; Owner: cdr
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


ALTER FUNCTION switch.writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id integer, i_rtp_stats_data json, i_global_tag character varying, i_customer_id character varying, i_vendor_id character varying, i_customer_acc_id character varying, i_vendor_acc_id character varying, i_customer_auth_id character varying, i_destination_id character varying, i_destination_prefix character varying, i_dialpeer_id character varying, i_dialpeer_prefix character varying, i_orig_gw_id character varying, i_term_gw_id character varying, i_routing_group_id character varying, i_rateplan_id character varying, i_destination_initial_rate character varying, i_destination_next_rate character varying, i_destination_initial_interval integer, i_destination_next_interval integer, i_destination_rate_policy_id integer, i_dialpeer_initial_interval integer, i_dialpeer_next_interval integer, i_dialpeer_next_rate character varying, i_destination_fee character varying, i_dialpeer_initial_rate character varying, i_dialpeer_fee character varying, i_dst_prefix_in character varying, i_dst_prefix_out character varying, i_src_prefix_in character varying, i_src_prefix_out character varying, i_src_name_in character varying, i_src_name_out character varying, i_diversion_in character varying, i_diversion_out character varying, i_auth_orig_ip inet, i_auth_orig_port integer, i_dst_country_id integer, i_dst_network_id integer, i_dst_prefix_routing character varying, i_src_prefix_routing character varying, i_routing_plan_id integer, i_lrn character varying, i_lnp_database_id smallint) OWNER TO cdr;

SET search_path = sys, pg_catalog;

--
-- TOC entry 422 (class 1255 OID 17059)
-- Name: cdr_createtable(integer); Type: FUNCTION; Schema: sys; Owner: cdr
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


ALTER FUNCTION sys.cdr_createtable(i_offset integer) OWNER TO cdr;

--
-- TOC entry 414 (class 1255 OID 17060)
-- Name: cdr_drop_table(character varying); Type: FUNCTION; Schema: sys; Owner: cdr
--

CREATE FUNCTION cdr_drop_table(i_tbname character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
v_t record;
BEGIN
    SELECT INTO v_t * from sys.cdr_tables WHERE "name"=i_tbname;
    IF FOUND THEN
        if v_t.writable THEN
            RAISE EXCEPTION 'sys.cdr_drop_table: table used, cant drop.';
        ELSE
            EXECUTE 'DROP TABLE '||v_t.name;
            DELETE FROM sys.cdr_tables where id=v_t.id;
            PERFORM cdrtable_tgr_reload();
        END IF;
    END IF;
END;
$$;


ALTER FUNCTION sys.cdr_drop_table(i_tbname character varying) OWNER TO cdr;

--
-- TOC entry 415 (class 1255 OID 17061)
-- Name: cdr_export_data(character varying); Type: FUNCTION; Schema: sys; Owner: cdr
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


ALTER FUNCTION sys.cdr_export_data(i_tbname character varying) OWNER TO cdr;

--
-- TOC entry 416 (class 1255 OID 17062)
-- Name: cdr_export_data(character varying, character varying); Type: FUNCTION; Schema: sys; Owner: cdr
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


ALTER FUNCTION sys.cdr_export_data(i_tbname character varying, i_dir character varying) OWNER TO cdr;

--
-- TOC entry 419 (class 1255 OID 17099)
-- Name: cdr_reindex(character varying, character varying); Type: FUNCTION; Schema: sys; Owner: cdr
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


ALTER FUNCTION sys.cdr_reindex(i_schema character varying, i_tbname character varying) OWNER TO cdr;

--
-- TOC entry 423 (class 1255 OID 17064)
-- Name: cdrtable_tgr_reload(); Type: FUNCTION; Schema: sys; Owner: cdr
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


ALTER FUNCTION sys.cdrtable_tgr_reload() OWNER TO cdr;

SET search_path = billing, pg_catalog;

--
-- TOC entry 266 (class 1259 OID 19737)
-- Name: invoice_destinations; Type: TABLE; Schema: billing; Owner: cdr; Tablespace: 
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


ALTER TABLE billing.invoice_destinations OWNER TO cdr;

--
-- TOC entry 265 (class 1259 OID 19735)
-- Name: invoice_destinations_id_seq; Type: SEQUENCE; Schema: billing; Owner: cdr
--

CREATE SEQUENCE invoice_destinations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE billing.invoice_destinations_id_seq OWNER TO cdr;

--
-- TOC entry 2822 (class 0 OID 0)
-- Dependencies: 265
-- Name: invoice_destinations_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: cdr
--

ALTER SEQUENCE invoice_destinations_id_seq OWNED BY invoice_destinations.id;


--
-- TOC entry 268 (class 1259 OID 19780)
-- Name: invoice_documents; Type: TABLE; Schema: billing; Owner: cdr; Tablespace: 
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


ALTER TABLE billing.invoice_documents OWNER TO cdr;

--
-- TOC entry 267 (class 1259 OID 19778)
-- Name: invoice_documents_id_seq; Type: SEQUENCE; Schema: billing; Owner: cdr
--

CREATE SEQUENCE invoice_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE billing.invoice_documents_id_seq OWNER TO cdr;

--
-- TOC entry 2823 (class 0 OID 0)
-- Dependencies: 267
-- Name: invoice_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: cdr
--

ALTER SEQUENCE invoice_documents_id_seq OWNED BY invoice_documents.id;


--
-- TOC entry 287 (class 1259 OID 20269)
-- Name: invoice_states; Type: TABLE; Schema: billing; Owner: cdr; Tablespace: 
--

CREATE TABLE invoice_states (
    id smallint NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE billing.invoice_states OWNER TO cdr;

--
-- TOC entry 292 (class 1259 OID 28558)
-- Name: invoice_types; Type: TABLE; Schema: billing; Owner: cdr; Tablespace: 
--

CREATE TABLE invoice_types (
    id smallint NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE billing.invoice_types OWNER TO cdr;

--
-- TOC entry 231 (class 1259 OID 18130)
-- Name: invoices; Type: TABLE; Schema: billing; Owner: cdr; Tablespace: 
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


ALTER TABLE billing.invoices OWNER TO cdr;

--
-- TOC entry 230 (class 1259 OID 18128)
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: billing; Owner: cdr
--

CREATE SEQUENCE invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE billing.invoices_id_seq OWNER TO cdr;

--
-- TOC entry 2824 (class 0 OID 0)
-- Dependencies: 230
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: cdr
--

ALTER SEQUENCE invoices_id_seq OWNED BY invoices.id;


SET search_path = cdr, pg_catalog;

--
-- TOC entry 232 (class 1259 OID 18250)
-- Name: cdr_archive; Type: TABLE; Schema: cdr; Owner: cdr; Tablespace: 
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
    routing_delay real,
    pdd real,
    rtt real,
    early_media_present boolean,
    lnp_database_id smallint,
    lrn character varying,
    destination_prefix character varying,
    dialpeer_prefix character varying,
    routing_plan_id integer
);


ALTER TABLE cdr.cdr_archive OWNER TO cdr;

--
-- TOC entry 200 (class 1259 OID 17023)
-- Name: cdr_id_seq; Type: SEQUENCE; Schema: cdr; Owner: cdr
--

CREATE SEQUENCE cdr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cdr.cdr_id_seq OWNER TO cdr;

--
-- TOC entry 2825 (class 0 OID 0)
-- Dependencies: 200
-- Name: cdr_id_seq; Type: SEQUENCE OWNED BY; Schema: cdr; Owner: cdr
--

ALTER SEQUENCE cdr_id_seq OWNED BY cdr.id;


--
-- TOC entry 229 (class 1259 OID 18108)
-- Name: cdr_201412; Type: TABLE; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE TABLE cdr_201412 (
    id bigint DEFAULT nextval('cdr_id_seq'::regclass) NOT NULL,
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
    routing_delay real,
    pdd real,
    rtt real,
    early_media_present boolean,
    lnp_database_id smallint,
    lrn character varying,
    destination_prefix character varying,
    dialpeer_prefix character varying,
    CONSTRAINT cdr_201412_time_start_check CHECK (((time_start >= '2014-12-01'::date) AND (time_start < '2015-01-01'::date)))
)
INHERITS (cdr_archive);


ALTER TABLE cdr.cdr_201412 OWNER TO cdr;

--
-- TOC entry 228 (class 1259 OID 18094)
-- Name: cdr_201501; Type: TABLE; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE TABLE cdr_201501 (
    CONSTRAINT cdr_201501_time_start_check CHECK (((time_start >= '2015-01-01'::date) AND (time_start < '2015-02-01'::date)))
)
INHERITS (cdr);


ALTER TABLE cdr.cdr_201501 OWNER TO cdr;

--
-- TOC entry 227 (class 1259 OID 18080)
-- Name: cdr_201502; Type: TABLE; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE TABLE cdr_201502 (
    CONSTRAINT cdr_201502_time_start_check CHECK (((time_start >= '2015-02-01'::date) AND (time_start < '2015-03-01'::date)))
)
INHERITS (cdr);


ALTER TABLE cdr.cdr_201502 OWNER TO cdr;

--
-- TOC entry 272 (class 1259 OID 19842)
-- Name: cdr_201503; Type: TABLE; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE TABLE cdr_201503 (
    CONSTRAINT cdr_201503_time_start_check CHECK (((time_start >= '2015-03-01 02:00:00+02'::timestamp with time zone) AND (time_start < '2015-04-01 03:00:00+03'::timestamp with time zone)))
)
INHERITS (cdr);


ALTER TABLE cdr.cdr_201503 OWNER TO cdr;

--
-- TOC entry 270 (class 1259 OID 19818)
-- Name: cdr_201504; Type: TABLE; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE TABLE cdr_201504 (
    CONSTRAINT cdr_201504_time_start_check CHECK (((time_start >= '2015-04-01 03:00:00+03'::timestamp with time zone) AND (time_start < '2015-05-01 03:00:00+03'::timestamp with time zone)))
)
INHERITS (cdr);


ALTER TABLE cdr.cdr_201504 OWNER TO cdr;

--
-- TOC entry 269 (class 1259 OID 19806)
-- Name: cdr_201505; Type: TABLE; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE TABLE cdr_201505 (
    CONSTRAINT cdr_201505_time_start_check CHECK (((time_start >= '2015-05-01 03:00:00+03'::timestamp with time zone) AND (time_start < '2015-06-01 03:00:00+03'::timestamp with time zone)))
)
INHERITS (cdr);


ALTER TABLE cdr.cdr_201505 OWNER TO cdr;

--
-- TOC entry 271 (class 1259 OID 19830)
-- Name: cdr_201506; Type: TABLE; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE TABLE cdr_201506 (
    CONSTRAINT cdr_201506_time_start_check CHECK (((time_start >= '2015-06-01 03:00:00+03'::timestamp with time zone) AND (time_start < '2015-07-01 03:00:00+03'::timestamp with time zone)))
)
INHERITS (cdr);


ALTER TABLE cdr.cdr_201506 OWNER TO cdr;

--
-- TOC entry 294 (class 1259 OID 28764)
-- Name: cdr_201507; Type: TABLE; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE TABLE cdr_201507 (
    CONSTRAINT cdr_201507_time_start_check CHECK (((time_start >= '2015-07-01 03:00:00+03'::timestamp with time zone) AND (time_start < '2015-08-01 03:00:00+03'::timestamp with time zone)))
)
INHERITS (cdr);


ALTER TABLE cdr.cdr_201507 OWNER TO cdr;

--
-- TOC entry 293 (class 1259 OID 28752)
-- Name: cdr_201508; Type: TABLE; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE TABLE cdr_201508 (
    CONSTRAINT cdr_201508_time_start_check CHECK (((time_start >= '2015-08-01 03:00:00+03'::timestamp with time zone) AND (time_start < '2015-09-01 03:00:00+03'::timestamp with time zone)))
)
INHERITS (cdr);


ALTER TABLE cdr.cdr_201508 OWNER TO cdr;

--
-- TOC entry 295 (class 1259 OID 28776)
-- Name: cdr_201509; Type: TABLE; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE TABLE cdr_201509 (
    CONSTRAINT cdr_201509_time_start_check CHECK (((time_start >= '2015-09-01 03:00:00+03'::timestamp with time zone) AND (time_start < '2015-10-01 03:00:00+03'::timestamp with time zone)))
)
INHERITS (cdr);


ALTER TABLE cdr.cdr_201509 OWNER TO cdr;

--
-- TOC entry 296 (class 1259 OID 28788)
-- Name: cdr_201510; Type: TABLE; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE TABLE cdr_201510 (
    CONSTRAINT cdr_201510_time_start_check CHECK (((time_start >= '2015-10-01 03:00:00+03'::timestamp with time zone) AND (time_start < '2015-11-01 02:00:00+02'::timestamp with time zone)))
)
INHERITS (cdr);


ALTER TABLE cdr.cdr_201510 OWNER TO cdr;

SET search_path = pgq, pg_catalog;

--
-- TOC entry 186 (class 1259 OID 16699)
-- Name: batch_id_seq; Type: SEQUENCE; Schema: pgq; Owner: cdr
--

CREATE SEQUENCE batch_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pgq.batch_id_seq OWNER TO cdr;

--
-- TOC entry 182 (class 1259 OID 16648)
-- Name: consumer; Type: TABLE; Schema: pgq; Owner: cdr; Tablespace: 
--

CREATE TABLE consumer (
    co_id integer NOT NULL,
    co_name text NOT NULL
);


ALTER TABLE pgq.consumer OWNER TO cdr;

--
-- TOC entry 181 (class 1259 OID 16646)
-- Name: consumer_co_id_seq; Type: SEQUENCE; Schema: pgq; Owner: cdr
--

CREATE SEQUENCE consumer_co_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pgq.consumer_co_id_seq OWNER TO cdr;

--
-- TOC entry 2827 (class 0 OID 0)
-- Dependencies: 181
-- Name: consumer_co_id_seq; Type: SEQUENCE OWNED BY; Schema: pgq; Owner: cdr
--

ALTER SEQUENCE consumer_co_id_seq OWNED BY consumer.co_id;


--
-- TOC entry 189 (class 1259 OID 16722)
-- Name: event_template; Type: TABLE; Schema: pgq; Owner: cdr; Tablespace: 
--

CREATE TABLE event_template (
    ev_id bigint NOT NULL,
    ev_time timestamp with time zone NOT NULL,
    ev_txid bigint DEFAULT txid_current() NOT NULL,
    ev_owner integer,
    ev_retry integer,
    ev_type text,
    ev_data text,
    ev_extra1 text,
    ev_extra2 text,
    ev_extra3 text,
    ev_extra4 text
);


ALTER TABLE pgq.event_template OWNER TO cdr;

--
-- TOC entry 209 (class 1259 OID 17485)
-- Name: event_3; Type: TABLE; Schema: pgq; Owner: cdr; Tablespace: 
--

CREATE TABLE event_3 (
)
INHERITS (event_template);


ALTER TABLE pgq.event_3 OWNER TO cdr;

--
-- TOC entry 210 (class 1259 OID 17492)
-- Name: event_3_0; Type: TABLE; Schema: pgq; Owner: cdr; Tablespace: 
--

CREATE TABLE event_3_0 (
)
INHERITS (event_3)
WITH (fillfactor=100, autovacuum_enabled=off, toast.autovacuum_enabled=off);


ALTER TABLE pgq.event_3_0 OWNER TO cdr;

--
-- TOC entry 211 (class 1259 OID 17501)
-- Name: event_3_1; Type: TABLE; Schema: pgq; Owner: cdr; Tablespace: 
--

CREATE TABLE event_3_1 (
)
INHERITS (event_3)
WITH (fillfactor=100, autovacuum_enabled=off, toast.autovacuum_enabled=off);


ALTER TABLE pgq.event_3_1 OWNER TO cdr;

--
-- TOC entry 212 (class 1259 OID 17510)
-- Name: event_3_2; Type: TABLE; Schema: pgq; Owner: cdr; Tablespace: 
--

CREATE TABLE event_3_2 (
)
INHERITS (event_3)
WITH (fillfactor=100, autovacuum_enabled=off, toast.autovacuum_enabled=off);


ALTER TABLE pgq.event_3_2 OWNER TO cdr;

--
-- TOC entry 208 (class 1259 OID 17483)
-- Name: event_3_id_seq; Type: SEQUENCE; Schema: pgq; Owner: cdr
--

CREATE SEQUENCE event_3_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pgq.event_3_id_seq OWNER TO cdr;

--
-- TOC entry 207 (class 1259 OID 17481)
-- Name: event_3_tick_seq; Type: SEQUENCE; Schema: pgq; Owner: cdr
--

CREATE SEQUENCE event_3_tick_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pgq.event_3_tick_seq OWNER TO cdr;

--
-- TOC entry 184 (class 1259 OID 16661)
-- Name: queue; Type: TABLE; Schema: pgq; Owner: cdr; Tablespace: 
--

CREATE TABLE queue (
    queue_id integer NOT NULL,
    queue_name text NOT NULL,
    queue_ntables integer DEFAULT 3 NOT NULL,
    queue_cur_table integer DEFAULT 0 NOT NULL,
    queue_rotation_period interval DEFAULT '02:00:00'::interval NOT NULL,
    queue_switch_step1 bigint DEFAULT txid_current() NOT NULL,
    queue_switch_step2 bigint DEFAULT txid_current(),
    queue_switch_time timestamp with time zone DEFAULT now() NOT NULL,
    queue_external_ticker boolean DEFAULT false NOT NULL,
    queue_disable_insert boolean DEFAULT false NOT NULL,
    queue_ticker_paused boolean DEFAULT false NOT NULL,
    queue_ticker_max_count integer DEFAULT 500 NOT NULL,
    queue_ticker_max_lag interval DEFAULT '00:00:03'::interval NOT NULL,
    queue_ticker_idle_period interval DEFAULT '00:01:00'::interval NOT NULL,
    queue_per_tx_limit integer,
    queue_data_pfx text NOT NULL,
    queue_event_seq text NOT NULL,
    queue_tick_seq text NOT NULL
);


ALTER TABLE pgq.queue OWNER TO cdr;

--
-- TOC entry 183 (class 1259 OID 16659)
-- Name: queue_queue_id_seq; Type: SEQUENCE; Schema: pgq; Owner: cdr
--

CREATE SEQUENCE queue_queue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pgq.queue_queue_id_seq OWNER TO cdr;

--
-- TOC entry 2836 (class 0 OID 0)
-- Dependencies: 183
-- Name: queue_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: pgq; Owner: cdr
--

ALTER SEQUENCE queue_queue_id_seq OWNED BY queue.queue_id;


--
-- TOC entry 190 (class 1259 OID 16729)
-- Name: retry_queue; Type: TABLE; Schema: pgq; Owner: cdr; Tablespace: 
--

CREATE TABLE retry_queue (
    ev_retry_after timestamp with time zone NOT NULL,
    ev_queue integer NOT NULL,
    ev_id bigint NOT NULL,
    ev_time timestamp with time zone NOT NULL,
    ev_txid bigint,
    ev_owner integer NOT NULL,
    ev_retry integer,
    ev_type text,
    ev_data text,
    ev_extra1 text,
    ev_extra2 text,
    ev_extra3 text,
    ev_extra4 text
);


ALTER TABLE pgq.retry_queue OWNER TO cdr;

--
-- TOC entry 188 (class 1259 OID 16703)
-- Name: subscription; Type: TABLE; Schema: pgq; Owner: cdr; Tablespace: 
--

CREATE TABLE subscription (
    sub_id integer NOT NULL,
    sub_queue integer NOT NULL,
    sub_consumer integer NOT NULL,
    sub_last_tick bigint,
    sub_active timestamp with time zone DEFAULT now() NOT NULL,
    sub_batch bigint,
    sub_next_tick bigint
);


ALTER TABLE pgq.subscription OWNER TO cdr;

--
-- TOC entry 187 (class 1259 OID 16701)
-- Name: subscription_sub_id_seq; Type: SEQUENCE; Schema: pgq; Owner: cdr
--

CREATE SEQUENCE subscription_sub_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pgq.subscription_sub_id_seq OWNER TO cdr;

--
-- TOC entry 2839 (class 0 OID 0)
-- Dependencies: 187
-- Name: subscription_sub_id_seq; Type: SEQUENCE OWNED BY; Schema: pgq; Owner: cdr
--

ALTER SEQUENCE subscription_sub_id_seq OWNED BY subscription.sub_id;


--
-- TOC entry 185 (class 1259 OID 16684)
-- Name: tick; Type: TABLE; Schema: pgq; Owner: cdr; Tablespace: 
--

CREATE TABLE tick (
    tick_queue integer NOT NULL,
    tick_id bigint NOT NULL,
    tick_time timestamp with time zone DEFAULT now() NOT NULL,
    tick_snapshot txid_snapshot DEFAULT txid_current_snapshot() NOT NULL,
    tick_event_seq bigint NOT NULL
);


ALTER TABLE pgq.tick OWNER TO cdr;

SET search_path = pgq_ext, pg_catalog;

--
-- TOC entry 192 (class 1259 OID 16807)
-- Name: completed_batch; Type: TABLE; Schema: pgq_ext; Owner: cdr; Tablespace: 
--

CREATE TABLE completed_batch (
    consumer_id text NOT NULL,
    subconsumer_id text DEFAULT ''::text NOT NULL,
    last_batch_id bigint NOT NULL
);


ALTER TABLE pgq_ext.completed_batch OWNER TO cdr;

--
-- TOC entry 193 (class 1259 OID 16815)
-- Name: completed_event; Type: TABLE; Schema: pgq_ext; Owner: cdr; Tablespace: 
--

CREATE TABLE completed_event (
    consumer_id text NOT NULL,
    subconsumer_id text DEFAULT ''::text NOT NULL,
    batch_id bigint NOT NULL,
    event_id bigint NOT NULL
);


ALTER TABLE pgq_ext.completed_event OWNER TO cdr;

--
-- TOC entry 191 (class 1259 OID 16799)
-- Name: completed_tick; Type: TABLE; Schema: pgq_ext; Owner: cdr; Tablespace: 
--

CREATE TABLE completed_tick (
    consumer_id text NOT NULL,
    subconsumer_id text DEFAULT ''::text NOT NULL,
    last_tick_id bigint NOT NULL
);


ALTER TABLE pgq_ext.completed_tick OWNER TO cdr;

--
-- TOC entry 194 (class 1259 OID 16823)
-- Name: partial_batch; Type: TABLE; Schema: pgq_ext; Owner: cdr; Tablespace: 
--

CREATE TABLE partial_batch (
    consumer_id text NOT NULL,
    subconsumer_id text DEFAULT ''::text NOT NULL,
    cur_batch_id bigint NOT NULL
);


ALTER TABLE pgq_ext.partial_batch OWNER TO cdr;

SET search_path = pgq_node, pg_catalog;

--
-- TOC entry 197 (class 1259 OID 16874)
-- Name: local_state; Type: TABLE; Schema: pgq_node; Owner: cdr; Tablespace: 
--

CREATE TABLE local_state (
    queue_name text NOT NULL,
    consumer_name text NOT NULL,
    provider_node text NOT NULL,
    last_tick_id bigint NOT NULL,
    cur_error text,
    paused boolean DEFAULT false NOT NULL,
    uptodate boolean DEFAULT false NOT NULL
);


ALTER TABLE pgq_node.local_state OWNER TO cdr;

--
-- TOC entry 196 (class 1259 OID 16859)
-- Name: node_info; Type: TABLE; Schema: pgq_node; Owner: cdr; Tablespace: 
--

CREATE TABLE node_info (
    queue_name text NOT NULL,
    node_type text NOT NULL,
    node_name text NOT NULL,
    worker_name text,
    combined_queue text,
    node_attrs text,
    CONSTRAINT node_info_check CHECK (
CASE
    WHEN (node_type = 'root'::text) THEN ((worker_name IS NOT NULL) AND (combined_queue IS NULL))
    WHEN (node_type = 'branch'::text) THEN ((worker_name IS NOT NULL) AND (combined_queue IS NULL))
    WHEN (node_type = 'leaf'::text) THEN (worker_name IS NOT NULL)
    ELSE false
END),
    CONSTRAINT node_info_node_type_check CHECK ((node_type = ANY (ARRAY['root'::text, 'branch'::text, 'leaf'::text])))
);


ALTER TABLE pgq_node.node_info OWNER TO cdr;

--
-- TOC entry 195 (class 1259 OID 16850)
-- Name: node_location; Type: TABLE; Schema: pgq_node; Owner: cdr; Tablespace: 
--

CREATE TABLE node_location (
    queue_name text NOT NULL,
    node_name text NOT NULL,
    node_location text NOT NULL,
    dead boolean DEFAULT false NOT NULL
);


ALTER TABLE pgq_node.node_location OWNER TO cdr;

--
-- TOC entry 198 (class 1259 OID 16894)
-- Name: subscriber_info; Type: TABLE; Schema: pgq_node; Owner: cdr; Tablespace: 
--

CREATE TABLE subscriber_info (
    queue_name text NOT NULL,
    subscriber_node text NOT NULL,
    worker_name text NOT NULL,
    watermark_name text NOT NULL
);


ALTER TABLE pgq_node.subscriber_info OWNER TO cdr;

SET search_path = reports, pg_catalog;

--
-- TOC entry 213 (class 1259 OID 17803)
-- Name: cdr_custom_report; Type: TABLE; Schema: reports; Owner: cdr; Tablespace: 
--

CREATE TABLE cdr_custom_report (
    id integer NOT NULL,
    date_start timestamp with time zone,
    date_end timestamp with time zone,
    filter character varying,
    group_by character varying,
    created_at timestamp with time zone
);


ALTER TABLE reports.cdr_custom_report OWNER TO cdr;

--
-- TOC entry 214 (class 1259 OID 17809)
-- Name: cdr_custom_report_data; Type: TABLE; Schema: reports; Owner: cdr; Tablespace: 
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


ALTER TABLE reports.cdr_custom_report_data OWNER TO cdr;

--
-- TOC entry 215 (class 1259 OID 17815)
-- Name: cdr_custom_report_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: cdr
--

CREATE SEQUENCE cdr_custom_report_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reports.cdr_custom_report_data_id_seq OWNER TO cdr;

--
-- TOC entry 2841 (class 0 OID 0)
-- Dependencies: 215
-- Name: cdr_custom_report_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: cdr
--

ALTER SEQUENCE cdr_custom_report_data_id_seq OWNED BY cdr_custom_report_data.id;


--
-- TOC entry 216 (class 1259 OID 17817)
-- Name: cdr_custom_report_id_seq; Type: SEQUENCE; Schema: reports; Owner: cdr
--

CREATE SEQUENCE cdr_custom_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reports.cdr_custom_report_id_seq OWNER TO cdr;

--
-- TOC entry 2842 (class 0 OID 0)
-- Dependencies: 216
-- Name: cdr_custom_report_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: cdr
--

ALTER SEQUENCE cdr_custom_report_id_seq OWNED BY cdr_custom_report.id;


--
-- TOC entry 281 (class 1259 OID 20122)
-- Name: cdr_custom_report_schedulers; Type: TABLE; Schema: reports; Owner: cdr; Tablespace: 
--

CREATE TABLE cdr_custom_report_schedulers (
    id integer NOT NULL,
    created_at timestamp with time zone,
    period_id integer NOT NULL,
    filter character varying,
    group_by character varying[],
    send_to integer[],
    last_run_at timestamp with time zone,
    next_run_at timestamp with time zone
);


ALTER TABLE reports.cdr_custom_report_schedulers OWNER TO cdr;

--
-- TOC entry 280 (class 1259 OID 20120)
-- Name: cdr_custom_report_schedulers_id_seq; Type: SEQUENCE; Schema: reports; Owner: cdr
--

CREATE SEQUENCE cdr_custom_report_schedulers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reports.cdr_custom_report_schedulers_id_seq OWNER TO cdr;

--
-- TOC entry 2843 (class 0 OID 0)
-- Dependencies: 280
-- Name: cdr_custom_report_schedulers_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: cdr
--

ALTER SEQUENCE cdr_custom_report_schedulers_id_seq OWNED BY cdr_custom_report_schedulers.id;


--
-- TOC entry 217 (class 1259 OID 17819)
-- Name: cdr_interval_report; Type: TABLE; Schema: reports; Owner: cdr; Tablespace: 
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


ALTER TABLE reports.cdr_interval_report OWNER TO cdr;

--
-- TOC entry 218 (class 1259 OID 17825)
-- Name: cdr_interval_report_aggrerator; Type: TABLE; Schema: reports; Owner: cdr; Tablespace: 
--

CREATE TABLE cdr_interval_report_aggrerator (
    id integer NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE reports.cdr_interval_report_aggrerator OWNER TO cdr;

--
-- TOC entry 219 (class 1259 OID 17831)
-- Name: cdr_interval_report_data; Type: TABLE; Schema: reports; Owner: cdr; Tablespace: 
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


ALTER TABLE reports.cdr_interval_report_data OWNER TO cdr;

--
-- TOC entry 220 (class 1259 OID 17837)
-- Name: cdr_interval_report_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: cdr
--

CREATE SEQUENCE cdr_interval_report_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reports.cdr_interval_report_data_id_seq OWNER TO cdr;

--
-- TOC entry 2844 (class 0 OID 0)
-- Dependencies: 220
-- Name: cdr_interval_report_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: cdr
--

ALTER SEQUENCE cdr_interval_report_data_id_seq OWNED BY cdr_interval_report_data.id;


--
-- TOC entry 221 (class 1259 OID 17839)
-- Name: cdr_interval_report_id_seq; Type: SEQUENCE; Schema: reports; Owner: cdr
--

CREATE SEQUENCE cdr_interval_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reports.cdr_interval_report_id_seq OWNER TO cdr;

--
-- TOC entry 2845 (class 0 OID 0)
-- Dependencies: 221
-- Name: cdr_interval_report_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: cdr
--

ALTER SEQUENCE cdr_interval_report_id_seq OWNED BY cdr_interval_report.id;


--
-- TOC entry 283 (class 1259 OID 20138)
-- Name: cdr_interval_report_schedulers; Type: TABLE; Schema: reports; Owner: cdr; Tablespace: 
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


ALTER TABLE reports.cdr_interval_report_schedulers OWNER TO cdr;

--
-- TOC entry 282 (class 1259 OID 20136)
-- Name: cdr_interval_report_schedulers_id_seq; Type: SEQUENCE; Schema: reports; Owner: cdr
--

CREATE SEQUENCE cdr_interval_report_schedulers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reports.cdr_interval_report_schedulers_id_seq OWNER TO cdr;

--
-- TOC entry 2846 (class 0 OID 0)
-- Dependencies: 282
-- Name: cdr_interval_report_schedulers_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: cdr
--

ALTER SEQUENCE cdr_interval_report_schedulers_id_seq OWNED BY cdr_interval_report_schedulers.id;


--
-- TOC entry 258 (class 1259 OID 19594)
-- Name: customer_traffic_report; Type: TABLE; Schema: reports; Owner: cdr; Tablespace: 
--

CREATE TABLE customer_traffic_report (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    date_start timestamp with time zone,
    date_end timestamp with time zone,
    customer_id integer NOT NULL
);


ALTER TABLE reports.customer_traffic_report OWNER TO cdr;

--
-- TOC entry 291 (class 1259 OID 28467)
-- Name: customer_traffic_report_data_by_destination; Type: TABLE; Schema: reports; Owner: cdr; Tablespace: 
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
    success_calls_count numeric,
    first_call_at timestamp with time zone,
    last_call_at timestamp with time zone,
    short_calls_count bigint NOT NULL
);


ALTER TABLE reports.customer_traffic_report_data_by_destination OWNER TO cdr;

--
-- TOC entry 290 (class 1259 OID 28465)
-- Name: customer_traffic_report_data_by_destination_id_seq; Type: SEQUENCE; Schema: reports; Owner: cdr
--

CREATE SEQUENCE customer_traffic_report_data_by_destination_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reports.customer_traffic_report_data_by_destination_id_seq OWNER TO cdr;

--
-- TOC entry 2847 (class 0 OID 0)
-- Dependencies: 290
-- Name: customer_traffic_report_data_by_destination_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: cdr
--

ALTER SEQUENCE customer_traffic_report_data_by_destination_id_seq OWNED BY customer_traffic_report_data_by_destination.id;


--
-- TOC entry 260 (class 1259 OID 19602)
-- Name: customer_traffic_report_data_by_vendor; Type: TABLE; Schema: reports; Owner: cdr; Tablespace: 
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


ALTER TABLE reports.customer_traffic_report_data_by_vendor OWNER TO cdr;

--
-- TOC entry 289 (class 1259 OID 28456)
-- Name: customer_traffic_report_data_full; Type: TABLE; Schema: reports; Owner: cdr; Tablespace: 
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
    success_calls_count numeric,
    first_call_at timestamp with time zone,
    last_call_at timestamp with time zone,
    short_calls_count bigint NOT NULL
);


ALTER TABLE reports.customer_traffic_report_data_full OWNER TO cdr;

--
-- TOC entry 288 (class 1259 OID 28454)
-- Name: customer_traffic_report_data_full_id_seq; Type: SEQUENCE; Schema: reports; Owner: cdr
--

CREATE SEQUENCE customer_traffic_report_data_full_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reports.customer_traffic_report_data_full_id_seq OWNER TO cdr;

--
-- TOC entry 2848 (class 0 OID 0)
-- Dependencies: 288
-- Name: customer_traffic_report_data_full_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: cdr
--

ALTER SEQUENCE customer_traffic_report_data_full_id_seq OWNED BY customer_traffic_report_data_full.id;


--
-- TOC entry 259 (class 1259 OID 19600)
-- Name: customer_traffic_report_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: cdr
--

CREATE SEQUENCE customer_traffic_report_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reports.customer_traffic_report_data_id_seq OWNER TO cdr;

--
-- TOC entry 2849 (class 0 OID 0)
-- Dependencies: 259
-- Name: customer_traffic_report_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: cdr
--

ALTER SEQUENCE customer_traffic_report_data_id_seq OWNED BY customer_traffic_report_data_by_vendor.id;


--
-- TOC entry 257 (class 1259 OID 19592)
-- Name: customer_traffic_report_id_seq; Type: SEQUENCE; Schema: reports; Owner: cdr
--

CREATE SEQUENCE customer_traffic_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reports.customer_traffic_report_id_seq OWNER TO cdr;

--
-- TOC entry 2850 (class 0 OID 0)
-- Dependencies: 257
-- Name: customer_traffic_report_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: cdr
--

ALTER SEQUENCE customer_traffic_report_id_seq OWNED BY customer_traffic_report.id;


--
-- TOC entry 277 (class 1259 OID 20090)
-- Name: customer_traffic_report_schedulers; Type: TABLE; Schema: reports; Owner: cdr; Tablespace: 
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


ALTER TABLE reports.customer_traffic_report_schedulers OWNER TO cdr;

--
-- TOC entry 276 (class 1259 OID 20088)
-- Name: customer_traffic_report_schedulers_id_seq; Type: SEQUENCE; Schema: reports; Owner: cdr
--

CREATE SEQUENCE customer_traffic_report_schedulers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reports.customer_traffic_report_schedulers_id_seq OWNER TO cdr;

--
-- TOC entry 2851 (class 0 OID 0)
-- Dependencies: 276
-- Name: customer_traffic_report_schedulers_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: cdr
--

ALTER SEQUENCE customer_traffic_report_schedulers_id_seq OWNED BY customer_traffic_report_schedulers.id;


--
-- TOC entry 222 (class 1259 OID 17841)
-- Name: report_vendors; Type: TABLE; Schema: reports; Owner: cdr; Tablespace: 
--

CREATE TABLE report_vendors (
    id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL
);


ALTER TABLE reports.report_vendors OWNER TO cdr;

--
-- TOC entry 223 (class 1259 OID 17845)
-- Name: report_vendors_data; Type: TABLE; Schema: reports; Owner: cdr; Tablespace: 
--

CREATE TABLE report_vendors_data (
    id bigint NOT NULL,
    report_id integer NOT NULL,
    calls_count bigint
);


ALTER TABLE reports.report_vendors_data OWNER TO cdr;

--
-- TOC entry 224 (class 1259 OID 17848)
-- Name: report_vendors_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: cdr
--

CREATE SEQUENCE report_vendors_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reports.report_vendors_data_id_seq OWNER TO cdr;

--
-- TOC entry 2852 (class 0 OID 0)
-- Dependencies: 224
-- Name: report_vendors_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: cdr
--

ALTER SEQUENCE report_vendors_data_id_seq OWNED BY report_vendors_data.id;


--
-- TOC entry 225 (class 1259 OID 17850)
-- Name: report_vendors_id_seq; Type: SEQUENCE; Schema: reports; Owner: cdr
--

CREATE SEQUENCE report_vendors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reports.report_vendors_id_seq OWNER TO cdr;

--
-- TOC entry 2853 (class 0 OID 0)
-- Dependencies: 225
-- Name: report_vendors_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: cdr
--

ALTER SEQUENCE report_vendors_id_seq OWNED BY report_vendors.id;


--
-- TOC entry 275 (class 1259 OID 20013)
-- Name: scheduler_periods; Type: TABLE; Schema: reports; Owner: cdr; Tablespace: 
--

CREATE TABLE scheduler_periods (
    id smallint NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE reports.scheduler_periods OWNER TO cdr;

--
-- TOC entry 262 (class 1259 OID 19675)
-- Name: vendor_traffic_report; Type: TABLE; Schema: reports; Owner: cdr; Tablespace: 
--

CREATE TABLE vendor_traffic_report (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    date_start timestamp with time zone,
    date_end timestamp with time zone,
    vendor_id integer NOT NULL
);


ALTER TABLE reports.vendor_traffic_report OWNER TO cdr;

--
-- TOC entry 264 (class 1259 OID 19683)
-- Name: vendor_traffic_report_data; Type: TABLE; Schema: reports; Owner: cdr; Tablespace: 
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


ALTER TABLE reports.vendor_traffic_report_data OWNER TO cdr;

--
-- TOC entry 263 (class 1259 OID 19681)
-- Name: vendor_traffic_report_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: cdr
--

CREATE SEQUENCE vendor_traffic_report_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reports.vendor_traffic_report_data_id_seq OWNER TO cdr;

--
-- TOC entry 2854 (class 0 OID 0)
-- Dependencies: 263
-- Name: vendor_traffic_report_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: cdr
--

ALTER SEQUENCE vendor_traffic_report_data_id_seq OWNED BY vendor_traffic_report_data.id;


--
-- TOC entry 261 (class 1259 OID 19673)
-- Name: vendor_traffic_report_id_seq; Type: SEQUENCE; Schema: reports; Owner: cdr
--

CREATE SEQUENCE vendor_traffic_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reports.vendor_traffic_report_id_seq OWNER TO cdr;

--
-- TOC entry 2855 (class 0 OID 0)
-- Dependencies: 261
-- Name: vendor_traffic_report_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: cdr
--

ALTER SEQUENCE vendor_traffic_report_id_seq OWNED BY vendor_traffic_report.id;


--
-- TOC entry 279 (class 1259 OID 20106)
-- Name: vendor_traffic_report_schedulers; Type: TABLE; Schema: reports; Owner: cdr; Tablespace: 
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


ALTER TABLE reports.vendor_traffic_report_schedulers OWNER TO cdr;

--
-- TOC entry 278 (class 1259 OID 20104)
-- Name: vendor_traffic_report_schedulers_id_seq; Type: SEQUENCE; Schema: reports; Owner: cdr
--

CREATE SEQUENCE vendor_traffic_report_schedulers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reports.vendor_traffic_report_schedulers_id_seq OWNER TO cdr;

--
-- TOC entry 2856 (class 0 OID 0)
-- Dependencies: 278
-- Name: vendor_traffic_report_schedulers_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: cdr
--

ALTER SEQUENCE vendor_traffic_report_schedulers_id_seq OWNED BY vendor_traffic_report_schedulers.id;


SET search_path = stats, pg_catalog;

--
-- TOC entry 240 (class 1259 OID 18564)
-- Name: active_call_customer_accounts; Type: TABLE; Schema: stats; Owner: cdr; Tablespace: 
--

CREATE TABLE active_call_customer_accounts (
    id bigint NOT NULL,
    account_id integer NOT NULL,
    count integer NOT NULL,
    created_at timestamp with time zone
);


ALTER TABLE stats.active_call_customer_accounts OWNER TO cdr;

--
-- TOC entry 250 (class 1259 OID 18647)
-- Name: active_call_customer_accounts_hourly; Type: TABLE; Schema: stats; Owner: cdr; Tablespace: 
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


ALTER TABLE stats.active_call_customer_accounts_hourly OWNER TO cdr;

--
-- TOC entry 249 (class 1259 OID 18645)
-- Name: active_call_customer_accounts_hourly_id_seq; Type: SEQUENCE; Schema: stats; Owner: cdr
--

CREATE SEQUENCE active_call_customer_accounts_hourly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stats.active_call_customer_accounts_hourly_id_seq OWNER TO cdr;

--
-- TOC entry 2857 (class 0 OID 0)
-- Dependencies: 249
-- Name: active_call_customer_accounts_hourly_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: cdr
--

ALTER SEQUENCE active_call_customer_accounts_hourly_id_seq OWNED BY active_call_customer_accounts_hourly.id;


--
-- TOC entry 239 (class 1259 OID 18562)
-- Name: active_call_customer_accounts_id_seq; Type: SEQUENCE; Schema: stats; Owner: cdr
--

CREATE SEQUENCE active_call_customer_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stats.active_call_customer_accounts_id_seq OWNER TO cdr;

--
-- TOC entry 2858 (class 0 OID 0)
-- Dependencies: 239
-- Name: active_call_customer_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: cdr
--

ALTER SEQUENCE active_call_customer_accounts_id_seq OWNED BY active_call_customer_accounts.id;


--
-- TOC entry 236 (class 1259 OID 18548)
-- Name: active_call_orig_gateways; Type: TABLE; Schema: stats; Owner: cdr; Tablespace: 
--

CREATE TABLE active_call_orig_gateways (
    id bigint NOT NULL,
    gateway_id integer NOT NULL,
    count integer NOT NULL,
    created_at timestamp with time zone
);


ALTER TABLE stats.active_call_orig_gateways OWNER TO cdr;

--
-- TOC entry 246 (class 1259 OID 18631)
-- Name: active_call_orig_gateways_hourly; Type: TABLE; Schema: stats; Owner: cdr; Tablespace: 
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


ALTER TABLE stats.active_call_orig_gateways_hourly OWNER TO cdr;

--
-- TOC entry 245 (class 1259 OID 18629)
-- Name: active_call_orig_gateways_hourly_id_seq; Type: SEQUENCE; Schema: stats; Owner: cdr
--

CREATE SEQUENCE active_call_orig_gateways_hourly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stats.active_call_orig_gateways_hourly_id_seq OWNER TO cdr;

--
-- TOC entry 2859 (class 0 OID 0)
-- Dependencies: 245
-- Name: active_call_orig_gateways_hourly_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: cdr
--

ALTER SEQUENCE active_call_orig_gateways_hourly_id_seq OWNED BY active_call_orig_gateways_hourly.id;


--
-- TOC entry 235 (class 1259 OID 18546)
-- Name: active_call_orig_gateways_id_seq; Type: SEQUENCE; Schema: stats; Owner: cdr
--

CREATE SEQUENCE active_call_orig_gateways_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stats.active_call_orig_gateways_id_seq OWNER TO cdr;

--
-- TOC entry 2860 (class 0 OID 0)
-- Dependencies: 235
-- Name: active_call_orig_gateways_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: cdr
--

ALTER SEQUENCE active_call_orig_gateways_id_seq OWNED BY active_call_orig_gateways.id;


--
-- TOC entry 238 (class 1259 OID 18556)
-- Name: active_call_term_gateways; Type: TABLE; Schema: stats; Owner: cdr; Tablespace: 
--

CREATE TABLE active_call_term_gateways (
    id bigint NOT NULL,
    gateway_id integer NOT NULL,
    count integer NOT NULL,
    created_at timestamp with time zone
);


ALTER TABLE stats.active_call_term_gateways OWNER TO cdr;

--
-- TOC entry 248 (class 1259 OID 18639)
-- Name: active_call_term_gateways_hourly; Type: TABLE; Schema: stats; Owner: cdr; Tablespace: 
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


ALTER TABLE stats.active_call_term_gateways_hourly OWNER TO cdr;

--
-- TOC entry 247 (class 1259 OID 18637)
-- Name: active_call_term_gateways_hourly_id_seq; Type: SEQUENCE; Schema: stats; Owner: cdr
--

CREATE SEQUENCE active_call_term_gateways_hourly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stats.active_call_term_gateways_hourly_id_seq OWNER TO cdr;

--
-- TOC entry 2861 (class 0 OID 0)
-- Dependencies: 247
-- Name: active_call_term_gateways_hourly_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: cdr
--

ALTER SEQUENCE active_call_term_gateways_hourly_id_seq OWNED BY active_call_term_gateways_hourly.id;


--
-- TOC entry 237 (class 1259 OID 18554)
-- Name: active_call_term_gateways_id_seq; Type: SEQUENCE; Schema: stats; Owner: cdr
--

CREATE SEQUENCE active_call_term_gateways_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stats.active_call_term_gateways_id_seq OWNER TO cdr;

--
-- TOC entry 2862 (class 0 OID 0)
-- Dependencies: 237
-- Name: active_call_term_gateways_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: cdr
--

ALTER SEQUENCE active_call_term_gateways_id_seq OWNED BY active_call_term_gateways.id;


--
-- TOC entry 242 (class 1259 OID 18572)
-- Name: active_call_vendor_accounts; Type: TABLE; Schema: stats; Owner: cdr; Tablespace: 
--

CREATE TABLE active_call_vendor_accounts (
    id bigint NOT NULL,
    account_id integer NOT NULL,
    count integer NOT NULL,
    created_at timestamp with time zone
);


ALTER TABLE stats.active_call_vendor_accounts OWNER TO cdr;

--
-- TOC entry 252 (class 1259 OID 18655)
-- Name: active_call_vendor_accounts_hourly; Type: TABLE; Schema: stats; Owner: cdr; Tablespace: 
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


ALTER TABLE stats.active_call_vendor_accounts_hourly OWNER TO cdr;

--
-- TOC entry 251 (class 1259 OID 18653)
-- Name: active_call_vendor_accounts_hourly_id_seq; Type: SEQUENCE; Schema: stats; Owner: cdr
--

CREATE SEQUENCE active_call_vendor_accounts_hourly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stats.active_call_vendor_accounts_hourly_id_seq OWNER TO cdr;

--
-- TOC entry 2863 (class 0 OID 0)
-- Dependencies: 251
-- Name: active_call_vendor_accounts_hourly_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: cdr
--

ALTER SEQUENCE active_call_vendor_accounts_hourly_id_seq OWNED BY active_call_vendor_accounts_hourly.id;


--
-- TOC entry 241 (class 1259 OID 18570)
-- Name: active_call_vendor_accounts_id_seq; Type: SEQUENCE; Schema: stats; Owner: cdr
--

CREATE SEQUENCE active_call_vendor_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stats.active_call_vendor_accounts_id_seq OWNER TO cdr;

--
-- TOC entry 2864 (class 0 OID 0)
-- Dependencies: 241
-- Name: active_call_vendor_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: cdr
--

ALTER SEQUENCE active_call_vendor_accounts_id_seq OWNED BY active_call_vendor_accounts.id;


--
-- TOC entry 234 (class 1259 OID 18540)
-- Name: active_calls; Type: TABLE; Schema: stats; Owner: cdr; Tablespace: 
--

CREATE TABLE active_calls (
    id bigint NOT NULL,
    node_id integer NOT NULL,
    count integer NOT NULL,
    created_at timestamp with time zone
);


ALTER TABLE stats.active_calls OWNER TO cdr;

--
-- TOC entry 244 (class 1259 OID 18623)
-- Name: active_calls_hourly; Type: TABLE; Schema: stats; Owner: cdr; Tablespace: 
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


ALTER TABLE stats.active_calls_hourly OWNER TO cdr;

--
-- TOC entry 243 (class 1259 OID 18621)
-- Name: active_calls_hourly_id_seq; Type: SEQUENCE; Schema: stats; Owner: cdr
--

CREATE SEQUENCE active_calls_hourly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stats.active_calls_hourly_id_seq OWNER TO cdr;

--
-- TOC entry 2865 (class 0 OID 0)
-- Dependencies: 243
-- Name: active_calls_hourly_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: cdr
--

ALTER SEQUENCE active_calls_hourly_id_seq OWNED BY active_calls_hourly.id;


--
-- TOC entry 233 (class 1259 OID 18538)
-- Name: active_calls_id_seq; Type: SEQUENCE; Schema: stats; Owner: cdr
--

CREATE SEQUENCE active_calls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stats.active_calls_id_seq OWNER TO cdr;

--
-- TOC entry 2866 (class 0 OID 0)
-- Dependencies: 233
-- Name: active_calls_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: cdr
--

ALTER SEQUENCE active_calls_id_seq OWNED BY active_calls.id;


--
-- TOC entry 285 (class 1259 OID 20166)
-- Name: termination_quality_stats; Type: TABLE; Schema: stats; Owner: cdr; Tablespace: 
--

CREATE TABLE termination_quality_stats (
    id bigint NOT NULL,
    dialpeer_id bigint,
    gateway_id integer,
    time_start timestamp with time zone NOT NULL,
    success boolean NOT NULL,
    duration bigint NOT NULL,
    pdd real,
    early_media_present boolean
);


ALTER TABLE stats.termination_quality_stats OWNER TO cdr;

--
-- TOC entry 284 (class 1259 OID 20164)
-- Name: termination_quality_stats_id_seq; Type: SEQUENCE; Schema: stats; Owner: cdr
--

CREATE SEQUENCE termination_quality_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stats.termination_quality_stats_id_seq OWNER TO cdr;

--
-- TOC entry 2867 (class 0 OID 0)
-- Dependencies: 284
-- Name: termination_quality_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: cdr
--

ALTER SEQUENCE termination_quality_stats_id_seq OWNED BY termination_quality_stats.id;


--
-- TOC entry 254 (class 1259 OID 18746)
-- Name: traffic_customer_accounts; Type: TABLE; Schema: stats; Owner: cdr; Tablespace: 
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


ALTER TABLE stats.traffic_customer_accounts OWNER TO cdr;

--
-- TOC entry 253 (class 1259 OID 18744)
-- Name: traffic_customer_accounts_id_seq; Type: SEQUENCE; Schema: stats; Owner: cdr
--

CREATE SEQUENCE traffic_customer_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stats.traffic_customer_accounts_id_seq OWNER TO cdr;

--
-- TOC entry 2868 (class 0 OID 0)
-- Dependencies: 253
-- Name: traffic_customer_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: cdr
--

ALTER SEQUENCE traffic_customer_accounts_id_seq OWNED BY traffic_customer_accounts.id;


--
-- TOC entry 256 (class 1259 OID 18755)
-- Name: traffic_vendor_accounts; Type: TABLE; Schema: stats; Owner: cdr; Tablespace: 
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


ALTER TABLE stats.traffic_vendor_accounts OWNER TO cdr;

--
-- TOC entry 255 (class 1259 OID 18753)
-- Name: traffic_vendor_accounts_id_seq; Type: SEQUENCE; Schema: stats; Owner: cdr
--

CREATE SEQUENCE traffic_vendor_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stats.traffic_vendor_accounts_id_seq OWNER TO cdr;

--
-- TOC entry 2869 (class 0 OID 0)
-- Dependencies: 255
-- Name: traffic_vendor_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: cdr
--

ALTER SEQUENCE traffic_vendor_accounts_id_seq OWNED BY traffic_vendor_accounts.id;


SET search_path = sys, pg_catalog;

--
-- TOC entry 273 (class 1259 OID 19971)
-- Name: call_duration_round_modes; Type: TABLE; Schema: sys; Owner: cdr; Tablespace: 
--

CREATE TABLE call_duration_round_modes (
    id smallint NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE sys.call_duration_round_modes OWNER TO cdr;

--
-- TOC entry 203 (class 1259 OID 17047)
-- Name: cdr_tables; Type: TABLE; Schema: sys; Owner: cdr; Tablespace: 
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


ALTER TABLE sys.cdr_tables OWNER TO cdr;

--
-- TOC entry 202 (class 1259 OID 17045)
-- Name: cdr_tables_id_seq; Type: SEQUENCE; Schema: sys; Owner: cdr
--

CREATE SEQUENCE cdr_tables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sys.cdr_tables_id_seq OWNER TO cdr;

--
-- TOC entry 2870 (class 0 OID 0)
-- Dependencies: 202
-- Name: cdr_tables_id_seq; Type: SEQUENCE OWNED BY; Schema: sys; Owner: cdr
--

ALTER SEQUENCE cdr_tables_id_seq OWNED BY cdr_tables.id;


--
-- TOC entry 274 (class 1259 OID 19981)
-- Name: config; Type: TABLE; Schema: sys; Owner: cdr; Tablespace: 
--

CREATE TABLE config (
    id smallint NOT NULL,
    call_duration_round_mode_id smallint DEFAULT 1 NOT NULL
);


ALTER TABLE sys.config OWNER TO cdr;

--
-- TOC entry 205 (class 1259 OID 17238)
-- Name: version; Type: TABLE; Schema: sys; Owner: cdr; Tablespace: 
--

CREATE TABLE version (
    id bigint NOT NULL,
    number integer NOT NULL,
    apply_date timestamp with time zone DEFAULT now() NOT NULL,
    comment character varying
);


ALTER TABLE sys.version OWNER TO cdr;

--
-- TOC entry 204 (class 1259 OID 17236)
-- Name: version_id_seq; Type: SEQUENCE; Schema: sys; Owner: cdr
--

CREATE SEQUENCE version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sys.version_id_seq OWNER TO cdr;

--
-- TOC entry 2871 (class 0 OID 0)
-- Dependencies: 204
-- Name: version_id_seq; Type: SEQUENCE OWNED BY; Schema: sys; Owner: cdr
--

ALTER SEQUENCE version_id_seq OWNED BY version.id;


SET search_path = billing, pg_catalog;

--
-- TOC entry 2470 (class 2604 OID 19740)
-- Name: id; Type: DEFAULT; Schema: billing; Owner: cdr
--

ALTER TABLE ONLY invoice_destinations ALTER COLUMN id SET DEFAULT nextval('invoice_destinations_id_seq'::regclass);


--
-- TOC entry 2471 (class 2604 OID 19783)
-- Name: id; Type: DEFAULT; Schema: billing; Owner: cdr
--

ALTER TABLE ONLY invoice_documents ALTER COLUMN id SET DEFAULT nextval('invoice_documents_id_seq'::regclass);


--
-- TOC entry 2452 (class 2604 OID 18133)
-- Name: id; Type: DEFAULT; Schema: billing; Owner: cdr
--

ALTER TABLE ONLY invoices ALTER COLUMN id SET DEFAULT nextval('invoices_id_seq'::regclass);


SET search_path = cdr, pg_catalog;

--
-- TOC entry 2419 (class 2604 OID 17028)
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- TOC entry 2444 (class 2604 OID 18097)
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201501 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- TOC entry 2445 (class 2604 OID 18100)
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201501 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- TOC entry 2441 (class 2604 OID 18083)
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201502 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- TOC entry 2442 (class 2604 OID 18086)
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201502 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- TOC entry 2481 (class 2604 OID 19845)
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201503 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- TOC entry 2482 (class 2604 OID 19846)
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201503 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- TOC entry 2475 (class 2604 OID 19821)
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201504 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- TOC entry 2476 (class 2604 OID 19822)
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201504 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- TOC entry 2472 (class 2604 OID 19809)
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201505 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- TOC entry 2473 (class 2604 OID 19810)
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201505 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- TOC entry 2478 (class 2604 OID 19833)
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201506 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- TOC entry 2479 (class 2604 OID 19834)
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201506 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- TOC entry 2495 (class 2604 OID 28767)
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201507 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- TOC entry 2496 (class 2604 OID 28768)
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201507 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- TOC entry 2492 (class 2604 OID 28755)
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201508 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- TOC entry 2493 (class 2604 OID 28756)
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201508 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- TOC entry 2498 (class 2604 OID 28779)
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201509 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- TOC entry 2499 (class 2604 OID 28780)
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201509 ALTER COLUMN dump_level_id SET DEFAULT 0;


--
-- TOC entry 2501 (class 2604 OID 28791)
-- Name: id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201510 ALTER COLUMN id SET DEFAULT nextval('cdr_id_seq'::regclass);


--
-- TOC entry 2502 (class 2604 OID 28792)
-- Name: dump_level_id; Type: DEFAULT; Schema: cdr; Owner: cdr
--

ALTER TABLE ONLY cdr_201510 ALTER COLUMN dump_level_id SET DEFAULT 0;


SET search_path = pgq, pg_catalog;

--
-- TOC entry 2391 (class 2604 OID 16651)
-- Name: co_id; Type: DEFAULT; Schema: pgq; Owner: cdr
--

ALTER TABLE ONLY consumer ALTER COLUMN co_id SET DEFAULT nextval('consumer_co_id_seq'::regclass);


--
-- TOC entry 2427 (class 2604 OID 17488)
-- Name: ev_txid; Type: DEFAULT; Schema: pgq; Owner: cdr
--

ALTER TABLE ONLY event_3 ALTER COLUMN ev_txid SET DEFAULT txid_current();


--
-- TOC entry 2429 (class 2604 OID 17499)
-- Name: ev_id; Type: DEFAULT; Schema: pgq; Owner: cdr
--

ALTER TABLE ONLY event_3_0 ALTER COLUMN ev_id SET DEFAULT nextval('event_3_id_seq'::regclass);


--
-- TOC entry 2428 (class 2604 OID 17495)
-- Name: ev_txid; Type: DEFAULT; Schema: pgq; Owner: cdr
--

ALTER TABLE ONLY event_3_0 ALTER COLUMN ev_txid SET DEFAULT txid_current();


--
-- TOC entry 2431 (class 2604 OID 17508)
-- Name: ev_id; Type: DEFAULT; Schema: pgq; Owner: cdr
--

ALTER TABLE ONLY event_3_1 ALTER COLUMN ev_id SET DEFAULT nextval('event_3_id_seq'::regclass);


--
-- TOC entry 2430 (class 2604 OID 17504)
-- Name: ev_txid; Type: DEFAULT; Schema: pgq; Owner: cdr
--

ALTER TABLE ONLY event_3_1 ALTER COLUMN ev_txid SET DEFAULT txid_current();


--
-- TOC entry 2433 (class 2604 OID 17517)
-- Name: ev_id; Type: DEFAULT; Schema: pgq; Owner: cdr
--

ALTER TABLE ONLY event_3_2 ALTER COLUMN ev_id SET DEFAULT nextval('event_3_id_seq'::regclass);


--
-- TOC entry 2432 (class 2604 OID 17513)
-- Name: ev_txid; Type: DEFAULT; Schema: pgq; Owner: cdr
--

ALTER TABLE ONLY event_3_2 ALTER COLUMN ev_txid SET DEFAULT txid_current();


--
-- TOC entry 2392 (class 2604 OID 16664)
-- Name: queue_id; Type: DEFAULT; Schema: pgq; Owner: cdr
--

ALTER TABLE ONLY queue ALTER COLUMN queue_id SET DEFAULT nextval('queue_queue_id_seq'::regclass);


--
-- TOC entry 2407 (class 2604 OID 16706)
-- Name: sub_id; Type: DEFAULT; Schema: pgq; Owner: cdr
--

ALTER TABLE ONLY subscription ALTER COLUMN sub_id SET DEFAULT nextval('subscription_sub_id_seq'::regclass);


SET search_path = reports, pg_catalog;

--
-- TOC entry 2434 (class 2604 OID 17852)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY cdr_custom_report ALTER COLUMN id SET DEFAULT nextval('cdr_custom_report_id_seq'::regclass);


--
-- TOC entry 2435 (class 2604 OID 17853)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY cdr_custom_report_data ALTER COLUMN id SET DEFAULT nextval('cdr_custom_report_data_id_seq'::regclass);


--
-- TOC entry 2487 (class 2604 OID 20125)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY cdr_custom_report_schedulers ALTER COLUMN id SET DEFAULT nextval('cdr_custom_report_schedulers_id_seq'::regclass);


--
-- TOC entry 2436 (class 2604 OID 17854)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY cdr_interval_report ALTER COLUMN id SET DEFAULT nextval('cdr_interval_report_id_seq'::regclass);


--
-- TOC entry 2437 (class 2604 OID 17855)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY cdr_interval_report_data ALTER COLUMN id SET DEFAULT nextval('cdr_interval_report_data_id_seq'::regclass);


--
-- TOC entry 2488 (class 2604 OID 20141)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY cdr_interval_report_schedulers ALTER COLUMN id SET DEFAULT nextval('cdr_interval_report_schedulers_id_seq'::regclass);


--
-- TOC entry 2466 (class 2604 OID 19597)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY customer_traffic_report ALTER COLUMN id SET DEFAULT nextval('customer_traffic_report_id_seq'::regclass);


--
-- TOC entry 2491 (class 2604 OID 28470)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY customer_traffic_report_data_by_destination ALTER COLUMN id SET DEFAULT nextval('customer_traffic_report_data_by_destination_id_seq'::regclass);


--
-- TOC entry 2467 (class 2604 OID 19605)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY customer_traffic_report_data_by_vendor ALTER COLUMN id SET DEFAULT nextval('customer_traffic_report_data_id_seq'::regclass);


--
-- TOC entry 2490 (class 2604 OID 28459)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY customer_traffic_report_data_full ALTER COLUMN id SET DEFAULT nextval('customer_traffic_report_data_full_id_seq'::regclass);


--
-- TOC entry 2485 (class 2604 OID 20093)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY customer_traffic_report_schedulers ALTER COLUMN id SET DEFAULT nextval('customer_traffic_report_schedulers_id_seq'::regclass);


--
-- TOC entry 2439 (class 2604 OID 17856)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY report_vendors ALTER COLUMN id SET DEFAULT nextval('report_vendors_id_seq'::regclass);


--
-- TOC entry 2440 (class 2604 OID 17857)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY report_vendors_data ALTER COLUMN id SET DEFAULT nextval('report_vendors_data_id_seq'::regclass);


--
-- TOC entry 2468 (class 2604 OID 19678)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY vendor_traffic_report ALTER COLUMN id SET DEFAULT nextval('vendor_traffic_report_id_seq'::regclass);


--
-- TOC entry 2469 (class 2604 OID 19686)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY vendor_traffic_report_data ALTER COLUMN id SET DEFAULT nextval('vendor_traffic_report_data_id_seq'::regclass);


--
-- TOC entry 2486 (class 2604 OID 20109)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY vendor_traffic_report_schedulers ALTER COLUMN id SET DEFAULT nextval('vendor_traffic_report_schedulers_id_seq'::regclass);


SET search_path = stats, pg_catalog;

--
-- TOC entry 2457 (class 2604 OID 18567)
-- Name: id; Type: DEFAULT; Schema: stats; Owner: cdr
--

ALTER TABLE ONLY active_call_customer_accounts ALTER COLUMN id SET DEFAULT nextval('active_call_customer_accounts_id_seq'::regclass);


--
-- TOC entry 2462 (class 2604 OID 18650)
-- Name: id; Type: DEFAULT; Schema: stats; Owner: cdr
--

ALTER TABLE ONLY active_call_customer_accounts_hourly ALTER COLUMN id SET DEFAULT nextval('active_call_customer_accounts_hourly_id_seq'::regclass);


--
-- TOC entry 2455 (class 2604 OID 18551)
-- Name: id; Type: DEFAULT; Schema: stats; Owner: cdr
--

ALTER TABLE ONLY active_call_orig_gateways ALTER COLUMN id SET DEFAULT nextval('active_call_orig_gateways_id_seq'::regclass);


--
-- TOC entry 2460 (class 2604 OID 18634)
-- Name: id; Type: DEFAULT; Schema: stats; Owner: cdr
--

ALTER TABLE ONLY active_call_orig_gateways_hourly ALTER COLUMN id SET DEFAULT nextval('active_call_orig_gateways_hourly_id_seq'::regclass);


--
-- TOC entry 2456 (class 2604 OID 18559)
-- Name: id; Type: DEFAULT; Schema: stats; Owner: cdr
--

ALTER TABLE ONLY active_call_term_gateways ALTER COLUMN id SET DEFAULT nextval('active_call_term_gateways_id_seq'::regclass);


--
-- TOC entry 2461 (class 2604 OID 18642)
-- Name: id; Type: DEFAULT; Schema: stats; Owner: cdr
--

ALTER TABLE ONLY active_call_term_gateways_hourly ALTER COLUMN id SET DEFAULT nextval('active_call_term_gateways_hourly_id_seq'::regclass);


--
-- TOC entry 2458 (class 2604 OID 18575)
-- Name: id; Type: DEFAULT; Schema: stats; Owner: cdr
--

ALTER TABLE ONLY active_call_vendor_accounts ALTER COLUMN id SET DEFAULT nextval('active_call_vendor_accounts_id_seq'::regclass);


--
-- TOC entry 2463 (class 2604 OID 18658)
-- Name: id; Type: DEFAULT; Schema: stats; Owner: cdr
--

ALTER TABLE ONLY active_call_vendor_accounts_hourly ALTER COLUMN id SET DEFAULT nextval('active_call_vendor_accounts_hourly_id_seq'::regclass);


--
-- TOC entry 2454 (class 2604 OID 18543)
-- Name: id; Type: DEFAULT; Schema: stats; Owner: cdr
--

ALTER TABLE ONLY active_calls ALTER COLUMN id SET DEFAULT nextval('active_calls_id_seq'::regclass);


--
-- TOC entry 2459 (class 2604 OID 18626)
-- Name: id; Type: DEFAULT; Schema: stats; Owner: cdr
--

ALTER TABLE ONLY active_calls_hourly ALTER COLUMN id SET DEFAULT nextval('active_calls_hourly_id_seq'::regclass);


--
-- TOC entry 2489 (class 2604 OID 20169)
-- Name: id; Type: DEFAULT; Schema: stats; Owner: cdr
--

ALTER TABLE ONLY termination_quality_stats ALTER COLUMN id SET DEFAULT nextval('termination_quality_stats_id_seq'::regclass);


--
-- TOC entry 2464 (class 2604 OID 18749)
-- Name: id; Type: DEFAULT; Schema: stats; Owner: cdr
--

ALTER TABLE ONLY traffic_customer_accounts ALTER COLUMN id SET DEFAULT nextval('traffic_customer_accounts_id_seq'::regclass);


--
-- TOC entry 2465 (class 2604 OID 18758)
-- Name: id; Type: DEFAULT; Schema: stats; Owner: cdr
--

ALTER TABLE ONLY traffic_vendor_accounts ALTER COLUMN id SET DEFAULT nextval('traffic_vendor_accounts_id_seq'::regclass);


SET search_path = sys, pg_catalog;

--
-- TOC entry 2422 (class 2604 OID 17050)
-- Name: id; Type: DEFAULT; Schema: sys; Owner: cdr
--

ALTER TABLE ONLY cdr_tables ALTER COLUMN id SET DEFAULT nextval('cdr_tables_id_seq'::regclass);


--
-- TOC entry 2426 (class 2604 OID 17241)
-- Name: id; Type: DEFAULT; Schema: sys; Owner: cdr
--

ALTER TABLE ONLY version ALTER COLUMN id SET DEFAULT nextval('version_id_seq'::regclass);


SET search_path = billing, pg_catalog;

--
-- TOC entry 2616 (class 2606 OID 19745)
-- Name: invoice_destinations_pkey; Type: CONSTRAINT; Schema: billing; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY invoice_destinations
    ADD CONSTRAINT invoice_destinations_pkey PRIMARY KEY (id);


--
-- TOC entry 2618 (class 2606 OID 19788)
-- Name: invoice_documents_pkey; Type: CONSTRAINT; Schema: billing; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY invoice_documents
    ADD CONSTRAINT invoice_documents_pkey PRIMARY KEY (id);


--
-- TOC entry 2654 (class 2606 OID 20278)
-- Name: invoice_states_name_key; Type: CONSTRAINT; Schema: billing; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY invoice_states
    ADD CONSTRAINT invoice_states_name_key UNIQUE (name);


--
-- TOC entry 2656 (class 2606 OID 20276)
-- Name: invoice_states_pkey; Type: CONSTRAINT; Schema: billing; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY invoice_states
    ADD CONSTRAINT invoice_states_pkey PRIMARY KEY (id);


--
-- TOC entry 2662 (class 2606 OID 28567)
-- Name: invoice_type_name_key; Type: CONSTRAINT; Schema: billing; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY invoice_types
    ADD CONSTRAINT invoice_type_name_key UNIQUE (name);


--
-- TOC entry 2664 (class 2606 OID 28565)
-- Name: invoice_type_pkey; Type: CONSTRAINT; Schema: billing; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY invoice_types
    ADD CONSTRAINT invoice_type_pkey PRIMARY KEY (id);


--
-- TOC entry 2577 (class 2606 OID 18139)
-- Name: invoices_pkey; Type: CONSTRAINT; Schema: billing; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


SET search_path = cdr, pg_catalog;

--
-- TOC entry 2574 (class 2606 OID 18120)
-- Name: cdr_201412_pkey; Type: CONSTRAINT; Schema: cdr; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_201412
    ADD CONSTRAINT cdr_201412_pkey PRIMARY KEY (id);


--
-- TOC entry 2571 (class 2606 OID 18106)
-- Name: cdr_201501_pkey; Type: CONSTRAINT; Schema: cdr; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_201501
    ADD CONSTRAINT cdr_201501_pkey PRIMARY KEY (id);


--
-- TOC entry 2568 (class 2606 OID 18092)
-- Name: cdr_201502_pkey; Type: CONSTRAINT; Schema: cdr; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_201502
    ADD CONSTRAINT cdr_201502_pkey PRIMARY KEY (id);


--
-- TOC entry 2629 (class 2606 OID 19852)
-- Name: cdr_201503_pkey; Type: CONSTRAINT; Schema: cdr; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_201503
    ADD CONSTRAINT cdr_201503_pkey PRIMARY KEY (id);


--
-- TOC entry 2623 (class 2606 OID 19828)
-- Name: cdr_201504_pkey; Type: CONSTRAINT; Schema: cdr; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_201504
    ADD CONSTRAINT cdr_201504_pkey PRIMARY KEY (id);


--
-- TOC entry 2620 (class 2606 OID 19816)
-- Name: cdr_201505_pkey; Type: CONSTRAINT; Schema: cdr; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_201505
    ADD CONSTRAINT cdr_201505_pkey PRIMARY KEY (id);


--
-- TOC entry 2626 (class 2606 OID 19840)
-- Name: cdr_201506_pkey; Type: CONSTRAINT; Schema: cdr; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_201506
    ADD CONSTRAINT cdr_201506_pkey PRIMARY KEY (id);


--
-- TOC entry 2669 (class 2606 OID 28774)
-- Name: cdr_201507_pkey; Type: CONSTRAINT; Schema: cdr; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_201507
    ADD CONSTRAINT cdr_201507_pkey PRIMARY KEY (id);


--
-- TOC entry 2666 (class 2606 OID 28762)
-- Name: cdr_201508_pkey; Type: CONSTRAINT; Schema: cdr; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_201508
    ADD CONSTRAINT cdr_201508_pkey PRIMARY KEY (id);


--
-- TOC entry 2672 (class 2606 OID 28786)
-- Name: cdr_201509_pkey; Type: CONSTRAINT; Schema: cdr; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_201509
    ADD CONSTRAINT cdr_201509_pkey PRIMARY KEY (id);


--
-- TOC entry 2675 (class 2606 OID 28798)
-- Name: cdr_201510_pkey; Type: CONSTRAINT; Schema: cdr; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_201510
    ADD CONSTRAINT cdr_201510_pkey PRIMARY KEY (id);


--
-- TOC entry 2538 (class 2606 OID 17036)
-- Name: cdr_pkey; Type: CONSTRAINT; Schema: cdr; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr
    ADD CONSTRAINT cdr_pkey PRIMARY KEY (id);


SET search_path = pgq, pg_catalog;

--
-- TOC entry 2505 (class 2606 OID 16658)
-- Name: consumer_name_uq; Type: CONSTRAINT; Schema: pgq; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY consumer
    ADD CONSTRAINT consumer_name_uq UNIQUE (co_name);


--
-- TOC entry 2507 (class 2606 OID 16656)
-- Name: consumer_pkey; Type: CONSTRAINT; Schema: pgq; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY consumer
    ADD CONSTRAINT consumer_pkey PRIMARY KEY (co_id);


--
-- TOC entry 2509 (class 2606 OID 16683)
-- Name: queue_name_uq; Type: CONSTRAINT; Schema: pgq; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY queue
    ADD CONSTRAINT queue_name_uq UNIQUE (queue_name);


--
-- TOC entry 2511 (class 2606 OID 16681)
-- Name: queue_pkey; Type: CONSTRAINT; Schema: pgq; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY queue
    ADD CONSTRAINT queue_pkey PRIMARY KEY (queue_id);


--
-- TOC entry 2519 (class 2606 OID 16736)
-- Name: rq_pkey; Type: CONSTRAINT; Schema: pgq; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY retry_queue
    ADD CONSTRAINT rq_pkey PRIMARY KEY (ev_owner, ev_id);


--
-- TOC entry 2515 (class 2606 OID 16711)
-- Name: subscription_batch_idx; Type: CONSTRAINT; Schema: pgq; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY subscription
    ADD CONSTRAINT subscription_batch_idx UNIQUE (sub_batch);


--
-- TOC entry 2517 (class 2606 OID 16709)
-- Name: subscription_pkey; Type: CONSTRAINT; Schema: pgq; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY subscription
    ADD CONSTRAINT subscription_pkey PRIMARY KEY (sub_queue, sub_consumer);


--
-- TOC entry 2513 (class 2606 OID 16693)
-- Name: tick_pkey; Type: CONSTRAINT; Schema: pgq; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY tick
    ADD CONSTRAINT tick_pkey PRIMARY KEY (tick_queue, tick_id);


SET search_path = pgq_ext, pg_catalog;

--
-- TOC entry 2524 (class 2606 OID 16814)
-- Name: completed_batch_pkey; Type: CONSTRAINT; Schema: pgq_ext; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY completed_batch
    ADD CONSTRAINT completed_batch_pkey PRIMARY KEY (consumer_id, subconsumer_id);


--
-- TOC entry 2526 (class 2606 OID 16822)
-- Name: completed_event_pkey; Type: CONSTRAINT; Schema: pgq_ext; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY completed_event
    ADD CONSTRAINT completed_event_pkey PRIMARY KEY (consumer_id, subconsumer_id, batch_id, event_id);


--
-- TOC entry 2522 (class 2606 OID 16806)
-- Name: completed_tick_pkey; Type: CONSTRAINT; Schema: pgq_ext; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY completed_tick
    ADD CONSTRAINT completed_tick_pkey PRIMARY KEY (consumer_id, subconsumer_id);


--
-- TOC entry 2528 (class 2606 OID 16830)
-- Name: partial_batch_pkey; Type: CONSTRAINT; Schema: pgq_ext; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY partial_batch
    ADD CONSTRAINT partial_batch_pkey PRIMARY KEY (consumer_id, subconsumer_id);


SET search_path = pgq_node, pg_catalog;

--
-- TOC entry 2534 (class 2606 OID 16883)
-- Name: local_state_pkey; Type: CONSTRAINT; Schema: pgq_node; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY local_state
    ADD CONSTRAINT local_state_pkey PRIMARY KEY (queue_name, consumer_name);


--
-- TOC entry 2532 (class 2606 OID 16868)
-- Name: node_info_pkey; Type: CONSTRAINT; Schema: pgq_node; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY node_info
    ADD CONSTRAINT node_info_pkey PRIMARY KEY (queue_name);


--
-- TOC entry 2530 (class 2606 OID 16858)
-- Name: node_location_pkey; Type: CONSTRAINT; Schema: pgq_node; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY node_location
    ADD CONSTRAINT node_location_pkey PRIMARY KEY (queue_name, node_name);


--
-- TOC entry 2536 (class 2606 OID 16901)
-- Name: subscriber_info_pkey; Type: CONSTRAINT; Schema: pgq_node; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY subscriber_info
    ADD CONSTRAINT subscriber_info_pkey PRIMARY KEY (queue_name, subscriber_node);


SET search_path = reports, pg_catalog;

--
-- TOC entry 2554 (class 2606 OID 17859)
-- Name: cdr_custom_report_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_custom_report_data
    ADD CONSTRAINT cdr_custom_report_data_pkey PRIMARY KEY (id);


--
-- TOC entry 2552 (class 2606 OID 17861)
-- Name: cdr_custom_report_pkey; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_custom_report
    ADD CONSTRAINT cdr_custom_report_pkey PRIMARY KEY (id);


--
-- TOC entry 2646 (class 2606 OID 20130)
-- Name: cdr_custom_report_schedulers_pkey; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_custom_report_schedulers
    ADD CONSTRAINT cdr_custom_report_schedulers_pkey PRIMARY KEY (id);


--
-- TOC entry 2558 (class 2606 OID 17863)
-- Name: cdr_interval_report_aggrerator_name_key; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_interval_report_aggrerator
    ADD CONSTRAINT cdr_interval_report_aggrerator_name_key UNIQUE (name);


--
-- TOC entry 2560 (class 2606 OID 17865)
-- Name: cdr_interval_report_aggrerator_pkey; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_interval_report_aggrerator
    ADD CONSTRAINT cdr_interval_report_aggrerator_pkey PRIMARY KEY (id);


--
-- TOC entry 2562 (class 2606 OID 17867)
-- Name: cdr_interval_report_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_interval_report_data
    ADD CONSTRAINT cdr_interval_report_data_pkey PRIMARY KEY (id);


--
-- TOC entry 2556 (class 2606 OID 17869)
-- Name: cdr_interval_report_pkey; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_interval_report
    ADD CONSTRAINT cdr_interval_report_pkey PRIMARY KEY (id);


--
-- TOC entry 2648 (class 2606 OID 20146)
-- Name: cdr_interval_report_schedulers_pkey; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_interval_report_schedulers
    ADD CONSTRAINT cdr_interval_report_schedulers_pkey PRIMARY KEY (id);


--
-- TOC entry 2660 (class 2606 OID 28475)
-- Name: customer_traffic_report_data_by_destination_pkey; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY customer_traffic_report_data_by_destination
    ADD CONSTRAINT customer_traffic_report_data_by_destination_pkey PRIMARY KEY (id);


--
-- TOC entry 2658 (class 2606 OID 28464)
-- Name: customer_traffic_report_data_full_pkey; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY customer_traffic_report_data_full
    ADD CONSTRAINT customer_traffic_report_data_full_pkey PRIMARY KEY (id);


--
-- TOC entry 2607 (class 2606 OID 19610)
-- Name: customer_traffic_report_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY customer_traffic_report_data_by_vendor
    ADD CONSTRAINT customer_traffic_report_data_pkey PRIMARY KEY (id);


--
-- TOC entry 2605 (class 2606 OID 19599)
-- Name: customer_traffic_report_pkey; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY customer_traffic_report
    ADD CONSTRAINT customer_traffic_report_pkey PRIMARY KEY (id);


--
-- TOC entry 2642 (class 2606 OID 20098)
-- Name: customer_traffic_report_schedulers_pkey; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY customer_traffic_report_schedulers
    ADD CONSTRAINT customer_traffic_report_schedulers_pkey PRIMARY KEY (id);


--
-- TOC entry 2566 (class 2606 OID 17871)
-- Name: report_vendors_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY report_vendors_data
    ADD CONSTRAINT report_vendors_data_pkey PRIMARY KEY (id);


--
-- TOC entry 2564 (class 2606 OID 17873)
-- Name: report_vendors_pkey; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY report_vendors
    ADD CONSTRAINT report_vendors_pkey PRIMARY KEY (id);


--
-- TOC entry 2638 (class 2606 OID 20022)
-- Name: scheduler_periods_name_key; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY scheduler_periods
    ADD CONSTRAINT scheduler_periods_name_key UNIQUE (name);


--
-- TOC entry 2640 (class 2606 OID 20020)
-- Name: scheduler_periods_pkey; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY scheduler_periods
    ADD CONSTRAINT scheduler_periods_pkey PRIMARY KEY (id);


--
-- TOC entry 2612 (class 2606 OID 19691)
-- Name: vendor_traffic_report_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY vendor_traffic_report_data
    ADD CONSTRAINT vendor_traffic_report_data_pkey PRIMARY KEY (id);


--
-- TOC entry 2610 (class 2606 OID 19680)
-- Name: vendor_traffic_report_pkey; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY vendor_traffic_report
    ADD CONSTRAINT vendor_traffic_report_pkey PRIMARY KEY (id);


--
-- TOC entry 2644 (class 2606 OID 20114)
-- Name: vendor_traffic_report_schedulers_pkey; Type: CONSTRAINT; Schema: reports; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY vendor_traffic_report_schedulers
    ADD CONSTRAINT vendor_traffic_report_schedulers_pkey PRIMARY KEY (id);


SET search_path = stats, pg_catalog;

--
-- TOC entry 2595 (class 2606 OID 18652)
-- Name: active_call_customer_accounts_hourly_pkey; Type: CONSTRAINT; Schema: stats; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY active_call_customer_accounts_hourly
    ADD CONSTRAINT active_call_customer_accounts_hourly_pkey PRIMARY KEY (id);


--
-- TOC entry 2585 (class 2606 OID 18569)
-- Name: active_call_customer_accounts_pkey; Type: CONSTRAINT; Schema: stats; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY active_call_customer_accounts
    ADD CONSTRAINT active_call_customer_accounts_pkey PRIMARY KEY (id);


--
-- TOC entry 2591 (class 2606 OID 18636)
-- Name: active_call_orig_gateways_hourly_pkey; Type: CONSTRAINT; Schema: stats; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY active_call_orig_gateways_hourly
    ADD CONSTRAINT active_call_orig_gateways_hourly_pkey PRIMARY KEY (id);


--
-- TOC entry 2581 (class 2606 OID 18553)
-- Name: active_call_orig_gateways_pkey; Type: CONSTRAINT; Schema: stats; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY active_call_orig_gateways
    ADD CONSTRAINT active_call_orig_gateways_pkey PRIMARY KEY (id);


--
-- TOC entry 2593 (class 2606 OID 18644)
-- Name: active_call_term_gateways_hourly_pkey; Type: CONSTRAINT; Schema: stats; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY active_call_term_gateways_hourly
    ADD CONSTRAINT active_call_term_gateways_hourly_pkey PRIMARY KEY (id);


--
-- TOC entry 2583 (class 2606 OID 18561)
-- Name: active_call_term_gateways_pkey; Type: CONSTRAINT; Schema: stats; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY active_call_term_gateways
    ADD CONSTRAINT active_call_term_gateways_pkey PRIMARY KEY (id);


--
-- TOC entry 2597 (class 2606 OID 18660)
-- Name: active_call_vendor_accounts_hourly_pkey; Type: CONSTRAINT; Schema: stats; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY active_call_vendor_accounts_hourly
    ADD CONSTRAINT active_call_vendor_accounts_hourly_pkey PRIMARY KEY (id);


--
-- TOC entry 2587 (class 2606 OID 18577)
-- Name: active_call_vendor_accounts_pkey; Type: CONSTRAINT; Schema: stats; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY active_call_vendor_accounts
    ADD CONSTRAINT active_call_vendor_accounts_pkey PRIMARY KEY (id);


--
-- TOC entry 2589 (class 2606 OID 18628)
-- Name: active_calls_hourly_pkey; Type: CONSTRAINT; Schema: stats; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY active_calls_hourly
    ADD CONSTRAINT active_calls_hourly_pkey PRIMARY KEY (id);


--
-- TOC entry 2579 (class 2606 OID 18545)
-- Name: active_calls_pkey; Type: CONSTRAINT; Schema: stats; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY active_calls
    ADD CONSTRAINT active_calls_pkey PRIMARY KEY (id);


--
-- TOC entry 2652 (class 2606 OID 20171)
-- Name: termination_quality_stats_pkey; Type: CONSTRAINT; Schema: stats; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY termination_quality_stats
    ADD CONSTRAINT termination_quality_stats_pkey PRIMARY KEY (id);


--
-- TOC entry 2600 (class 2606 OID 18751)
-- Name: traffic_customer_accounts_pkey; Type: CONSTRAINT; Schema: stats; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY traffic_customer_accounts
    ADD CONSTRAINT traffic_customer_accounts_pkey PRIMARY KEY (id);


--
-- TOC entry 2603 (class 2606 OID 18760)
-- Name: traffic_vendor_accounts_pkey; Type: CONSTRAINT; Schema: stats; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY traffic_vendor_accounts
    ADD CONSTRAINT traffic_vendor_accounts_pkey PRIMARY KEY (id);


SET search_path = sys, pg_catalog;

--
-- TOC entry 2632 (class 2606 OID 19980)
-- Name: call_duration_round_modes_name_key; Type: CONSTRAINT; Schema: sys; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY call_duration_round_modes
    ADD CONSTRAINT call_duration_round_modes_name_key UNIQUE (name);


--
-- TOC entry 2634 (class 2606 OID 19978)
-- Name: call_duration_round_modes_pkey; Type: CONSTRAINT; Schema: sys; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY call_duration_round_modes
    ADD CONSTRAINT call_duration_round_modes_pkey PRIMARY KEY (id);


--
-- TOC entry 2542 (class 2606 OID 17057)
-- Name: cdr_tables_pkey; Type: CONSTRAINT; Schema: sys; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY cdr_tables
    ADD CONSTRAINT cdr_tables_pkey PRIMARY KEY (id);


--
-- TOC entry 2636 (class 2606 OID 19986)
-- Name: config_pkey; Type: CONSTRAINT; Schema: sys; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY config
    ADD CONSTRAINT config_pkey PRIMARY KEY (id);


--
-- TOC entry 2544 (class 2606 OID 17249)
-- Name: version_number_key; Type: CONSTRAINT; Schema: sys; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY version
    ADD CONSTRAINT version_number_key UNIQUE (number);


--
-- TOC entry 2546 (class 2606 OID 17247)
-- Name: version_pkey; Type: CONSTRAINT; Schema: sys; Owner: cdr; Tablespace: 
--

ALTER TABLE ONLY version
    ADD CONSTRAINT version_pkey PRIMARY KEY (id);


SET search_path = billing, pg_catalog;

--
-- TOC entry 2614 (class 1259 OID 19752)
-- Name: invoice_destinations_invoice_id_idx; Type: INDEX; Schema: billing; Owner: cdr; Tablespace: 
--

CREATE INDEX invoice_destinations_invoice_id_idx ON invoice_destinations USING btree (invoice_id);


SET search_path = cdr, pg_catalog;

--
-- TOC entry 2575 (class 1259 OID 19391)
-- Name: cdr_201412_time_start_idx; Type: INDEX; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE INDEX cdr_201412_time_start_idx ON cdr_201412 USING btree (time_start);


--
-- TOC entry 2572 (class 1259 OID 19390)
-- Name: cdr_201501_time_start_idx; Type: INDEX; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE INDEX cdr_201501_time_start_idx ON cdr_201501 USING btree (time_start);


--
-- TOC entry 2569 (class 1259 OID 19389)
-- Name: cdr_201502_time_start_idx; Type: INDEX; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE INDEX cdr_201502_time_start_idx ON cdr_201502 USING btree (time_start);


--
-- TOC entry 2630 (class 1259 OID 19853)
-- Name: cdr_201503_time_start_idx; Type: INDEX; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE INDEX cdr_201503_time_start_idx ON cdr_201503 USING btree (time_start);


--
-- TOC entry 2624 (class 1259 OID 19829)
-- Name: cdr_201504_time_start_idx; Type: INDEX; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE INDEX cdr_201504_time_start_idx ON cdr_201504 USING btree (time_start);


--
-- TOC entry 2621 (class 1259 OID 19817)
-- Name: cdr_201505_time_start_idx; Type: INDEX; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE INDEX cdr_201505_time_start_idx ON cdr_201505 USING btree (time_start);


--
-- TOC entry 2627 (class 1259 OID 19841)
-- Name: cdr_201506_time_start_idx; Type: INDEX; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE INDEX cdr_201506_time_start_idx ON cdr_201506 USING btree (time_start);


--
-- TOC entry 2670 (class 1259 OID 28775)
-- Name: cdr_201507_time_start_idx; Type: INDEX; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE INDEX cdr_201507_time_start_idx ON cdr_201507 USING btree (time_start);


--
-- TOC entry 2667 (class 1259 OID 28763)
-- Name: cdr_201508_time_start_idx; Type: INDEX; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE INDEX cdr_201508_time_start_idx ON cdr_201508 USING btree (time_start);


--
-- TOC entry 2673 (class 1259 OID 28787)
-- Name: cdr_201509_time_start_idx; Type: INDEX; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE INDEX cdr_201509_time_start_idx ON cdr_201509 USING btree (time_start);


--
-- TOC entry 2676 (class 1259 OID 28799)
-- Name: cdr_201510_time_start_idx; Type: INDEX; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE INDEX cdr_201510_time_start_idx ON cdr_201510 USING btree (time_start);


--
-- TOC entry 2539 (class 1259 OID 19386)
-- Name: cdr_time_start_idx; Type: INDEX; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE INDEX cdr_time_start_idx ON cdr USING btree (time_start);


--
-- TOC entry 2540 (class 1259 OID 17038)
-- Name: cdr_vendor_invoice_id_idx; Type: INDEX; Schema: cdr; Owner: cdr; Tablespace: 
--

CREATE INDEX cdr_vendor_invoice_id_idx ON cdr USING btree (vendor_invoice_id);


SET search_path = pgq, pg_catalog;

--
-- TOC entry 2547 (class 1259 OID 17500)
-- Name: event_3_0_txid_idx; Type: INDEX; Schema: pgq; Owner: cdr; Tablespace: 
--

CREATE INDEX event_3_0_txid_idx ON event_3_0 USING btree (ev_txid);


--
-- TOC entry 2548 (class 1259 OID 17509)
-- Name: event_3_1_txid_idx; Type: INDEX; Schema: pgq; Owner: cdr; Tablespace: 
--

CREATE INDEX event_3_1_txid_idx ON event_3_1 USING btree (ev_txid);


--
-- TOC entry 2549 (class 1259 OID 17518)
-- Name: event_3_2_txid_idx; Type: INDEX; Schema: pgq; Owner: cdr; Tablespace: 
--

CREATE INDEX event_3_2_txid_idx ON event_3_2 USING btree (ev_txid);


--
-- TOC entry 2520 (class 1259 OID 16742)
-- Name: rq_retry_idx; Type: INDEX; Schema: pgq; Owner: cdr; Tablespace: 
--

CREATE INDEX rq_retry_idx ON retry_queue USING btree (ev_retry_after);


SET search_path = reports, pg_catalog;

--
-- TOC entry 2550 (class 1259 OID 17874)
-- Name: cdr_custom_report_id_idx; Type: INDEX; Schema: reports; Owner: cdr; Tablespace: 
--

CREATE UNIQUE INDEX cdr_custom_report_id_idx ON cdr_custom_report USING btree (id) WHERE (id IS NOT NULL);


--
-- TOC entry 2608 (class 1259 OID 19616)
-- Name: customer_traffic_report_data_report_id_idx; Type: INDEX; Schema: reports; Owner: cdr; Tablespace: 
--

CREATE INDEX customer_traffic_report_data_report_id_idx ON customer_traffic_report_data_by_vendor USING btree (report_id);


--
-- TOC entry 2613 (class 1259 OID 19697)
-- Name: vendor_traffic_report_data_report_id_idx; Type: INDEX; Schema: reports; Owner: cdr; Tablespace: 
--

CREATE INDEX vendor_traffic_report_data_report_id_idx ON vendor_traffic_report_data USING btree (report_id);


SET search_path = stats, pg_catalog;

--
-- TOC entry 2649 (class 1259 OID 20200)
-- Name: termination_quality_stats_dialpeer_id_idx; Type: INDEX; Schema: stats; Owner: cdr; Tablespace: 
--

CREATE INDEX termination_quality_stats_dialpeer_id_idx ON termination_quality_stats USING btree (dialpeer_id);


--
-- TOC entry 2650 (class 1259 OID 20199)
-- Name: termination_quality_stats_gateway_id_idx; Type: INDEX; Schema: stats; Owner: cdr; Tablespace: 
--

CREATE INDEX termination_quality_stats_gateway_id_idx ON termination_quality_stats USING btree (gateway_id);


--
-- TOC entry 2598 (class 1259 OID 19543)
-- Name: traffic_customer_accounts_account_id_timestamp_idx; Type: INDEX; Schema: stats; Owner: cdr; Tablespace: 
--

CREATE UNIQUE INDEX traffic_customer_accounts_account_id_timestamp_idx ON traffic_customer_accounts USING btree (account_id, "timestamp");


--
-- TOC entry 2601 (class 1259 OID 19552)
-- Name: traffic_vendor_accounts_account_id_timestamp_idx; Type: INDEX; Schema: stats; Owner: cdr; Tablespace: 
--

CREATE UNIQUE INDEX traffic_vendor_accounts_account_id_timestamp_idx ON traffic_vendor_accounts USING btree (account_id, "timestamp");


SET search_path = cdr, pg_catalog;

--
-- TOC entry 2702 (class 2620 OID 17039)
-- Name: cdr_i; Type: TRIGGER; Schema: cdr; Owner: cdr
--

CREATE TRIGGER cdr_i BEFORE INSERT ON cdr FOR EACH ROW EXECUTE PROCEDURE cdr_i_tgf();


SET search_path = billing, pg_catalog;

--
-- TOC entry 2695 (class 2606 OID 19746)
-- Name: invoice_destinations_invoice_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: cdr
--

ALTER TABLE ONLY invoice_destinations
    ADD CONSTRAINT invoice_destinations_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES invoices(id);


--
-- TOC entry 2696 (class 2606 OID 19789)
-- Name: invoice_documents_invoice_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: cdr
--

ALTER TABLE ONLY invoice_documents
    ADD CONSTRAINT invoice_documents_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES invoices(id);


--
-- TOC entry 2692 (class 2606 OID 20280)
-- Name: invoices_state_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: cdr
--

ALTER TABLE ONLY invoices
    ADD CONSTRAINT invoices_state_id_fkey FOREIGN KEY (state_id) REFERENCES invoice_states(id);


--
-- TOC entry 2691 (class 2606 OID 28747)
-- Name: invoices_type_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: cdr
--

ALTER TABLE ONLY invoices
    ADD CONSTRAINT invoices_type_id_fkey FOREIGN KEY (type_id) REFERENCES invoice_types(id);


SET search_path = pgq, pg_catalog;

--
-- TOC entry 2680 (class 2606 OID 16737)
-- Name: rq_queue_id_fkey; Type: FK CONSTRAINT; Schema: pgq; Owner: cdr
--

ALTER TABLE ONLY retry_queue
    ADD CONSTRAINT rq_queue_id_fkey FOREIGN KEY (ev_queue) REFERENCES queue(queue_id);


--
-- TOC entry 2679 (class 2606 OID 16717)
-- Name: sub_consumer_fkey; Type: FK CONSTRAINT; Schema: pgq; Owner: cdr
--

ALTER TABLE ONLY subscription
    ADD CONSTRAINT sub_consumer_fkey FOREIGN KEY (sub_consumer) REFERENCES consumer(co_id);


--
-- TOC entry 2678 (class 2606 OID 16712)
-- Name: sub_queue_fkey; Type: FK CONSTRAINT; Schema: pgq; Owner: cdr
--

ALTER TABLE ONLY subscription
    ADD CONSTRAINT sub_queue_fkey FOREIGN KEY (sub_queue) REFERENCES queue(queue_id);


--
-- TOC entry 2677 (class 2606 OID 16694)
-- Name: tick_queue_fkey; Type: FK CONSTRAINT; Schema: pgq; Owner: cdr
--

ALTER TABLE ONLY tick
    ADD CONSTRAINT tick_queue_fkey FOREIGN KEY (tick_queue) REFERENCES queue(queue_id);


SET search_path = pgq_node, pg_catalog;

--
-- TOC entry 2682 (class 2606 OID 16884)
-- Name: local_state_queue_name_fkey; Type: FK CONSTRAINT; Schema: pgq_node; Owner: cdr
--

ALTER TABLE ONLY local_state
    ADD CONSTRAINT local_state_queue_name_fkey FOREIGN KEY (queue_name) REFERENCES node_info(queue_name);


--
-- TOC entry 2683 (class 2606 OID 16889)
-- Name: local_state_queue_name_fkey1; Type: FK CONSTRAINT; Schema: pgq_node; Owner: cdr
--

ALTER TABLE ONLY local_state
    ADD CONSTRAINT local_state_queue_name_fkey1 FOREIGN KEY (queue_name, provider_node) REFERENCES node_location(queue_name, node_name);


--
-- TOC entry 2681 (class 2606 OID 16869)
-- Name: node_info_queue_name_fkey; Type: FK CONSTRAINT; Schema: pgq_node; Owner: cdr
--

ALTER TABLE ONLY node_info
    ADD CONSTRAINT node_info_queue_name_fkey FOREIGN KEY (queue_name, node_name) REFERENCES node_location(queue_name, node_name);


--
-- TOC entry 2684 (class 2606 OID 16902)
-- Name: subscriber_info_queue_name_fkey; Type: FK CONSTRAINT; Schema: pgq_node; Owner: cdr
--

ALTER TABLE ONLY subscriber_info
    ADD CONSTRAINT subscriber_info_queue_name_fkey FOREIGN KEY (queue_name, subscriber_node) REFERENCES node_location(queue_name, node_name);


--
-- TOC entry 2686 (class 2606 OID 16912)
-- Name: subscriber_info_watermark_name_fkey; Type: FK CONSTRAINT; Schema: pgq_node; Owner: cdr
--

ALTER TABLE ONLY subscriber_info
    ADD CONSTRAINT subscriber_info_watermark_name_fkey FOREIGN KEY (watermark_name) REFERENCES pgq.consumer(co_name);


--
-- TOC entry 2685 (class 2606 OID 16907)
-- Name: subscriber_info_worker_name_fkey; Type: FK CONSTRAINT; Schema: pgq_node; Owner: cdr
--

ALTER TABLE ONLY subscriber_info
    ADD CONSTRAINT subscriber_info_worker_name_fkey FOREIGN KEY (worker_name) REFERENCES pgq.consumer(co_name);


SET search_path = reports, pg_catalog;

--
-- TOC entry 2687 (class 2606 OID 17875)
-- Name: cdr_custom_report_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY cdr_custom_report_data
    ADD CONSTRAINT cdr_custom_report_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES cdr_custom_report(id);


--
-- TOC entry 2700 (class 2606 OID 20131)
-- Name: cdr_custom_report_schedulers_period_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY cdr_custom_report_schedulers
    ADD CONSTRAINT cdr_custom_report_schedulers_period_id_fkey FOREIGN KEY (period_id) REFERENCES scheduler_periods(id);


--
-- TOC entry 2688 (class 2606 OID 17880)
-- Name: cdr_interval_report_aggregator_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY cdr_interval_report
    ADD CONSTRAINT cdr_interval_report_aggregator_id_fkey FOREIGN KEY (aggregator_id) REFERENCES cdr_interval_report_aggrerator(id);


--
-- TOC entry 2689 (class 2606 OID 17885)
-- Name: cdr_interval_report_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY cdr_interval_report_data
    ADD CONSTRAINT cdr_interval_report_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES cdr_interval_report(id);


--
-- TOC entry 2701 (class 2606 OID 20147)
-- Name: cdr_interval_report_schedulers_period_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY cdr_interval_report_schedulers
    ADD CONSTRAINT cdr_interval_report_schedulers_period_id_fkey FOREIGN KEY (period_id) REFERENCES scheduler_periods(id);


--
-- TOC entry 2693 (class 2606 OID 19611)
-- Name: customer_traffic_report_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY customer_traffic_report_data_by_vendor
    ADD CONSTRAINT customer_traffic_report_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES customer_traffic_report(id);


--
-- TOC entry 2698 (class 2606 OID 20099)
-- Name: customer_traffic_report_schedulers_period_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY customer_traffic_report_schedulers
    ADD CONSTRAINT customer_traffic_report_schedulers_period_id_fkey FOREIGN KEY (period_id) REFERENCES scheduler_periods(id);


--
-- TOC entry 2690 (class 2606 OID 17890)
-- Name: report_vendors_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY report_vendors_data
    ADD CONSTRAINT report_vendors_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES report_vendors(id);


--
-- TOC entry 2694 (class 2606 OID 19692)
-- Name: vendor_traffic_report_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY vendor_traffic_report_data
    ADD CONSTRAINT vendor_traffic_report_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES vendor_traffic_report(id);


--
-- TOC entry 2699 (class 2606 OID 20115)
-- Name: vendor_traffic_report_schedulers_period_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: cdr
--

ALTER TABLE ONLY vendor_traffic_report_schedulers
    ADD CONSTRAINT vendor_traffic_report_schedulers_period_id_fkey FOREIGN KEY (period_id) REFERENCES scheduler_periods(id);


SET search_path = sys, pg_catalog;

--
-- TOC entry 2697 (class 2606 OID 19987)
-- Name: config_call_duration_round_mode_id_fkey; Type: FK CONSTRAINT; Schema: sys; Owner: cdr
--

ALTER TABLE ONLY config
    ADD CONSTRAINT config_call_duration_round_mode_id_fkey FOREIGN KEY (call_duration_round_mode_id) REFERENCES call_duration_round_modes(id);


--
-- TOC entry 2815 (class 0 OID 0)
-- Dependencies: 7
-- Name: pgq; Type: ACL; Schema: -; Owner: cdr
--

REVOKE ALL ON SCHEMA pgq FROM PUBLIC;
REVOKE ALL ON SCHEMA pgq FROM cdr;
GRANT ALL ON SCHEMA pgq TO cdr;
GRANT USAGE ON SCHEMA pgq TO PUBLIC;


--
-- TOC entry 2816 (class 0 OID 0)
-- Dependencies: 10
-- Name: pgq_coop; Type: ACL; Schema: -; Owner: cdr
--

REVOKE ALL ON SCHEMA pgq_coop FROM PUBLIC;
REVOKE ALL ON SCHEMA pgq_coop FROM cdr;
GRANT ALL ON SCHEMA pgq_coop TO cdr;
GRANT USAGE ON SCHEMA pgq_coop TO PUBLIC;


--
-- TOC entry 2817 (class 0 OID 0)
-- Dependencies: 8
-- Name: pgq_ext; Type: ACL; Schema: -; Owner: cdr
--

REVOKE ALL ON SCHEMA pgq_ext FROM PUBLIC;
REVOKE ALL ON SCHEMA pgq_ext FROM cdr;
GRANT ALL ON SCHEMA pgq_ext TO cdr;
GRANT USAGE ON SCHEMA pgq_ext TO PUBLIC;


--
-- TOC entry 2818 (class 0 OID 0)
-- Dependencies: 9
-- Name: pgq_node; Type: ACL; Schema: -; Owner: cdr
--

REVOKE ALL ON SCHEMA pgq_node FROM PUBLIC;
REVOKE ALL ON SCHEMA pgq_node FROM cdr;
GRANT ALL ON SCHEMA pgq_node TO cdr;
GRANT USAGE ON SCHEMA pgq_node TO PUBLIC;


--
-- TOC entry 2820 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


SET search_path = pgq, pg_catalog;

--
-- TOC entry 2826 (class 0 OID 0)
-- Dependencies: 182
-- Name: consumer; Type: ACL; Schema: pgq; Owner: cdr
--

REVOKE ALL ON TABLE consumer FROM PUBLIC;
REVOKE ALL ON TABLE consumer FROM cdr;
GRANT ALL ON TABLE consumer TO cdr;
GRANT SELECT ON TABLE consumer TO PUBLIC;


--
-- TOC entry 2828 (class 0 OID 0)
-- Dependencies: 189
-- Name: event_template; Type: ACL; Schema: pgq; Owner: cdr
--

REVOKE ALL ON TABLE event_template FROM PUBLIC;
REVOKE ALL ON TABLE event_template FROM cdr;
GRANT ALL ON TABLE event_template TO cdr;
GRANT SELECT ON TABLE event_template TO PUBLIC;


--
-- TOC entry 2829 (class 0 OID 0)
-- Dependencies: 209
-- Name: event_3; Type: ACL; Schema: pgq; Owner: cdr
--

REVOKE ALL ON TABLE event_3 FROM PUBLIC;
GRANT SELECT ON TABLE event_3 TO PUBLIC;


--
-- TOC entry 2830 (class 0 OID 0)
-- Dependencies: 210
-- Name: event_3_0; Type: ACL; Schema: pgq; Owner: cdr
--

REVOKE ALL ON TABLE event_3_0 FROM PUBLIC;
GRANT SELECT ON TABLE event_3_0 TO PUBLIC;


--
-- TOC entry 2831 (class 0 OID 0)
-- Dependencies: 211
-- Name: event_3_1; Type: ACL; Schema: pgq; Owner: cdr
--

REVOKE ALL ON TABLE event_3_1 FROM PUBLIC;
GRANT SELECT ON TABLE event_3_1 TO PUBLIC;


--
-- TOC entry 2832 (class 0 OID 0)
-- Dependencies: 212
-- Name: event_3_2; Type: ACL; Schema: pgq; Owner: cdr
--

REVOKE ALL ON TABLE event_3_2 FROM PUBLIC;
GRANT SELECT ON TABLE event_3_2 TO PUBLIC;


--
-- TOC entry 2833 (class 0 OID 0)
-- Dependencies: 208
-- Name: event_3_id_seq; Type: ACL; Schema: pgq; Owner: cdr
--

REVOKE ALL ON SEQUENCE event_3_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE event_3_id_seq FROM cdr;
GRANT ALL ON SEQUENCE event_3_id_seq TO cdr;
GRANT SELECT ON SEQUENCE event_3_id_seq TO PUBLIC;


--
-- TOC entry 2834 (class 0 OID 0)
-- Dependencies: 207
-- Name: event_3_tick_seq; Type: ACL; Schema: pgq; Owner: cdr
--

REVOKE ALL ON SEQUENCE event_3_tick_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE event_3_tick_seq FROM cdr;
GRANT ALL ON SEQUENCE event_3_tick_seq TO cdr;
GRANT SELECT ON SEQUENCE event_3_tick_seq TO PUBLIC;


--
-- TOC entry 2835 (class 0 OID 0)
-- Dependencies: 184
-- Name: queue; Type: ACL; Schema: pgq; Owner: cdr
--

REVOKE ALL ON TABLE queue FROM PUBLIC;
REVOKE ALL ON TABLE queue FROM cdr;
GRANT ALL ON TABLE queue TO cdr;
GRANT SELECT ON TABLE queue TO PUBLIC;


--
-- TOC entry 2837 (class 0 OID 0)
-- Dependencies: 190
-- Name: retry_queue; Type: ACL; Schema: pgq; Owner: cdr
--

REVOKE ALL ON TABLE retry_queue FROM PUBLIC;
REVOKE ALL ON TABLE retry_queue FROM cdr;
GRANT ALL ON TABLE retry_queue TO cdr;
GRANT SELECT ON TABLE retry_queue TO PUBLIC;


--
-- TOC entry 2838 (class 0 OID 0)
-- Dependencies: 188
-- Name: subscription; Type: ACL; Schema: pgq; Owner: cdr
--

REVOKE ALL ON TABLE subscription FROM PUBLIC;
REVOKE ALL ON TABLE subscription FROM cdr;
GRANT ALL ON TABLE subscription TO cdr;
GRANT SELECT ON TABLE subscription TO PUBLIC;


--
-- TOC entry 2840 (class 0 OID 0)
-- Dependencies: 185
-- Name: tick; Type: ACL; Schema: pgq; Owner: cdr
--

REVOKE ALL ON TABLE tick FROM PUBLIC;
REVOKE ALL ON TABLE tick FROM cdr;
GRANT ALL ON TABLE tick TO cdr;
GRANT SELECT ON TABLE tick TO PUBLIC;


-- Completed on 2015-07-04 23:06:11 EEST

--
-- PostgreSQL database dump complete
--

