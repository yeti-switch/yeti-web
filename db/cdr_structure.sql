SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth_log; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth_log;


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
-- Name: external_data; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA external_data;


--
-- Name: pgq; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgq WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION pgq; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgq IS 'Generic queue for PostgreSQL';


--
-- Name: pgq_ext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgq_ext WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION pgq_ext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgq_ext IS 'Target-side batch tracking infrastructure';


--
-- Name: reports; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA reports;


--
-- Name: rtp_statistics; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA rtp_statistics;


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
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: interval_billing_data; Type: TYPE; Schema: billing; Owner: -
--

CREATE TYPE billing.interval_billing_data AS (
	duration numeric,
	amount numeric,
	amount_no_vat numeric
);


--
-- Name: rx_stream_ty; Type: TYPE; Schema: rtp_statistics; Owner: -
--

CREATE TYPE rtp_statistics.rx_stream_ty AS (
	rx_ssrc bigint,
	local_host inet,
	local_port integer,
	remote_host inet,
	remote_port integer,
	rx_packets bigint,
	rx_bytes bigint,
	rx_total_lost bigint,
	rx_payloads_transcoded character varying,
	rx_payloads_relayed character varying,
	rx_decode_errors bigint,
	rx_packet_delta_min real,
	rx_packet_delta_max real,
	rx_packet_delta_mean real,
	rx_packet_delta_std real,
	rx_packet_jitter_min real,
	rx_packet_jitter_max real,
	rx_packet_jitter_mean real,
	rx_packet_jitter_std real,
	rx_rtcp_jitter_min real,
	rx_rtcp_jitter_max real,
	rx_rtcp_jitter_mean real,
	rx_rtcp_jitter_std real
);


--
-- Name: tx_stream_ty; Type: TYPE; Schema: rtp_statistics; Owner: -
--

CREATE TYPE rtp_statistics.tx_stream_ty AS (
	time_start double precision,
	time_end double precision,
	local_tag character varying,
	rtcp_rtt_min real,
	rtcp_rtt_max real,
	rtcp_rtt_mean real,
	rtcp_rtt_std real,
	rx_out_of_buffer_errors bigint,
	rx_rtp_parse_errors bigint,
	rx_dropped_packets bigint,
	tx_packets bigint,
	tx_bytes bigint,
	tx_ssrc bigint,
	local_host inet,
	local_port integer,
	tx_total_lost integer,
	tx_payloads_transcoded character varying,
	tx_payloads_relayed character varying,
	tx_rtcp_jitter_min real,
	tx_rtcp_jitter_max real,
	tx_rtcp_jitter_mean real,
	tx_rtcp_jitter_std real,
	rx rtp_statistics.rx_stream_ty[],
	rx_srtp_decrypt_errors bigint
);


--
-- Name: async_cdr_statistics_ty; Type: TYPE; Schema: switch; Owner: -
--

CREATE TYPE switch.async_cdr_statistics_ty AS (
	processed_records integer,
	data json
);


--
-- Name: dynamic_cdr_data_ty; Type: TYPE; Schema: switch; Owner: -
--

CREATE TYPE switch.dynamic_cdr_data_ty AS (
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
	customer_auth_name character varying,
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
	dialpeer_reverse_billing boolean,
	src_country_id integer,
	src_network_id integer,
	lega_ss_status_id smallint,
	legb_ss_status_id smallint,
	metadata character varying,
	customer_auth_external_type character varying,
	package_counter_id bigint,
	src_network_type_id smallint,
	dst_network_type_id smallint
);


--
-- Name: reason_ty; Type: TYPE; Schema: switch; Owner: -
--

CREATE TYPE switch.reason_ty AS (
	q850_cause smallint,
	q850_text character varying,
	q850_params character varying
);


--
-- Name: lega_headers_ty; Type: TYPE; Schema: switch; Owner: -
--

CREATE TYPE switch.lega_headers_ty AS (
	p_charge_info character varying,
	reason switch.reason_ty
);


--
-- Name: lega_request_headers_ty; Type: TYPE; Schema: switch; Owner: -
--

CREATE TYPE switch.lega_request_headers_ty AS (
	p_charge_info character varying,
	reason switch.reason_ty,
	diversion character varying[],
	p_asserted_identity character varying[],
	p_preferred_identity character varying,
	privacy character varying[],
	remote_party_id character varying[],
	rpid_privacy character varying[]
);


--
-- Name: legb_headers_ty; Type: TYPE; Schema: switch; Owner: -
--

CREATE TYPE switch.legb_headers_ty AS (
	reason switch.reason_ty
);


--
-- Name: legb_reply_headers_ty; Type: TYPE; Schema: switch; Owner: -
--

CREATE TYPE switch.legb_reply_headers_ty AS (
	reason switch.reason_ty
);


--
-- Name: legb_request_headers_ty; Type: TYPE; Schema: switch; Owner: -
--

CREATE TYPE switch.legb_request_headers_ty AS (
	diversion character varying[],
	p_asserted_identity character varying[],
	p_preferred_identity character varying,
	privacy character varying[],
	remote_party_id character varying[],
	rpid_privacy character varying[]
);


--
-- Name: rtp_stats_data_ty; Type: TYPE; Schema: switch; Owner: -
--

CREATE TYPE switch.rtp_stats_data_ty AS (
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

CREATE TYPE switch.time_data_ty AS (
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

CREATE TYPE switch.versions_ty AS (
	core character varying,
	yeti character varying,
	aleg character varying,
	bleg character varying
);


SET default_tablespace = '';

--
-- Name: cdr; Type: TABLE; Schema: cdr; Owner: -
--

CREATE TABLE cdr.cdr (
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
    time_start timestamp with time zone NOT NULL,
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
    legb_disconnect_code integer,
    legb_disconnect_reason character varying,
    auth_orig_ip inet,
    auth_orig_port integer,
    global_tag character varying,
    dst_country_id integer,
    dst_network_id integer,
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
    vendor_duration integer,
    customer_auth_name character varying,
    legb_local_tag character varying,
    legb_ruri character varying,
    legb_outbound_proxy character varying,
    p_charge_info_in character varying,
    src_country_id integer,
    src_network_id integer,
    lega_identity jsonb,
    lega_ss_status_id smallint,
    legb_ss_status_id smallint,
    dump_level_id smallint,
    metadata jsonb,
    customer_auth_external_type character varying,
    lega_q850_text character varying,
    legb_q850_text character varying,
    lega_q850_cause smallint,
    lega_q850_params character varying,
    legb_q850_cause smallint,
    legb_q850_params character varying,
    internal_disconnect_code_id smallint,
    package_counter_id bigint,
    src_network_type_id smallint,
    dst_network_type_id smallint
)
PARTITION BY RANGE (time_start);


--
-- Name: bill_cdr(cdr.cdr); Type: FUNCTION; Schema: billing; Owner: -
--

CREATE FUNCTION billing.bill_cdr(i_cdr cdr.cdr) RETURNS cdr.cdr
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    _v billing.interval_billing_data%rowtype;
BEGIN
    if i_cdr.duration>0 and i_cdr.success then  -- run billing.
        if i_cdr.package_counter_id is not null then
          -- running billing with fake rates to calculate duration
          _v=billing.interval_billing(
            i_cdr.duration,
            '1.0'::numeric,
            '1.0'::numeric,
            '1.0'::numeric,
            i_cdr.destination_initial_interval,
            i_cdr.destination_next_interval,
            0::integer);
         i_cdr.customer_price=0;
         i_cdr.customer_price_no_vat=0;
         i_cdr.customer_duration=_v.duration;
        else
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
        end if;

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
        i_cdr.customer_price_no_vat=0;
        i_cdr.vendor_price=0;
        i_cdr.profit=0;
    end if;
    RETURN i_cdr;
END;
$$;


--
-- Name: interval_billing(numeric, numeric, numeric, numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: billing; Owner: -
--

CREATE FUNCTION billing.interval_billing(i_duration numeric, i_connection_fee numeric, i_initial_rate numeric, i_next_rate numeric, i_initial_interval numeric, i_next_interval numeric, i_vat numeric DEFAULT 0) RETURNS billing.interval_billing_data
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

    _v.amount=_v.amount_no_vat*(1+i_vat/100);

    _v.duration=i_initial_interval+(i_duration>i_initial_interval)::boolean::integer * CEIL((i_duration-i_initial_interval)::numeric/i_next_interval) *i_next_interval;

    RETURN _v;
END;
$$;


--
-- Name: billing_insert_event(text, anyelement); Type: FUNCTION; Schema: event; Owner: -
--

CREATE FUNCTION event.billing_insert_event(ev_type text, ev_data anyelement) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
begin
    return pgq.insert_event('cdr_billing', ev_type, event.serialize(ev_data), null, null, null, null);
end;
$$;


--
-- Name: rtp_streams_insert_event(character varying, anyelement); Type: FUNCTION; Schema: event; Owner: -
--

CREATE FUNCTION event.rtp_streams_insert_event(ev_type character varying, ev_data anyelement) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
begin
    return pgq.insert_event(ev_type, ev_type, event.serialize(ev_data), null, null, null, null);
end;
$$;


--
-- Name: serialize(anyelement); Type: FUNCTION; Schema: event; Owner: -
--

CREATE FUNCTION event.serialize(i_data anyelement) RETURNS text
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    _s text;
BEGIN
    _s:=row_to_json(i_data,false);
    return _s;
END;
$$;


--
-- Name: streaming_insert_event(anyelement); Type: FUNCTION; Schema: event; Owner: -
--

CREATE FUNCTION event.streaming_insert_event(ev_data anyelement) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
begin
    return pgq.insert_event('cdr_streaming', 'cdr', event.serialize(ev_data), null, null, null, null);
end;
$$;


--
-- Name: update_rt_stats(cdr.cdr); Type: FUNCTION; Schema: stats; Owner: -
--

CREATE FUNCTION stats.update_rt_stats(i_cdr cdr.cdr) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
BEGIN
    perform pgq.insert_event('async_cdr_statistics', 'cdr', event.serialize(i_cdr), null, null, null, null);
    RETURN ;
END;
$$;


--
-- Name: async_cdr_statistics(); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION switch.async_cdr_statistics() RETURNS switch.async_cdr_statistics_ty
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


SET default_table_access_method = heap;

--
-- Name: config; Type: TABLE; Schema: sys; Owner: -
--

CREATE TABLE sys.config (
    id smallint NOT NULL,
    call_duration_round_mode_id smallint DEFAULT 1 NOT NULL,
    customer_amount_round_mode_id smallint DEFAULT 1 NOT NULL,
    customer_amount_round_precision smallint DEFAULT 5 NOT NULL,
    vendor_amount_round_mode_id smallint DEFAULT 1 NOT NULL,
    vendor_amount_round_precision smallint DEFAULT 5 NOT NULL,
    disable_realtime_statistics boolean DEFAULT false NOT NULL,
    CONSTRAINT config_customer_amount_round_precision_check CHECK (((customer_amount_round_precision >= 0) AND (customer_amount_round_precision <= 10))),
    CONSTRAINT config_vendor_amount_round_precision_check CHECK (((vendor_amount_round_precision >= 0) AND (vendor_amount_round_precision <= 10)))
);


--
-- Name: customer_price_round(sys.config, numeric); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION switch.customer_price_round(i_config sys.config, i_amount numeric) RETURNS numeric
    LANGUAGE plpgsql COST 10
    AS $$
      DECLARE
      BEGIN

        case i_config.customer_amount_round_mode_id
        when 1 then -- disable rounding
        return i_amount;
        when 2 then --always up
        return trunc(i_amount, i_config.customer_amount_round_precision) +
          (mod(i_amount::numeric, power(10,-i_config.customer_amount_round_precision)::numeric)>0)::int*power(10,-i_config.customer_amount_round_precision);
        when 3 then --always down
        return trunc(i_amount, i_config.customer_amount_round_precision);
        when 4 then -- math
        return round(i_amount, i_config.customer_amount_round_precision);
        else -- fallback to math rules
        return round(i_amount, i_config.customer_amount_round_precision);
        end case;
        END;
        $$;


--
-- Name: duration_round(sys.config, double precision); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION switch.duration_round(i_config sys.config, i_duration double precision) RETURNS integer
    LANGUAGE plpgsql COST 10
    AS $$
  DECLARE

  BEGIN

    case i_config.call_duration_round_mode_id
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
-- Name: process_cdr_statistics(json); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION switch.process_cdr_statistics(i_cdrs json) RETURNS integer
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


--
-- Name: vendor_price_round(sys.config, numeric); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION switch.vendor_price_round(i_config sys.config, i_amount numeric) RETURNS numeric
    LANGUAGE plpgsql COST 10
    AS $$
    DECLARE

    BEGIN

      case i_config.vendor_amount_round_mode_id
      when 1 then -- disable rounding
      return i_amount;
      when 2 then --always up
      return trunc(i_amount, i_config.vendor_amount_round_precision) +
        (mod(i_amount::numeric, power(10,-i_config.vendor_amount_round_precision)::numeric)>0)::int*power(10,-i_config.vendor_amount_round_precision);
      when 3 then --always down
      return trunc(i_amount, i_config.vendor_amount_round_precision);
      when 4 then -- math
      return round(i_amount, i_config.vendor_amount_round_precision);
      else -- fallback to math rules
      return round(i_amount, i_config.vendor_amount_round_precision);
      end case;
      END;
      $$;


--
-- Name: write_auth_log(boolean, integer, integer, double precision, smallint, character varying, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, boolean, smallint, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, integer, smallint, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION switch.write_auth_log(i_is_master boolean, i_node_id integer, i_pop_id integer, i_request_time double precision, i_transport_proto_id smallint, i_transport_remote_ip character varying, i_transport_remote_port integer, i_transport_local_ip character varying, i_transport_local_port integer, i_username character varying, i_realm character varying, i_method character varying, i_ruri character varying, i_from_uri character varying, i_to_uri character varying, i_call_id character varying, i_success boolean, i_code smallint, i_reason character varying, i_internal_reason character varying, i_nonce character varying, i_response character varying, i_gateway_id integer, i_x_yeti_auth character varying, i_diversion character varying, i_origination_ip character varying, i_origination_port integer, i_origination_proto_id smallint, i_pai character varying, i_ppi character varying, i_privacy character varying, i_rpid character varying, i_rpid_privacy character varying) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE

    v_log auth_log.auth_log%rowtype;
BEGIN

  v_log.node_id = i_node_id;
  v_log.pop_id = i_pop_id;
  v_log.request_time = to_timestamp(i_request_time);
  v_log.transport_proto_id = i_transport_proto_id;
  v_log.transport_remote_ip = i_transport_remote_ip;
  v_log.transport_remote_port = i_transport_remote_port;
  v_log.transport_local_ip = i_transport_local_ip;
  v_log.transport_local_port = i_transport_local_port;
  v_log.origination_ip = i_origination_ip;
  v_log.origination_port = i_origination_port;
  v_log.origination_proto_id = i_origination_proto_id;
  v_log.username = i_username;
  v_log.realm = i_realm;
  v_log.request_method = i_method;
  v_log.ruri = i_ruri;
  v_log.from_uri = i_from_uri;
  v_log.to_uri = i_to_uri;
  v_log.call_id = i_call_id;
  v_log.success = i_success;
  v_log.code = i_code;
  v_log.reason = i_reason;
  v_log.internal_reason = i_internal_reason;
  v_log.nonce = i_nonce;
  v_log.response = i_response;
  v_log.gateway_id = i_gateway_id;
  v_log.x_yeti_auth = i_x_yeti_auth;
  v_log.diversion = i_diversion;
  v_log.pai = i_pai;
  v_log.ppi = i_ppi;
  v_log.privacy = i_privacy;
  v_log.rpid = i_rpid;
  v_log.rpid_privacy = i_rpid_privacy;

  v_log.id = nextval('auth_log.auth_log_id_seq');

  insert into auth_log.auth_log values(v_log.*);

  RETURN 0;
END;
$$;


--
-- Name: write_rtp_statistics(json, integer, integer, bigint, bigint, bigint, bigint, character varying, character varying); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION switch.write_rtp_statistics(i_data json, i_pop_id integer, i_node_id integer, i_lega_gateway_id bigint, i_lega_gateway_external_id bigint, i_legb_gateway_id bigint, i_legb_gateway_external_id bigint, i_lega_local_tag character varying, i_legb_local_tag character varying) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_rx rtp_statistics.rx_stream_ty;
  v_tx_stream rtp_statistics.tx_stream_ty;
  v_rtp_rx_stream_data rtp_statistics.rx_streams%rowtype;
  v_rtp_tx_stream_data rtp_statistics.tx_streams%rowtype;
BEGIN

  if i_data is null or json_array_length(i_data)=0 then
    return;
  end if;

  for v_tx_stream IN select * from json_populate_recordset(null::rtp_statistics.tx_stream_ty,i_data) LOOP

        if v_tx_stream.local_tag = i_lega_local_tag then
          -- legA stream
          v_rtp_tx_stream_data.gateway_id = i_lega_gateway_id;
          v_rtp_tx_stream_data.gateway_external_id = i_lega_gateway_external_id;
        elsif v_tx_stream.local_tag = i_legb_local_tag then
          -- legb stream
          v_rtp_tx_stream_data.gateway_id = i_legb_gateway_id;
          v_rtp_tx_stream_data.gateway_external_id = i_legb_gateway_external_id;
        else
          -- unknown stream
        end if;

        v_rtp_tx_stream_data.id=nextval('rtp_statistics.tx_streams_id_seq'::regclass);
        v_rtp_tx_stream_data.pop_id=i_pop_id;
        v_rtp_tx_stream_data.node_id=i_node_id;
        v_rtp_tx_stream_data.local_tag=v_tx_stream.local_tag;

        v_rtp_tx_stream_data.time_start=to_timestamp(v_tx_stream.time_start);
        v_rtp_tx_stream_data.time_end=to_timestamp(v_tx_stream.time_end);

        v_rtp_tx_stream_data.rtcp_rtt_min=v_tx_stream.rtcp_rtt_min;
        v_rtp_tx_stream_data.rtcp_rtt_max=v_tx_stream.rtcp_rtt_max;
        v_rtp_tx_stream_data.rtcp_rtt_mean=v_tx_stream.rtcp_rtt_mean;
        v_rtp_tx_stream_data.rtcp_rtt_std=v_tx_stream.rtcp_rtt_std;
        v_rtp_tx_stream_data.rx_out_of_buffer_errors=v_tx_stream.rx_out_of_buffer_errors;
        v_rtp_tx_stream_data.rx_rtp_parse_errors=v_tx_stream.rx_rtp_parse_errors;
        v_rtp_tx_stream_data.rx_dropped_packets=v_tx_stream.rx_dropped_packets;
        v_rtp_tx_stream_data.rx_srtp_decrypt_errors = v_tx_stream.rx_srtp_decrypt_errors;
        v_rtp_tx_stream_data.tx_packets=v_tx_stream.tx_packets;
        v_rtp_tx_stream_data.tx_bytes=v_tx_stream.tx_bytes;
        v_rtp_tx_stream_data.tx_ssrc=v_tx_stream.tx_ssrc;
        v_rtp_tx_stream_data.local_host=v_tx_stream.local_host;
        v_rtp_tx_stream_data.local_port=v_tx_stream.local_port;
        v_rtp_tx_stream_data.tx_total_lost=v_tx_stream.tx_total_lost;

        v_rtp_tx_stream_data.tx_payloads_transcoded=string_to_array(v_tx_stream.tx_payloads_transcoded,',');
        v_rtp_tx_stream_data.tx_payloads_relayed=string_to_array(v_tx_stream.tx_payloads_relayed,',');

        v_rtp_tx_stream_data.tx_rtcp_jitter_min=v_tx_stream.tx_rtcp_jitter_min;
        v_rtp_tx_stream_data.tx_rtcp_jitter_max=v_tx_stream.tx_rtcp_jitter_max;
        v_rtp_tx_stream_data.tx_rtcp_jitter_mean=v_tx_stream.tx_rtcp_jitter_mean;
        v_rtp_tx_stream_data.tx_rtcp_jitter_std=v_tx_stream.tx_rtcp_jitter_std;

        INSERT INTO rtp_statistics.tx_streams VALUES(v_rtp_tx_stream_data.*);
        PERFORM event.rtp_streams_insert_event('rtp_tx_stream', v_rtp_tx_stream_data);

        FOREACH v_rx IN ARRAY v_tx_stream.rx LOOP
          v_rtp_rx_stream_data = NULL;
          v_rtp_rx_stream_data.id=nextval('rtp_statistics.rx_streams_id_seq'::regclass);
          v_rtp_rx_stream_data.tx_stream_id = v_rtp_tx_stream_data.id;
          v_rtp_rx_stream_data.time_start = v_rtp_tx_stream_data.time_start;
          v_rtp_rx_stream_data.time_end = v_rtp_tx_stream_data.time_end;

          v_rtp_rx_stream_data.pop_id=v_rtp_tx_stream_data.pop_id;
          v_rtp_rx_stream_data.node_id=v_rtp_tx_stream_data.node_id;
          v_rtp_rx_stream_data.gateway_id=v_rtp_tx_stream_data.gateway_id;
          v_rtp_rx_stream_data.gateway_external_id=v_rtp_tx_stream_data.gateway_external_id;

          v_rtp_rx_stream_data.local_tag=v_tx_stream.local_tag;
          v_rtp_rx_stream_data.rx_ssrc=v_rx.rx_ssrc;

          -- local socket info from TX stream
          v_rtp_rx_stream_data.local_host = v_tx_stream.local_host;
          v_rtp_rx_stream_data.remote_port = v_tx_stream.local_port;

          v_rtp_rx_stream_data.remote_host=v_rx.remote_host;
          v_rtp_rx_stream_data.remote_port=v_rx.remote_port;
          v_rtp_rx_stream_data.rx_packets=v_rx.rx_packets;
          v_rtp_rx_stream_data.rx_bytes=v_rx.rx_bytes;
          v_rtp_rx_stream_data.rx_total_lost=v_rx.rx_total_lost;
          v_rtp_rx_stream_data.rx_payloads_transcoded=string_to_array(v_rx.rx_payloads_transcoded,',');
          v_rtp_rx_stream_data.rx_payloads_relayed=string_to_array(v_rx.rx_payloads_relayed,',');
          v_rtp_rx_stream_data.rx_decode_errors=v_rx.rx_decode_errors;
          v_rtp_rx_stream_data.rx_packet_delta_min=v_rx.rx_packet_delta_min;
          v_rtp_rx_stream_data.rx_packet_delta_max=v_rx.rx_packet_delta_max;
          v_rtp_rx_stream_data.rx_packet_delta_mean=v_rx.rx_packet_delta_mean;
          v_rtp_rx_stream_data.rx_packet_delta_std=v_rx.rx_packet_delta_std;
          v_rtp_rx_stream_data.rx_packet_jitter_min=v_rx.rx_packet_jitter_min;
          v_rtp_rx_stream_data.rx_packet_jitter_max=v_rx.rx_packet_jitter_max;
          v_rtp_rx_stream_data.rx_packet_jitter_mean=v_rx.rx_packet_jitter_mean;
          v_rtp_rx_stream_data.rx_packet_jitter_std=v_rx.rx_packet_jitter_std;
          v_rtp_rx_stream_data.rx_rtcp_jitter_min=v_rx.rx_rtcp_jitter_min;
          v_rtp_rx_stream_data.rx_rtcp_jitter_max=v_rx.rx_rtcp_jitter_max;
          v_rtp_rx_stream_data.rx_rtcp_jitter_mean=v_rx.rx_rtcp_jitter_mean;
          v_rtp_rx_stream_data.rx_rtcp_jitter_std=v_rx.rx_rtcp_jitter_std;

          INSERT INTO rtp_statistics.rx_streams VALUES(v_rtp_rx_stream_data.*);
          PERFORM event.rtp_streams_insert_event('rtp_rx_stream', v_rtp_rx_stream_data);
        END LOOP;
  end loop;

  RETURN;
END;
$$;


--
-- Name: writecdr(boolean, integer, integer, integer, boolean, smallint, character varying, integer, character varying, integer, smallint, character varying, integer, character varying, integer, character varying, character varying, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, character varying, smallint, boolean, json, json, character varying, character varying, json, smallint, bigint, json, json, boolean, json, json, json, json); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION switch.writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_transport_protocol_id smallint, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_transport_protocol_id smallint, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_legb_ruri character varying, i_legb_outbound_proxy character varying, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_legb_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id smallint, i_audio_recorded boolean, i_rtp_stats_data json, i_rtp_statistics json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_versions json, i_is_redirected boolean, i_dynamic json, i_lega_headers json, i_legb_headers json, i_lega_identity json) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_cdr cdr.cdr%rowtype;

  v_time_data switch.time_data_ty;
  v_version_data switch.versions_ty;
  v_dynamic switch.dynamic_cdr_data_ty;

  v_nozerolen boolean;
  v_config sys.config%rowtype;

  v_rtp_rx_stream_data rtp_statistics.rx_streams%rowtype;
  v_rtp_tx_stream_data rtp_statistics.tx_streams%rowtype;

  v_lega_headers switch.lega_headers_ty;
  v_legb_headers switch.legb_headers_ty;
  v_lega_reason switch.reason_ty;
  v_legb_reason switch.reason_ty;
BEGIN
  --  raise warning 'type: % id: %', i_failed_resource_type_id, i_failed_resource_id;
  --  RAISE warning 'DTMF: %', i_dtmf_events;

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);
  v_version_data:=json_populate_record(null::switch.versions_ty, i_versions);
  v_dynamic:=json_populate_record(null::switch.dynamic_cdr_data_ty, i_dynamic);

  v_lega_headers:=json_populate_record(null::switch.lega_headers_ty, i_lega_headers);
  v_legb_headers:=json_populate_record(null::switch.legb_headers_ty, i_legb_headers);

  v_cdr.p_charge_info_in = v_lega_headers.p_charge_info;

  v_lega_reason = v_lega_headers.reason;
  v_cdr.lega_q850_cause = v_lega_reason.q850_cause;
  v_cdr.lega_q850_text = v_lega_reason.q850_text;
  v_cdr.lega_q850_params = v_lega_reason.q850_params;

  v_legb_reason = v_legb_headers.reason;
  v_cdr.legb_q850_cause = v_legb_reason.q850_cause;
  v_cdr.legb_q850_text = v_legb_reason.q850_text;
  v_cdr.legb_q850_params = v_legb_reason.q850_params;

  v_cdr.lega_identity = i_lega_identity;
  v_cdr.lega_ss_status_id = v_dynamic.lega_ss_status_id;
  v_cdr.legb_ss_status_id = v_dynamic.legb_ss_status_id;

  v_cdr.metadata = v_dynamic.metadata::jsonb;

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
  v_cdr.customer_auth_external_type:=v_dynamic.customer_auth_external_type;
  v_cdr.customer_auth_name:=v_dynamic.customer_auth_name;

  v_cdr.vendor_id:=v_dynamic.vendor_id;
  v_cdr.vendor_external_id:=v_dynamic.vendor_external_id;
  v_cdr.vendor_acc_id:=v_dynamic.vendor_acc_id;
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

  v_cdr.package_counter_id = v_dynamic.package_counter_id;
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
  v_cdr.sign_orig_ip=i_lega_remote_ip;
  v_cdr.sign_orig_port=NULLIF(i_lega_remote_port,0);
  v_cdr.sign_orig_local_ip=i_lega_local_ip;
  v_cdr.sign_orig_local_port=NULLIF(i_lega_local_port,0);

  v_cdr.sign_term_transport_protocol_id=i_legb_transport_protocol_id;
  v_cdr.sign_term_ip=i_legb_remote_ip;
  v_cdr.sign_term_port=NULLIF(i_legb_remote_port,0);
  v_cdr.sign_term_local_ip=i_legb_local_ip;
  v_cdr.sign_term_local_port=NULLIF(i_legb_local_port,0);

  v_cdr.local_tag=i_local_tag;
  v_cdr.legb_local_tag=i_legb_local_tag;
  v_cdr.legb_ruri=i_legb_ruri;
  v_cdr.legb_outbound_proxy=i_legb_outbound_proxy;

  v_cdr.is_redirected=i_is_redirected;

  /* Call time data */
  v_cdr.time_start:=to_timestamp(v_time_data.time_start);

  select into strict v_config * from sys.config;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect:=to_timestamp(v_time_data.time_connect);
    v_cdr.duration:=switch.duration_round(v_config, v_time_data.time_end-v_time_data.time_connect); -- rounding
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

  perform switch.write_rtp_statistics(
    i_rtp_statistics,
    i_pop_id,
    i_node_id,
    v_dynamic.orig_gw_id,
    v_dynamic.orig_gw_external_id,
    v_dynamic.term_gw_id,
    v_dynamic.term_gw_external_id,
    i_local_tag,
    i_legb_local_tag
  );

  v_cdr.global_tag=i_global_tag;

  v_cdr.src_country_id=v_dynamic.src_country_id;
  v_cdr.src_network_id=v_dynamic.src_network_id;
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

  v_cdr.failed_resource_type_id = i_failed_resource_type_id;
  v_cdr.failed_resource_id = i_failed_resource_id;

  v_cdr:=billing.bill_cdr(v_cdr);

  if not v_config.disable_realtime_statistics then
    perform stats.update_rt_stats(v_cdr);
  end if;

  v_cdr.customer_price = switch.customer_price_round(v_config, v_cdr.customer_price);
  v_cdr.customer_price_no_vat = switch.customer_price_round(v_config, v_cdr.customer_price_no_vat);
  v_cdr.vendor_price = switch.vendor_price_round(v_config, v_cdr.vendor_price);

  -- generate event to billing engine
  perform event.billing_insert_event('cdr_full',v_cdr);
  perform event.streaming_insert_event(v_cdr);
  INSERT INTO cdr.cdr VALUES( v_cdr.*);
  RETURN 0;
END;
$$;


--
-- Name: writecdr(boolean, integer, integer, integer, boolean, smallint, character varying, integer, character varying, integer, smallint, character varying, integer, character varying, integer, character varying, character varying, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, smallint, character varying, character varying, character varying, character varying, character varying, smallint, boolean, json, json, character varying, character varying, json, smallint, bigint, json, json, boolean, json, json, json, json); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION switch.writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_transport_protocol_id smallint, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_transport_protocol_id smallint, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_legb_ruri character varying, i_legb_outbound_proxy character varying, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_internal_disconnect_code_id smallint, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_legb_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id smallint, i_audio_recorded boolean, i_rtp_stats_data json, i_rtp_statistics json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_versions json, i_is_redirected boolean, i_dynamic json, i_lega_headers json, i_legb_headers json, i_lega_identity json) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_cdr cdr.cdr%rowtype;

  v_time_data switch.time_data_ty;
  v_version_data switch.versions_ty;
  v_dynamic switch.dynamic_cdr_data_ty;

  v_nozerolen boolean;
  v_config sys.config%rowtype;

  v_rtp_rx_stream_data rtp_statistics.rx_streams%rowtype;
  v_rtp_tx_stream_data rtp_statistics.tx_streams%rowtype;

  v_lega_headers switch.lega_headers_ty;
  v_legb_headers switch.legb_headers_ty;
  v_lega_reason switch.reason_ty;
  v_legb_reason switch.reason_ty;
BEGIN
  --  raise warning 'type: % id: %', i_failed_resource_type_id, i_failed_resource_id;
  --  RAISE warning 'DTMF: %', i_dtmf_events;

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);
  v_version_data:=json_populate_record(null::switch.versions_ty, i_versions);
  v_dynamic:=json_populate_record(null::switch.dynamic_cdr_data_ty, i_dynamic);

  v_lega_headers:=json_populate_record(null::switch.lega_headers_ty, i_lega_headers);
  v_legb_headers:=json_populate_record(null::switch.legb_headers_ty, i_legb_headers);

  v_cdr.p_charge_info_in = v_lega_headers.p_charge_info;

  v_lega_reason = v_lega_headers.reason;
  v_cdr.lega_q850_cause = v_lega_reason.q850_cause;
  v_cdr.lega_q850_text = v_lega_reason.q850_text;
  v_cdr.lega_q850_params = v_lega_reason.q850_params;

  v_legb_reason = v_legb_headers.reason;
  v_cdr.legb_q850_cause = v_legb_reason.q850_cause;
  v_cdr.legb_q850_text = v_legb_reason.q850_text;
  v_cdr.legb_q850_params = v_legb_reason.q850_params;

  v_cdr.lega_identity = i_lega_identity;
  v_cdr.lega_ss_status_id = v_dynamic.lega_ss_status_id;
  v_cdr.legb_ss_status_id = v_dynamic.legb_ss_status_id;

  v_cdr.metadata = v_dynamic.metadata::jsonb;

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
  v_cdr.customer_auth_external_type:=v_dynamic.customer_auth_external_type;
  v_cdr.customer_auth_name:=v_dynamic.customer_auth_name;

  v_cdr.vendor_id:=v_dynamic.vendor_id;
  v_cdr.vendor_external_id:=v_dynamic.vendor_external_id;
  v_cdr.vendor_acc_id:=v_dynamic.vendor_acc_id;
  v_cdr.vendor_acc_external_id:=v_dynamic.vendor_acc_external_id;

  v_cdr.package_counter_id = v_dynamic.package_counter_id;
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
  v_cdr.sign_orig_ip=i_lega_remote_ip;
  v_cdr.sign_orig_port=NULLIF(i_lega_remote_port,0);
  v_cdr.sign_orig_local_ip=i_lega_local_ip;
  v_cdr.sign_orig_local_port=NULLIF(i_lega_local_port,0);

  v_cdr.sign_term_transport_protocol_id=i_legb_transport_protocol_id;
  v_cdr.sign_term_ip=i_legb_remote_ip;
  v_cdr.sign_term_port=NULLIF(i_legb_remote_port,0);
  v_cdr.sign_term_local_ip=i_legb_local_ip;
  v_cdr.sign_term_local_port=NULLIF(i_legb_local_port,0);

  v_cdr.local_tag=i_local_tag;
  v_cdr.legb_local_tag=i_legb_local_tag;
  v_cdr.legb_ruri=i_legb_ruri;
  v_cdr.legb_outbound_proxy=i_legb_outbound_proxy;

  v_cdr.is_redirected=i_is_redirected;

  /* Call time data */
  v_cdr.time_start:=to_timestamp(v_time_data.time_start);

  select into strict v_config * from sys.config;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect:=to_timestamp(v_time_data.time_connect);
    v_cdr.duration:=switch.duration_round(v_config, v_time_data.time_end-v_time_data.time_connect); -- rounding
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
  v_cdr.legb_disconnect_code=i_legb_disconnect_code;
  v_cdr.legb_disconnect_reason=i_legb_disconnect_reason;
  v_cdr.disconnect_initiator_id=i_disconnect_initiator;
  v_cdr.internal_disconnect_code_id=i_internal_disconnect_code_id;
  v_cdr.internal_disconnect_code=i_internal_disconnect_code;
  v_cdr.internal_disconnect_reason=i_internal_disconnect_reason;
  v_cdr.lega_disconnect_code=i_lega_disconnect_code;
  v_cdr.lega_disconnect_reason=i_lega_disconnect_reason;

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

  perform switch.write_rtp_statistics(
    i_rtp_statistics,
    i_pop_id,
    i_node_id,
    v_dynamic.orig_gw_id,
    v_dynamic.orig_gw_external_id,
    v_dynamic.term_gw_id,
    v_dynamic.term_gw_external_id,
    i_local_tag,
    i_legb_local_tag
  );

  v_cdr.global_tag=i_global_tag;

  v_cdr.src_country_id=v_dynamic.src_country_id;
  v_cdr.src_network_id=v_dynamic.src_network_id;
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

  v_cdr.failed_resource_type_id = i_failed_resource_type_id;
  v_cdr.failed_resource_id = i_failed_resource_id;

  v_cdr:=billing.bill_cdr(v_cdr);

  if not v_config.disable_realtime_statistics then
    perform stats.update_rt_stats(v_cdr);
  end if;

  v_cdr.customer_price = switch.customer_price_round(v_config, v_cdr.customer_price);
  v_cdr.customer_price_no_vat = switch.customer_price_round(v_config, v_cdr.customer_price_no_vat);
  v_cdr.vendor_price = switch.vendor_price_round(v_config, v_cdr.vendor_price);

  -- generate event to billing engine
  perform event.billing_insert_event('cdr_full',v_cdr);
  perform event.streaming_insert_event(v_cdr);
  INSERT INTO cdr.cdr VALUES( v_cdr.*);
  RETURN 0;
END;
$$;


--
-- Name: writecdr(boolean, integer, integer, integer, boolean, smallint, character varying, integer, character varying, integer, smallint, character varying, integer, character varying, integer, character varying, character varying, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, character varying, character varying, character varying, character varying, character varying, smallint, boolean, json, json, character varying, character varying, json, smallint, bigint, json, json, boolean, json, json, json, json, json); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION switch.writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_transport_protocol_id smallint, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_transport_protocol_id smallint, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_legb_ruri character varying, i_legb_outbound_proxy character varying, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_legb_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id smallint, i_audio_recorded boolean, i_rtp_stats_data json, i_rtp_statistics json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_versions json, i_is_redirected boolean, i_dynamic json, i_lega_request_headers json, i_legb_request_headers json, i_legb_reply_headers json, i_lega_identity json) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
BEGIN
  RETURN switch.writecdr(
i_is_master, i_node_id, i_pop_id, i_routing_attempt, i_is_last_cdr,
i_lega_transport_protocol_id, i_lega_local_ip, i_lega_local_port, i_lega_remote_ip,
i_lega_remote_port, i_legb_transport_protocol_id,
i_legb_local_ip, i_legb_local_port, i_legb_remote_ip, i_legb_remote_port, i_legb_ruri,
i_legb_outbound_proxy, i_time_data, i_early_media_present, i_legb_disconnect_code, i_legb_disconnect_reason,
i_disconnect_initiator, i_internal_disconnect_code, i_internal_disconnect_reason, i_lega_disconnect_code, i_lega_disconnect_reason,
NULL, /* i_internal_disconnect_code_id */
i_orig_call_id, i_term_call_id, i_local_tag, i_legb_local_tag, i_msg_logger_path,
i_dump_level_id, i_audio_recorded, i_rtp_stats_data, i_rtp_statistics,
i_global_tag, i_resources, i_active_resources, i_failed_resource_type_id, i_failed_resource_id,
i_dtmf_events, i_versions, i_is_redirected, i_dynamic,
i_lega_request_headers,
i_legb_request_headers,
i_legb_reply_headers,
i_lega_identity
);

END;
$$;


--
-- Name: writecdr(boolean, integer, integer, integer, boolean, smallint, character varying, integer, character varying, integer, smallint, character varying, integer, character varying, integer, character varying, character varying, json, boolean, integer, character varying, integer, integer, character varying, integer, character varying, smallint, character varying, character varying, character varying, character varying, character varying, smallint, boolean, json, json, character varying, character varying, json, smallint, bigint, json, json, boolean, json, json, json, json, json); Type: FUNCTION; Schema: switch; Owner: -
--

CREATE FUNCTION switch.writecdr(i_is_master boolean, i_node_id integer, i_pop_id integer, i_routing_attempt integer, i_is_last_cdr boolean, i_lega_transport_protocol_id smallint, i_lega_local_ip character varying, i_lega_local_port integer, i_lega_remote_ip character varying, i_lega_remote_port integer, i_legb_transport_protocol_id smallint, i_legb_local_ip character varying, i_legb_local_port integer, i_legb_remote_ip character varying, i_legb_remote_port integer, i_legb_ruri character varying, i_legb_outbound_proxy character varying, i_time_data json, i_early_media_present boolean, i_legb_disconnect_code integer, i_legb_disconnect_reason character varying, i_disconnect_initiator integer, i_internal_disconnect_code integer, i_internal_disconnect_reason character varying, i_lega_disconnect_code integer, i_lega_disconnect_reason character varying, i_internal_disconnect_code_id smallint, i_orig_call_id character varying, i_term_call_id character varying, i_local_tag character varying, i_legb_local_tag character varying, i_msg_logger_path character varying, i_dump_level_id smallint, i_audio_recorded boolean, i_rtp_stats_data json, i_rtp_statistics json, i_global_tag character varying, i_resources character varying, i_active_resources json, i_failed_resource_type_id smallint, i_failed_resource_id bigint, i_dtmf_events json, i_versions json, i_is_redirected boolean, i_dynamic json, i_lega_request_headers json, i_legb_request_headers json, i_legb_reply_headers json, i_lega_identity json) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_cdr cdr.cdr%rowtype;

  v_time_data switch.time_data_ty;
  v_version_data switch.versions_ty;
  v_dynamic switch.dynamic_cdr_data_ty;

  v_nozerolen boolean;
  v_config sys.config%rowtype;

  v_rtp_rx_stream_data rtp_statistics.rx_streams%rowtype;
  v_rtp_tx_stream_data rtp_statistics.tx_streams%rowtype;

  v_lega_request_headers switch.lega_request_headers_ty;
  v_legb_request_headers switch.legb_request_headers_ty;
  v_legb_reply_headers switch.legb_reply_headers_ty;
  v_lega_reason switch.reason_ty;
  v_legb_reason switch.reason_ty;
BEGIN
  --  raise warning 'type: % id: %', i_failed_resource_type_id, i_failed_resource_id;
  --  RAISE warning 'DTMF: %', i_dtmf_events;

  v_time_data:=json_populate_record(null::switch.time_data_ty, i_time_data);
  v_version_data:=json_populate_record(null::switch.versions_ty, i_versions);
  v_dynamic:=json_populate_record(null::switch.dynamic_cdr_data_ty, i_dynamic);

  v_lega_request_headers = json_populate_record(null::switch.lega_request_headers_ty, i_lega_request_headers);
  v_legb_request_headers = json_populate_record(null::switch.legb_request_headers_ty, i_legb_request_headers);
  v_legb_reply_headers = json_populate_record(null::switch.legb_reply_headers_ty, i_legb_reply_headers);

  v_cdr.p_charge_info_in = v_lega_request_headers.p_charge_info;

  v_lega_reason = v_lega_request_headers.reason;
  v_cdr.lega_q850_cause = v_lega_reason.q850_cause;
  v_cdr.lega_q850_text = v_lega_reason.q850_text;
  v_cdr.lega_q850_params = v_lega_reason.q850_params;

  v_legb_reason = v_legb_reply_headers.reason;
  v_cdr.legb_q850_cause = v_legb_reason.q850_cause;
  v_cdr.legb_q850_text = v_legb_reason.q850_text;
  v_cdr.legb_q850_params = v_legb_reason.q850_params;

  v_cdr.diversion_in = array_to_string(v_lega_request_headers.diversion, ',');
  v_cdr.pai_in = array_to_string(v_lega_request_headers.p_asserted_identity, ',');
  v_cdr.ppi_in = v_lega_request_headers.p_preferred_identity;
  v_cdr.privacy_in = array_to_string(v_lega_request_headers.privacy, ',');
  v_cdr.rpid_in = array_to_string(v_lega_request_headers.remote_party_id, ',');
  v_cdr.rpid_privacy_in = array_to_string(v_lega_request_headers.rpid_privacy, ',');

  v_cdr.diversion_out = array_to_string(v_legb_request_headers.diversion, ',');
  v_cdr.pai_out = array_to_string(v_legb_request_headers.p_asserted_identity, ',');
  v_cdr.ppi_out = v_legb_request_headers.p_preferred_identity;
  v_cdr.privacy_out = array_to_string(v_legb_request_headers.privacy, ',');
  v_cdr.rpid_out = array_to_string(v_legb_request_headers.remote_party_id, ',');
  v_cdr.rpid_privacy_out = array_to_string(v_legb_request_headers.rpid_privacy, ',');

  v_cdr.lega_identity = i_lega_identity;
  v_cdr.lega_ss_status_id = v_dynamic.lega_ss_status_id;
  v_cdr.legb_ss_status_id = v_dynamic.legb_ss_status_id;

  v_cdr.metadata = v_dynamic.metadata::jsonb;

  v_cdr.core_version=v_version_data.core;
  v_cdr.yeti_version=v_version_data.yeti;
  v_cdr.lega_user_agent=v_version_data.aleg;
  v_cdr.legb_user_agent=v_version_data.bleg;

  v_cdr.pop_id=i_pop_id;
  v_cdr.node_id=i_node_id;

  v_cdr.src_name_in:=v_dynamic.src_name_in;
  v_cdr.src_name_out:=v_dynamic.src_name_out;

  v_cdr.customer_id:=v_dynamic.customer_id;
  v_cdr.customer_external_id:=v_dynamic.customer_external_id;

  v_cdr.customer_acc_id:=v_dynamic.customer_acc_id;
  v_cdr.customer_account_check_balance=v_dynamic.customer_acc_check_balance;
  v_cdr.customer_acc_external_id=v_dynamic.customer_acc_external_id;
  v_cdr.customer_acc_vat:=v_dynamic.customer_acc_vat;

  v_cdr.customer_auth_id:=v_dynamic.customer_auth_id;
  v_cdr.customer_auth_external_id:=v_dynamic.customer_auth_external_id;
  v_cdr.customer_auth_external_type:=v_dynamic.customer_auth_external_type;
  v_cdr.customer_auth_name:=v_dynamic.customer_auth_name;

  v_cdr.vendor_id:=v_dynamic.vendor_id;
  v_cdr.vendor_external_id:=v_dynamic.vendor_external_id;
  v_cdr.vendor_acc_id:=v_dynamic.vendor_acc_id;
  v_cdr.vendor_acc_external_id:=v_dynamic.vendor_acc_external_id;

  v_cdr.package_counter_id = v_dynamic.package_counter_id;
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
  v_cdr.sign_orig_transport_protocol_id = i_lega_transport_protocol_id;
  v_cdr.sign_orig_ip = i_lega_remote_ip;
  v_cdr.sign_orig_port = NULLIF(i_lega_remote_port,0);
  v_cdr.sign_orig_local_ip = i_lega_local_ip;
  v_cdr.sign_orig_local_port = NULLIF(i_lega_local_port,0);

  v_cdr.sign_term_transport_protocol_id = i_legb_transport_protocol_id;
  v_cdr.sign_term_ip = i_legb_remote_ip;
  v_cdr.sign_term_port = NULLIF(i_legb_remote_port,0);
  v_cdr.sign_term_local_ip = i_legb_local_ip;
  v_cdr.sign_term_local_port = NULLIF(i_legb_local_port,0);

  v_cdr.local_tag = i_local_tag;
  v_cdr.legb_local_tag = i_legb_local_tag;
  v_cdr.legb_ruri = i_legb_ruri;
  v_cdr.legb_outbound_proxy = i_legb_outbound_proxy;

  v_cdr.is_redirected = i_is_redirected;

  /* Call time data */
  v_cdr.time_start = to_timestamp(v_time_data.time_start);

  select into strict v_config * from sys.config;

  if v_time_data.time_connect is not null then
    v_cdr.time_connect = to_timestamp(v_time_data.time_connect);
    v_cdr.duration = switch.duration_round(v_config, v_time_data.time_end-v_time_data.time_connect); -- rounding
    v_nozerolen = true;
    v_cdr.success = true;
  else
    v_cdr.time_connect = NULL;
    v_cdr.duration = 0;
    v_nozerolen = false;
    v_cdr.success = false;
  end if;
  v_cdr.routing_delay = (v_time_data.leg_b_time-v_time_data.time_start)::real;
  v_cdr.pdd = (coalesce(v_time_data.time_18x,v_time_data.time_connect)-v_time_data.time_start)::real;
  v_cdr.rtt = (coalesce(v_time_data.time_1xx,v_time_data.time_18x,v_time_data.time_connect)-v_time_data.leg_b_time)::real;
  v_cdr.early_media_present = i_early_media_present;

  v_cdr.time_end = to_timestamp(v_time_data.time_end);

  -- DC processing
  v_cdr.legb_disconnect_code = i_legb_disconnect_code;
  v_cdr.legb_disconnect_reason = i_legb_disconnect_reason;
  v_cdr.disconnect_initiator_id = i_disconnect_initiator;
  v_cdr.internal_disconnect_code_id = i_internal_disconnect_code_id;
  v_cdr.internal_disconnect_code = i_internal_disconnect_code;
  v_cdr.internal_disconnect_reason = i_internal_disconnect_reason;
  v_cdr.lega_disconnect_code = i_lega_disconnect_code;
  v_cdr.lega_disconnect_reason = i_lega_disconnect_reason;

  v_cdr.src_prefix_in = v_dynamic.src_prefix_in;
  v_cdr.src_prefix_out = v_dynamic.src_prefix_out;
  v_cdr.dst_prefix_in = v_dynamic.dst_prefix_in;
  v_cdr.dst_prefix_out = v_dynamic.dst_prefix_out;

  v_cdr.orig_call_id = i_orig_call_id;
  v_cdr.term_call_id = i_term_call_id;

  /* removed */
  --v_cdr.dump_file = i_msg_logger_path;

  v_cdr.dump_level_id = i_dump_level_id;
  v_cdr.audio_recorded = i_audio_recorded;

  v_cdr.auth_orig_transport_protocol_id = v_dynamic.auth_orig_protocol_id;
  v_cdr.auth_orig_ip = v_dynamic.auth_orig_ip;
  v_cdr.auth_orig_ip = v_dynamic.auth_orig_ip;
  v_cdr.auth_orig_port = v_dynamic.auth_orig_port;

  perform switch.write_rtp_statistics(
    i_rtp_statistics,
    i_pop_id,
    i_node_id,
    v_dynamic.orig_gw_id,
    v_dynamic.orig_gw_external_id,
    v_dynamic.term_gw_id,
    v_dynamic.term_gw_external_id,
    i_local_tag,
    i_legb_local_tag
  );

  v_cdr.global_tag = i_global_tag;

  v_cdr.src_country_id = v_dynamic.src_country_id;
  v_cdr.src_network_id = v_dynamic.src_network_id;
  v_cdr.src_network_type_id = v_dynamic.src_network_type_id;
  v_cdr.dst_country_id = v_dynamic.dst_country_id;
  v_cdr.dst_network_id = v_dynamic.dst_network_id;
  v_cdr.dst_network_type_id = v_dynamic.dst_network_type_id;

  v_cdr.dst_prefix_routing = v_dynamic.dst_prefix_routing;
  v_cdr.src_prefix_routing = v_dynamic.src_prefix_routing;
  v_cdr.routing_plan_id = v_dynamic.routing_plan_id;
  v_cdr.lrn = v_dynamic.lrn;
  v_cdr.lnp_database_id = v_dynamic.lnp_database_id;

  v_cdr.ruri_domain = v_dynamic.ruri_domain;
  v_cdr.to_domain = v_dynamic.to_domain;
  v_cdr.from_domain = v_dynamic.from_domain;

  v_cdr.src_area_id = v_dynamic.src_area_id;
  v_cdr.dst_area_id = v_dynamic.dst_area_id;
  v_cdr.routing_tag_ids = v_dynamic.routing_tag_ids;


  v_cdr.id = nextval('cdr.cdr_id_seq'::regclass);
  v_cdr.uuid = public.uuid_generate_v1();

  v_cdr.failed_resource_type_id = i_failed_resource_type_id;
  v_cdr.failed_resource_id = i_failed_resource_id;

  v_cdr = billing.bill_cdr(v_cdr);

  if not v_config.disable_realtime_statistics then
    perform stats.update_rt_stats(v_cdr);
  end if;

  v_cdr.customer_price = switch.customer_price_round(v_config, v_cdr.customer_price);
  v_cdr.customer_price_no_vat = switch.customer_price_round(v_config, v_cdr.customer_price_no_vat);
  v_cdr.vendor_price = switch.vendor_price_round(v_config, v_cdr.vendor_price);

  -- generate event to billing engine
  perform event.billing_insert_event('cdr_full',v_cdr);
  perform event.streaming_insert_event(v_cdr);
  INSERT INTO cdr.cdr VALUES( v_cdr.*);
  RETURN 0;
END;
$$;


--
-- Name: cdr_export_data(character varying); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION sys.cdr_export_data(i_tbname character varying) RETURNS void
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

CREATE FUNCTION sys.cdr_export_data(i_tbname character varying, i_dir character varying) RETURNS void
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
-- Name: auth_log; Type: TABLE; Schema: auth_log; Owner: -
--

CREATE TABLE auth_log.auth_log (
    id bigint NOT NULL,
    node_id smallint,
    pop_id smallint,
    request_time timestamp with time zone NOT NULL,
    transport_proto_id smallint,
    transport_remote_ip character varying,
    transport_remote_port integer,
    transport_local_ip character varying,
    transport_local_port integer,
    origination_ip character varying,
    origination_port integer,
    origination_proto_id smallint,
    username character varying,
    realm character varying,
    request_method character varying,
    ruri character varying,
    from_uri character varying,
    to_uri character varying,
    call_id character varying,
    success boolean,
    code smallint,
    reason character varying,
    internal_reason character varying,
    nonce character varying,
    response character varying,
    gateway_id integer,
    x_yeti_auth character varying,
    diversion character varying,
    pai character varying,
    ppi character varying,
    privacy character varying,
    rpid character varying,
    rpid_privacy character varying
)
PARTITION BY RANGE (request_time);


--
-- Name: auth_log_id_seq; Type: SEQUENCE; Schema: auth_log; Owner: -
--

CREATE SEQUENCE auth_log.auth_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auth_log_id_seq; Type: SEQUENCE OWNED BY; Schema: auth_log; Owner: -
--

ALTER SEQUENCE auth_log.auth_log_id_seq OWNED BY auth_log.auth_log.id;


--
-- Name: invoice_documents; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.invoice_documents (
    id integer NOT NULL,
    invoice_id integer NOT NULL,
    data bytea,
    filename character varying NOT NULL,
    pdf_data bytea
);


--
-- Name: invoice_documents_id_seq; Type: SEQUENCE; Schema: billing; Owner: -
--

CREATE SEQUENCE billing.invoice_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: -
--

ALTER SEQUENCE billing.invoice_documents_id_seq OWNED BY billing.invoice_documents.id;


--
-- Name: invoice_originated_destinations; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.invoice_originated_destinations (
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
    billing_duration bigint,
    spent boolean DEFAULT true NOT NULL
);


--
-- Name: invoice_originated_destinations_id_seq; Type: SEQUENCE; Schema: billing; Owner: -
--

CREATE SEQUENCE billing.invoice_originated_destinations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_originated_destinations_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: -
--

ALTER SEQUENCE billing.invoice_originated_destinations_id_seq OWNED BY billing.invoice_originated_destinations.id;


--
-- Name: invoice_originated_networks; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.invoice_originated_networks (
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
    billing_duration bigint,
    spent boolean DEFAULT true NOT NULL
);


--
-- Name: invoice_originated_networks_id_seq; Type: SEQUENCE; Schema: billing; Owner: -
--

CREATE SEQUENCE billing.invoice_originated_networks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_originated_networks_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: -
--

ALTER SEQUENCE billing.invoice_originated_networks_id_seq OWNED BY billing.invoice_originated_networks.id;


--
-- Name: invoice_service_data; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.invoice_service_data (
    id bigint NOT NULL,
    invoice_id integer NOT NULL,
    service_id bigint,
    amount numeric NOT NULL,
    spent boolean DEFAULT true NOT NULL,
    transactions_count integer NOT NULL
);


--
-- Name: invoice_service_data_id_seq; Type: SEQUENCE; Schema: billing; Owner: -
--

CREATE SEQUENCE billing.invoice_service_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_service_data_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: -
--

ALTER SEQUENCE billing.invoice_service_data_id_seq OWNED BY billing.invoice_service_data.id;


--
-- Name: invoice_terminated_destinations; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.invoice_terminated_destinations (
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
    billing_duration bigint,
    spent boolean DEFAULT false NOT NULL
);


--
-- Name: invoice_terminated_destinations_id_seq; Type: SEQUENCE; Schema: billing; Owner: -
--

CREATE SEQUENCE billing.invoice_terminated_destinations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_terminated_destinations_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: -
--

ALTER SEQUENCE billing.invoice_terminated_destinations_id_seq OWNED BY billing.invoice_terminated_destinations.id;


--
-- Name: invoice_terminated_networks; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.invoice_terminated_networks (
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
    billing_duration bigint,
    spent boolean DEFAULT false NOT NULL
);


--
-- Name: invoice_terminated_networks_id_seq; Type: SEQUENCE; Schema: billing; Owner: -
--

CREATE SEQUENCE billing.invoice_terminated_networks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_terminated_networks_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: -
--

ALTER SEQUENCE billing.invoice_terminated_networks_id_seq OWNED BY billing.invoice_terminated_networks.id;


--
-- Name: invoices; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.invoices (
    id integer NOT NULL,
    account_id integer NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL,
    originated_amount_spent numeric DEFAULT 0 NOT NULL,
    originated_calls_count bigint DEFAULT 0 NOT NULL,
    first_originated_call_at timestamp with time zone,
    last_originated_call_at timestamp with time zone,
    contractor_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    originated_calls_duration bigint DEFAULT 0 NOT NULL,
    state_id smallint DEFAULT 3 NOT NULL,
    originated_successful_calls_count bigint DEFAULT 0 NOT NULL,
    type_id smallint NOT NULL,
    originated_billing_duration bigint DEFAULT 0 NOT NULL,
    reference character varying,
    uuid uuid DEFAULT public.uuid_generate_v1() NOT NULL,
    terminated_amount_earned numeric DEFAULT 0 NOT NULL,
    terminated_calls_count integer DEFAULT 0 NOT NULL,
    first_terminated_call_at timestamp with time zone,
    last_terminated_call_at timestamp with time zone,
    terminated_calls_duration integer DEFAULT 0 NOT NULL,
    terminated_successful_calls_count integer DEFAULT 0 NOT NULL,
    terminated_billing_duration integer DEFAULT 0 NOT NULL,
    terminated_amount_spent numeric DEFAULT 0 NOT NULL,
    originated_amount_earned numeric DEFAULT 0 NOT NULL,
    amount_spent numeric DEFAULT 0 NOT NULL,
    amount_earned numeric DEFAULT 0 NOT NULL,
    amount_total numeric DEFAULT 0 NOT NULL,
    services_amount_spent numeric DEFAULT 0.0 NOT NULL,
    services_amount_earned numeric DEFAULT 0.0 NOT NULL,
    service_transactions_count integer DEFAULT 0 NOT NULL
);


--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: billing; Owner: -
--

CREATE SEQUENCE billing.invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: -
--

ALTER SEQUENCE billing.invoices_id_seq OWNED BY billing.invoices.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: cdr; Owner: -
--

CREATE TABLE cdr.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cdr_id_seq; Type: SEQUENCE; Schema: cdr; Owner: -
--

CREATE SEQUENCE cdr.cdr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cdr_id_seq; Type: SEQUENCE OWNED BY; Schema: cdr; Owner: -
--

ALTER SEQUENCE cdr.cdr_id_seq OWNED BY cdr.cdr.id;


--
-- Name: countries; Type: TABLE; Schema: external_data; Owner: -
--

CREATE TABLE external_data.countries (
    id integer NOT NULL,
    name character varying,
    iso2 character varying
);


--
-- Name: network_prefixes; Type: TABLE; Schema: external_data; Owner: -
--

CREATE TABLE external_data.network_prefixes (
    id integer NOT NULL,
    number_max_length integer,
    number_min_length integer,
    prefix character varying,
    uuid uuid,
    country_id integer,
    network_id integer
);


--
-- Name: networks; Type: TABLE; Schema: external_data; Owner: -
--

CREATE TABLE external_data.networks (
    id integer NOT NULL,
    name character varying,
    type_id integer,
    uuid uuid
);


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: cdr_custom_report; Type: TABLE; Schema: reports; Owner: -
--

CREATE TABLE reports.cdr_custom_report (
    id integer NOT NULL,
    date_start timestamp with time zone,
    date_end timestamp with time zone,
    filter character varying,
    group_by character varying[],
    created_at timestamp with time zone,
    customer_id integer,
    completed boolean DEFAULT false NOT NULL,
    send_to integer[]
);


--
-- Name: cdr_custom_report_data; Type: TABLE; Schema: reports; Owner: -
--

CREATE TABLE reports.cdr_custom_report_data (
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
    duration integer,
    success boolean,
    dialpeer_reverse_billing boolean,
    destination_reverse_billing boolean,
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
    vendor_invoice_id integer,
    customer_invoice_id integer,
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
    legb_disconnect_reason character varying,
    agg_customer_calls_duration bigint,
    agg_vendor_calls_duration bigint,
    agg_customer_price_no_vat numeric,
    src_area_id integer,
    dst_area_id integer,
    src_network_id integer,
    src_country_id integer,
    lega_user_agent character varying,
    legb_user_agent character varying,
    p_charge_info_in character varying,
    auth_orig_ip character varying,
    agg_successful_calls_count bigint,
    agg_short_calls_count bigint,
    agg_uniq_calls_count bigint
);


--
-- Name: cdr_custom_report_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE reports.cdr_custom_report_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cdr_custom_report_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE reports.cdr_custom_report_data_id_seq OWNED BY reports.cdr_custom_report_data.id;


--
-- Name: cdr_custom_report_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE reports.cdr_custom_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cdr_custom_report_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE reports.cdr_custom_report_id_seq OWNED BY reports.cdr_custom_report.id;


--
-- Name: cdr_custom_report_schedulers; Type: TABLE; Schema: reports; Owner: -
--

CREATE TABLE reports.cdr_custom_report_schedulers (
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

CREATE SEQUENCE reports.cdr_custom_report_schedulers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cdr_custom_report_schedulers_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE reports.cdr_custom_report_schedulers_id_seq OWNED BY reports.cdr_custom_report_schedulers.id;


--
-- Name: cdr_interval_report; Type: TABLE; Schema: reports; Owner: -
--

CREATE TABLE reports.cdr_interval_report (
    id integer NOT NULL,
    date_start timestamp with time zone NOT NULL,
    date_end timestamp with time zone NOT NULL,
    filter character varying,
    group_by character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    created_at timestamp with time zone NOT NULL,
    interval_length integer NOT NULL,
    aggregator_id integer NOT NULL,
    aggregate_by character varying NOT NULL,
    completed boolean DEFAULT false NOT NULL,
    send_to integer[]
);


--
-- Name: cdr_interval_report_aggregator; Type: TABLE; Schema: reports; Owner: -
--

CREATE TABLE reports.cdr_interval_report_aggregator (
    id integer NOT NULL,
    name character varying NOT NULL
);


--
-- Name: cdr_interval_report_data; Type: TABLE; Schema: reports; Owner: -
--

CREATE TABLE reports.cdr_interval_report_data (
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
    dialpeer_reverse_billing boolean,
    destination_reverse_billing boolean,
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
    aggregated_value numeric,
    auth_orig_ip character varying
);


--
-- Name: cdr_interval_report_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE reports.cdr_interval_report_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cdr_interval_report_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE reports.cdr_interval_report_data_id_seq OWNED BY reports.cdr_interval_report_data.id;


--
-- Name: cdr_interval_report_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE reports.cdr_interval_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cdr_interval_report_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE reports.cdr_interval_report_id_seq OWNED BY reports.cdr_interval_report.id;


--
-- Name: cdr_interval_report_schedulers; Type: TABLE; Schema: reports; Owner: -
--

CREATE TABLE reports.cdr_interval_report_schedulers (
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

CREATE SEQUENCE reports.cdr_interval_report_schedulers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cdr_interval_report_schedulers_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE reports.cdr_interval_report_schedulers_id_seq OWNED BY reports.cdr_interval_report_schedulers.id;


--
-- Name: customer_traffic_report; Type: TABLE; Schema: reports; Owner: -
--

CREATE TABLE reports.customer_traffic_report (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    date_start timestamp with time zone,
    date_end timestamp with time zone,
    customer_id integer NOT NULL,
    completed boolean DEFAULT false NOT NULL,
    send_to integer[]
);


--
-- Name: customer_traffic_report_data_by_destination; Type: TABLE; Schema: reports; Owner: -
--

CREATE TABLE reports.customer_traffic_report_data_by_destination (
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
    short_calls_count bigint NOT NULL,
    customer_calls_duration bigint NOT NULL,
    vendor_calls_duration bigint NOT NULL
);


--
-- Name: customer_traffic_report_data_by_destination_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE reports.customer_traffic_report_data_by_destination_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_traffic_report_data_by_destination_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE reports.customer_traffic_report_data_by_destination_id_seq OWNED BY reports.customer_traffic_report_data_by_destination.id;


--
-- Name: customer_traffic_report_data_by_vendor; Type: TABLE; Schema: reports; Owner: -
--

CREATE TABLE reports.customer_traffic_report_data_by_vendor (
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
    short_calls_count bigint,
    customer_calls_duration bigint,
    vendor_calls_duration bigint
);


--
-- Name: customer_traffic_report_data_full; Type: TABLE; Schema: reports; Owner: -
--

CREATE TABLE reports.customer_traffic_report_data_full (
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
    short_calls_count bigint NOT NULL,
    customer_calls_duration bigint NOT NULL,
    vendor_calls_duration bigint NOT NULL
);


--
-- Name: customer_traffic_report_data_full_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE reports.customer_traffic_report_data_full_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_traffic_report_data_full_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE reports.customer_traffic_report_data_full_id_seq OWNED BY reports.customer_traffic_report_data_full.id;


--
-- Name: customer_traffic_report_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE reports.customer_traffic_report_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_traffic_report_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE reports.customer_traffic_report_data_id_seq OWNED BY reports.customer_traffic_report_data_by_vendor.id;


--
-- Name: customer_traffic_report_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE reports.customer_traffic_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_traffic_report_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE reports.customer_traffic_report_id_seq OWNED BY reports.customer_traffic_report.id;


--
-- Name: customer_traffic_report_schedulers; Type: TABLE; Schema: reports; Owner: -
--

CREATE TABLE reports.customer_traffic_report_schedulers (
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

CREATE SEQUENCE reports.customer_traffic_report_schedulers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_traffic_report_schedulers_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE reports.customer_traffic_report_schedulers_id_seq OWNED BY reports.customer_traffic_report_schedulers.id;


--
-- Name: scheduler_periods; Type: TABLE; Schema: reports; Owner: -
--

CREATE TABLE reports.scheduler_periods (
    id smallint NOT NULL,
    name character varying NOT NULL
);


--
-- Name: vendor_traffic_report; Type: TABLE; Schema: reports; Owner: -
--

CREATE TABLE reports.vendor_traffic_report (
    id bigint NOT NULL,
    created_at timestamp with time zone,
    date_start timestamp with time zone,
    date_end timestamp with time zone,
    vendor_id integer NOT NULL,
    completed boolean DEFAULT false NOT NULL,
    send_to integer[]
);


--
-- Name: vendor_traffic_report_data; Type: TABLE; Schema: reports; Owner: -
--

CREATE TABLE reports.vendor_traffic_report_data (
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
    short_calls_count bigint,
    customer_calls_duration bigint,
    vendor_calls_duration bigint
);


--
-- Name: vendor_traffic_report_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE reports.vendor_traffic_report_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vendor_traffic_report_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE reports.vendor_traffic_report_data_id_seq OWNED BY reports.vendor_traffic_report_data.id;


--
-- Name: vendor_traffic_report_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE reports.vendor_traffic_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vendor_traffic_report_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE reports.vendor_traffic_report_id_seq OWNED BY reports.vendor_traffic_report.id;


--
-- Name: vendor_traffic_report_schedulers; Type: TABLE; Schema: reports; Owner: -
--

CREATE TABLE reports.vendor_traffic_report_schedulers (
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

CREATE SEQUENCE reports.vendor_traffic_report_schedulers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vendor_traffic_report_schedulers_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE reports.vendor_traffic_report_schedulers_id_seq OWNED BY reports.vendor_traffic_report_schedulers.id;


--
-- Name: rx_streams; Type: TABLE; Schema: rtp_statistics; Owner: -
--

CREATE TABLE rtp_statistics.rx_streams (
    id bigint NOT NULL,
    tx_stream_id bigint,
    time_start timestamp with time zone NOT NULL,
    time_end timestamp with time zone,
    pop_id integer,
    node_id integer,
    gateway_id bigint,
    gateway_external_id bigint,
    local_tag character varying,
    rx_ssrc bigint,
    local_host inet,
    local_port integer,
    remote_host inet,
    remote_port integer,
    rx_packets bigint,
    rx_bytes bigint,
    rx_total_lost bigint,
    rx_payloads_transcoded character varying[],
    rx_payloads_relayed character varying[],
    rx_decode_errors bigint,
    rx_packet_delta_min real,
    rx_packet_delta_max real,
    rx_packet_delta_mean real,
    rx_packet_delta_std real,
    rx_packet_jitter_min real,
    rx_packet_jitter_max real,
    rx_packet_jitter_mean real,
    rx_packet_jitter_std real,
    rx_rtcp_jitter_min real,
    rx_rtcp_jitter_max real,
    rx_rtcp_jitter_mean real,
    rx_rtcp_jitter_std real
)
PARTITION BY RANGE (time_start);


--
-- Name: rx_streams_id_seq; Type: SEQUENCE; Schema: rtp_statistics; Owner: -
--

CREATE SEQUENCE rtp_statistics.rx_streams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rx_streams_id_seq; Type: SEQUENCE OWNED BY; Schema: rtp_statistics; Owner: -
--

ALTER SEQUENCE rtp_statistics.rx_streams_id_seq OWNED BY rtp_statistics.rx_streams.id;


--
-- Name: tx_streams; Type: TABLE; Schema: rtp_statistics; Owner: -
--

CREATE TABLE rtp_statistics.tx_streams (
    id bigint NOT NULL,
    time_start timestamp with time zone NOT NULL,
    time_end timestamp with time zone,
    pop_id integer,
    node_id integer,
    gateway_id bigint,
    gateway_external_id bigint,
    local_tag character varying NOT NULL,
    rtcp_rtt_min real,
    rtcp_rtt_max real,
    rtcp_rtt_mean real,
    rtcp_rtt_std real,
    rx_out_of_buffer_errors bigint,
    rx_rtp_parse_errors bigint,
    rx_dropped_packets bigint,
    tx_packets bigint,
    tx_bytes bigint,
    tx_ssrc bigint,
    local_host inet,
    local_port integer,
    tx_total_lost integer,
    tx_payloads_transcoded character varying[],
    tx_payloads_relayed character varying[],
    tx_rtcp_jitter_min real,
    tx_rtcp_jitter_max real,
    tx_rtcp_jitter_mean real,
    tx_rtcp_jitter_std real,
    rx_srtp_decrypt_errors bigint
)
PARTITION BY RANGE (time_start);


--
-- Name: tx_streams_id_seq; Type: SEQUENCE; Schema: rtp_statistics; Owner: -
--

CREATE SEQUENCE rtp_statistics.tx_streams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tx_streams_id_seq; Type: SEQUENCE OWNED BY; Schema: rtp_statistics; Owner: -
--

ALTER SEQUENCE rtp_statistics.tx_streams_id_seq OWNED BY rtp_statistics.tx_streams.id;


--
-- Name: active_call_accounts; Type: TABLE; Schema: stats; Owner: -
--

CREATE TABLE stats.active_call_accounts (
    id bigint NOT NULL,
    account_id integer NOT NULL,
    originated_count integer NOT NULL,
    terminated_count integer NOT NULL,
    created_at timestamp with time zone
);


--
-- Name: active_call_accounts_hourly; Type: TABLE; Schema: stats; Owner: -
--

CREATE TABLE stats.active_call_accounts_hourly (
    id bigint NOT NULL,
    account_id integer NOT NULL,
    max_originated_count integer NOT NULL,
    avg_originated_count integer NOT NULL,
    min_originated_count integer NOT NULL,
    max_terminated_count integer NOT NULL,
    avg_terminated_count integer NOT NULL,
    min_terminated_count integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    calls_time timestamp with time zone NOT NULL
);


--
-- Name: active_call_accounts_hourly_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE stats.active_call_accounts_hourly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_call_accounts_hourly_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE stats.active_call_accounts_hourly_id_seq OWNED BY stats.active_call_accounts_hourly.id;


--
-- Name: active_call_accounts_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE stats.active_call_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_call_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE stats.active_call_accounts_id_seq OWNED BY stats.active_call_accounts.id;


--
-- Name: active_call_orig_gateways; Type: TABLE; Schema: stats; Owner: -
--

CREATE TABLE stats.active_call_orig_gateways (
    id bigint NOT NULL,
    gateway_id integer NOT NULL,
    count integer NOT NULL,
    created_at timestamp with time zone
);


--
-- Name: active_call_orig_gateways_hourly; Type: TABLE; Schema: stats; Owner: -
--

CREATE TABLE stats.active_call_orig_gateways_hourly (
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

CREATE SEQUENCE stats.active_call_orig_gateways_hourly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_call_orig_gateways_hourly_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE stats.active_call_orig_gateways_hourly_id_seq OWNED BY stats.active_call_orig_gateways_hourly.id;


--
-- Name: active_call_orig_gateways_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE stats.active_call_orig_gateways_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_call_orig_gateways_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE stats.active_call_orig_gateways_id_seq OWNED BY stats.active_call_orig_gateways.id;


--
-- Name: active_call_term_gateways; Type: TABLE; Schema: stats; Owner: -
--

CREATE TABLE stats.active_call_term_gateways (
    id bigint NOT NULL,
    gateway_id integer NOT NULL,
    count integer NOT NULL,
    created_at timestamp with time zone
);


--
-- Name: active_call_term_gateways_hourly; Type: TABLE; Schema: stats; Owner: -
--

CREATE TABLE stats.active_call_term_gateways_hourly (
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

CREATE SEQUENCE stats.active_call_term_gateways_hourly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_call_term_gateways_hourly_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE stats.active_call_term_gateways_hourly_id_seq OWNED BY stats.active_call_term_gateways_hourly.id;


--
-- Name: active_call_term_gateways_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE stats.active_call_term_gateways_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_call_term_gateways_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE stats.active_call_term_gateways_id_seq OWNED BY stats.active_call_term_gateways.id;


--
-- Name: active_calls; Type: TABLE; Schema: stats; Owner: -
--

CREATE TABLE stats.active_calls (
    id bigint NOT NULL,
    node_id integer NOT NULL,
    count integer NOT NULL,
    created_at timestamp with time zone
);


--
-- Name: active_calls_hourly; Type: TABLE; Schema: stats; Owner: -
--

CREATE TABLE stats.active_calls_hourly (
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

CREATE SEQUENCE stats.active_calls_hourly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_calls_hourly_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE stats.active_calls_hourly_id_seq OWNED BY stats.active_calls_hourly.id;


--
-- Name: active_calls_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE stats.active_calls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_calls_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE stats.active_calls_id_seq OWNED BY stats.active_calls.id;


--
-- Name: customer_auth_stats; Type: TABLE; Schema: stats; Owner: -
--

CREATE TABLE stats.customer_auth_stats (
    id bigint NOT NULL,
    customer_auth_id integer NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    duration integer DEFAULT 0 NOT NULL,
    customer_duration integer DEFAULT 0 NOT NULL,
    calls_count integer DEFAULT 0 NOT NULL,
    customer_price numeric DEFAULT 0 NOT NULL,
    customer_price_no_vat numeric DEFAULT 0 NOT NULL,
    vendor_price numeric DEFAULT 0 NOT NULL
);


--
-- Name: customer_auth_stats_id_seq; Type: SEQUENCE; Schema: stats; Owner: -
--

CREATE SEQUENCE stats.customer_auth_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_auth_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE stats.customer_auth_stats_id_seq OWNED BY stats.customer_auth_stats.id;


--
-- Name: termination_quality_stats; Type: TABLE; Schema: stats; Owner: -
--

CREATE TABLE stats.termination_quality_stats (
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

CREATE SEQUENCE stats.termination_quality_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: termination_quality_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE stats.termination_quality_stats_id_seq OWNED BY stats.termination_quality_stats.id;


--
-- Name: traffic_customer_accounts; Type: TABLE; Schema: stats; Owner: -
--

CREATE TABLE stats.traffic_customer_accounts (
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

CREATE SEQUENCE stats.traffic_customer_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: traffic_customer_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE stats.traffic_customer_accounts_id_seq OWNED BY stats.traffic_customer_accounts.id;


--
-- Name: traffic_vendor_accounts; Type: TABLE; Schema: stats; Owner: -
--

CREATE TABLE stats.traffic_vendor_accounts (
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

CREATE SEQUENCE stats.traffic_vendor_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: traffic_vendor_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: stats; Owner: -
--

ALTER SEQUENCE stats.traffic_vendor_accounts_id_seq OWNED BY stats.traffic_vendor_accounts.id;


--
-- Name: amount_round_modes; Type: TABLE; Schema: sys; Owner: -
--

CREATE TABLE sys.amount_round_modes (
    id smallint NOT NULL,
    name character varying NOT NULL
);


--
-- Name: call_duration_round_modes; Type: TABLE; Schema: sys; Owner: -
--

CREATE TABLE sys.call_duration_round_modes (
    id smallint NOT NULL,
    name character varying NOT NULL
);


--
-- Name: auth_log id; Type: DEFAULT; Schema: auth_log; Owner: -
--

ALTER TABLE ONLY auth_log.auth_log ALTER COLUMN id SET DEFAULT nextval('auth_log.auth_log_id_seq'::regclass);


--
-- Name: invoice_documents id; Type: DEFAULT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_documents ALTER COLUMN id SET DEFAULT nextval('billing.invoice_documents_id_seq'::regclass);


--
-- Name: invoice_originated_destinations id; Type: DEFAULT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_originated_destinations ALTER COLUMN id SET DEFAULT nextval('billing.invoice_originated_destinations_id_seq'::regclass);


--
-- Name: invoice_originated_networks id; Type: DEFAULT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_originated_networks ALTER COLUMN id SET DEFAULT nextval('billing.invoice_originated_networks_id_seq'::regclass);


--
-- Name: invoice_service_data id; Type: DEFAULT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_service_data ALTER COLUMN id SET DEFAULT nextval('billing.invoice_service_data_id_seq'::regclass);


--
-- Name: invoice_terminated_destinations id; Type: DEFAULT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_terminated_destinations ALTER COLUMN id SET DEFAULT nextval('billing.invoice_terminated_destinations_id_seq'::regclass);


--
-- Name: invoice_terminated_networks id; Type: DEFAULT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_terminated_networks ALTER COLUMN id SET DEFAULT nextval('billing.invoice_terminated_networks_id_seq'::regclass);


--
-- Name: invoices id; Type: DEFAULT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoices ALTER COLUMN id SET DEFAULT nextval('billing.invoices_id_seq'::regclass);


--
-- Name: cdr id; Type: DEFAULT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr.cdr ALTER COLUMN id SET DEFAULT nextval('cdr.cdr_id_seq'::regclass);


--
-- Name: cdr_custom_report id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_custom_report ALTER COLUMN id SET DEFAULT nextval('reports.cdr_custom_report_id_seq'::regclass);


--
-- Name: cdr_custom_report_data id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_custom_report_data ALTER COLUMN id SET DEFAULT nextval('reports.cdr_custom_report_data_id_seq'::regclass);


--
-- Name: cdr_custom_report_schedulers id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_custom_report_schedulers ALTER COLUMN id SET DEFAULT nextval('reports.cdr_custom_report_schedulers_id_seq'::regclass);


--
-- Name: cdr_interval_report id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_interval_report ALTER COLUMN id SET DEFAULT nextval('reports.cdr_interval_report_id_seq'::regclass);


--
-- Name: cdr_interval_report_data id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_interval_report_data ALTER COLUMN id SET DEFAULT nextval('reports.cdr_interval_report_data_id_seq'::regclass);


--
-- Name: cdr_interval_report_schedulers id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_interval_report_schedulers ALTER COLUMN id SET DEFAULT nextval('reports.cdr_interval_report_schedulers_id_seq'::regclass);


--
-- Name: customer_traffic_report id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.customer_traffic_report ALTER COLUMN id SET DEFAULT nextval('reports.customer_traffic_report_id_seq'::regclass);


--
-- Name: customer_traffic_report_data_by_destination id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.customer_traffic_report_data_by_destination ALTER COLUMN id SET DEFAULT nextval('reports.customer_traffic_report_data_by_destination_id_seq'::regclass);


--
-- Name: customer_traffic_report_data_by_vendor id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.customer_traffic_report_data_by_vendor ALTER COLUMN id SET DEFAULT nextval('reports.customer_traffic_report_data_id_seq'::regclass);


--
-- Name: customer_traffic_report_data_full id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.customer_traffic_report_data_full ALTER COLUMN id SET DEFAULT nextval('reports.customer_traffic_report_data_full_id_seq'::regclass);


--
-- Name: customer_traffic_report_schedulers id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.customer_traffic_report_schedulers ALTER COLUMN id SET DEFAULT nextval('reports.customer_traffic_report_schedulers_id_seq'::regclass);


--
-- Name: vendor_traffic_report id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.vendor_traffic_report ALTER COLUMN id SET DEFAULT nextval('reports.vendor_traffic_report_id_seq'::regclass);


--
-- Name: vendor_traffic_report_data id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.vendor_traffic_report_data ALTER COLUMN id SET DEFAULT nextval('reports.vendor_traffic_report_data_id_seq'::regclass);


--
-- Name: vendor_traffic_report_schedulers id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.vendor_traffic_report_schedulers ALTER COLUMN id SET DEFAULT nextval('reports.vendor_traffic_report_schedulers_id_seq'::regclass);


--
-- Name: rx_streams id; Type: DEFAULT; Schema: rtp_statistics; Owner: -
--

ALTER TABLE ONLY rtp_statistics.rx_streams ALTER COLUMN id SET DEFAULT nextval('rtp_statistics.rx_streams_id_seq'::regclass);


--
-- Name: tx_streams id; Type: DEFAULT; Schema: rtp_statistics; Owner: -
--

ALTER TABLE ONLY rtp_statistics.tx_streams ALTER COLUMN id SET DEFAULT nextval('rtp_statistics.tx_streams_id_seq'::regclass);


--
-- Name: active_call_accounts id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.active_call_accounts ALTER COLUMN id SET DEFAULT nextval('stats.active_call_accounts_id_seq'::regclass);


--
-- Name: active_call_accounts_hourly id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.active_call_accounts_hourly ALTER COLUMN id SET DEFAULT nextval('stats.active_call_accounts_hourly_id_seq'::regclass);


--
-- Name: active_call_orig_gateways id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.active_call_orig_gateways ALTER COLUMN id SET DEFAULT nextval('stats.active_call_orig_gateways_id_seq'::regclass);


--
-- Name: active_call_orig_gateways_hourly id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.active_call_orig_gateways_hourly ALTER COLUMN id SET DEFAULT nextval('stats.active_call_orig_gateways_hourly_id_seq'::regclass);


--
-- Name: active_call_term_gateways id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.active_call_term_gateways ALTER COLUMN id SET DEFAULT nextval('stats.active_call_term_gateways_id_seq'::regclass);


--
-- Name: active_call_term_gateways_hourly id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.active_call_term_gateways_hourly ALTER COLUMN id SET DEFAULT nextval('stats.active_call_term_gateways_hourly_id_seq'::regclass);


--
-- Name: active_calls id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.active_calls ALTER COLUMN id SET DEFAULT nextval('stats.active_calls_id_seq'::regclass);


--
-- Name: active_calls_hourly id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.active_calls_hourly ALTER COLUMN id SET DEFAULT nextval('stats.active_calls_hourly_id_seq'::regclass);


--
-- Name: customer_auth_stats id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.customer_auth_stats ALTER COLUMN id SET DEFAULT nextval('stats.customer_auth_stats_id_seq'::regclass);


--
-- Name: termination_quality_stats id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.termination_quality_stats ALTER COLUMN id SET DEFAULT nextval('stats.termination_quality_stats_id_seq'::regclass);


--
-- Name: traffic_customer_accounts id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.traffic_customer_accounts ALTER COLUMN id SET DEFAULT nextval('stats.traffic_customer_accounts_id_seq'::regclass);


--
-- Name: traffic_vendor_accounts id; Type: DEFAULT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.traffic_vendor_accounts ALTER COLUMN id SET DEFAULT nextval('stats.traffic_vendor_accounts_id_seq'::regclass);


--
-- Name: auth_log auth_log_pkey; Type: CONSTRAINT; Schema: auth_log; Owner: -
--

ALTER TABLE ONLY auth_log.auth_log
    ADD CONSTRAINT auth_log_pkey PRIMARY KEY (id, request_time);


--
-- Name: invoice_originated_destinations invoice_destinations_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_originated_destinations
    ADD CONSTRAINT invoice_destinations_pkey PRIMARY KEY (id);


--
-- Name: invoice_documents invoice_documents_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_documents
    ADD CONSTRAINT invoice_documents_pkey PRIMARY KEY (id);


--
-- Name: invoice_originated_networks invoice_networks_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_originated_networks
    ADD CONSTRAINT invoice_networks_pkey PRIMARY KEY (id);


--
-- Name: invoice_service_data invoice_service_data_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_service_data
    ADD CONSTRAINT invoice_service_data_pkey PRIMARY KEY (id);


--
-- Name: invoice_terminated_destinations invoice_terminated_destinations_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_terminated_destinations
    ADD CONSTRAINT invoice_terminated_destinations_pkey PRIMARY KEY (id);


--
-- Name: invoice_terminated_networks invoice_terminated_networks_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_terminated_networks
    ADD CONSTRAINT invoice_terminated_networks_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: cdr cdr_pkey; Type: CONSTRAINT; Schema: cdr; Owner: -
--

ALTER TABLE ONLY cdr.cdr
    ADD CONSTRAINT cdr_pkey PRIMARY KEY (id, time_start);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: external_data; Owner: -
--

ALTER TABLE ONLY external_data.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: network_prefixes network_prefixes_pkey; Type: CONSTRAINT; Schema: external_data; Owner: -
--

ALTER TABLE ONLY external_data.network_prefixes
    ADD CONSTRAINT network_prefixes_pkey PRIMARY KEY (id);


--
-- Name: networks networks_pkey; Type: CONSTRAINT; Schema: external_data; Owner: -
--

ALTER TABLE ONLY external_data.networks
    ADD CONSTRAINT networks_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: cdr_custom_report_data cdr_custom_report_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_custom_report_data
    ADD CONSTRAINT cdr_custom_report_data_pkey PRIMARY KEY (id);


--
-- Name: cdr_custom_report cdr_custom_report_pkey; Type: CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_custom_report
    ADD CONSTRAINT cdr_custom_report_pkey PRIMARY KEY (id);


--
-- Name: cdr_custom_report_schedulers cdr_custom_report_schedulers_pkey; Type: CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_custom_report_schedulers
    ADD CONSTRAINT cdr_custom_report_schedulers_pkey PRIMARY KEY (id);


--
-- Name: cdr_interval_report_aggregator cdr_interval_report_aggregator_name_key; Type: CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_interval_report_aggregator
    ADD CONSTRAINT cdr_interval_report_aggregator_name_key UNIQUE (name);


--
-- Name: cdr_interval_report_aggregator cdr_interval_report_aggregator_pkey; Type: CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_interval_report_aggregator
    ADD CONSTRAINT cdr_interval_report_aggregator_pkey PRIMARY KEY (id);


--
-- Name: cdr_interval_report_data cdr_interval_report_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_interval_report_data
    ADD CONSTRAINT cdr_interval_report_data_pkey PRIMARY KEY (id);


--
-- Name: cdr_interval_report cdr_interval_report_pkey; Type: CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_interval_report
    ADD CONSTRAINT cdr_interval_report_pkey PRIMARY KEY (id);


--
-- Name: cdr_interval_report_schedulers cdr_interval_report_schedulers_pkey; Type: CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_interval_report_schedulers
    ADD CONSTRAINT cdr_interval_report_schedulers_pkey PRIMARY KEY (id);


--
-- Name: customer_traffic_report_data_by_destination customer_traffic_report_data_by_destination_pkey; Type: CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.customer_traffic_report_data_by_destination
    ADD CONSTRAINT customer_traffic_report_data_by_destination_pkey PRIMARY KEY (id);


--
-- Name: customer_traffic_report_data_full customer_traffic_report_data_full_pkey; Type: CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.customer_traffic_report_data_full
    ADD CONSTRAINT customer_traffic_report_data_full_pkey PRIMARY KEY (id);


--
-- Name: customer_traffic_report_data_by_vendor customer_traffic_report_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.customer_traffic_report_data_by_vendor
    ADD CONSTRAINT customer_traffic_report_data_pkey PRIMARY KEY (id);


--
-- Name: customer_traffic_report customer_traffic_report_pkey; Type: CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.customer_traffic_report
    ADD CONSTRAINT customer_traffic_report_pkey PRIMARY KEY (id);


--
-- Name: customer_traffic_report_schedulers customer_traffic_report_schedulers_pkey; Type: CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.customer_traffic_report_schedulers
    ADD CONSTRAINT customer_traffic_report_schedulers_pkey PRIMARY KEY (id);


--
-- Name: scheduler_periods scheduler_periods_name_key; Type: CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.scheduler_periods
    ADD CONSTRAINT scheduler_periods_name_key UNIQUE (name);


--
-- Name: scheduler_periods scheduler_periods_pkey; Type: CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.scheduler_periods
    ADD CONSTRAINT scheduler_periods_pkey PRIMARY KEY (id);


--
-- Name: vendor_traffic_report_data vendor_traffic_report_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.vendor_traffic_report_data
    ADD CONSTRAINT vendor_traffic_report_data_pkey PRIMARY KEY (id);


--
-- Name: vendor_traffic_report vendor_traffic_report_pkey; Type: CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.vendor_traffic_report
    ADD CONSTRAINT vendor_traffic_report_pkey PRIMARY KEY (id);


--
-- Name: vendor_traffic_report_schedulers vendor_traffic_report_schedulers_pkey; Type: CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.vendor_traffic_report_schedulers
    ADD CONSTRAINT vendor_traffic_report_schedulers_pkey PRIMARY KEY (id);


--
-- Name: rx_streams rx_streams_pkey; Type: CONSTRAINT; Schema: rtp_statistics; Owner: -
--

ALTER TABLE ONLY rtp_statistics.rx_streams
    ADD CONSTRAINT rx_streams_pkey PRIMARY KEY (id, time_start);


--
-- Name: tx_streams tx_streams_pkey; Type: CONSTRAINT; Schema: rtp_statistics; Owner: -
--

ALTER TABLE ONLY rtp_statistics.tx_streams
    ADD CONSTRAINT tx_streams_pkey PRIMARY KEY (id, time_start);


--
-- Name: active_call_accounts_hourly active_call_accounts_hourly_pkey; Type: CONSTRAINT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.active_call_accounts_hourly
    ADD CONSTRAINT active_call_accounts_hourly_pkey PRIMARY KEY (id);


--
-- Name: active_call_accounts active_call_accounts_pkey; Type: CONSTRAINT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.active_call_accounts
    ADD CONSTRAINT active_call_accounts_pkey PRIMARY KEY (id);


--
-- Name: active_call_orig_gateways_hourly active_call_orig_gateways_hourly_pkey; Type: CONSTRAINT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.active_call_orig_gateways_hourly
    ADD CONSTRAINT active_call_orig_gateways_hourly_pkey PRIMARY KEY (id);


--
-- Name: active_call_orig_gateways active_call_orig_gateways_pkey; Type: CONSTRAINT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.active_call_orig_gateways
    ADD CONSTRAINT active_call_orig_gateways_pkey PRIMARY KEY (id);


--
-- Name: active_call_term_gateways_hourly active_call_term_gateways_hourly_pkey; Type: CONSTRAINT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.active_call_term_gateways_hourly
    ADD CONSTRAINT active_call_term_gateways_hourly_pkey PRIMARY KEY (id);


--
-- Name: active_call_term_gateways active_call_term_gateways_pkey; Type: CONSTRAINT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.active_call_term_gateways
    ADD CONSTRAINT active_call_term_gateways_pkey PRIMARY KEY (id);


--
-- Name: active_calls_hourly active_calls_hourly_pkey; Type: CONSTRAINT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.active_calls_hourly
    ADD CONSTRAINT active_calls_hourly_pkey PRIMARY KEY (id);


--
-- Name: active_calls active_calls_pkey; Type: CONSTRAINT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.active_calls
    ADD CONSTRAINT active_calls_pkey PRIMARY KEY (id);


--
-- Name: customer_auth_stats customer_auth_stats_pkey; Type: CONSTRAINT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.customer_auth_stats
    ADD CONSTRAINT customer_auth_stats_pkey PRIMARY KEY (id);


--
-- Name: termination_quality_stats termination_quality_stats_pkey; Type: CONSTRAINT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.termination_quality_stats
    ADD CONSTRAINT termination_quality_stats_pkey PRIMARY KEY (id);


--
-- Name: traffic_customer_accounts traffic_customer_accounts_pkey; Type: CONSTRAINT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.traffic_customer_accounts
    ADD CONSTRAINT traffic_customer_accounts_pkey PRIMARY KEY (id);


--
-- Name: traffic_vendor_accounts traffic_vendor_accounts_pkey; Type: CONSTRAINT; Schema: stats; Owner: -
--

ALTER TABLE ONLY stats.traffic_vendor_accounts
    ADD CONSTRAINT traffic_vendor_accounts_pkey PRIMARY KEY (id);


--
-- Name: amount_round_modes amount_round_modes_name_key; Type: CONSTRAINT; Schema: sys; Owner: -
--

ALTER TABLE ONLY sys.amount_round_modes
    ADD CONSTRAINT amount_round_modes_name_key UNIQUE (name);


--
-- Name: amount_round_modes amount_round_modes_pkey; Type: CONSTRAINT; Schema: sys; Owner: -
--

ALTER TABLE ONLY sys.amount_round_modes
    ADD CONSTRAINT amount_round_modes_pkey PRIMARY KEY (id);


--
-- Name: call_duration_round_modes call_duration_round_modes_name_key; Type: CONSTRAINT; Schema: sys; Owner: -
--

ALTER TABLE ONLY sys.call_duration_round_modes
    ADD CONSTRAINT call_duration_round_modes_name_key UNIQUE (name);


--
-- Name: call_duration_round_modes call_duration_round_modes_pkey; Type: CONSTRAINT; Schema: sys; Owner: -
--

ALTER TABLE ONLY sys.call_duration_round_modes
    ADD CONSTRAINT call_duration_round_modes_pkey PRIMARY KEY (id);


--
-- Name: config config_pkey; Type: CONSTRAINT; Schema: sys; Owner: -
--

ALTER TABLE ONLY sys.config
    ADD CONSTRAINT config_pkey PRIMARY KEY (id);


--
-- Name: auth_log_id_idx; Type: INDEX; Schema: auth_log; Owner: -
--

CREATE INDEX auth_log_id_idx ON ONLY auth_log.auth_log USING btree (id);


--
-- Name: auth_log_request_time_idx; Type: INDEX; Schema: auth_log; Owner: -
--

CREATE INDEX auth_log_request_time_idx ON ONLY auth_log.auth_log USING btree (request_time);


--
-- Name: index_billing.invoices_on_reference; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX "index_billing.invoices_on_reference" ON billing.invoices USING btree (reference);


--
-- Name: invoice_documents_invoice_id_idx; Type: INDEX; Schema: billing; Owner: -
--

CREATE UNIQUE INDEX invoice_documents_invoice_id_idx ON billing.invoice_documents USING btree (invoice_id);


--
-- Name: invoice_originated_destinations_invoice_id_idx; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX invoice_originated_destinations_invoice_id_idx ON billing.invoice_originated_destinations USING btree (invoice_id);


--
-- Name: invoice_originated_networks_invoice_id_idx; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX invoice_originated_networks_invoice_id_idx ON billing.invoice_originated_networks USING btree (invoice_id);


--
-- Name: invoice_service_data_invoice_id_idx; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX invoice_service_data_invoice_id_idx ON billing.invoice_service_data USING btree (invoice_id);


--
-- Name: invoice_terminated_destinations_invoice_id_idx; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX invoice_terminated_destinations_invoice_id_idx ON billing.invoice_terminated_destinations USING btree (invoice_id);


--
-- Name: invoice_terminated_networks_invoice_id_idx; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX invoice_terminated_networks_invoice_id_idx ON billing.invoice_terminated_networks USING btree (invoice_id);


--
-- Name: cdr_customer_acc_external_id_time_start_idx; Type: INDEX; Schema: cdr; Owner: -
--

CREATE INDEX cdr_customer_acc_external_id_time_start_idx ON ONLY cdr.cdr USING btree (customer_acc_external_id, time_start) WHERE is_last_cdr;


--
-- Name: cdr_customer_acc_id_time_start_idx1; Type: INDEX; Schema: cdr; Owner: -
--

CREATE INDEX cdr_customer_acc_id_time_start_idx1 ON ONLY cdr.cdr USING btree (customer_acc_id, time_start);


--
-- Name: cdr_customer_id_time_start_idx; Type: INDEX; Schema: cdr; Owner: -
--

CREATE INDEX cdr_customer_id_time_start_idx ON ONLY cdr.cdr USING btree (customer_id, time_start);


--
-- Name: cdr_id_idx; Type: INDEX; Schema: cdr; Owner: -
--

CREATE INDEX cdr_id_idx ON ONLY cdr.cdr USING btree (id);


--
-- Name: cdr_time_start_idx; Type: INDEX; Schema: cdr; Owner: -
--

CREATE INDEX cdr_time_start_idx ON ONLY cdr.cdr USING btree (time_start);


--
-- Name: cdr_vendor_id_time_start_idx; Type: INDEX; Schema: cdr; Owner: -
--

CREATE INDEX cdr_vendor_id_time_start_idx ON ONLY cdr.cdr USING btree (vendor_id, time_start);


--
-- Name: unique_public.schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "unique_public.schema_migrations" ON public.schema_migrations USING btree (version);


--
-- Name: cdr_custom_report_data_report_id_idx; Type: INDEX; Schema: reports; Owner: -
--

CREATE INDEX cdr_custom_report_data_report_id_idx ON reports.cdr_custom_report_data USING btree (report_id);


--
-- Name: cdr_interval_report_data_report_id_idx; Type: INDEX; Schema: reports; Owner: -
--

CREATE INDEX cdr_interval_report_data_report_id_idx ON reports.cdr_interval_report_data USING btree (report_id);


--
-- Name: customer_traffic_report_data_by_destination_report_id_idx; Type: INDEX; Schema: reports; Owner: -
--

CREATE INDEX customer_traffic_report_data_by_destination_report_id_idx ON reports.customer_traffic_report_data_by_destination USING btree (report_id);


--
-- Name: customer_traffic_report_data_full_report_id_idx; Type: INDEX; Schema: reports; Owner: -
--

CREATE INDEX customer_traffic_report_data_full_report_id_idx ON reports.customer_traffic_report_data_full USING btree (report_id);


--
-- Name: customer_traffic_report_data_report_id_idx; Type: INDEX; Schema: reports; Owner: -
--

CREATE INDEX customer_traffic_report_data_report_id_idx ON reports.customer_traffic_report_data_by_vendor USING btree (report_id);


--
-- Name: vendor_traffic_report_data_report_id_idx; Type: INDEX; Schema: reports; Owner: -
--

CREATE INDEX vendor_traffic_report_data_report_id_idx ON reports.vendor_traffic_report_data USING btree (report_id);


--
-- Name: active_call_accounts_account_id_created_at_idx; Type: INDEX; Schema: stats; Owner: -
--

CREATE INDEX active_call_accounts_account_id_created_at_idx ON stats.active_call_accounts USING btree (account_id, created_at);


--
-- Name: customer_auth_stats_customer_auth_id_timestamp_idx; Type: INDEX; Schema: stats; Owner: -
--

CREATE UNIQUE INDEX customer_auth_stats_customer_auth_id_timestamp_idx ON stats.customer_auth_stats USING btree (customer_auth_id, "timestamp");


--
-- Name: termination_quality_stats_dialpeer_id_idx; Type: INDEX; Schema: stats; Owner: -
--

CREATE INDEX termination_quality_stats_dialpeer_id_idx ON stats.termination_quality_stats USING btree (dialpeer_id);


--
-- Name: termination_quality_stats_gateway_id_idx; Type: INDEX; Schema: stats; Owner: -
--

CREATE INDEX termination_quality_stats_gateway_id_idx ON stats.termination_quality_stats USING btree (gateway_id);


--
-- Name: traffic_customer_accounts_account_id_timestamp_idx; Type: INDEX; Schema: stats; Owner: -
--

CREATE UNIQUE INDEX traffic_customer_accounts_account_id_timestamp_idx ON stats.traffic_customer_accounts USING btree (account_id, "timestamp");


--
-- Name: traffic_vendor_accounts_account_id_timestamp_idx; Type: INDEX; Schema: stats; Owner: -
--

CREATE UNIQUE INDEX traffic_vendor_accounts_account_id_timestamp_idx ON stats.traffic_vendor_accounts USING btree (account_id, "timestamp");


--
-- Name: invoice_documents invoice_documents_invoice_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_documents
    ADD CONSTRAINT invoice_documents_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES billing.invoices(id);


--
-- Name: invoice_originated_destinations invoice_originated_destinations_invoice_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_originated_destinations
    ADD CONSTRAINT invoice_originated_destinations_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES billing.invoices(id);


--
-- Name: invoice_originated_networks invoice_originated_networks_invoice_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_originated_networks
    ADD CONSTRAINT invoice_originated_networks_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES billing.invoices(id);


--
-- Name: invoice_service_data invoice_service_data_invoice_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_service_data
    ADD CONSTRAINT invoice_service_data_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES billing.invoices(id);


--
-- Name: invoice_terminated_destinations invoice_terminated_destinations_invoice_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_terminated_destinations
    ADD CONSTRAINT invoice_terminated_destinations_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES billing.invoices(id);


--
-- Name: invoice_terminated_networks invoice_terminated_networks_invoice_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_terminated_networks
    ADD CONSTRAINT invoice_terminated_networks_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES billing.invoices(id);


--
-- Name: cdr_custom_report_data cdr_custom_report_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_custom_report_data
    ADD CONSTRAINT cdr_custom_report_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES reports.cdr_custom_report(id);


--
-- Name: cdr_custom_report_schedulers cdr_custom_report_schedulers_period_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_custom_report_schedulers
    ADD CONSTRAINT cdr_custom_report_schedulers_period_id_fkey FOREIGN KEY (period_id) REFERENCES reports.scheduler_periods(id);


--
-- Name: cdr_interval_report cdr_interval_report_aggregator_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_interval_report
    ADD CONSTRAINT cdr_interval_report_aggregator_id_fkey FOREIGN KEY (aggregator_id) REFERENCES reports.cdr_interval_report_aggregator(id);


--
-- Name: cdr_interval_report_data cdr_interval_report_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_interval_report_data
    ADD CONSTRAINT cdr_interval_report_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES reports.cdr_interval_report(id);


--
-- Name: cdr_interval_report_schedulers cdr_interval_report_schedulers_period_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.cdr_interval_report_schedulers
    ADD CONSTRAINT cdr_interval_report_schedulers_period_id_fkey FOREIGN KEY (period_id) REFERENCES reports.scheduler_periods(id);


--
-- Name: customer_traffic_report_data_by_vendor customer_traffic_report_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.customer_traffic_report_data_by_vendor
    ADD CONSTRAINT customer_traffic_report_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES reports.customer_traffic_report(id);


--
-- Name: customer_traffic_report_schedulers customer_traffic_report_schedulers_period_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.customer_traffic_report_schedulers
    ADD CONSTRAINT customer_traffic_report_schedulers_period_id_fkey FOREIGN KEY (period_id) REFERENCES reports.scheduler_periods(id);


--
-- Name: vendor_traffic_report_data vendor_traffic_report_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.vendor_traffic_report_data
    ADD CONSTRAINT vendor_traffic_report_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES reports.vendor_traffic_report(id);


--
-- Name: vendor_traffic_report_schedulers vendor_traffic_report_schedulers_period_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY reports.vendor_traffic_report_schedulers
    ADD CONSTRAINT vendor_traffic_report_schedulers_period_id_fkey FOREIGN KEY (period_id) REFERENCES reports.scheduler_periods(id);


--
-- Name: config config_call_duration_round_mode_id_fkey; Type: FK CONSTRAINT; Schema: sys; Owner: -
--

ALTER TABLE ONLY sys.config
    ADD CONSTRAINT config_call_duration_round_mode_id_fkey FOREIGN KEY (call_duration_round_mode_id) REFERENCES sys.call_duration_round_modes(id);


--
-- Name: config config_customer_amount_round_mode_id_fkey; Type: FK CONSTRAINT; Schema: sys; Owner: -
--

ALTER TABLE ONLY sys.config
    ADD CONSTRAINT config_customer_amount_round_mode_id_fkey FOREIGN KEY (customer_amount_round_mode_id) REFERENCES sys.amount_round_modes(id);


--
-- Name: config config_vendor_amount_round_mode_id_fkey; Type: FK CONSTRAINT; Schema: sys; Owner: -
--

ALTER TABLE ONLY sys.config
    ADD CONSTRAINT config_vendor_amount_round_mode_id_fkey FOREIGN KEY (vendor_amount_round_mode_id) REFERENCES sys.amount_round_modes(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO cdr, reports, billing, public;

INSERT INTO "public"."schema_migrations" (version) VALUES
('20170907204350'),
('20170911172650'),
('20171104162958'),
('20180228200703'),
('20180307142909'),
('20180312211714'),
('20180312215122'),
('20180328123622'),
('20180328170352'),
('20180425200716'),
('20180427194936'),
('20180607135226'),
('20180611140540'),
('20180619091111'),
('20180621130107'),
('20180911180345'),
('20181105175206'),
('20190604064015'),
('20190629185813'),
('20190707214813'),
('20200105230734'),
('20200106104136'),
('20200120195529'),
('20200120200605'),
('20200220113109'),
('20200221080918'),
('20200514153523'),
('20200527173737'),
('20200803201602'),
('20201128134302'),
('20210116150950'),
('20210212102105'),
('20210218095038'),
('20210223125543'),
('20210307170219'),
('20210614110059'),
('20211005183259'),
('20220221142459'),
('20220317170217'),
('20220317180321'),
('20220317180333'),
('20220426100841'),
('20220503094804'),
('20220509203319'),
('20220625185940'),
('20220709123408'),
('20220803115423'),
('20221105191015'),
('20230321124900'),
('20230518150839'),
('20230524185032'),
('20230602123903'),
('20230708183812'),
('20230828175949'),
('20230913210707'),
('20230916152534'),
('20230929081324'),
('20231007121159'),
('20231007123320'),
('20231027110359'),
('20231101165858'),
('20231106100135'),
('20231106125344'),
('20231212213111'),
('20231231115209'),
('20240122201619'),
('20240405165010'),
('20240411092931'),
('20240609092136'),
('20240617084103'),
('20241006113650'),
('20241006123022'),
('20241216143200');


