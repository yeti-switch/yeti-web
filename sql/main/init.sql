begin;
--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.5
-- Dumped by pg_dump version 9.3.5
-- Started on 2014-10-13 15:09:31 EEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 6 (class 2615 OID 16386)
-- Name: billing; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA billing;


--
-- TOC entry 7 (class 2615 OID 16387)
-- Name: class4; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA class4;


--
-- TOC entry 8 (class 2615 OID 16388)
-- Name: data_import; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA data_import;


--
-- TOC entry 9 (class 2615 OID 16389)
-- Name: gui; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA gui;


--
-- TOC entry 10 (class 2615 OID 16390)
-- Name: logs; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA logs;


--
-- TOC entry 11 (class 2615 OID 16391)
-- Name: reports; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA reports;


--
-- TOC entry 12 (class 2615 OID 16392)
-- Name: runtime_stats; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA runtime_stats;


--
-- TOC entry 15 (class 2615 OID 18899)
-- Name: switch1; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA switch1;


--
-- TOC entry 13 (class 2615 OID 16394)
-- Name: sys; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA sys;


--
-- TOC entry 318 (class 3079 OID 11756)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3526 (class 0 OID 0)
-- Dependencies: 318
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 322 (class 3079 OID 16395)
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- TOC entry 3527 (class 0 OID 0)
-- Dependencies: 322
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- TOC entry 321 (class 3079 OID 16917)
-- Name: dblink; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;


--
-- TOC entry 3528 (class 0 OID 0)
-- Dependencies: 321
-- Name: EXTENSION dblink; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';


--
-- TOC entry 320 (class 3079 OID 16963)
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- TOC entry 3529 (class 0 OID 0)
-- Dependencies: 320
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- TOC entry 319 (class 3079 OID 17083)
-- Name: prefix; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS prefix WITH SCHEMA public;


--
-- TOC entry 3530 (class 0 OID 0)
-- Dependencies: 319
-- Name: EXTENSION prefix; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION prefix IS 'Prefix Range module for PostgreSQL';


SET search_path = billing, pg_catalog;

--
-- TOC entry 1336 (class 1247 OID 18716)
-- Name: cdr_v1; Type: TYPE; Schema: billing; Owner: -
--

CREATE TYPE cdr_v1 AS (
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
	vendor_billed boolean,
	customer_billed boolean,
	profit numeric,
	dst_prefix_in character varying,
	dst_prefix_out character varying,
	src_prefix_in character varying,
	src_prefix_out character varying,
	time_start timestamp without time zone,
	time_connect timestamp without time zone,
	time_end timestamp without time zone,
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
	dump_level_id integer,
	auth_orig_ip inet,
	auth_orig_port integer,
	lega_rx_bytes integer,
	lega_tx_bytes integer,
	legb_rx_bytes integer,
	legb_tx_bytes integer,
	global_tag character varying
);


SET search_path = switch1, pg_catalog;

--
-- TOC entry 1360 (class 1247 OID 18902)
-- Name: callprofile34_ty; Type: TYPE; Schema: switch1; Owner: -
--

CREATE TYPE callprofile34_ty AS (
	ruri character varying,
	ruri_host character varying,
	"from" character varying,
	"to" character varying,
	call_id character varying,
	transparent_dlg_id boolean,
	dlg_nat_handling boolean,
	force_outbound_proxy boolean,
	outbound_proxy character varying,
	aleg_force_outbound_proxy boolean,
	aleg_outbound_proxy character varying,
	next_hop character varying,
	next_hop_1st_req boolean,
	aleg_next_hop character varying,
	header_filter_type_id integer,
	header_filter_list character varying,
	message_filter_type_id integer,
	message_filter_list character varying,
	anonymize_sdp boolean,
	sdp_filter_type_id integer,
	sdp_filter_list character varying,
	sdp_alines_filter_type_id integer,
	sdp_alines_filter_list character varying,
	enable_session_timer boolean,
	enable_aleg_session_timer boolean,
	session_expires integer,
	minimum_timer integer,
	maximum_timer integer,
	session_refresh_method_id integer,
	accept_501_reply character varying,
	aleg_session_expires integer,
	aleg_minimum_timer integer,
	aleg_maximum_timer integer,
	aleg_session_refresh_method_id integer,
	aleg_accept_501_reply character varying,
	enable_auth boolean,
	auth_user character varying,
	auth_pwd character varying,
	enable_aleg_auth boolean,
	auth_aleg_user character varying,
	auth_aleg_pwd character varying,
	append_headers character varying,
	append_headers_req character varying,
	aleg_append_headers_req character varying,
	disconnect_code_id integer,
	enable_rtprelay boolean,
	rtprelay_force_symmetric_rtp boolean,
	rtprelay_msgflags_symmetric_rtp boolean,
	rtprelay_interface character varying,
	aleg_rtprelay_interface character varying,
	rtprelay_transparent_seqno boolean,
	rtprelay_transparent_ssrc boolean,
	outbound_interface character varying,
	aleg_outbound_interface character varying,
	contact_displayname character varying,
	contact_user character varying,
	contact_host character varying,
	contact_port smallint,
	enable_contact_hiding boolean,
	contact_hiding_prefix character varying,
	contact_hiding_vars character varying,
	try_avoid_transcoding boolean,
	rtprelay_dtmf_filtering boolean,
	rtprelay_dtmf_detection boolean,
	prefer_existing_codecs_aleg character varying,
	transcoder_codecs character varying,
	callee_codeccaps character varying,
	enable_transcoder character varying,
	dtmf_transcoding character varying,
	lowfi_codecs character varying,
	prefer_transcoding_for_codecs character varying,
	prefer_transcoding_for_codecs_aleg character varying,
	dump_level_id integer,
	enable_reg_caching boolean,
	min_reg_expires integer,
	max_ua_expires integer,
	time_limit integer,
	resources character varying,
	cache_time integer,
	reply_translations character varying,
	aleg_rtprelay_force_symmetric_rtp boolean,
	aleg_policy_id integer,
	bleg_policy_id integer,
	aleg_codecs_group_id integer,
	bleg_codecs_group_id integer,
	aleg_single_codec_in_200ok boolean,
	bleg_single_codec_in_200ok boolean,
	ringing_timeout integer,
	global_tag character varying,
	patch_ruri_next_hop boolean,
	rtprelay_force_dtmf_relay boolean,
	aleg_force_symmetric_rtp boolean,
	bleg_force_symmetric_rtp boolean,
	aleg_symmetric_rtp_nonstop boolean,
	bleg_symmetric_rtp_nonstop boolean,
	aleg_symmetric_rtp_ignore_rtcp boolean,
	bleg_symmetric_rtp_ignore_rtcp boolean,
	aleg_rtp_ping boolean,
	bleg_rtp_ping boolean,
	aleg_relay_options boolean,
	bleg_relay_options boolean,
	filter_noaudio_streams boolean,
	relay_reinvite boolean,
	aleg_sdp_c_location_id integer,
	bleg_sdp_c_location_id integer,
	trusted_hdrs_gw boolean,
	aleg_append_headers_reply character varying,
	bleg_sdp_alines_filter_list character varying,
	bleg_sdp_alines_filter_type_id integer,
	customer_id character varying,
	vendor_id character varying,
	customer_acc_id character varying,
	vendor_acc_id character varying,
	customer_auth_id character varying,
	destination_id character varying,
	dialpeer_id character varying,
	orig_gw_id character varying,
	term_gw_id character varying,
	routing_group_id character varying,
	rateplan_id character varying,
	destination_initial_rate character varying,
	destination_next_rate character varying,
	destination_initial_interval integer,
	destination_next_interval integer,
	destination_rate_policy_id integer,
	dialpeer_initial_interval integer,
	dialpeer_next_interval integer,
	dialpeer_next_rate character varying,
	destination_fee character varying,
	dialpeer_initial_rate character varying,
	dialpeer_fee character varying,
	dst_prefix_in character varying,
	dst_prefix_out character varying,
	src_prefix_in character varying,
	src_prefix_out character varying,
	src_name_in character varying,
	src_name_out character varying,
	diversion_in character varying,
	diversion_out character varying,
	auth_orig_ip inet,
	auth_orig_port integer
);


--
-- TOC entry 1388 (class 1247 OID 19012)
-- Name: callprofile35_ty; Type: TYPE; Schema: switch1; Owner: -
--

CREATE TYPE callprofile35_ty AS (
	ruri character varying,
	ruri_host character varying,
	"from" character varying,
	"to" character varying,
	call_id character varying,
	transparent_dlg_id boolean,
	dlg_nat_handling boolean,
	force_outbound_proxy boolean,
	outbound_proxy character varying,
	aleg_force_outbound_proxy boolean,
	aleg_outbound_proxy character varying,
	next_hop character varying,
	next_hop_1st_req boolean,
	aleg_next_hop character varying,
	header_filter_type_id integer,
	header_filter_list character varying,
	message_filter_type_id integer,
	message_filter_list character varying,
	anonymize_sdp boolean,
	sdp_filter_type_id integer,
	sdp_filter_list character varying,
	sdp_alines_filter_type_id integer,
	sdp_alines_filter_list character varying,
	enable_session_timer boolean,
	enable_aleg_session_timer boolean,
	session_expires integer,
	minimum_timer integer,
	maximum_timer integer,
	session_refresh_method_id integer,
	accept_501_reply character varying,
	aleg_session_expires integer,
	aleg_minimum_timer integer,
	aleg_maximum_timer integer,
	aleg_session_refresh_method_id integer,
	aleg_accept_501_reply character varying,
	enable_auth boolean,
	auth_user character varying,
	auth_pwd character varying,
	enable_aleg_auth boolean,
	auth_aleg_user character varying,
	auth_aleg_pwd character varying,
	append_headers character varying,
	append_headers_req character varying,
	aleg_append_headers_req character varying,
	disconnect_code_id integer,
	enable_rtprelay boolean,
	rtprelay_msgflags_symmetric_rtp boolean,
	rtprelay_interface character varying,
	aleg_rtprelay_interface character varying,
	rtprelay_transparent_seqno boolean,
	rtprelay_transparent_ssrc boolean,
	outbound_interface character varying,
	aleg_outbound_interface character varying,
	contact_displayname character varying,
	contact_user character varying,
	contact_host character varying,
	contact_port smallint,
	enable_contact_hiding boolean,
	contact_hiding_prefix character varying,
	contact_hiding_vars character varying,
	try_avoid_transcoding boolean,
	rtprelay_dtmf_filtering boolean,
	rtprelay_dtmf_detection boolean,
	dtmf_transcoding character varying,
	lowfi_codecs character varying,
	dump_level_id integer,
	enable_reg_caching boolean,
	min_reg_expires integer,
	max_ua_expires integer,
	time_limit integer,
	resources character varying,
	cache_time integer,
	reply_translations character varying,
	aleg_policy_id integer,
	bleg_policy_id integer,
	aleg_codecs_group_id integer,
	bleg_codecs_group_id integer,
	aleg_single_codec_in_200ok boolean,
	bleg_single_codec_in_200ok boolean,
	ringing_timeout integer,
	global_tag character varying,
	patch_ruri_next_hop boolean,
	rtprelay_force_dtmf_relay boolean,
	aleg_force_symmetric_rtp boolean,
	bleg_force_symmetric_rtp boolean,
	aleg_symmetric_rtp_nonstop boolean,
	bleg_symmetric_rtp_nonstop boolean,
	aleg_symmetric_rtp_ignore_rtcp boolean,
	bleg_symmetric_rtp_ignore_rtcp boolean,
	aleg_rtp_ping boolean,
	bleg_rtp_ping boolean,
	aleg_relay_options boolean,
	bleg_relay_options boolean,
	filter_noaudio_streams boolean,
	relay_reinvite boolean,
	aleg_sdp_c_location_id integer,
	bleg_sdp_c_location_id integer,
	trusted_hdrs_gw boolean,
	aleg_append_headers_reply character varying,
	bleg_sdp_alines_filter_list character varying,
	bleg_sdp_alines_filter_type_id integer,
	relay_hold boolean,
	dead_rtp_time integer,
	relay_prack boolean,
	customer_id character varying,
	vendor_id character varying,
	customer_acc_id character varying,
	vendor_acc_id character varying,
	customer_auth_id character varying,
	destination_id character varying,
	dialpeer_id character varying,
	orig_gw_id character varying,
	term_gw_id character varying,
	routing_group_id character varying,
	rateplan_id character varying,
	destination_initial_rate character varying,
	destination_next_rate character varying,
	destination_initial_interval integer,
	destination_next_interval integer,
	destination_rate_policy_id integer,
	dialpeer_initial_interval integer,
	dialpeer_next_interval integer,
	dialpeer_next_rate character varying,
	destination_fee character varying,
	dialpeer_initial_rate character varying,
	dialpeer_fee character varying,
	dst_prefix_in character varying,
	dst_prefix_out character varying,
	src_prefix_in character varying,
	src_prefix_out character varying,
	src_name_in character varying,
	src_name_out character varying,
	diversion_in character varying,
	diversion_out character varying,
	auth_orig_ip inet,
	auth_orig_port integer
);


SET search_path = billing, pg_catalog;

--
-- TOC entry 609 (class 1255 OID 17171)
-- Name: bill_account(integer, numeric); Type: FUNCTION; Schema: billing; Owner: -
--

CREATE FUNCTION bill_account(i_account_id integer, i_amount numeric) RETURNS boolean
    LANGUAGE plpgsql COST 10
    AS $$

DECLARE
i integer;
v_id bigint;
BEGIN
        UPDATE billing.accounts SET balance=balance-i_amount WHERE id=i_account_id;
        RETURN FOUND;
END;
$$;


--
-- TOC entry 649 (class 1255 OID 18717)
-- Name: bill_cdr(cdr_v1); Type: FUNCTION; Schema: billing; Owner: -
--

CREATE FUNCTION bill_cdr(i_cdr cdr_v1) RETURNS cdr_v1
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
BEGIN
        i_cdr.vendor_price:=i_cdr.dialpeer_fee+
            i_cdr.dialpeer_initial_interval*i_cdr.dialpeer_initial_rate::numeric/60 + -- initial interval billing
            (i_cdr.duration>i_cdr.dialpeer_initial_interval)::boolean::integer * -- next interval billing enabled
            CEIL((i_cdr.duration-i_cdr.dialpeer_initial_interval)::numeric/i_cdr.dialpeer_next_interval) *-- next interval count
            i_cdr.dialpeer_next_interval * --interval len
            i_cdr.dialpeer_next_rate::numeric/60; -- next interval rate per second

        i_cdr.customer_price:=i_cdr.destination_fee+
            i_cdr.destination_initial_interval*i_cdr.destination_initial_rate::numeric/60 + -- initial interval billing
            (i_cdr.duration>i_cdr.destination_initial_interval)::boolean::integer * -- next interval billing enabled
            CEIL((i_cdr.duration-i_cdr.destination_initial_interval)::numeric/i_cdr.destination_next_interval) * -- next interval count
            i_cdr.destination_next_interval * --interval len
            i_cdr.destination_next_rate::numeric/60;  -- next interval rate per second
            
        i_cdr.vendor_billed:=billing.bill_account(i_cdr.vendor_acc_id, -i_cdr.vendor_price::numeric);
        i_cdr.customer_billed:=billing.bill_account(i_cdr.customer_acc_id, i_cdr.customer_price::numeric);
        i_cdr.profit=i_cdr.customer_billed::integer*i_cdr.customer_price-i_cdr.vendor_billed::integer*i_cdr.vendor_price;
        RETURN i_cdr;
END;
$$;


--
-- TOC entry 612 (class 1255 OID 17182)
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
        PERFORM sys.logic_log('billing.invoice_generate', 100, 'Started. i_contractor_id='||i_contractor_id::varchar||' i_account_id='||i_account_id::varchar);
        BEGIN
                INSERT into billing.invoices(contractor_id,account_id,start_date,end_date,amount,vendor_invoice,cdrs)
                        VALUES(i_contractor_id,i_account_id,i_startdate,i_enddate,0,i_vendor_flag,0) RETURNING id INTO v_id;
        EXCEPTION
                WHEN foreign_key_violation THEN
                        RAISE EXCEPTION 'billing.invoice_generate: account not found in this moment';
        END;

        if i_vendor_flag THEN
                PERFORM * FROM class4.cdrs WHERE vendor_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND vendor_invoice_id IS NOT NULL;
                IF FOUND THEN
                        RAISE EXCEPTION 'billing.invoice_generate: some vendor invoices already found for this interval';
                END IF;
                UPDATE class4.cdrs SET vendor_invoice_id=v_id WHERE vendor_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND vendor_invoice_id IS NULL;
                SELECT INTO v_count,v_amount,v_min_date,v_max_date
                        count(*),
                        COALESCE(sum(vendor_price),0),
                        min(time_start),
                        max(time_start)
                        from class4.cdrs 
                        WHERE vendor_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND vendor_invoice_id =v_id;
                        RAISE NOTICE 'wer % - %',v_count,v_amount;
                UPDATE billing.invoices SET amount=v_amount,cdrs=v_count,first_cdr_date=v_min_date,last_cdr_date=v_max_date WHERE id=v_id;
        ELSE
                PERFORM * FROM class4.cdrs WHERE customer_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND customer_invoice_id IS NOT NULL;
                IF FOUND THEN
                        RAISE EXCEPTION 'billing.invoice_generate: some customer invoices already found for this interval';
                END IF;
                UPDATE class4.cdrs SET customer_invoice_id=v_id WHERE customer_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND customer_invoice_id IS NULL;
                SELECT INTO v_count,v_amount,v_min_date,v_max_date
                        count(*),
                        COALESCE(sum(customer_price),0),
                        min(time_start),
                        max(time_start)
                         from class4.cdrs 
                        WHERE customer_acc_id =i_account_id AND time_start>=i_startdate AND time_end<i_enddate AND customer_invoice_id =v_id;
                UPDATE billing.invoices SET amount=v_amount,cdrs=v_count,first_cdr_date=v_min_date,last_cdr_date=v_max_date WHERE id=v_id;
        END IF;
        PERFORM sys.logic_log('billing.invoice_generate', 100, 'Done.');
RETURN v_id;
END;
$$;


--
-- TOC entry 613 (class 1255 OID 17183)
-- Name: invoice_remove(integer); Type: FUNCTION; Schema: billing; Owner: -
--

CREATE FUNCTION invoice_remove(i_invoice_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
v_vendor_flag boolean;
BEGIN
        SELECT into v_vendor_flag vendor_invoice from billing.invoices WHERE id=i_invoice_id;
        IF NOT FOUND THEN
               --RAISE EXCEPTION 'Already removed';
               RETURN;
        END IF;

        IF v_vendor_flag THEN
                UPdate class4.cdrs set vendor_invoice_id = NULL where vendor_invoice_id=i_invoice_id;
        ELSE
                UPdate class4.cdrs set customer_invoice_id = NULL where customer_invoice_id=i_invoice_id;
        END IF;

        DELETE FROM billing.invoices where id=i_invoice_id;

END;
$$;


--
-- TOC entry 614 (class 1255 OID 17184)
-- Name: payment_add(integer, numeric, character varying); Type: FUNCTION; Schema: billing; Owner: -
--

CREATE FUNCTION payment_add(i_account_id integer, i_amount numeric, i_notes character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

DECLARE
i integer;
v_id bigint;
BEGIN
        PERFORM * FROM billing.accounts WHERE id=i_account_id FOR UPDATE;
        IF NOT FOUND THEN
                RAISE EXCEPTION 'billing.payment_add: account % not found', i_account_id;
        END IF;
        INSERT INTO billing.payments(account_id,amount,notes)
                VALUES(i_account_id,i_amount,i_notes) RETURNING id INTO v_id;
        UPDATE billing.accounts SET balance=balance+i_amount::real WHERE id=i_account_id;
RETURN v_id;
END;
$$;


--
-- TOC entry 615 (class 1255 OID 17185)
-- Name: unbill_cdr(bigint); Type: FUNCTION; Schema: billing; Owner: -
--

CREATE FUNCTION unbill_cdr(i_cdr_id bigint) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    v_cdr class4.cdrs%rowtype;
BEGIN
        SELECT into v_cdr * from class4.cdrs WHERE id=i_cdr_id;
        PERFORM billing.bill_account(v_cdr.vendor_acc_id, +v_cdr.vendor_price::numeric);
        PERFORM billing.bill_account(v_cdr.customer_acc_id, -v_cdr.customer_price::numeric);
        delete from class4.cdrs where id=i_cdr_id;
END;
$$;


SET search_path = class4, pg_catalog;

--
-- TOC entry 616 (class 1255 OID 17186)
-- Name: cdrs_i_tgf(); Type: FUNCTION; Schema: class4; Owner: -
--

CREATE FUNCTION cdrs_i_tgf() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
BEGIN  IF ( NEW.time_start >= DATE '2013-01-01' AND NEW.time_start < DATE '2013-02-01' ) THEN INSERT INTO class4.cdrs_201301 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2013-02-01' AND NEW.time_start < DATE '2013-03-01' ) THEN INSERT INTO class4.cdrs_201302 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2013-03-01' AND NEW.time_start < DATE '2013-04-01' ) THEN INSERT INTO class4.cdrs_201303 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2013-06-01' AND NEW.time_start < DATE '2013-07-01' ) THEN INSERT INTO class4.cdrs_201306 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2013-07-01' AND NEW.time_start < DATE '2013-08-01' ) THEN INSERT INTO class4.cdrs_201307 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2013-08-01' AND NEW.time_start < DATE '2013-09-01' ) THEN INSERT INTO class4.cdrs_201308 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2013-09-01' AND NEW.time_start < DATE '2013-10-01' ) THEN INSERT INTO class4.cdrs_201309 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2013-10-01' AND NEW.time_start < DATE '2013-11-01' ) THEN INSERT INTO class4.cdrs_201310 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2013-11-01' AND NEW.time_start < DATE '2013-12-01' ) THEN INSERT INTO class4.cdrs_201311 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2013-12-01' AND NEW.time_start < DATE '2014-01-01' ) THEN INSERT INTO class4.cdrs_201312 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2014-01-01' AND NEW.time_start < DATE '2014-02-01' ) THEN INSERT INTO class4.cdrs_201401 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2014-02-01' AND NEW.time_start < DATE '2014-03-01' ) THEN INSERT INTO class4.cdrs_201402 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2014-03-01' AND NEW.time_start < DATE '2014-04-01' ) THEN INSERT INTO class4.cdrs_201403 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2014-04-01' AND NEW.time_start < DATE '2014-05-01' ) THEN INSERT INTO class4.cdrs_201404 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2014-05-01' AND NEW.time_start < DATE '2014-06-01' ) THEN INSERT INTO class4.cdrs_201405 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2014-06-01' AND NEW.time_start < DATE '2014-07-01' ) THEN INSERT INTO class4.cdrs_201406 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2014-07-01' AND NEW.time_start < DATE '2014-08-01' ) THEN INSERT INTO class4.cdrs_201407 VALUES (NEW.*);
ELSIF ( NEW.time_start >= DATE '2014-08-01' AND NEW.time_start < DATE '2014-09-01' ) THEN INSERT INTO class4.cdrs_201408 VALUES (NEW.*);
 ELSE 
 RAISE EXCEPTION 'class4.cdrs_i_tg: time_start out of range.'; 
 END IF;  
RETURN NULL; 
END; $$;


SET search_path = data_import, pg_catalog;

--
-- TOC entry 617 (class 1255 OID 17187)
-- Name: accounts_handler(character varying[]); Type: FUNCTION; Schema: data_import; Owner: -
--

CREATE FUNCTION accounts_handler(i_uf character varying[]) RETURNS void
    LANGUAGE plpgsql COST 6000
    AS $$
DECLARE
BEGIN
    UPDATE data_import.import_accounts as ta 
        SET contractor_id=tb.id
    from public.contractors tb 
    WHERE ta.contractor_name=tb.name;
    
    PERFORM data_import.resolve_object_id('billing.accounts','data_import.import_accounts',i_uf);
END;
$$;


--
-- TOC entry 618 (class 1255 OID 17188)
-- Name: contractors_handler(character varying[]); Type: FUNCTION; Schema: data_import; Owner: -
--

CREATE FUNCTION contractors_handler(i_uf character varying[]) RETURNS void
    LANGUAGE plpgsql COST 6000
    AS $$
DECLARE
BEGIN
    PERFORM data_import.resolve_object_id('public.contractors','data_import.import_contractors',i_uf);
END;
$$;


--
-- TOC entry 619 (class 1255 OID 17189)
-- Name: customers_auth_handler(character varying[]); Type: FUNCTION; Schema: data_import; Owner: -
--

CREATE FUNCTION customers_auth_handler(i_uf character varying[]) RETURNS void
    LANGUAGE plpgsql COST 6000
    AS $$
DECLARE
BEGIN
UPDATE data_import.import_customers_auth as ta 
    SET routing_group_id=tb.id
    from class4.routing_groups tb 
    WHERE ta.routing_group_name=tb.name;

UPDATE data_import.import_customers_auth as ta 
    SET rateplan_id=tb.id
    from class4.rateplans tb 
    WHERE ta.rateplan_name=tb.name;

UPDATE data_import.import_customers_auth as ta 
    SET gateway_id=tb.id
    from class4.gateways tb 
    WHERE ta.gateway_name=tb.name;
    
UPDATE data_import.import_customers_auth as ta 
    SET account_id=tb.id,
        customer_id=tb.contractor_id
    from billing.accounts tb 
    WHERE ta.account_name=tb.name;

UPDATE data_import.import_customers_auth as ta 
    SET dump_level_id=tb.id
    from class4.dump_level tb 
    WHERE ta.dump_level_name=tb.name;

UPDATE data_import.import_customers_auth as ta 
    SET pop_id=tb.id
    from sys.pops tb 
    WHERE ta.pop_name=tb.name;

UPDATE data_import.import_customers_auth as ta 
    SET diversion_policy_id=tb.id
    from class4.diversion_policy tb 
    WHERE ta.diversion_policy_name=tb.name;
    

UPDATE data_import.import_customers_auth SET src_prefix='' WHERE src_prefix IS NULL;
UPDATE data_import.import_customers_auth SET dst_prefix='' WHERE dst_prefix IS NULL;

PERFORM data_import.resolve_object_id('customers_auth',i_uf);

END;
$$;


--
-- TOC entry 610 (class 1255 OID 17190)
-- Name: destinations_handler(character varying[]); Type: FUNCTION; Schema: data_import; Owner: -
--

CREATE FUNCTION destinations_handler(i_uf character varying[]) RETURNS void
    LANGUAGE plpgsql COST 6000
    AS $$
DECLARE
BEGIN
UPDATE data_import.import_destinations as ta 
    SET rateplan_id=tb.id
    from class4.rateplans tb 
    WHERE ta.rateplan_name=tb.name;

UPDATE data_import.import_destinations as ta 
    SET rate_policy_id=tb.id
    from class4.destination_rate_policy tb 
    WHERE ta.rate_policy_name=tb.name;

PERFORM data_import.resolve_object_id('destinations',i_uf);
END;
$$;


--
-- TOC entry 611 (class 1255 OID 17191)
-- Name: dialpeers_handler(character varying[]); Type: FUNCTION; Schema: data_import; Owner: -
--

CREATE FUNCTION dialpeers_handler(i_uf character varying[]) RETURNS void
    LANGUAGE plpgsql COST 6000
    AS $$
DECLARE
BEGIN

UPDATE data_import.import_dialpeers as ta 
    SET routing_group_id=tb.id
    from class4.routing_groups tb 
    WHERE ta.routing_group_name=tb.name;

UPDATE data_import.import_dialpeers as ta 
    SET gateway_id=tb.id
    from class4.gateways tb 
    WHERE ta.gateway_name=tb.name;

UPDATE data_import.import_dialpeers as ta 
    SET account_id=tb.id,
        vendor_id=tb.contractor_id
    from billing.accounts tb 
    WHERE ta.account_name=tb.name;

UPDATE data_import.import_dialpeers SET asr_limit=0 WHERE asr_limit IS NULL;
--UPDATE data_import.import_dialpeers SET acd_prefix='' WHERE dst_prefix IS NULL;

PERFORM data_import.resolve_object_id('dialpeers',i_uf);

END;
$$;


--
-- TOC entry 620 (class 1255 OID 17192)
-- Name: disconnect_policies_handler(character varying[]); Type: FUNCTION; Schema: data_import; Owner: -
--

CREATE FUNCTION disconnect_policies_handler(i_uf character varying[]) RETURNS void
    LANGUAGE plpgsql COST 6000
    AS $$
DECLARE
BEGIN
    PERFORM data_import.resolve_object_id('class4.disconnect_policy','data_import.import_disconnect_policies',i_uf);
END;
$$;


--
-- TOC entry 621 (class 1255 OID 17193)
-- Name: gateway_groups_handler(character varying[]); Type: FUNCTION; Schema: data_import; Owner: -
--

CREATE FUNCTION gateway_groups_handler(i_uf character varying[]) RETURNS void
    LANGUAGE plpgsql COST 6000
    AS $$
DECLARE
BEGIN
    UPDATE data_import.import_gateway_groups as ta 
        SET vendor_id=tb.id
    from public.contractors tb 
    WHERE ta.vendor_name=tb.name;
    
    PERFORM data_import.resolve_object_id('class4.gateway_groups','data_import.import_gateway_groups',i_uf);
END;
$$;


--
-- TOC entry 622 (class 1255 OID 17194)
-- Name: gateways_handler(character varying[]); Type: FUNCTION; Schema: data_import; Owner: -
--

CREATE FUNCTION gateways_handler(i_uf character varying[]) RETURNS void
    LANGUAGE plpgsql COST 6000
    AS $$
DECLARE

BEGIN

    UPDATE data_import.import_gateways as ta 
        SET contractor_id=tb.id
    from public.contractors tb 
    WHERE ta.contractor_name=tb.name;

    UPDATE data_import.import_gateways as ta 
        SET session_refresh_method_id=tb.id
    from class4.session_refresh_methods tb 
    WHERE ta.session_refresh_method_name=tb.name;

    UPDATE data_import.import_gateways as ta 
        SET pop_id=tb.id
    from sys.pops tb 
    WHERE ta.pop_name=tb.name;

    UPDATE data_import.import_gateways as ta 
        SET gateway_group_id=tb.id
    from class4.gateway_groups tb 
    WHERE ta.gateway_group_name=tb.name;


    PERFORM data_import.resolve_object_id('class4.gateways','data_import.import_gateways',i_uf);

END;
$$;


--
-- TOC entry 623 (class 1255 OID 17195)
-- Name: rateplans_handler(character varying[]); Type: FUNCTION; Schema: data_import; Owner: -
--

CREATE FUNCTION rateplans_handler(i_uf character varying[]) RETURNS void
    LANGUAGE plpgsql COST 6000
    AS $$
DECLARE
BEGIN
PERFORM data_import.resolve_object_id('rateplans',i_uf);
END;
$$;


--
-- TOC entry 624 (class 1255 OID 17196)
-- Name: registrations_handler(character varying[]); Type: FUNCTION; Schema: data_import; Owner: -
--

CREATE FUNCTION registrations_handler(i_uf character varying[]) RETURNS void
    LANGUAGE plpgsql COST 6000
    AS $$
DECLARE
BEGIN

UPDATE data_import.import_registrations as ta 
    SET pop_id=tb.id
    from sys.pops tb 
    WHERE ta.pop_name=tb.name;

UPDATE data_import.import_registrations as ta 
    SET node_id=tb.id
    from sys.nodes tb 
    WHERE ta.node_name=tb.name;

PERFORM data_import.resolve_object_id('class4.registrations','data_import.import_registrations',i_uf);

END;
$$;


--
-- TOC entry 625 (class 1255 OID 17197)
-- Name: resolve_object_id(character varying, character varying[]); Type: FUNCTION; Schema: data_import; Owner: -
--

CREATE FUNCTION resolve_object_id(i_table_name character varying, i_unique_fields character varying[]) RETURNS void
    LANGUAGE plpgsql COST 6000
    AS $$
DECLARE
v_uf VARCHAR;
v_sql VARCHAR;
v_sql_where VARCHAR := '';
BEGIN
    --check for existence if object id  was set
    v_sql:='UPDATE data_import.import_'||i_table_name||' ta SET o_id = NULL WHERE o_id IS NOT NULL AND o_id NOT IN (SELECT id FROM class4.'||i_table_name||')';
    RAISE NOTICE 'sql = "%"',v_sql;
    EXECUTE v_sql;

    IF array_length(i_unique_fields,1)=0 THEN
        RAISE WARNING 'got empty unique fields array. so return';
        RETURN;
    END IF;
    
    --resolve object id  using given unique fields list
    FOR v_uf IN SELECT * FROM unnest(i_unique_fields)
    LOOP
        v_uf:=trim(both '''' from v_uf);
        IF v_uf = '' THEN
            RAISE WARNING 'empty unique field name. skip it';
            CONTINUE;
        END IF;
        v_sql_where:=v_sql_where||'ta.'||v_uf||'=tb.'||v_uf||' AND ';
    END LOOP;
    v_sql_where:=left(v_sql_where,-5);

    v_sql:= 'UPDATE data_import.import_'||i_table_name||' ta SET o_id = tb.id FROM class4.'||i_table_name||' tb WHERE '||v_sql_where;
    RAISE NOTICE 'sql = "%"',v_sql;
    EXECUTE v_sql;
END;
$$;


--
-- TOC entry 626 (class 1255 OID 17198)
-- Name: resolve_object_id(character varying, character varying, character varying[]); Type: FUNCTION; Schema: data_import; Owner: -
--

CREATE FUNCTION resolve_object_id(i_from_table character varying, i_to_table character varying, i_unique_fields character varying[]) RETURNS void
    LANGUAGE plpgsql COST 6000
    AS $$
DECLARE
v_uf VARCHAR;
v_sql VARCHAR;
v_sql_where VARCHAR := '';
BEGIN
    --check for existence if object id  was set
    v_sql:='UPDATE '||i_to_table||' ta SET o_id = NULL WHERE o_id IS NOT NULL AND o_id NOT IN (SELECT id FROM '||i_from_table||')';
    RAISE NOTICE 'sql = "%"',v_sql;
    EXECUTE v_sql;

    IF array_length(i_unique_fields,1)=0 THEN
        RAISE WARNING 'got empty unique fields array. so return';
        RETURN;
    END IF;
    
    --resolve object id  using given unique fields list
    FOR v_uf IN SELECT * FROM unnest(i_unique_fields)
    LOOP
        v_uf:=trim(both '''' from v_uf);
        IF v_uf = '' THEN
            RAISE WARNING 'empty unique field name. skip it';
            CONTINUE;
        END IF;
        v_sql_where:=v_sql_where||'ta.'||v_uf||'=tb.'||v_uf||' AND ';
    END LOOP;
    v_sql_where:=left(v_sql_where,-5);

    v_sql:= 'UPDATE '||i_to_table||' ta SET o_id = tb.id FROM '||i_from_table||' tb WHERE '||v_sql_where;
    RAISE NOTICE 'sql = "%"',v_sql;
    EXECUTE v_sql;
END;
$$;


--
-- TOC entry 627 (class 1255 OID 17199)
-- Name: routing_groups_handler(character varying[]); Type: FUNCTION; Schema: data_import; Owner: -
--

CREATE FUNCTION routing_groups_handler(i_uf character varying[]) RETURNS void
    LANGUAGE plpgsql COST 6000
    AS $$
DECLARE
BEGIN
    UPDATE data_import.import_routing_groups as ta 
    SET sorting_id=tb.id
    from class4.sortings tb
    WHERE ta.sorting_name=tb.name;

    PERFORM data_import.resolve_object_id('class4.routing_groups','data_import.import_routing_groups',i_uf);
END;
$$;


SET search_path = public, pg_catalog;

--
-- TOC entry 628 (class 1255 OID 17200)
-- Name: rewrite_dst(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rewrite_dst(i_dst character varying) RETURNS character varying
    LANGUAGE sql
    AS $_$
        SELECT CASE
                WHEN $1 like 'sip:SKYPE%'
                        THEN regexp_replace($1,'^sip:SKYPE(.*)@(.*)',E'Skype: \\1','i')
                WHEN $1 like 'sip:GTALK%'
                        THEN regexp_replace($1,'^sip:GTALK(.*)@(.*)',E'Gtalk: \\1','i')
                WHEN $1 like 'sip:IAX%'
                        THEN 'IAX'::varchar
                WHEN $1 like 'sip:H323%'
                        THEN 'H323'
                WHEN $1 like 'tel:%'
                        THEN regexp_replace($1,'^tel:(.*)',E'PSTN: \\1','i')
                WHEN $1 like '%@sip.didreseller.com'
                        THEN 'ACF'
                ELSE    $1
                END;
$_$;


--
-- TOC entry 629 (class 1255 OID 17201)
-- Name: rtest(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rtest() RETURNS SETOF integer
    LANGUAGE plpgsql
    AS $$
declare
i INTEGER;
begin
for i in select * from generate_series(1,10)
loop
return next i;
end loop;
return;
end
$$;


SET search_path = reports, pg_catalog;

--
-- TOC entry 630 (class 1255 OID 17202)
-- Name: cdr_custom_report(timestamp without time zone, timestamp without time zone, character varying, character varying); Type: FUNCTION; Schema: reports; Owner: -
--

CREATE FUNCTION cdr_custom_report(i_date_start timestamp without time zone, i_date_end timestamp without time zone, i_group_by character varying, i_filter character varying) RETURNS integer
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    v_rid integer;
    v_sql varchar;
    v_keys varchar:='';
    v_i integer:=0;
    v_field varchar;
    v_filter varchar;
BEGIN
    INSERT INTO reports.cdr_custom_report(created_at,date_start,date_end,filter,group_by)
        values(now(),i_date_start,i_date_end,i_filter,i_group_by) RETURNING id INTO v_rid;

    For v_field in select * from regexp_split_to_table(i_group_by,',') LOOP
        v_i:=v_i+1;
        --IF regexp_match(v_field','w');
        v_keys:=v_keys||'key'||v_i::varchar||',';
    end loop;
    
    v_filter=COALESCE('AND '||NULLIF(i_filter,''),'');
    
    v_sql:='
        INSERT INTO cdr_custom_report_data(report_id,'||i_group_by||',agg_calls_count,agg_calls_duration,agg_customer_price,agg_vendor_price,agg_profit,agg_asr_origination,agg_asr_termination) 
            SELECT '||v_rid::varchar||','||i_group_by::varchar||',count(id),sum(duration),sum(customer_price),sum(vendor_price),sum(profit),1,1
            from class4.cdrs
            WHERE 
                time_start>='''||i_date_start::varchar||'''
                AND time_start<'''||i_date_end::varchar||''' '||v_filter||'
            GROUP BY '||i_group_by;
    RAISE WARNING 'SQL: %',v_sql;
    EXECUTE v_sql;
    RETURN v_rid;

END;
$$;


--
-- TOC entry 631 (class 1255 OID 17203)
-- Name: cdr_custom_report_remove(integer); Type: FUNCTION; Schema: reports; Owner: -
--

CREATE FUNCTION cdr_custom_report_remove(i_report_id integer) RETURNS void
    LANGUAGE plpgsql COST 3000
    AS $$
DECLARE

BEGIN
    delete from reports.cdr_custom_report_data where report_id=i_report_id;
    delete from reports.cdr_custom_report where id=i_report_id;
END;
$$;


--
-- TOC entry 632 (class 1255 OID 17204)
-- Name: cdr_interval_report(timestamp without time zone, timestamp without time zone, integer, integer, character varying, character varying, character varying); Type: FUNCTION; Schema: reports; Owner: -
--

CREATE FUNCTION cdr_interval_report(i_date_start timestamp without time zone, i_date_end timestamp without time zone, i_interval_length integer, i_agg_id integer, i_agg_by character varying, i_filter character varying, i_group_by character varying) RETURNS integer
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
BEGIN
    INSERT INTO reports.cdr_interval_report(created_at,date_start,date_end,
    filter,group_by,interval_length,aggregator_id,aggregate_by)
        values(now(),i_date_start,i_date_end,i_filter,i_group_by,i_interval_length,i_agg_id,i_agg_by) RETURNING id INTO v_rid;

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
            from class4.cdrs
            WHERE 
                time_start>='''||i_date_start::varchar||'''
                AND time_start<'''||i_date_end::varchar||''' '||v_filter||'
            GROUP BY '||v_tsp||v_group_by;
            
    RAISE WARNING 'SQL: %',v_sql;
    EXECUTE v_sql;
    RETURN v_rid;

END;
$$;


--
-- TOC entry 633 (class 1255 OID 17205)
-- Name: cdr_interval_report_remove(integer); Type: FUNCTION; Schema: reports; Owner: -
--

CREATE FUNCTION cdr_interval_report_remove(i_report_id integer) RETURNS void
    LANGUAGE plpgsql COST 3000
    AS $$
DECLARE

BEGIN
    delete from reports.cdr_interval_report_data where report_id=i_report_id;
    delete from reports.cdr_interval_report where id=i_report_id;
END;
$$;


SET search_path = runtime_stats, pg_catalog;

--
-- TOC entry 650 (class 1255 OID 18718)
-- Name: update_dp(billing.cdr_v1); Type: FUNCTION; Schema: runtime_stats; Owner: -
--

CREATE FUNCTION update_dp(i_cdr billing.cdr_v1) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$

DECLARE
i integer;
v_id bigint;
v_success integer;
v_duration integer;
BEGIN
        v_success=i_cdr.success::integer;
        IF i_cdr.success THEN
                v_duration=i_cdr.duration;
        ELSE
                v_duration=0;
        END IF;
        UPDATE runtime_stats.dialpeers_stats SET
                calls=calls+1,calls_success=calls_success+v_success,calls_fail=calls_fail+(1-v_success),
                total_duration=total_duration+v_duration,
                acd=(total_duration+i_cdr.duration)::real/(calls+1)::real,
                asr=(calls_success+v_success)::real/(calls+1)::real
        WHERE dialpeer_id=i_cdr.dialpeer_id;
        IF NOT FOUND THEN
                -- we can get lost update in this case if row deleted in concurrent transaction. but this is minor issue;
                BEGIN
                        INSERT into runtime_stats.dialpeers_stats(dialpeer_id,calls,calls_success,calls_fail,total_duration,acd,asr) 
                        VALUES(i_cdr.dialpeer_id,1,v_success,1-v_success,v_duration,v_duration::real/1,v_success::real/1);
                EXCEPTION
                        WHEN OTHERS THEN
                                UPDATE runtime_stats.dialpeers_stats SET
                                calls=calls+1,calls_success=calls_success+v_success,calls_fail=calls_fail+(1-v_success),
                                total_duration=total_duration+v_duration,
                                acd=(total_duration+i_cdr.duration)::real/(calls+1)::real,
                                asr=(calls_success+v_success)::real/(calls+1)::real
                                WHERE dialpeer_id=i_cdr.dialpeer_id;
                END;
        END IF;
END;
$$;


--
-- TOC entry 652 (class 1255 OID 18719)
-- Name: update_gw(billing.cdr_v1); Type: FUNCTION; Schema: runtime_stats; Owner: -
--

CREATE FUNCTION update_gw(i_cdr billing.cdr_v1) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$

DECLARE
i integer;
v_id bigint;
v_success integer;
v_duration integer;
BEGIN
        v_success=i_cdr.success::integer;
        IF i_cdr.success THEN
                v_duration=i_cdr.duration;
        ELSE
                v_duration=0;
        END IF;
        UPDATE runtime_stats.gateways_stats SET
                calls=calls+1,calls_success=calls_success+v_success,calls_fail=calls_fail+(1-v_success),
                total_duration=total_duration+v_duration,
                acd=(total_duration+i_cdr.duration)::real/(calls+1)::real,
                asr=(calls_success+v_success)::real/(calls+1)::real
        WHERE gateway_id=i_cdr.term_gw_id;
        IF NOT FOUND THEN
                -- we can get lost update in this case if row deleted in concurrent transaction. but this is minor issue;
                BEGIN
                        INSERT into runtime_stats.gateways_stats(gateway_id,calls,calls_success,calls_fail,total_duration,acd,asr) 
                        VALUES(i_cdr.term_gw_id,1,v_success,1-v_success,v_duration,v_duration::real/1,v_success::real/1);
                EXCEPTION
                        WHEN OTHERS THEN
                                UPDATE runtime_stats.gateways_stats SET
                                calls=calls+1,calls_success=calls_success+v_success,calls_fail=calls_fail+(1-v_success),
                                total_duration=total_duration+v_duration,
                                acd=(total_duration+i_cdr.duration)::real/(calls+1)::real,
                                asr=(calls_success+v_success)::real/(calls+1)::real
                                WHERE gateway_id=i_cdr.term_gw_id;
                END;
        END IF;

END;
$$;


SET search_path = switch1, pg_catalog;

--
-- TOC entry 653 (class 1255 OID 18903)
-- Name: check_event(integer); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION check_event(i_event_id integer) RETURNS boolean
    LANGUAGE plpgsql COST 10
    AS $$
BEGIN
    PERFORM id from sys.events where id=i_event_id;
    return FOUND;
END;
$$;


--
-- TOC entry 671 (class 1255 OID 18904)
-- Name: debugprofile_f(inet, integer, character varying, character varying, integer, character varying); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION debugprofile_f(i_remote_ip inet, i_remote_port integer, i_src_prefix character varying, i_dst_prefix character varying, i_pop_id integer, i_uri_domain character varying) RETURNS SETOF callprofile34_ty
    LANGUAGE plpgsql SECURITY DEFINER ROWS 10
    AS $$
DECLARE
v_r record;
v_start  timestamp;
v_end timestamp;
BEGIN
    v_start:=now();
    v_end:=clock_timestamp(); /*DBG*/
    RAISE NOTICE '% ms -> DBG. Start',EXTRACT(MILLISECOND from v_end-v_start); /*DBG*/
    
    FOR v_r IN (SELECT * from route_debug(
        1,              --i_node_id
        i_pop_id,              --i_pop_id
        i_remote_ip::inet,
        i_remote_port::int,
        '127.0.0.1'::inet,    --i_local_ip
        '5060'::int,         --i_local_port
        'from_name'::varchar,
        i_src_prefix::varchar,   --i_from_name
        '127.0.0.1'::varchar,    --i_from_domain
        '5060'::int,         --i_from_port
        i_dst_prefix::varchar,   --i_to_name
        '127.0.0.1'::varchar,    --i_to_domain
        '5060'::int,         --i_to_port
        i_src_prefix::varchar,   --i_contact_name
        i_remote_ip::varchar,    --i_contact_domain
        i_remote_port::int,  --i_contact_port
        i_dst_prefix::varchar,   --i_user,
        i_uri_domain::varchar,   -- URI domain
        ''::varchar,            --i_headers,
        NULL, --diversion
        NULL, --X-ORIG-IP
        NULL --X-ORIG-PORT
        )) LOOP
            v_end:=clock_timestamp(); /*DBG*/
            RAISE NOTICE '% ms -> DBG. ROUTING RESULT: %',EXTRACT(MILLISECOND from v_end-v_start),hstore(v_r); /*DBG*/
        end loop;
END;
$$;


--
-- TOC entry 654 (class 1255 OID 18911)
-- Name: load_codecs(); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION load_codecs() RETURNS TABLE(o_id integer, o_codec_group_id integer, o_codec_name character varying, o_priority integer, o_dynamic_payload_id integer, o_format_params character varying)
    LANGUAGE plpgsql COST 10
    AS $$
BEGIN    
    RETURN 
    QUERY SELECT 
        cgc.id, 
        cgc.codec_group_id, 
        c.name ,
        cgc.priority,
        NULL::INTEGER,
        NULL::VARCHAR
    from class4.codec_group_codecs cgc
        JOIN class4.codecs c ON c.id=cgc.codec_id
    order by cgc.codec_group_id,cgc.priority desc ,c.name;
END;
$$;


SET search_path = class4, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 180 (class 1259 OID 17217)
-- Name: disconnect_code_namespace; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE disconnect_code_namespace (
    id integer NOT NULL,
    name character varying NOT NULL
);


SET search_path = switch1, pg_catalog;

--
-- TOC entry 655 (class 1255 OID 18912)
-- Name: load_disconnect_code_namespace(); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION load_disconnect_code_namespace() RETURNS SETOF class4.disconnect_code_namespace
    LANGUAGE plpgsql COST 10
    AS $$

BEGIN    
    RETURN QUERY SELECT * from class4.disconnect_code_namespace order by id;
END;
$$;


--
-- TOC entry 656 (class 1255 OID 18913)
-- Name: load_disconnect_code_refuse(); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION load_disconnect_code_refuse() RETURNS TABLE(o_id integer, o_code integer, o_reason character varying, o_rewrited_code integer, o_rewrited_reason character varying, o_store_cdr boolean, o_silently_drop boolean)
    LANGUAGE plpgsql COST 10
    AS $$
BEGIN    
    RETURN 
    QUERY SELECT id,code,reason,rewrited_code,rewrited_reason,store_cdr,silently_drop
    from class4.disconnect_code
    where namespace_id=0 or namespace_id=1
    order by id;
END;
$$;


--
-- TOC entry 657 (class 1255 OID 18914)
-- Name: load_disconnect_code_rerouting(); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION load_disconnect_code_rerouting() RETURNS TABLE(received_code integer, stop_rerouting boolean)
    LANGUAGE plpgsql COST 10
    AS $$

BEGIN    
    RETURN QUERY SELECT code,stop_hunting 
    from class4.disconnect_code
    WHERE namespace_id=2
    order by id;
END;
$$;


--
-- TOC entry 651 (class 1255 OID 18915)
-- Name: load_disconnect_code_rerouting_overrides(); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION load_disconnect_code_rerouting_overrides() RETURNS TABLE(policy_id integer, received_code integer, stop_rerouting boolean)
    LANGUAGE plpgsql COST 10
    AS $$

BEGIN    
    RETURN QUERY SELECT dpc.policy_id,dc.code,dpc.stop_hunting 
    from class4.disconnect_policy_code dpc
    join class4.disconnect_code dc
        ON dpc.code_id=dc.id          
    WHERE dc.namespace_id=2 -- SIP ONLY
    order by dpc.id;
END;
$$;


--
-- TOC entry 658 (class 1255 OID 18916)
-- Name: load_disconnect_code_rewrite(); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION load_disconnect_code_rewrite() RETURNS TABLE(o_code integer, o_reason character varying, o_pass_reason_to_originator boolean, o_rewrited_code integer, o_rewrited_reason character varying)
    LANGUAGE plpgsql COST 10
    AS $$
BEGIN    
    RETURN 
    QUERY SELECT code,reason,pass_reason_to_originator,rewrited_code,rewrited_reason 
    from class4.disconnect_code
    where namespace_id=2
    order by id;
END;
$$;


--
-- TOC entry 659 (class 1255 OID 18917)
-- Name: load_disconnect_code_rewrite_override(); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION load_disconnect_code_rewrite_override() RETURNS TABLE(o_policy_id integer, o_code integer, o_reason character varying, o_pass_reason_to_originator boolean, o_rewrited_code integer, o_rewrited_reason character varying)
    LANGUAGE plpgsql COST 10
    AS $$
BEGIN    
    RETURN 
    QUERY SELECT dpc.policy_id,dc.code,dc.reason,dpc.pass_reason_to_originator,dpc.rewrited_code,dpc.rewrited_reason 
    from class4.disconnect_policy_code dpc 
    JOIN class4.disconnect_code dc
        ON dc.id=dpc.code_id
    where dc.namespace_id=2 -- ONLY SIP
    order by dpc.id;
END;
$$;


--
-- TOC entry 660 (class 1255 OID 18918)
-- Name: load_disconnect_code_rewrite_overrides(); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION load_disconnect_code_rewrite_overrides() RETURNS TABLE(o_policy_id integer, o_code integer, o_reason character varying, o_pass_reason_to_originator boolean, o_rewrited_code integer, o_rewrited_reason character varying)
    LANGUAGE plpgsql COST 10
    AS $$
BEGIN    
    RETURN 
    QUERY SELECT dpc.policy_id,dc.code,dc.reason,dpc.pass_reason_to_originator,dpc.rewrited_code,dpc.rewrited_reason 
    from class4.disconnect_policy_code dpc 
    JOIN class4.disconnect_code dc
        ON dc.id=dpc.code_id
    where dc.namespace_id=2 -- ONLY SIP
    order by dpc.id;
END;
$$;


--
-- TOC entry 661 (class 1255 OID 18919)
-- Name: load_interface_in(); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION load_interface_in() RETURNS TABLE(varname character varying, vartype character varying, varformat character varying, varhashkey boolean)
    LANGUAGE plpgsql COST 10
    AS $$
BEGIN
    RETURN QUERY SELECT "name","type","format","hashkey" from switch_interface_in order by rank asc;
END;
$$;


--
-- TOC entry 662 (class 1255 OID 18920)
-- Name: load_interface_out(); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION load_interface_out() RETURNS TABLE(varname character varying, vartype character varying, forcdr boolean)
    LANGUAGE plpgsql COST 10
    AS $$
BEGIN
    RETURN QUERY SELECT "name","type","custom" from switch_interface_out order by rank asc;
END;
$$;


--
-- TOC entry 663 (class 1255 OID 18921)
-- Name: load_registrations_out(integer, integer); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION load_registrations_out(i_pop_id integer, i_node_id integer) RETURNS TABLE(o_id integer, o_domain character varying, o_user character varying, o_display_name character varying, o_auth_user character varying, o_auth_password character varying, o_proxy character varying, o_contact character varying, o_expire integer, o_force_expire boolean)
    LANGUAGE plpgsql COST 10 ROWS 100
    AS $$
BEGIN
RETURN QUERY
    SELECT
        id,"domain","username","display_username",auth_user,auth_password,proxy,contact,expire,force_expire
    FROM class4.registrations r
    WHERE
        r.enabled and
        (r.pop_id=i_pop_id OR r.pop_id is null) AND
        (r.node_id=i_node_id OR r.node_id IS NULL);
end;
$$;


--
-- TOC entry 301 (class 1259 OID 18922)
-- Name: resource_type; Type: TABLE; Schema: switch1; Owner: -; Tablespace: 
--

CREATE TABLE resource_type (
    id integer NOT NULL,
    name character varying NOT NULL,
    reject_code integer,
    reject_reason character varying,
    action_id integer DEFAULT 1 NOT NULL
);


--
-- TOC entry 664 (class 1255 OID 18929)
-- Name: load_resource_types(); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION load_resource_types() RETURNS SETOF resource_type
    LANGUAGE plpgsql COST 10 ROWS 10
    AS $$

BEGIN    
    RETURN QUERY SELECT * from resource_type;
END;
$$;


--
-- TOC entry 665 (class 1255 OID 18930)
-- Name: load_trusted_headers(integer); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION load_trusted_headers(i_node_id integer) RETURNS TABLE(o_name character varying)
    LANGUAGE plpgsql COST 10 ROWS 100
    AS $$
BEGIN
    RETURN QUERY    SELECT "name" from trusted_headers order by rank asc;
end;
$$;


--
-- TOC entry 674 (class 1255 OID 19020)
-- Name: new_profile(); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION new_profile() RETURNS callprofile35_ty
    LANGUAGE plpgsql COST 10
    AS $_$
DECLARE
    v_ret switch1.callprofile35_ty;
BEGIN    
    --v_ret.anonymize_sdp:=false;
    v_ret.append_headers:='User-Agent: SBC \r\nMax-Forwars: 70\r\n';
    v_ret.enable_auth:=false;
    v_ret.auth_user:='';
    v_ret.auth_pwd:='';
    v_ret.enable_aleg_auth:=false;
    v_ret.auth_aleg_user:='';
    v_ret.auth_aleg_pwd:='';
    v_ret.call_id:='$ci_leg43';
--    v_ret.contact:='<sip:$Ri>';
    v_ret."from":='$f';
    v_ret."to":='$t';
    v_ret.ruri:='$r';
    v_ret.ruri_host:='';
    v_ret.force_outbound_proxy:=false;
    v_ret.outbound_proxy:='';
    v_ret.next_hop:='';
--    v_ret.next_hop_for_replies:='';
    v_ret.next_hop_1st_req:=false;
    v_ret.anonymize_sdp:=TRUE;
    v_ret.header_filter_type_id:=0; -- transparent
    v_ret.header_filter_list:='';
    v_ret.message_filter_type_id:=0; -- transparent
    v_ret.message_filter_list:='';
    
    v_ret.sdp_filter_type_id:=0; -- transparent
    v_ret.sdp_filter_list:='';
    v_ret.sdp_alines_filter_type_id:=0; -- transparent
    v_ret.sdp_alines_filter_list:='';
    
    v_ret.enable_session_timer:=false;
    v_ret.session_expires ='150';
    v_ret.minimum_timer:='30';
    v_ret.minimum_timer:='60';
    v_ret.session_refresh_method_id:=1;
    v_ret.accept_501_reply:=true;
    v_ret.enable_aleg_session_timer=false;
    v_ret.aleg_session_expires:='180';
    v_ret.aleg_minimum_timer:='30';
    v_ret.aleg_maximum_timer:='60';
    v_ret.aleg_session_refresh_method_id:=1;
    v_ret.aleg_accept_501_reply:='';
    v_ret.reply_translations:='';

    v_ret.enable_rtprelay:=false;
    v_ret.rtprelay_msgflags_symmetric_rtp:=false;
    
    
    v_ret.rtprelay_interface:='';
    v_ret.aleg_rtprelay_interface:='';
    v_ret.rtprelay_transparent_seqno:=false;
    v_ret.rtprelay_transparent_ssrc:=false;
    v_ret.outbound_interface:='';
    v_ret.dtmf_transcoding:='';
    v_ret.lowfi_codecs:='';
    v_ret.customer_id:=0;
    v_ret.vendor_id:=0;
    v_ret.customer_acc_id:=0;
    v_ret.vendor_acc_id:=0;
    v_ret.customer_auth_id:=0;
    v_ret.destination_id:=0;
    v_ret.dialpeer_id:=0;
    v_ret.orig_gw_id:=0;
    v_ret.term_gw_id:=0;
    v_ret.routing_group_id:=0;
    v_ret.rateplan_id:=0;
    v_ret.destination_next_rate:=0;
    v_ret.destination_initial_rate:=0;
    v_ret.destination_fee:=0;
    v_ret.destination_initial_interval:=60;
    v_ret.destination_next_interval:=60;
    v_ret.destination_rate_policy_id:=1; -- FIXED rate policy
    v_ret.dialpeer_next_rate:=0;
    v_ret.dialpeer_initial_rate:=0;
    v_ret.dialpeer_fee:=0;
    v_ret.dialpeer_initial_interval:=60;
    v_ret.dialpeer_next_interval:=60;
    v_ret.time_limit:=0;
    v_ret.resources:='';
    v_ret.dump_level_id=0;
    v_ret.aleg_policy_id:=0;
    v_ret.bleg_policy_id:=0;

    --newly added fields. got from RS database
    
    v_ret.try_avoid_transcoding:=FALSE;
    
    v_ret.rtprelay_dtmf_filtering:=TRUE;
    v_ret.rtprelay_dtmf_detection:=TRUE;
    v_ret.rtprelay_force_dtmf_relay:=FALSE;
    
    v_ret.patch_ruri_next_hop:=FALSE;
    
    v_ret.aleg_force_symmetric_rtp:=TRUE;
    v_ret.bleg_force_symmetric_rtp:=TRUE;
    
    v_ret.aleg_symmetric_rtp_nonstop:=FALSE;
    v_ret.bleg_symmetric_rtp_nonstop:=FALSE;
    
    v_ret.aleg_symmetric_rtp_ignore_rtcp:=TRUE;
    v_ret.bleg_symmetric_rtp_ignore_rtcp:=TRUE;
    
    v_ret.aleg_rtp_ping:=FALSE;
    v_ret.bleg_rtp_ping:=FALSE;
    
    v_ret.aleg_relay_options:=FALSE;
    v_ret.bleg_relay_options:=FALSE;
    
    v_ret.filter_noaudio_streams:=FALSE;

    /* enum conn_location {
     *   BOTH = 0,
     *   SESSION_ONLY,
     *   MEDIA_ONLY
     * } */
    v_ret.aleg_sdp_c_location_id:=0; --BOTH
    v_ret.bleg_sdp_c_location_id:=0; --BOTH
    
    v_ret.trusted_hdrs_gw:=FALSE;
    
    --v_ret.aleg_append_headers_reply:='';
    v_ret.aleg_append_headers_reply=E'X-VND-INIT-INT:60\r\nX-VND-NEXT-INT:60\r\nX-VND-INIT-RATE:0\r\nX-VND-NEXT-RATE:0\r\nX-VND-CF:0';
    
    v_ret.relay_reinvite:=TRUE;
    
    /*
     *  #define FILTER_TYPE_TRANSPARENT     0
     *  #define FILTER_TYPE_BLACKLIST       1
     *  #define FILTER_TYPE_WHITELIST       2
     */
    v_ret.bleg_sdp_alines_filter_list:='';
    v_ret.bleg_sdp_alines_filter_type_id:=0; --FILTER_TYPE_TRANSPARENT
    
    RETURN v_ret;
END;
$_$;


--
-- TOC entry 666 (class 1255 OID 18932)
-- Name: preprocess(character varying, character varying, boolean); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION preprocess(i_namespace character varying, i_funcname character varying, i_comment boolean) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
v_sql VARCHAR;
v_sql_debug VARCHAR;
v_sql_release VARCHAR;
v_dbg_suffix VARCHAR = '_debug';
v_rel_suffix VARCHAR = '_release';
BEGIN

-- get function oiriginal definition 
SELECT INTO v_sql
    pg_get_functiondef(p.oid)
    FROM pg_proc p 
        JOIN pg_namespace n 
        ON p.pronamespace = n.oid 
    WHERE n.nspname = i_namespace AND p.proname = i_funcname;
    
IF v_sql IS NULL THEN
    RAISE EXCEPTION 'no such fucntion';
END IF;

--change function name for debug
SELECT into v_sql_debug regexp_replace(v_sql,'(CREATE OR REPLACE FUNCTION '||i_namespace||')\.('||i_funcname||')','\1.'||i_funcname||v_dbg_suffix);
--change function name for release
SELECT into v_sql_release regexp_replace(v_sql,'(CREATE OR REPLACE FUNCTION '||i_namespace||')\.('||i_funcname||')','\1.'||i_funcname||v_rel_suffix);

IF i_comment THEN
    --comment debug stuff in release code
    SELECT into v_sql_release regexp_replace(v_sql_release,'(/\*dbg{\*/)(.*?)(/\*}dbg\*/)','\1/*\2*/\3','g');
    --comment release stuff in debug code
    SELECT into v_sql_debug regexp_replace(v_sql_debug,'(/\*rel{\*/)(.*?)(/\*}rel\*/)','\1/*\2*/\3','g');
ELSE
    --remove debug stuff from release code
    SELECT into v_sql_release regexp_replace(v_sql_release,'/\*dbg{\*/.*?/\*}dbg\*/','','g');
    --remove release stuff from debug code
    SELECT into v_sql_debug regexp_replace(v_sql_debug,'/\*rel{\*/.*?/\*}rel\*/','','g');
END IF;

--RAISE NOTICE 'v_sql = "%"', v_sql;
--RAISE NOTICE 'v_sql_debug = "%"', v_sql_debug;
--RAISE NOTICE 'v_sql_release = "%"', v_sql_release;

-- create function debug version
EXECUTE v_sql_debug;
-- create function release version
EXECUTE v_sql_release;

END;
$$;


--
-- TOC entry 672 (class 1255 OID 18933)
-- Name: preprocess_all(); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION preprocess_all() RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
v_sql VARCHAR;
v_sql_debug VARCHAR;
v_sql_release VARCHAR;
v_dbg_suffix VARCHAR = '_debug';
v_rel_suffix VARCHAR = '_release';
BEGIN
    PERFORM preprocess('switch1','route',false);
    PERFORM preprocess('switch1','process_dp',false);
    PERFORM preprocess('switch1','process_gw',false);
END;
$$;


SET search_path = billing, pg_catalog;

--
-- TOC entry 181 (class 1259 OID 17245)
-- Name: accounts; Type: TABLE; Schema: billing; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    id integer NOT NULL,
    contractor_id integer NOT NULL,
    balance numeric NOT NULL,
    min_balance numeric NOT NULL,
    max_balance numeric NOT NULL,
    name character varying NOT NULL,
    origination_capacity integer DEFAULT 0 NOT NULL,
    termination_capacity integer DEFAULT 0 NOT NULL
);


SET search_path = class4, pg_catalog;

--
-- TOC entry 182 (class 1259 OID 17253)
-- Name: destinations; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE destinations (
    id bigint NOT NULL,
    enabled boolean NOT NULL,
    prefix character varying NOT NULL,
    rateplan_id integer NOT NULL,
    next_rate numeric DEFAULT 0.0 NOT NULL,
    connect_fee numeric DEFAULT 0.0,
    initial_interval integer DEFAULT 60 NOT NULL,
    next_interval integer DEFAULT 60 NOT NULL,
    dp_margin_fixed numeric DEFAULT 0 NOT NULL,
    dp_margin_percent numeric DEFAULT 0 NOT NULL,
    rate_policy_id integer DEFAULT 1 NOT NULL,
    initial_rate numeric DEFAULT 0.0 NOT NULL,
    reject_calls boolean DEFAULT false NOT NULL,
    use_dp_intervals boolean DEFAULT false NOT NULL,
    test character varying,
    CONSTRAINT destinations_non_zero_initial_interval CHECK ((initial_interval > 0)),
    CONSTRAINT destinations_non_zero_next_interval CHECK ((next_interval > 0))
);


--
-- TOC entry 183 (class 1259 OID 17271)
-- Name: dialpeers; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE dialpeers (
    id bigint NOT NULL,
    enabled boolean NOT NULL,
    prefix character varying NOT NULL,
    src_rewrite_rule character varying,
    dst_rewrite_rule character varying,
    acd_limit real DEFAULT 0,
    asr_limit real DEFAULT (0)::real NOT NULL,
    gateway_id integer,
    routing_group_id integer NOT NULL,
    next_rate numeric NOT NULL,
    connect_fee numeric NOT NULL,
    vendor_id integer NOT NULL,
    account_id integer NOT NULL,
    src_rewrite_result character varying,
    dst_rewrite_result character varying,
    locked boolean DEFAULT false NOT NULL,
    priority integer DEFAULT 100 NOT NULL,
    capacity integer DEFAULT 0 NOT NULL,
    lcr_rate_multiplier numeric DEFAULT 1 NOT NULL,
    initial_rate numeric DEFAULT 0.0 NOT NULL,
    initial_interval integer DEFAULT 60 NOT NULL,
    next_interval integer DEFAULT 60 NOT NULL,
    valid_from timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    valid_till timestamp without time zone DEFAULT '2020-01-01 00:00:00'::timestamp without time zone NOT NULL,
    gateway_group_id integer,
    test character varying,
    CONSTRAINT dialpeers_non_zero_initial_interval CHECK ((initial_interval > 0)),
    CONSTRAINT dialpeers_non_zero_next_interval CHECK ((next_interval > 0))
);


--
-- TOC entry 184 (class 1259 OID 17290)
-- Name: gateways; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE gateways (
    id integer NOT NULL,
    host character varying NOT NULL,
    port integer,
    src_rewrite_rule character varying,
    dst_rewrite_rule character varying,
    acd_limit real,
    asr_limit real,
    enabled boolean NOT NULL,
    name character varying NOT NULL,
    auth_enabled boolean DEFAULT false NOT NULL,
    auth_user character varying,
    auth_password character varying,
    term_outbound_proxy character varying,
    term_next_hop_for_replies boolean DEFAULT false NOT NULL,
    term_use_outbound_proxy boolean DEFAULT false NOT NULL,
    contractor_id integer NOT NULL,
    allow_termination boolean DEFAULT true NOT NULL,
    allow_origination boolean DEFAULT true NOT NULL,
    anonymize_sdp boolean DEFAULT true NOT NULL,
    proxy_media boolean DEFAULT false NOT NULL,
    transparent_seqno boolean DEFAULT false NOT NULL,
    transparent_ssrc boolean DEFAULT false NOT NULL,
    sst_enabled boolean DEFAULT false,
    sst_minimum_timer integer DEFAULT 50 NOT NULL,
    sst_maximum_timer integer DEFAULT 50 NOT NULL,
    sst_accept501 boolean DEFAULT true NOT NULL,
    session_refresh_method_id integer DEFAULT 3 NOT NULL,
    sst_session_expires integer DEFAULT 50,
    term_force_outbound_proxy boolean DEFAULT false NOT NULL,
    locked boolean DEFAULT false NOT NULL,
    codecs_payload_order character varying DEFAULT ''::character varying,
    codecs_prefer_transcoding_for character varying DEFAULT ''::character varying,
    src_rewrite_result character varying,
    dst_rewrite_result character varying,
    capacity integer DEFAULT 0 NOT NULL,
    term_next_hop character varying,
    orig_next_hop character varying,
    orig_append_headers_req character varying,
    term_append_headers_req character varying,
    dialog_nat_handling boolean DEFAULT true NOT NULL,
    orig_force_outbound_proxy boolean DEFAULT false NOT NULL,
    orig_use_outbound_proxy boolean DEFAULT false NOT NULL,
    orig_outbound_proxy character varying,
    prefer_existing_codecs boolean DEFAULT true NOT NULL,
    force_symmetric_rtp boolean DEFAULT true NOT NULL,
    transparent_dialog_id boolean DEFAULT false NOT NULL,
    sdp_alines_filter_type_id integer DEFAULT 0 NOT NULL,
    sdp_alines_filter_list character varying,
    gateway_group_id integer,
    orig_disconnect_policy_id integer,
    term_disconnect_policy_id integer,
    diversion_policy_id integer DEFAULT 1 NOT NULL,
    diversion_rewrite_rule character varying,
    diversion_rewrite_result character varying,
    src_name_rewrite_rule character varying,
    src_name_rewrite_result character varying,
    priority integer DEFAULT 100 NOT NULL,
    pop_id integer,
    codec_group_id integer DEFAULT 1 NOT NULL,
    single_codec_in_200ok boolean DEFAULT false NOT NULL,
    ringing_timeout integer,
    symmetric_rtp_nonstop boolean DEFAULT false NOT NULL,
    symmetric_rtp_ignore_rtcp boolean DEFAULT false NOT NULL,
    resolve_ruri boolean DEFAULT false NOT NULL,
    force_dtmf_relay boolean DEFAULT false NOT NULL,
    relay_options boolean DEFAULT false NOT NULL,
    rtp_ping boolean DEFAULT false NOT NULL,
    filter_noaudio_streams boolean DEFAULT false NOT NULL,
    relay_reinvite boolean DEFAULT false NOT NULL,
    sdp_c_location_id integer DEFAULT 2 NOT NULL,
    auth_from_user character varying,
    auth_from_domain character varying,
    relay_hold boolean DEFAULT false NOT NULL,
    rtp_timeout integer DEFAULT 30 NOT NULL
);


SET search_path = switch1, pg_catalog;

--
-- TOC entry 675 (class 1255 OID 19023)
-- Name: process_dp(callprofile35_ty, class4.destinations, class4.dialpeers, billing.accounts, class4.gateways, billing.accounts, integer); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION process_dp(i_profile callprofile35_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_pop_id integer) RETURNS SETOF callprofile35_ty
    LANGUAGE plpgsql STABLE SECURITY DEFINER COST 10000
    AS $$
DECLARE
/*dbg{*/
    v_start timestamp;
    v_end timestamp;
/*}dbg*/
    v_gw class4.gateways%rowtype;
BEGIN
/*dbg{*/
    v_start:=now();
    --RAISE NOTICE 'process_dp in: %',i_profile;5
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> process-DP. Found dialpeer: %',EXTRACT(MILLISECOND from v_end-v_start),hstore(i_dp);
/*}dbg*/
    
    --RAISE NOTICE 'process_dp dst: %',i_destination;
    if i_dp.gateway_id is null then
        PERFORM id from class4.gateway_groups where id=i_dp.gateway_group_id and prefer_same_pop;
        IF FOUND THEN
            /*rel{*/
            FOr v_gw in  select * from class4.gateways cg where cg.gateway_group_id=i_dp.gateway_group_id and cg.enabled ORDER BY cg.pop_id=i_pop_id desc,cg.priority desc LOOP
                return query select * from process_gw_release(i_profile, i_destination, i_dp, i_customer_acc, 
                            i_customer_gw, i_vendor_acc , v_gw);
            end loop;
            /*}rel*/
            /*dbg{*/
            FOr v_gw in  select * from class4.gateways cg where cg.gateway_group_id=i_dp.gateway_group_id and cg.enabled ORDER BY cg.pop_id=i_pop_id desc,cg.priority desc LOOP
                return query select * from process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc, 
                            i_customer_gw, i_vendor_acc , v_gw);
            end loop;
            /*}dbg*/
        else
            /*rel{*/
            FOr v_gw in  select * from class4.gateways cg where cg.gateway_group_id=i_dp.gateway_group_id and cg.enabled ORDER BY cg.priority desc LOOP
                return query select * from process_gw_release(i_profile, i_destination, i_dp, i_customer_acc, 
                            i_customer_gw, i_vendor_acc , v_gw);
            end loop;
            /*}rel*/
            /*dbg{*/
            FOr v_gw in  select * from class4.gateways cg where cg.gateway_group_id=i_dp.gateway_group_id and cg.enabled ORDER BY cg.priority desc LOOP
                return query select * from process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc, 
                            i_customer_gw, i_vendor_acc , v_gw);
            end loop;
            /*}dbg*/
        end if;
    else
        select into v_gw * from class4.gateways cg where cg.id=i_dp.gateway_id and cg.enabled;
        if FOUND THEN
            /*rel{*/
            return query select * from process_gw_release(i_profile, i_destination, i_dp, i_customer_acc,i_customer_gw, i_vendor_acc, v_gw);
            /*}rel*/
            /*dbg{*/
            return query select * from process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc,i_customer_gw, i_vendor_acc, v_gw);
            /*}dbg*/
        else
            return;
        end if;
    end if;
END;
$$;


--
-- TOC entry 673 (class 1255 OID 19044)
-- Name: process_dp_debug(callprofile35_ty, class4.destinations, class4.dialpeers, billing.accounts, class4.gateways, billing.accounts, integer); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION process_dp_debug(i_profile callprofile35_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_pop_id integer) RETURNS SETOF callprofile35_ty
    LANGUAGE plpgsql STABLE SECURITY DEFINER COST 10000
    AS $$
DECLARE
/*dbg{*/
    v_start timestamp;
    v_end timestamp;
/*}dbg*/
    v_gw class4.gateways%rowtype;
BEGIN
/*dbg{*/
    v_start:=now();
    --RAISE NOTICE 'process_dp in: %',i_profile;5
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> process-DP. Found dialpeer: %',EXTRACT(MILLISECOND from v_end-v_start),hstore(i_dp);
/*}dbg*/
    
    --RAISE NOTICE 'process_dp dst: %',i_destination;
    if i_dp.gateway_id is null then
        PERFORM id from class4.gateway_groups where id=i_dp.gateway_group_id and prefer_same_pop;
        IF FOUND THEN
            
            /*dbg{*/
            FOr v_gw in  select * from class4.gateways cg where cg.gateway_group_id=i_dp.gateway_group_id and cg.enabled ORDER BY cg.pop_id=i_pop_id desc,cg.priority desc LOOP
                return query select * from process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc, 
                            i_customer_gw, i_vendor_acc , v_gw);
            end loop;
            /*}dbg*/
        else
            
            /*dbg{*/
            FOr v_gw in  select * from class4.gateways cg where cg.gateway_group_id=i_dp.gateway_group_id and cg.enabled ORDER BY cg.priority desc LOOP
                return query select * from process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc, 
                            i_customer_gw, i_vendor_acc , v_gw);
            end loop;
            /*}dbg*/
        end if;
    else
        select into v_gw * from class4.gateways cg where cg.id=i_dp.gateway_id and cg.enabled;
        if FOUND THEN
            
            /*dbg{*/
            return query select * from process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc,i_customer_gw, i_vendor_acc, v_gw);
            /*}dbg*/
        else
            return;
        end if;
    end if;
END;
$$;


--
-- TOC entry 680 (class 1255 OID 19045)
-- Name: process_dp_release(callprofile35_ty, class4.destinations, class4.dialpeers, billing.accounts, class4.gateways, billing.accounts, integer); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION process_dp_release(i_profile callprofile35_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_pop_id integer) RETURNS SETOF callprofile35_ty
    LANGUAGE plpgsql STABLE SECURITY DEFINER COST 10000
    AS $$
DECLARE

    v_gw class4.gateways%rowtype;
BEGIN

    
    --RAISE NOTICE 'process_dp dst: %',i_destination;
    if i_dp.gateway_id is null then
        PERFORM id from class4.gateway_groups where id=i_dp.gateway_group_id and prefer_same_pop;
        IF FOUND THEN
            /*rel{*/
            FOr v_gw in  select * from class4.gateways cg where cg.gateway_group_id=i_dp.gateway_group_id and cg.enabled ORDER BY cg.pop_id=i_pop_id desc,cg.priority desc LOOP
                return query select * from process_gw_release(i_profile, i_destination, i_dp, i_customer_acc, 
                            i_customer_gw, i_vendor_acc , v_gw);
            end loop;
            /*}rel*/
            
        else
            /*rel{*/
            FOr v_gw in  select * from class4.gateways cg where cg.gateway_group_id=i_dp.gateway_group_id and cg.enabled ORDER BY cg.priority desc LOOP
                return query select * from process_gw_release(i_profile, i_destination, i_dp, i_customer_acc, 
                            i_customer_gw, i_vendor_acc , v_gw);
            end loop;
            /*}rel*/
            
        end if;
    else
        select into v_gw * from class4.gateways cg where cg.id=i_dp.gateway_id and cg.enabled;
        if FOUND THEN
            /*rel{*/
            return query select * from process_gw_release(i_profile, i_destination, i_dp, i_customer_acc,i_customer_gw, i_vendor_acc, v_gw);
            /*}rel*/
            
        else
            return;
        end if;
    end if;
END;
$$;


--
-- TOC entry 676 (class 1255 OID 19034)
-- Name: process_gw(callprofile35_ty, class4.destinations, class4.dialpeers, billing.accounts, class4.gateways, billing.accounts, class4.gateways); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION process_gw(i_profile callprofile35_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_vendor_gw class4.gateways) RETURNS callprofile35_ty
    LANGUAGE plpgsql STABLE SECURITY DEFINER COST 100000
    AS $_$
DECLARE
i integer;
v_customer_allowtime real;
v_vendor_allowtime real;
v_route_found boolean:=false;
/*dbg{*/
    v_start timestamp;
    v_end timestamp;
/*}dbg*/
BEGIN
/*dbg{*/
    v_start:=now();
    --RAISE NOTICE 'process_dp in: %',i_profile;
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> DP. Found dialpeer: %',EXTRACT(MILLISECOND from v_end-v_start),hstore(i_dp);
/*}dbg*/
    
    --RAISE NOTICE 'process_dp dst: %',i_destination;
    
    i_profile.destination_id:=i_destination.id;
--    i_profile.destination_initial_interval:=i_destination.initial_interval;
    i_profile.destination_fee:=i_destination.connect_fee::varchar;
    --i_profile.destination_next_interval:=i_destination.next_interval;
    i_profile.destination_rate_policy_id:=i_destination.rate_policy_id;

    --vendor account capacity limit;
    i_profile.resources:=i_profile.resources||'2:'||i_dp.account_id::varchar||':'||i_vendor_acc.termination_capacity::varchar||':1;';
    -- dialpeer account capacity limit;
    i_profile.resources:=i_profile.resources||'6:'||i_dp.id::varchar||':'||i_dp.capacity::varchar||':1;';
   
    /* */
    i_profile.dialpeer_id=i_dp.id;
    i_profile.dialpeer_next_rate=i_dp.next_rate::varchar;
    i_profile.dialpeer_initial_rate=i_dp.initial_rate::varchar;
    i_profile.dialpeer_initial_interval=i_dp.initial_interval;
    i_profile.dialpeer_next_interval=i_dp.next_interval;
    i_profile.dialpeer_fee=i_dp.connect_fee::varchar;
    i_profile.vendor_id=i_dp.vendor_id;
    i_profile.vendor_acc_id=i_dp.account_id;
    i_profile.term_gw_id=i_vendor_gw.id;

    if i_destination.use_dp_intervals THEN
        i_profile.destination_initial_interval:=i_dp.initial_interval;
        i_profile.destination_next_interval:=i_dp.next_interval;
    ELSE
        i_profile.destination_initial_interval:=i_destination.initial_interval;
        i_profile.destination_next_interval:=i_destination.next_interval;
    end if;

    CASE i_profile.destination_rate_policy_id
        WHEN 1 THEN -- fixed
            i_profile.destination_next_rate:=i_destination.next_rate::varchar;
            i_profile.destination_initial_rate:=i_destination.initial_rate::varchar;
        WHEN 2 THEN -- based on dialpeer
            i_profile.destination_next_rate:=(COALESCE(i_destination.dp_margin_fixed,0)+i_dp.next_rate*(1+COALESCE(i_destination.dp_margin_percent,0)))::varchar;
            i_profile.destination_initial_rate:=(COALESCE(i_destination.dp_margin_fixed,0)+i_dp.initial_rate*(1+COALESCE(i_destination.dp_margin_percent,0)))::varchar;
        WHEN 3 THEN -- min
            IF i_dp.next_rate >= i_destination.next_rate THEN
                i_profile.destination_next_rate:=i_destination.next_rate::varchar; -- FIXED least
                i_profile.destination_initial_rate:=i_destination.initial_rate::varchar;
            ELSE
                i_profile.destination_next_rate:=(COALESCE(i_destination.dp_margin_fixed,0)+i_dp.next_rate*(1+COALESCE(i_destination.dp_margin_percent,0)))::varchar; -- DYNAMIC
                i_profile.destination_initial_rate:=(COALESCE(i_destination.dp_margin_fixed,0)+i_dp.initial_rate*(1+COALESCE(i_destination.dp_margin_percent,0)))::varchar;
            END IF;
        WHEN 4 THEN -- max
            IF i_dp.next_rate < i_destination.next_rate THEN
                i_profile.destination_next_rate:=i_destination.next_rate::varchar; --FIXED
                i_profile.destination_initial_rate:=i_destination.initial_rate::varchar;
            ELSE
                i_profile.destination_next_rate:=(COALESCE(i_destination.dp_margin_fixed,0)+i_dp.next_rate*(1+COALESCE(i_destination.dp_margin_percent,0)))::varchar; -- DYNAMIC
                i_profile.destination_initial_rate:=(COALESCE(i_destination.dp_margin_fixed,0)+i_dp.initial_rate*(1+COALESCE(i_destination.dp_margin_percent,0)))::varchar;
            END IF;
        ELSE
            --
    end case;



    /* time limiting START */
    --SELECT INTO STRICT v_c_acc * FROM billing.accounts  WHERE id=v_customer_auth.account_id;
    --SELECT INTO STRICT v_v_acc * FROM billing.accounts  WHERE id=v_dialpeer.account_id;
    
    IF (i_customer_acc.balance-i_customer_acc.min_balance)-i_destination.connect_fee <0 THEN
        v_customer_allowtime:=0;
        i_profile:=refuse_call_f(i_profile,'403','Customer balance too low');
        RETURN i_profile;
    ELSIF (i_customer_acc.balance-i_customer_acc.min_balance)-i_destination.connect_fee-i_destination.initial_rate*i_destination.initial_interval<0 THEN
        v_customer_allowtime:=i_destination.initial_interval;
        i_profile:=refuse_call_f(i_profile,'403','Customer balance too low');
        RETURN i_profile;
    ELSIF i_destination.next_rate!=0 AND i_destination.next_interval!=0 THEN
        v_customer_allowtime:=i_destination.initial_interval+
        LEAST(FLOOR(((i_customer_acc.balance-i_customer_acc.min_balance)-i_destination.connect_fee-i_destination.initial_rate/60*i_destination.initial_interval)/
        (i_destination.next_rate/60*i_destination.next_interval)),24e6)::integer*i_destination.next_interval;
    ELSE
        v_customer_allowtime:=10800;
    end IF;
    
    IF (i_vendor_acc.max_balance-i_vendor_acc.balance)-i_dp.connect_fee <0 THEN
        v_vendor_allowtime:=0;
        i_profile:=refuse_call_f(i_profile,'403','Vendor balance too hight');
        RETURN i_profile;
    ELSIF (i_vendor_acc.max_balance-i_vendor_acc.balance)-i_dp.connect_fee-i_dp.initial_rate*i_dp.initial_interval<0 THEN
        v_vendor_allowtime:=i_dp.initial_interval;
        i_profile:=refuse_call_f(i_profile,'403','Vendor balance too hight');
        RETURN i_profile;
    ELSIF i_dp.next_rate!=0 AND i_dp.next_interval!=0 THEN
        v_vendor_allowtime:=i_dp.initial_interval+
        LEAST(FLOOR(((i_vendor_acc.max_balance-i_vendor_acc.balance)-i_dp.connect_fee-i_dp.initial_rate/60*i_dp.initial_interval)/
        (i_dp.next_rate/60*i_dp.next_interval)),24e6)::integer*i_dp.next_interval;
    ELSE
        v_vendor_allowtime:=10800;
    end IF;

    i_profile.time_limit=LEAST(v_vendor_allowtime,v_customer_allowtime,10800)::integer;
    /* time limiting END */


    /* number rewriting _After_ routing */
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> DP. Before rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),i_profile.src_prefix_out,i_profile.dst_prefix_out;
/*}dbg*/
    IF (i_dp.dst_rewrite_rule IS NOT NULL AND i_dp.dst_rewrite_rule!='') THEN
        i_profile.dst_prefix_out=regexp_replace(i_profile.dst_prefix_out,i_dp.dst_rewrite_rule,i_dp.dst_rewrite_result);
    END IF;

    IF (i_dp.src_rewrite_rule IS NOT NULL AND i_dp.src_rewrite_rule!='') THEN
        i_profile.src_prefix_out=regexp_replace(i_profile.src_prefix_out,i_dp.src_rewrite_rule,i_dp.src_rewrite_result);
    END IF;
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> DP. After rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),i_profile.src_prefix_out,i_profile.dst_prefix_out;
/*}dbg*/

    /*
        get termination gw data
    */
    --SELECT into v_dst_gw * from class4.gateways WHERE id=v_dialpeer.gateway_id;
    --SELECT into v_orig_gw * from class4.gateways WHERE id=v_customer_auth.gateway_id;
    --vendor gw
    i_profile.resources:=i_profile.resources||'5:'||i_vendor_gw.id::varchar||':'||i_vendor_gw.capacity::varchar||':1;';
    --customer gw
    i_profile.resources:=i_profile.resources||'4:'||i_customer_gw.id::varchar||':'||i_customer_gw.capacity::varchar||':1;';


    /* 
        number rewriting _After_ routing _IN_ termination GW
    */
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> GW. Before rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),i_profile.src_prefix_out,i_profile.dst_prefix_out;
/*}dbg*/
    IF (i_vendor_gw.dst_rewrite_rule IS NOT NULL AND i_vendor_gw.dst_rewrite_rule!='') THEN
        i_profile.dst_prefix_out=regexp_replace(i_profile.dst_prefix_out,i_vendor_gw.dst_rewrite_rule,i_vendor_gw.dst_rewrite_result);
    END IF;

    IF (i_vendor_gw.src_rewrite_rule IS NOT NULL AND i_vendor_gw.src_rewrite_rule!='') THEN
        i_profile.src_prefix_out=regexp_replace(i_profile.src_prefix_out,i_vendor_gw.src_rewrite_rule,i_vendor_gw.src_rewrite_result);
    END IF;
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> GW. After rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),i_profile.src_prefix_out,i_profile.dst_prefix_out;
/*}dbg*/

    i_profile.anonymize_sdp:=i_vendor_gw.anonymize_sdp OR i_customer_gw.anonymize_sdp;

    i_profile.append_headers:='User-Agent: YETI SBC\r\n';
    i_profile.append_headers_req:=i_vendor_gw.term_append_headers_req;
    i_profile.aleg_append_headers_req=i_customer_gw.orig_append_headers_req;

    i_profile.enable_auth:=i_vendor_gw.term_auth_enabled;
    i_profile.auth_pwd:=i_vendor_gw.term_auth_pwd;
    i_profile.auth_user:=i_vendor_gw.term_auth_user;
    i_profile.enable_aleg_auth:=false;
    i_profile.auth_aleg_pwd:='';
    i_profile.auth_aleg_user:='';
    
    i_profile.next_hop_1st_req=i_vendor_gw.term_auth_enabled; -- use low delay dns srv if auth enabled
    i_profile.next_hop:=i_vendor_gw.term_next_hop;
    i_profile.aleg_next_hop:=i_customer_gw.orig_next_hop;
--    i_profile.next_hop_for_replies:=v_dst_gw.term_next_hop_for_replies;

    i_profile.dlg_nat_handling=i_customer_gw.dialog_nat_handling;
    i_profile.transparent_dlg_id=i_customer_gw.transparent_dialog_id;
    
    i_profile.call_id:=''; -- Generation by sems
    
    --i_profile."from":='$f';
    --i_profile."from":='<sip:'||i_profile.src_prefix_out||'@46.19.209.45>';
    i_profile."from":=COALESCE(i_profile.src_name_out||' ','')||'<sip:'||i_profile.src_prefix_out||'@$Oi>';
    
    i_profile."to":='<sip:'||i_profile.dst_prefix_out||'@'||i_vendor_gw.host::varchar||COALESCE(':'||i_vendor_gw.port||'>','>');
    i_profile.ruri:='sip:'||i_profile.dst_prefix_out||'@'||i_vendor_gw.host::varchar||COALESCE(':'||i_vendor_gw.port,'');
    i_profile.ruri_host:=i_vendor_gw.host::varchar||COALESCE(':'||i_vendor_gw.port,'');

    IF (i_vendor_gw.term_use_outbound_proxy ) THEN
        i_profile.outbound_proxy:='sip:'||i_vendor_gw.term_outbound_proxy;
        i_profile.force_outbound_proxy:=i_vendor_gw.term_force_outbound_proxy;
    ELSE
        i_profile.outbound_proxy:=NULL;
        i_profile.force_outbound_proxy:=false;
    END IF;

    IF (i_customer_gw.orig_use_outbound_proxy ) THEN
        i_profile.aleg_force_outbound_proxy:=i_customer_gw.orig_force_outbound_proxy;
        i_profile.aleg_outbound_proxy='sip:'||i_customer_gw.orig_outbound_proxy;
    else
        i_profile.aleg_force_outbound_proxy:=FALSE;
        i_profile.aleg_outbound_proxy=NULL;
    end if;

    i_profile.aleg_policy_id=i_customer_gw.orig_disconnect_policy_id;
    i_profile.bleg_policy_id=i_vendor_gw.term_disconnect_policy_id;

    --i_profile.header_filter_type_id:=i_vendor_gw.header_filter_type_id;
    --i_profile.header_filter_list:=i_vendor_gw.header_filter_list;
    i_profile.header_filter_type_id:='1'; -- blacklist TODO: Switch to whitelist and hardcode all transit headers;
    i_profile.header_filter_list:='X-Yeti-Auth,Diversion,X-UID,X-ORIG-IP,X-ORIG-PORT,User-Agent,X-Asterisk-HangupCause,X-Asterisk-HangupCauseCode';

    
    i_profile.message_filter_type_id:=i_vendor_gw.message_filter_type_id;
    i_profile.message_filter_list:=i_vendor_gw.message_filter_list;

    i_profile.sdp_filter_type_id:=i_vendor_gw.sdp_filter_type_id;
    i_profile.sdp_filter_list:=i_vendor_gw.sdp_filter_list;
    
    i_profile.sdp_alines_filter_type_id:=i_vendor_gw.sdp_alines_filter_type_id;
    i_profile.sdp_alines_filter_list:=i_vendor_gw.sdp_alines_filter_list;

    i_profile.enable_session_timer=i_vendor_gw.sst_enabled;
    i_profile.session_expires =i_vendor_gw.sst_session_expires;
    i_profile.minimum_timer:=i_vendor_gw.sst_minimum_timer;
    i_profile.maximum_timer:=i_vendor_gw.sst_maximum_timer;
    i_profile.session_refresh_method_id:=i_vendor_gw.session_refresh_method_id;
    i_profile.accept_501_reply:=i_vendor_gw.sst_accept501;
  
    i_profile.enable_aleg_session_timer=i_customer_gw.sst_enabled;
    i_profile.aleg_session_expires:=i_customer_gw.sst_session_expires;
    i_profile.aleg_minimum_timer:=i_customer_gw.sst_minimum_timer;
    i_profile.aleg_maximum_timer:=i_customer_gw.sst_maximum_timer;
    i_profile.aleg_session_refresh_method_id:=i_customer_gw.session_refresh_method_id;
    i_profile.aleg_accept_501_reply:=i_customer_gw.sst_accept501;
    
    i_profile.reply_translations:='';
    i_profile.disconnect_code_id:=NULL;
    i_profile.enable_rtprelay:=i_vendor_gw.proxy_media OR i_customer_gw.proxy_media;
    i_profile.rtprelay_transparent_seqno:=i_vendor_gw.transparent_seqno OR i_customer_gw.transparent_seqno;
    i_profile.rtprelay_transparent_ssrc:=i_vendor_gw.transparent_ssrc OR i_customer_gw.transparent_ssrc;

    i_profile.rtprelay_interface:='';
    i_profile.aleg_rtprelay_interface:='';

    i_profile.outbound_interface:='';
    i_profile.aleg_outbound_interface:='';
    
    i_profile.rtprelay_msgflags_symmetric_rtp:=false;
    i_profile.bleg_force_symmetric_rtp:=i_vendor_gw.force_symmetric_rtp;
    i_profile.aleg_force_symmetric_rtp:=i_customer_gw.force_symmetric_rtp;


    /* OBSOLETE variables:
      i_profile.codec_preference:=i_vendor_gw.codecs_payload_order;
      i_profile.codec_preference_aleg :=i_customer_gw.codecs_payload_order;
    
      i_profile.prefer_existing_codecs:=i_vendor_gw.prefer_existing_codecs;
      i_profile.prefer_existing_codecs_aleg:=i_customer_gw.prefer_existing_codecs;
    */
    
    
    i_profile.dtmf_transcoding:='always';-- always, lowfi_codec, never
    i_profile.lowfi_codecs:='';
    
    
    i_profile.enable_reg_caching=false;
    i_profile.min_reg_expires:='100500';
    i_profile.max_ua_expires:='100500';
    
    i_profile.aleg_codecs_group_id:=i_customer_gw.codec_group_id;
    i_profile.bleg_codecs_group_id:=i_vendor_gw.codec_group_id;
    i_profile.aleg_single_codec_in_200ok:=i_customer_gw.single_codec_in_200ok;
    i_profile.bleg_single_codec_in_200ok:=i_vendor_gw.single_codec_in_200ok;
    i_profile.ringing_timeout=i_vendor_gw.ringing_timeout;
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> DP. Finished: % ',EXTRACT(MILLISECOND from v_end-v_start),hstore(i_profile);
/*}dbg*/
    RETURN i_profile;
END;
$_$;


--
-- TOC entry 681 (class 1255 OID 19046)
-- Name: process_gw_debug(callprofile35_ty, class4.destinations, class4.dialpeers, billing.accounts, class4.gateways, billing.accounts, class4.gateways); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION process_gw_debug(i_profile callprofile35_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_vendor_gw class4.gateways) RETURNS callprofile35_ty
    LANGUAGE plpgsql STABLE SECURITY DEFINER COST 100000
    AS $_$
DECLARE
i integer;
v_customer_allowtime real;
v_vendor_allowtime real;
v_route_found boolean:=false;
/*dbg{*/
    v_start timestamp;
    v_end timestamp;
/*}dbg*/
BEGIN
/*dbg{*/
    v_start:=now();
    --RAISE NOTICE 'process_dp in: %',i_profile;
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> DP. Found dialpeer: %',EXTRACT(MILLISECOND from v_end-v_start),hstore(i_dp);
/*}dbg*/
    
    --RAISE NOTICE 'process_dp dst: %',i_destination;
    
    i_profile.destination_id:=i_destination.id;
--    i_profile.destination_initial_interval:=i_destination.initial_interval;
    i_profile.destination_fee:=i_destination.connect_fee::varchar;
    --i_profile.destination_next_interval:=i_destination.next_interval;
    i_profile.destination_rate_policy_id:=i_destination.rate_policy_id;

    --vendor account capacity limit;
    i_profile.resources:=i_profile.resources||'2:'||i_dp.account_id::varchar||':'||i_vendor_acc.termination_capacity::varchar||':1;';
    -- dialpeer account capacity limit;
    i_profile.resources:=i_profile.resources||'6:'||i_dp.id::varchar||':'||i_dp.capacity::varchar||':1;';
   
    /* */
    i_profile.dialpeer_id=i_dp.id;
    i_profile.dialpeer_next_rate=i_dp.next_rate::varchar;
    i_profile.dialpeer_initial_rate=i_dp.initial_rate::varchar;
    i_profile.dialpeer_initial_interval=i_dp.initial_interval;
    i_profile.dialpeer_next_interval=i_dp.next_interval;
    i_profile.dialpeer_fee=i_dp.connect_fee::varchar;
    i_profile.vendor_id=i_dp.vendor_id;
    i_profile.vendor_acc_id=i_dp.account_id;
    i_profile.term_gw_id=i_vendor_gw.id;

    if i_destination.use_dp_intervals THEN
        i_profile.destination_initial_interval:=i_dp.initial_interval;
        i_profile.destination_next_interval:=i_dp.next_interval;
    ELSE
        i_profile.destination_initial_interval:=i_destination.initial_interval;
        i_profile.destination_next_interval:=i_destination.next_interval;
    end if;

    CASE i_profile.destination_rate_policy_id
        WHEN 1 THEN -- fixed
            i_profile.destination_next_rate:=i_destination.next_rate::varchar;
            i_profile.destination_initial_rate:=i_destination.initial_rate::varchar;
        WHEN 2 THEN -- based on dialpeer
            i_profile.destination_next_rate:=(COALESCE(i_destination.dp_margin_fixed,0)+i_dp.next_rate*(1+COALESCE(i_destination.dp_margin_percent,0)))::varchar;
            i_profile.destination_initial_rate:=(COALESCE(i_destination.dp_margin_fixed,0)+i_dp.initial_rate*(1+COALESCE(i_destination.dp_margin_percent,0)))::varchar;
        WHEN 3 THEN -- min
            IF i_dp.next_rate >= i_destination.next_rate THEN
                i_profile.destination_next_rate:=i_destination.next_rate::varchar; -- FIXED least
                i_profile.destination_initial_rate:=i_destination.initial_rate::varchar;
            ELSE
                i_profile.destination_next_rate:=(COALESCE(i_destination.dp_margin_fixed,0)+i_dp.next_rate*(1+COALESCE(i_destination.dp_margin_percent,0)))::varchar; -- DYNAMIC
                i_profile.destination_initial_rate:=(COALESCE(i_destination.dp_margin_fixed,0)+i_dp.initial_rate*(1+COALESCE(i_destination.dp_margin_percent,0)))::varchar;
            END IF;
        WHEN 4 THEN -- max
            IF i_dp.next_rate < i_destination.next_rate THEN
                i_profile.destination_next_rate:=i_destination.next_rate::varchar; --FIXED
                i_profile.destination_initial_rate:=i_destination.initial_rate::varchar;
            ELSE
                i_profile.destination_next_rate:=(COALESCE(i_destination.dp_margin_fixed,0)+i_dp.next_rate*(1+COALESCE(i_destination.dp_margin_percent,0)))::varchar; -- DYNAMIC
                i_profile.destination_initial_rate:=(COALESCE(i_destination.dp_margin_fixed,0)+i_dp.initial_rate*(1+COALESCE(i_destination.dp_margin_percent,0)))::varchar;
            END IF;
        ELSE
            --
    end case;



    /* time limiting START */
    --SELECT INTO STRICT v_c_acc * FROM billing.accounts  WHERE id=v_customer_auth.account_id;
    --SELECT INTO STRICT v_v_acc * FROM billing.accounts  WHERE id=v_dialpeer.account_id;
    
    IF (i_customer_acc.balance-i_customer_acc.min_balance)-i_destination.connect_fee <0 THEN
        v_customer_allowtime:=0;
        i_profile:=refuse_call_f(i_profile,'403','Customer balance too low');
        RETURN i_profile;
    ELSIF (i_customer_acc.balance-i_customer_acc.min_balance)-i_destination.connect_fee-i_destination.initial_rate*i_destination.initial_interval<0 THEN
        v_customer_allowtime:=i_destination.initial_interval;
        i_profile:=refuse_call_f(i_profile,'403','Customer balance too low');
        RETURN i_profile;
    ELSIF i_destination.next_rate!=0 AND i_destination.next_interval!=0 THEN
        v_customer_allowtime:=i_destination.initial_interval+
        LEAST(FLOOR(((i_customer_acc.balance-i_customer_acc.min_balance)-i_destination.connect_fee-i_destination.initial_rate/60*i_destination.initial_interval)/
        (i_destination.next_rate/60*i_destination.next_interval)),24e6)::integer*i_destination.next_interval;
    ELSE
        v_customer_allowtime:=10800;
    end IF;
    
    IF (i_vendor_acc.max_balance-i_vendor_acc.balance)-i_dp.connect_fee <0 THEN
        v_vendor_allowtime:=0;
        i_profile:=refuse_call_f(i_profile,'403','Vendor balance too hight');
        RETURN i_profile;
    ELSIF (i_vendor_acc.max_balance-i_vendor_acc.balance)-i_dp.connect_fee-i_dp.initial_rate*i_dp.initial_interval<0 THEN
        v_vendor_allowtime:=i_dp.initial_interval;
        i_profile:=refuse_call_f(i_profile,'403','Vendor balance too hight');
        RETURN i_profile;
    ELSIF i_dp.next_rate!=0 AND i_dp.next_interval!=0 THEN
        v_vendor_allowtime:=i_dp.initial_interval+
        LEAST(FLOOR(((i_vendor_acc.max_balance-i_vendor_acc.balance)-i_dp.connect_fee-i_dp.initial_rate/60*i_dp.initial_interval)/
        (i_dp.next_rate/60*i_dp.next_interval)),24e6)::integer*i_dp.next_interval;
    ELSE
        v_vendor_allowtime:=10800;
    end IF;

    i_profile.time_limit=LEAST(v_vendor_allowtime,v_customer_allowtime,10800)::integer;
    /* time limiting END */


    /* number rewriting _After_ routing */
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> DP. Before rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),i_profile.src_prefix_out,i_profile.dst_prefix_out;
/*}dbg*/
    IF (i_dp.dst_rewrite_rule IS NOT NULL AND i_dp.dst_rewrite_rule!='') THEN
        i_profile.dst_prefix_out=regexp_replace(i_profile.dst_prefix_out,i_dp.dst_rewrite_rule,i_dp.dst_rewrite_result);
    END IF;

    IF (i_dp.src_rewrite_rule IS NOT NULL AND i_dp.src_rewrite_rule!='') THEN
        i_profile.src_prefix_out=regexp_replace(i_profile.src_prefix_out,i_dp.src_rewrite_rule,i_dp.src_rewrite_result);
    END IF;
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> DP. After rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),i_profile.src_prefix_out,i_profile.dst_prefix_out;
/*}dbg*/

    /*
        get termination gw data
    */
    --SELECT into v_dst_gw * from class4.gateways WHERE id=v_dialpeer.gateway_id;
    --SELECT into v_orig_gw * from class4.gateways WHERE id=v_customer_auth.gateway_id;
    --vendor gw
    i_profile.resources:=i_profile.resources||'5:'||i_vendor_gw.id::varchar||':'||i_vendor_gw.capacity::varchar||':1;';
    --customer gw
    i_profile.resources:=i_profile.resources||'4:'||i_customer_gw.id::varchar||':'||i_customer_gw.capacity::varchar||':1;';


    /* 
        number rewriting _After_ routing _IN_ termination GW
    */
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> GW. Before rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),i_profile.src_prefix_out,i_profile.dst_prefix_out;
/*}dbg*/
    IF (i_vendor_gw.dst_rewrite_rule IS NOT NULL AND i_vendor_gw.dst_rewrite_rule!='') THEN
        i_profile.dst_prefix_out=regexp_replace(i_profile.dst_prefix_out,i_vendor_gw.dst_rewrite_rule,i_vendor_gw.dst_rewrite_result);
    END IF;

    IF (i_vendor_gw.src_rewrite_rule IS NOT NULL AND i_vendor_gw.src_rewrite_rule!='') THEN
        i_profile.src_prefix_out=regexp_replace(i_profile.src_prefix_out,i_vendor_gw.src_rewrite_rule,i_vendor_gw.src_rewrite_result);
    END IF;
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> GW. After rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),i_profile.src_prefix_out,i_profile.dst_prefix_out;
/*}dbg*/

    i_profile.anonymize_sdp:=i_vendor_gw.anonymize_sdp OR i_customer_gw.anonymize_sdp;

    i_profile.append_headers:='User-Agent: YETI SBC\r\n';
    i_profile.append_headers_req:=i_vendor_gw.term_append_headers_req;
    i_profile.aleg_append_headers_req=i_customer_gw.orig_append_headers_req;

    i_profile.enable_auth:=i_vendor_gw.term_auth_enabled;
    i_profile.auth_pwd:=i_vendor_gw.term_auth_pwd;
    i_profile.auth_user:=i_vendor_gw.term_auth_user;
    i_profile.enable_aleg_auth:=false;
    i_profile.auth_aleg_pwd:='';
    i_profile.auth_aleg_user:='';
    
    i_profile.next_hop_1st_req=i_vendor_gw.term_auth_enabled; -- use low delay dns srv if auth enabled
    i_profile.next_hop:=i_vendor_gw.term_next_hop;
    i_profile.aleg_next_hop:=i_customer_gw.orig_next_hop;
--    i_profile.next_hop_for_replies:=v_dst_gw.term_next_hop_for_replies;

    i_profile.dlg_nat_handling=i_customer_gw.dialog_nat_handling;
    i_profile.transparent_dlg_id=i_customer_gw.transparent_dialog_id;
    
    i_profile.call_id:=''; -- Generation by sems
    
    --i_profile."from":='$f';
    --i_profile."from":='<sip:'||i_profile.src_prefix_out||'@46.19.209.45>';
    i_profile."from":=COALESCE(i_profile.src_name_out||' ','')||'<sip:'||i_profile.src_prefix_out||'@$Oi>';
    
    i_profile."to":='<sip:'||i_profile.dst_prefix_out||'@'||i_vendor_gw.host::varchar||COALESCE(':'||i_vendor_gw.port||'>','>');
    i_profile.ruri:='sip:'||i_profile.dst_prefix_out||'@'||i_vendor_gw.host::varchar||COALESCE(':'||i_vendor_gw.port,'');
    i_profile.ruri_host:=i_vendor_gw.host::varchar||COALESCE(':'||i_vendor_gw.port,'');

    IF (i_vendor_gw.term_use_outbound_proxy ) THEN
        i_profile.outbound_proxy:='sip:'||i_vendor_gw.term_outbound_proxy;
        i_profile.force_outbound_proxy:=i_vendor_gw.term_force_outbound_proxy;
    ELSE
        i_profile.outbound_proxy:=NULL;
        i_profile.force_outbound_proxy:=false;
    END IF;

    IF (i_customer_gw.orig_use_outbound_proxy ) THEN
        i_profile.aleg_force_outbound_proxy:=i_customer_gw.orig_force_outbound_proxy;
        i_profile.aleg_outbound_proxy='sip:'||i_customer_gw.orig_outbound_proxy;
    else
        i_profile.aleg_force_outbound_proxy:=FALSE;
        i_profile.aleg_outbound_proxy=NULL;
    end if;

    i_profile.aleg_policy_id=i_customer_gw.orig_disconnect_policy_id;
    i_profile.bleg_policy_id=i_vendor_gw.term_disconnect_policy_id;

    --i_profile.header_filter_type_id:=i_vendor_gw.header_filter_type_id;
    --i_profile.header_filter_list:=i_vendor_gw.header_filter_list;
    i_profile.header_filter_type_id:='1'; -- blacklist TODO: Switch to whitelist and hardcode all transit headers;
    i_profile.header_filter_list:='X-Yeti-Auth,Diversion,X-UID,X-ORIG-IP,X-ORIG-PORT,User-Agent,X-Asterisk-HangupCause,X-Asterisk-HangupCauseCode';

    
    i_profile.message_filter_type_id:=i_vendor_gw.message_filter_type_id;
    i_profile.message_filter_list:=i_vendor_gw.message_filter_list;

    i_profile.sdp_filter_type_id:=i_vendor_gw.sdp_filter_type_id;
    i_profile.sdp_filter_list:=i_vendor_gw.sdp_filter_list;
    
    i_profile.sdp_alines_filter_type_id:=i_vendor_gw.sdp_alines_filter_type_id;
    i_profile.sdp_alines_filter_list:=i_vendor_gw.sdp_alines_filter_list;

    i_profile.enable_session_timer=i_vendor_gw.sst_enabled;
    i_profile.session_expires =i_vendor_gw.sst_session_expires;
    i_profile.minimum_timer:=i_vendor_gw.sst_minimum_timer;
    i_profile.maximum_timer:=i_vendor_gw.sst_maximum_timer;
    i_profile.session_refresh_method_id:=i_vendor_gw.session_refresh_method_id;
    i_profile.accept_501_reply:=i_vendor_gw.sst_accept501;
  
    i_profile.enable_aleg_session_timer=i_customer_gw.sst_enabled;
    i_profile.aleg_session_expires:=i_customer_gw.sst_session_expires;
    i_profile.aleg_minimum_timer:=i_customer_gw.sst_minimum_timer;
    i_profile.aleg_maximum_timer:=i_customer_gw.sst_maximum_timer;
    i_profile.aleg_session_refresh_method_id:=i_customer_gw.session_refresh_method_id;
    i_profile.aleg_accept_501_reply:=i_customer_gw.sst_accept501;
    
    i_profile.reply_translations:='';
    i_profile.disconnect_code_id:=NULL;
    i_profile.enable_rtprelay:=i_vendor_gw.proxy_media OR i_customer_gw.proxy_media;
    i_profile.rtprelay_transparent_seqno:=i_vendor_gw.transparent_seqno OR i_customer_gw.transparent_seqno;
    i_profile.rtprelay_transparent_ssrc:=i_vendor_gw.transparent_ssrc OR i_customer_gw.transparent_ssrc;

    i_profile.rtprelay_interface:='';
    i_profile.aleg_rtprelay_interface:='';

    i_profile.outbound_interface:='';
    i_profile.aleg_outbound_interface:='';
    
    i_profile.rtprelay_msgflags_symmetric_rtp:=false;
    i_profile.bleg_force_symmetric_rtp:=i_vendor_gw.force_symmetric_rtp;
    i_profile.aleg_force_symmetric_rtp:=i_customer_gw.force_symmetric_rtp;


    /* OBSOLETE variables:
      i_profile.codec_preference:=i_vendor_gw.codecs_payload_order;
      i_profile.codec_preference_aleg :=i_customer_gw.codecs_payload_order;
    
      i_profile.prefer_existing_codecs:=i_vendor_gw.prefer_existing_codecs;
      i_profile.prefer_existing_codecs_aleg:=i_customer_gw.prefer_existing_codecs;
    */
    
    
    i_profile.dtmf_transcoding:='always';-- always, lowfi_codec, never
    i_profile.lowfi_codecs:='';
    
    
    i_profile.enable_reg_caching=false;
    i_profile.min_reg_expires:='100500';
    i_profile.max_ua_expires:='100500';
    
    i_profile.aleg_codecs_group_id:=i_customer_gw.codec_group_id;
    i_profile.bleg_codecs_group_id:=i_vendor_gw.codec_group_id;
    i_profile.aleg_single_codec_in_200ok:=i_customer_gw.single_codec_in_200ok;
    i_profile.bleg_single_codec_in_200ok:=i_vendor_gw.single_codec_in_200ok;
    i_profile.ringing_timeout=i_vendor_gw.ringing_timeout;
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> DP. Finished: % ',EXTRACT(MILLISECOND from v_end-v_start),hstore(i_profile);
/*}dbg*/
    RETURN i_profile;
END;
$_$;


--
-- TOC entry 682 (class 1255 OID 19048)
-- Name: process_gw_release(callprofile35_ty, class4.destinations, class4.dialpeers, billing.accounts, class4.gateways, billing.accounts, class4.gateways); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION process_gw_release(i_profile callprofile35_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_vendor_gw class4.gateways) RETURNS callprofile35_ty
    LANGUAGE plpgsql STABLE SECURITY DEFINER COST 100000
    AS $_$
DECLARE
i integer;
v_customer_allowtime real;
v_vendor_allowtime real;
v_route_found boolean:=false;

BEGIN

    
    --RAISE NOTICE 'process_dp dst: %',i_destination;
    
    i_profile.destination_id:=i_destination.id;
--    i_profile.destination_initial_interval:=i_destination.initial_interval;
    i_profile.destination_fee:=i_destination.connect_fee::varchar;
    --i_profile.destination_next_interval:=i_destination.next_interval;
    i_profile.destination_rate_policy_id:=i_destination.rate_policy_id;

    --vendor account capacity limit;
    i_profile.resources:=i_profile.resources||'2:'||i_dp.account_id::varchar||':'||i_vendor_acc.termination_capacity::varchar||':1;';
    -- dialpeer account capacity limit;
    i_profile.resources:=i_profile.resources||'6:'||i_dp.id::varchar||':'||i_dp.capacity::varchar||':1;';
   
    /* */
    i_profile.dialpeer_id=i_dp.id;
    i_profile.dialpeer_next_rate=i_dp.next_rate::varchar;
    i_profile.dialpeer_initial_rate=i_dp.initial_rate::varchar;
    i_profile.dialpeer_initial_interval=i_dp.initial_interval;
    i_profile.dialpeer_next_interval=i_dp.next_interval;
    i_profile.dialpeer_fee=i_dp.connect_fee::varchar;
    i_profile.vendor_id=i_dp.vendor_id;
    i_profile.vendor_acc_id=i_dp.account_id;
    i_profile.term_gw_id=i_vendor_gw.id;

    if i_destination.use_dp_intervals THEN
        i_profile.destination_initial_interval:=i_dp.initial_interval;
        i_profile.destination_next_interval:=i_dp.next_interval;
    ELSE
        i_profile.destination_initial_interval:=i_destination.initial_interval;
        i_profile.destination_next_interval:=i_destination.next_interval;
    end if;

    CASE i_profile.destination_rate_policy_id
        WHEN 1 THEN -- fixed
            i_profile.destination_next_rate:=i_destination.next_rate::varchar;
            i_profile.destination_initial_rate:=i_destination.initial_rate::varchar;
        WHEN 2 THEN -- based on dialpeer
            i_profile.destination_next_rate:=(COALESCE(i_destination.dp_margin_fixed,0)+i_dp.next_rate*(1+COALESCE(i_destination.dp_margin_percent,0)))::varchar;
            i_profile.destination_initial_rate:=(COALESCE(i_destination.dp_margin_fixed,0)+i_dp.initial_rate*(1+COALESCE(i_destination.dp_margin_percent,0)))::varchar;
        WHEN 3 THEN -- min
            IF i_dp.next_rate >= i_destination.next_rate THEN
                i_profile.destination_next_rate:=i_destination.next_rate::varchar; -- FIXED least
                i_profile.destination_initial_rate:=i_destination.initial_rate::varchar;
            ELSE
                i_profile.destination_next_rate:=(COALESCE(i_destination.dp_margin_fixed,0)+i_dp.next_rate*(1+COALESCE(i_destination.dp_margin_percent,0)))::varchar; -- DYNAMIC
                i_profile.destination_initial_rate:=(COALESCE(i_destination.dp_margin_fixed,0)+i_dp.initial_rate*(1+COALESCE(i_destination.dp_margin_percent,0)))::varchar;
            END IF;
        WHEN 4 THEN -- max
            IF i_dp.next_rate < i_destination.next_rate THEN
                i_profile.destination_next_rate:=i_destination.next_rate::varchar; --FIXED
                i_profile.destination_initial_rate:=i_destination.initial_rate::varchar;
            ELSE
                i_profile.destination_next_rate:=(COALESCE(i_destination.dp_margin_fixed,0)+i_dp.next_rate*(1+COALESCE(i_destination.dp_margin_percent,0)))::varchar; -- DYNAMIC
                i_profile.destination_initial_rate:=(COALESCE(i_destination.dp_margin_fixed,0)+i_dp.initial_rate*(1+COALESCE(i_destination.dp_margin_percent,0)))::varchar;
            END IF;
        ELSE
            --
    end case;



    /* time limiting START */
    --SELECT INTO STRICT v_c_acc * FROM billing.accounts  WHERE id=v_customer_auth.account_id;
    --SELECT INTO STRICT v_v_acc * FROM billing.accounts  WHERE id=v_dialpeer.account_id;
    
    IF (i_customer_acc.balance-i_customer_acc.min_balance)-i_destination.connect_fee <0 THEN
        v_customer_allowtime:=0;
        i_profile:=refuse_call_f(i_profile,'403','Customer balance too low');
        RETURN i_profile;
    ELSIF (i_customer_acc.balance-i_customer_acc.min_balance)-i_destination.connect_fee-i_destination.initial_rate*i_destination.initial_interval<0 THEN
        v_customer_allowtime:=i_destination.initial_interval;
        i_profile:=refuse_call_f(i_profile,'403','Customer balance too low');
        RETURN i_profile;
    ELSIF i_destination.next_rate!=0 AND i_destination.next_interval!=0 THEN
        v_customer_allowtime:=i_destination.initial_interval+
        LEAST(FLOOR(((i_customer_acc.balance-i_customer_acc.min_balance)-i_destination.connect_fee-i_destination.initial_rate/60*i_destination.initial_interval)/
        (i_destination.next_rate/60*i_destination.next_interval)),24e6)::integer*i_destination.next_interval;
    ELSE
        v_customer_allowtime:=10800;
    end IF;
    
    IF (i_vendor_acc.max_balance-i_vendor_acc.balance)-i_dp.connect_fee <0 THEN
        v_vendor_allowtime:=0;
        i_profile:=refuse_call_f(i_profile,'403','Vendor balance too hight');
        RETURN i_profile;
    ELSIF (i_vendor_acc.max_balance-i_vendor_acc.balance)-i_dp.connect_fee-i_dp.initial_rate*i_dp.initial_interval<0 THEN
        v_vendor_allowtime:=i_dp.initial_interval;
        i_profile:=refuse_call_f(i_profile,'403','Vendor balance too hight');
        RETURN i_profile;
    ELSIF i_dp.next_rate!=0 AND i_dp.next_interval!=0 THEN
        v_vendor_allowtime:=i_dp.initial_interval+
        LEAST(FLOOR(((i_vendor_acc.max_balance-i_vendor_acc.balance)-i_dp.connect_fee-i_dp.initial_rate/60*i_dp.initial_interval)/
        (i_dp.next_rate/60*i_dp.next_interval)),24e6)::integer*i_dp.next_interval;
    ELSE
        v_vendor_allowtime:=10800;
    end IF;

    i_profile.time_limit=LEAST(v_vendor_allowtime,v_customer_allowtime,10800)::integer;
    /* time limiting END */


    /* number rewriting _After_ routing */

    IF (i_dp.dst_rewrite_rule IS NOT NULL AND i_dp.dst_rewrite_rule!='') THEN
        i_profile.dst_prefix_out=regexp_replace(i_profile.dst_prefix_out,i_dp.dst_rewrite_rule,i_dp.dst_rewrite_result);
    END IF;

    IF (i_dp.src_rewrite_rule IS NOT NULL AND i_dp.src_rewrite_rule!='') THEN
        i_profile.src_prefix_out=regexp_replace(i_profile.src_prefix_out,i_dp.src_rewrite_rule,i_dp.src_rewrite_result);
    END IF;


    /*
        get termination gw data
    */
    --SELECT into v_dst_gw * from class4.gateways WHERE id=v_dialpeer.gateway_id;
    --SELECT into v_orig_gw * from class4.gateways WHERE id=v_customer_auth.gateway_id;
    --vendor gw
    i_profile.resources:=i_profile.resources||'5:'||i_vendor_gw.id::varchar||':'||i_vendor_gw.capacity::varchar||':1;';
    --customer gw
    i_profile.resources:=i_profile.resources||'4:'||i_customer_gw.id::varchar||':'||i_customer_gw.capacity::varchar||':1;';


    /* 
        number rewriting _After_ routing _IN_ termination GW
    */

    IF (i_vendor_gw.dst_rewrite_rule IS NOT NULL AND i_vendor_gw.dst_rewrite_rule!='') THEN
        i_profile.dst_prefix_out=regexp_replace(i_profile.dst_prefix_out,i_vendor_gw.dst_rewrite_rule,i_vendor_gw.dst_rewrite_result);
    END IF;

    IF (i_vendor_gw.src_rewrite_rule IS NOT NULL AND i_vendor_gw.src_rewrite_rule!='') THEN
        i_profile.src_prefix_out=regexp_replace(i_profile.src_prefix_out,i_vendor_gw.src_rewrite_rule,i_vendor_gw.src_rewrite_result);
    END IF;


    i_profile.anonymize_sdp:=i_vendor_gw.anonymize_sdp OR i_customer_gw.anonymize_sdp;

    i_profile.append_headers:='User-Agent: YETI SBC\r\n';
    i_profile.append_headers_req:=i_vendor_gw.term_append_headers_req;
    i_profile.aleg_append_headers_req=i_customer_gw.orig_append_headers_req;

    i_profile.enable_auth:=i_vendor_gw.term_auth_enabled;
    i_profile.auth_pwd:=i_vendor_gw.term_auth_pwd;
    i_profile.auth_user:=i_vendor_gw.term_auth_user;
    i_profile.enable_aleg_auth:=false;
    i_profile.auth_aleg_pwd:='';
    i_profile.auth_aleg_user:='';
    
    i_profile.next_hop_1st_req=i_vendor_gw.term_auth_enabled; -- use low delay dns srv if auth enabled
    i_profile.next_hop:=i_vendor_gw.term_next_hop;
    i_profile.aleg_next_hop:=i_customer_gw.orig_next_hop;
--    i_profile.next_hop_for_replies:=v_dst_gw.term_next_hop_for_replies;

    i_profile.dlg_nat_handling=i_customer_gw.dialog_nat_handling;
    i_profile.transparent_dlg_id=i_customer_gw.transparent_dialog_id;
    
    i_profile.call_id:=''; -- Generation by sems
    
    --i_profile."from":='$f';
    --i_profile."from":='<sip:'||i_profile.src_prefix_out||'@46.19.209.45>';
    i_profile."from":=COALESCE(i_profile.src_name_out||' ','')||'<sip:'||i_profile.src_prefix_out||'@$Oi>';
    
    i_profile."to":='<sip:'||i_profile.dst_prefix_out||'@'||i_vendor_gw.host::varchar||COALESCE(':'||i_vendor_gw.port||'>','>');
    i_profile.ruri:='sip:'||i_profile.dst_prefix_out||'@'||i_vendor_gw.host::varchar||COALESCE(':'||i_vendor_gw.port,'');
    i_profile.ruri_host:=i_vendor_gw.host::varchar||COALESCE(':'||i_vendor_gw.port,'');

    IF (i_vendor_gw.term_use_outbound_proxy ) THEN
        i_profile.outbound_proxy:='sip:'||i_vendor_gw.term_outbound_proxy;
        i_profile.force_outbound_proxy:=i_vendor_gw.term_force_outbound_proxy;
    ELSE
        i_profile.outbound_proxy:=NULL;
        i_profile.force_outbound_proxy:=false;
    END IF;

    IF (i_customer_gw.orig_use_outbound_proxy ) THEN
        i_profile.aleg_force_outbound_proxy:=i_customer_gw.orig_force_outbound_proxy;
        i_profile.aleg_outbound_proxy='sip:'||i_customer_gw.orig_outbound_proxy;
    else
        i_profile.aleg_force_outbound_proxy:=FALSE;
        i_profile.aleg_outbound_proxy=NULL;
    end if;

    i_profile.aleg_policy_id=i_customer_gw.orig_disconnect_policy_id;
    i_profile.bleg_policy_id=i_vendor_gw.term_disconnect_policy_id;

    --i_profile.header_filter_type_id:=i_vendor_gw.header_filter_type_id;
    --i_profile.header_filter_list:=i_vendor_gw.header_filter_list;
    i_profile.header_filter_type_id:='1'; -- blacklist TODO: Switch to whitelist and hardcode all transit headers;
    i_profile.header_filter_list:='X-Yeti-Auth,Diversion,X-UID,X-ORIG-IP,X-ORIG-PORT,User-Agent,X-Asterisk-HangupCause,X-Asterisk-HangupCauseCode';

    
    i_profile.message_filter_type_id:=i_vendor_gw.message_filter_type_id;
    i_profile.message_filter_list:=i_vendor_gw.message_filter_list;

    i_profile.sdp_filter_type_id:=i_vendor_gw.sdp_filter_type_id;
    i_profile.sdp_filter_list:=i_vendor_gw.sdp_filter_list;
    
    i_profile.sdp_alines_filter_type_id:=i_vendor_gw.sdp_alines_filter_type_id;
    i_profile.sdp_alines_filter_list:=i_vendor_gw.sdp_alines_filter_list;

    i_profile.enable_session_timer=i_vendor_gw.sst_enabled;
    i_profile.session_expires =i_vendor_gw.sst_session_expires;
    i_profile.minimum_timer:=i_vendor_gw.sst_minimum_timer;
    i_profile.maximum_timer:=i_vendor_gw.sst_maximum_timer;
    i_profile.session_refresh_method_id:=i_vendor_gw.session_refresh_method_id;
    i_profile.accept_501_reply:=i_vendor_gw.sst_accept501;
  
    i_profile.enable_aleg_session_timer=i_customer_gw.sst_enabled;
    i_profile.aleg_session_expires:=i_customer_gw.sst_session_expires;
    i_profile.aleg_minimum_timer:=i_customer_gw.sst_minimum_timer;
    i_profile.aleg_maximum_timer:=i_customer_gw.sst_maximum_timer;
    i_profile.aleg_session_refresh_method_id:=i_customer_gw.session_refresh_method_id;
    i_profile.aleg_accept_501_reply:=i_customer_gw.sst_accept501;
    
    i_profile.reply_translations:='';
    i_profile.disconnect_code_id:=NULL;
    i_profile.enable_rtprelay:=i_vendor_gw.proxy_media OR i_customer_gw.proxy_media;
    i_profile.rtprelay_transparent_seqno:=i_vendor_gw.transparent_seqno OR i_customer_gw.transparent_seqno;
    i_profile.rtprelay_transparent_ssrc:=i_vendor_gw.transparent_ssrc OR i_customer_gw.transparent_ssrc;

    i_profile.rtprelay_interface:='';
    i_profile.aleg_rtprelay_interface:='';

    i_profile.outbound_interface:='';
    i_profile.aleg_outbound_interface:='';
    
    i_profile.rtprelay_msgflags_symmetric_rtp:=false;
    i_profile.bleg_force_symmetric_rtp:=i_vendor_gw.force_symmetric_rtp;
    i_profile.aleg_force_symmetric_rtp:=i_customer_gw.force_symmetric_rtp;


    /* OBSOLETE variables:
      i_profile.codec_preference:=i_vendor_gw.codecs_payload_order;
      i_profile.codec_preference_aleg :=i_customer_gw.codecs_payload_order;
    
      i_profile.prefer_existing_codecs:=i_vendor_gw.prefer_existing_codecs;
      i_profile.prefer_existing_codecs_aleg:=i_customer_gw.prefer_existing_codecs;
    */
    
    
    i_profile.dtmf_transcoding:='always';-- always, lowfi_codec, never
    i_profile.lowfi_codecs:='';
    
    
    i_profile.enable_reg_caching=false;
    i_profile.min_reg_expires:='100500';
    i_profile.max_ua_expires:='100500';
    
    i_profile.aleg_codecs_group_id:=i_customer_gw.codec_group_id;
    i_profile.bleg_codecs_group_id:=i_vendor_gw.codec_group_id;
    i_profile.aleg_single_codec_in_200ok:=i_customer_gw.single_codec_in_200ok;
    i_profile.bleg_single_codec_in_200ok:=i_vendor_gw.single_codec_in_200ok;
    i_profile.ringing_timeout=i_vendor_gw.ringing_timeout;

    RETURN i_profile;
END;
$_$;


--
-- TOC entry 667 (class 1255 OID 18943)
-- Name: recompile_interface(integer); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION recompile_interface(i_version integer) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
v_attr record;
v_sql varchar;
BEGIN
    v_sql:='CREATE TYPE callprofile'||i_version::varchar||'_ty AS (';
    FOR v_attr IN SELECT * from load_interface_out() LOOP
        v_sql:=v_sql||'"'||v_attr.varname::varchar||'" '||v_attr.vartype||',';
    END LOOP;
    v_sql:=left(v_sql,-1)||')'; --removing last ',' added in loop and add )
    EXECUTE v_sql;
END;
$$;


--
-- TOC entry 677 (class 1255 OID 19021)
-- Name: route(integer, integer, inet, integer, inet, integer, character varying, character varying, character varying, integer, character varying, character varying, integer, character varying, character varying, integer, character varying, character varying, character varying, character varying, inet, integer); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION route(i_node_id integer, i_pop_id integer, i_remote_ip inet, i_remote_port integer, i_local_ip inet, i_local_port integer, i_from_dsp character varying, i_from_name character varying, i_from_domain character varying, i_from_port integer, i_to_name character varying, i_to_domain character varying, i_to_port integer, i_contact_name character varying, i_contact_domain character varying, i_contact_port integer, i_uri_name character varying, i_uri_domain character varying, i_x_yeti_auth character varying, i_diversion character varying, i_x_orig_ip inet, i_x_orig_port integer) RETURNS SETOF callprofile35_ty
    LANGUAGE plpgsql SECURITY DEFINER ROWS 10
    AS $$
DECLARE
v_ret switch1.callprofile35_ty;
i integer;
v_ip inet;
v_remote_ip inet;
v_remote_port INTEGER;
v_customer_auth record;
v_destination class4.destinations%rowtype;
v_dialpeer record;
v_dst_gw class4.gateways%rowtype;
v_orig_gw class4.gateways%rowtype;
v_rg class4.routing_groups%rowtype;
v_customer_allowtime real;
v_vendor_allowtime real;
v_sorting_id integer;
v_customer_acc integer;
v_route_found boolean:=false;
v_c_acc billing.accounts%rowtype;
v_v_acc billing.accounts%rowtype;
routedata record;
/*dbg{*/
    v_start timestamp;
    v_end timestamp;
/*}dbg*/
v_rate NUMERIC;
v_now timestamp;
v_x_yeti_auth varchar;
v_uri_domain varchar;
BEGIN
/*dbg{*/
    v_start:=now();
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> Execution start',EXTRACT(MILLISECOND from v_end-v_start);
/*}dbg*/

    IF i_x_orig_ip IS NULL OR i_x_orig_port IS NULL THEN
        v_remote_ip:=i_remote_ip;
        v_remote_port:=i_remote_port;
        /*dbg{*/RAISE NOTICE '% ms -> Got originator address "%:%" from switch leg info',EXTRACT(MILLISECOND from v_end-v_start), v_remote_ip,v_remote_port;/*}dbg*/
    ELSE
        v_remote_ip:=i_x_orig_ip;
        v_remote_port:=i_x_orig_port;
        /*dbg{*/RAISE NOTICE '% ms -> Got originator address "%:%" from x-headers',EXTRACT(MILLISECOND from v_end-v_start), v_remote_ip,v_remote_port;/*}dbg*/
    END IF;

    v_now:=now();
    v_ret:=switch1.new_profile();
    v_ret.cache_time = 10;

    v_ret.diversion_in:=i_diversion;
    v_ret.diversion_out:=i_diversion; -- FIXME

    v_ret.auth_orig_ip = v_remote_ip;
    v_ret.auth_orig_port = v_remote_port;
    
    v_ret.src_name_in:=i_from_dsp;
    v_ret.src_name_out:=i_from_dsp; --FIXME

    v_ret.src_prefix_in:=i_from_name;
    v_ret.dst_prefix_in:=i_uri_name;
    v_ret.dst_prefix_out:=v_ret.dst_prefix_in;
    v_ret.src_prefix_out:=v_ret.src_prefix_in;
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> AUTH. lookup started',EXTRACT(MILLISECOND from v_end-v_start);
/*}dbg*/
    v_x_yeti_auth:=COALESCE(i_x_yeti_auth,'');
    v_uri_domain:=COALESCE(i_uri_domain,'');
    SELECT into v_customer_auth ca.*,acc.origination_capacity as acc_capacity, acc.id as acc_id from class4.customers_auth ca
        JOIN billing.accounts acc
            ON acc.id=ca.account_id
        WHERE ca.enabled AND 
            ca.ip>>=v_remote_ip AND
            prefix_range(ca.dst_prefix)@>prefix_range(v_ret.dst_prefix_in) AND
            prefix_range(ca.src_prefix)@>prefix_range(v_ret.src_prefix_in) AND
            (ca.pop_id=i_pop_id or ca.pop_id is null) and
            COALESCE(ca.x_yeti_auth,'')=v_x_yeti_auth AND
            COALESCE(nullif(ca.uri_domain,'')=v_uri_domain,true) AND
            acc.balance-acc.min_balance>0
        ORDER BY masklen(ca.ip) DESC, length(ca.dst_prefix) DESC, length(ca.src_prefix) DESC
        LIMIT 1;
    IF NOT FOUND THEN
/*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> AUTH.  disconnection with 110.Cant find customer or customer locked',EXTRACT(MILLISECOND from v_end-v_start);
/*}dbg*/
        v_ret.disconnect_code_id=110; --Cant find customer or customer locked
        RETURN NEXT v_ret;
        RETURN;
    END IF;

        -- log_rtp log_sip dumplevel description (must be the same in UI)
    --   f      f        0        nothing
    --   f      t        1        only sip
    --   t      f        2        only rtp
    --   t      t        3        both

    v_ret.dump_level_id:=v_customer_auth.dump_level_id;
    
    v_ret.resources:=v_ret.resources||'1:'||v_customer_auth.acc_id::varchar||':'||v_customer_auth.acc_capacity::varchar||':1;';
    v_ret.resources:=v_ret.resources||'3:'||v_customer_auth.id::varchar||':'||v_customer_auth.capacity::varchar||':1;';
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> AUTH. found: %',EXTRACT(MILLISECOND from v_end-v_start),hstore(v_customer_auth);
/*}dbg*/
    -- feel customer data
    v_ret.customer_auth_id:=v_customer_auth.id;
    v_ret.customer_id:=v_customer_auth.customer_id;
    v_ret.rateplan_id:=v_customer_auth.rateplan_id;
    v_ret.routing_group_id:=v_customer_auth.routing_group_id;
    v_ret.customer_acc_id:=v_customer_auth.account_id;
    v_ret.orig_gw_id:=v_customer_auth.gateway_id;

    SELECT INTO STRICT v_c_acc * FROM billing.accounts  WHERE id=v_customer_auth.account_id;
    SELECT into v_orig_gw * from class4.gateways WHERE id=v_customer_auth.gateway_id;

   
    /* 
        number rewriting _Before_ routing
    */
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> AUTH. Before rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.src_prefix_out,v_ret.dst_prefix_out;
/*}dbg*/
    IF (v_customer_auth.dst_rewrite_rule IS NOT NULL AND v_customer_auth.dst_rewrite_rule!='') THEN
        v_ret.dst_prefix_out=regexp_replace(v_ret.dst_prefix_out,v_customer_auth.dst_rewrite_rule,v_customer_auth.dst_rewrite_result);
    END IF;

    IF (v_customer_auth.src_rewrite_rule IS NOT NULL AND v_customer_auth.src_rewrite_rule!='') THEN
        v_ret.src_prefix_out=regexp_replace(v_ret.src_prefix_out,v_customer_auth.src_rewrite_rule,v_customer_auth.src_rewrite_result);
    END IF;
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> AUTH. After rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.src_prefix_out,v_ret.dst_prefix_out;
/*}dbg*/


--- Blacklist processing
    if v_customer_auth.dst_blacklist_id is not null then
        perform * from class4.blacklist_items bl 
        where bl.blacklist_id=v_customer_auth.dst_blacklist_id and bl.key=v_ret.dst_prefix_out;
        IF FOUND then
            v_ret.disconnect_code_id=115; --destination blacklisted
            RETURN NEXT v_ret;
            RETURN;
        end if;
    end if;
    if v_customer_auth.src_blacklist_id is not null then
        perform * from class4.blacklist_items bl 
        where bl.blacklist_id=v_customer_auth.src_blacklist_id and bl.key=v_ret.src_prefix_out;
        IF FOUND then
            v_ret.disconnect_code_id=116; --source blacklisted
            RETURN NEXT v_ret;
            RETURN;
        end if;
    end if;

/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> DST. search start',EXTRACT(MILLISECOND from v_end-v_start);
/*}dbg*/
    SELECT into v_destination d.*/*,switch.tracelog(d.*)*/ from class4.destinations d
    WHERE 
        prefix_range(prefix)@>prefix_range(v_ret.dst_prefix_out)
        AND rateplan_id=v_customer_auth.rateplan_id
        AND enabled
    ORDER BY length(prefix) DESC limit 1;
    IF NOT FOUND THEN
/*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> DST.  Destination not found',EXTRACT(MILLISECOND from v_end-v_start);
/*}dbg*/
        v_ret.disconnect_code_id=111; --Cant find destination prefix
        RETURN NEXT v_ret;
        RETURN;
    END IF;
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> DST. found: %',EXTRACT(MILLISECOND from v_end-v_start),hstore(v_destination);
/*}dbg*/
    v_ret.destination_id:=v_destination.id;
    v_ret.destination_initial_interval:=v_destination.initial_interval;
    v_ret.destination_fee:=v_destination.connect_fee::varchar;
    v_ret.destination_next_interval:=v_destination.next_interval;
    v_ret.destination_rate_policy_id:=v_destination.rate_policy_id;
    IF v_destination.reject_calls THEN
        v_ret.disconnect_code_id=112; --Rejected by destination
        RETURN NEXT v_ret;
        RETURN;
    END IF;

    /* 
                FIND dialpeers logic. Queries must use prefix index for best performance
    */
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> DP. search start',EXTRACT(MILLISECOND from v_end-v_start);
/*}dbg*/
    SELECT INTO v_rg * from class4.routing_groups WHERE id=v_customer_auth.routing_group_id;
    CASE v_rg.sorting_id
        WHEN'1' THEN -- LCR,Prio, ACD&ASR control
            IF v_rg.more_specific_per_vendor THEN
                FOR routedata IN (
                    WITH step1 AS(
                        SELECT
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            t_dp.priority as dp_next_rate,
                            t_dp.lcr_rate_multiplier AS dp_lcr_rate_multiplier,
                            t_dp.priority AS dp_priority,
                            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id = t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                            AND NOT t_dp.locked --ACD&ASR control for DP
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    from step1
                    WHERE r=1
                    ORDER BY dp_next_rate*dp_lcr_rate_multiplier, dp_priority DESC limit 10
                ) LOOP
                    RETURN QUERY 
                    /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}rel*/
                    /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}dbg*/
                end LOOP;
            ELSE
                FOR routedata IN (
                    WITH step1 AS(
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            t_dp.priority as dp_next_rate,
                            t_dp.lcr_rate_multiplier AS dp_lcr_rate_multiplier,
                            t_dp.priority AS dp_priority,
                            rank() OVER (PARTITION BY length(t_dp.prefix) ORDER BY length(t_dp.prefix) desc) as r
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id = t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                            AND NOT t_dp.locked --ACD&ASR control for DP
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    from step1
                    WHERE r=1
                    ORDER BY dp_next_rate*dp_lcr_rate_multiplier, dp_priority DESC limit 10
                ) LOOP
                RETURN QUERY 
                    /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}rel*/
                    /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}dbg*/
                end loop;
           END IF;
        WHEN '2' THEN --LCR, no prio, No ACD&ASR control
            IF v_rg.more_specific_per_vendor THEN
                FOR routedata IN (
                    WITH step1 AS( -- filtering
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_gateway.*)::class4.gateways as s1_vendor_gateway,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r,
                            t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    FROM step1
                    WHERE r=1
                    ORDER BY dp_metric limit 10
                ) LOOP
                    RETURN QUERY 
                    /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}rel*/
                    /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}dbg*/
                END LOOP;
            ELSE
                FOR routedata IN (
                     WITH step1 AS( -- filtering
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            rank() OVER (PARTITION BY length(t_dp.prefix) ORDER BY length(t_dp.prefix) desc) as r,
                            t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    FROM step1
                    WHERE r=1
                    ORDER BY dp_metric limit 10
                ) LOOp
                    RETURN QUERY 
                    /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}rel*/
                    /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}dbg*/
                end loop;
            END IF;
        WHEN '3' THEN --Prio, LCR, ACD&ASR control
            IF v_rg.more_specific_per_vendor THEN
                FOR routedata in(
                    WITH step1 AS( -- filtering
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r,
                            t_dp.priority as dp_metric_priority,
                            t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                            AND NOT t_dp.locked --ACD&ASR control for DP
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    FROM step1
                    WHERE r=1
                    ORDER BY dp_metric_priority DESC, dp_metric limit 10
                )LOOP
                    RETURN QUERY 
                    /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}rel*/
                    /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}dbg*/
                END LOOP;
            ELSE
               FOR routedata IN (
                    WITH step1 AS( -- filtering
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_gateway.*)::class4.gateways as s1_vendor_gateway,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            rank() OVER (PARTITION BY length(t_dp.prefix) ORDER BY length(t_dp.prefix) desc) as r,
                            t_dp.priority as dp_metric_priority,
                            t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                            AND NOT t_dp.locked --ACD&ASR control for DP
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    FROM step1
                    WHERE r=1
                    ORDER BY dp_metric_priority DESC, dp_metric limit 10
                ) LOOp
                    RETURN QUERY 
                    /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}rel*/
                    /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}dbg*/
                end loop;
            END IF;
        WHEN'4' THEN -- LCRD, Prio, ACD&ACR control
            IF v_rg.more_specific_per_vendor THEN
                FOR routedata IN (
                    WITH step1 AS(
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r,  
                            ((t_dp.next_rate - first_value(t_dp.next_rate) OVER(ORDER BY t_dp.next_rate ASC)) > v_rg.rate_delta_max)::INTEGER *(t_dp.next_rate + t_dp.priority) - t_dp.priority AS r2
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id = t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                            AND NOT t_dp.locked --ACD&ASR control for DP
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    from step1
                    WHERE r=1
                    ORDER BY r2 ASC limit 10
                ) LOOP
                    RETURN QUERY 
                    /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}rel*/
                    /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}dbg*/
                end LOOP;
            ELSE
                FOR routedata IN (
                    WITH step1 AS(
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            rank() OVER (PARTITION BY length(t_dp.prefix) ORDER BY length(t_dp.prefix) desc) as r,
                            ((t_dp.next_rate - first_value(t_dp.next_rate) OVER(ORDER BY t_dp.next_rate ASC)) > v_rg.rate_delta_max)::INTEGER *(t_dp.next_rate + t_dp.priority) - t_dp.priority AS r2
                        from class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id = t_vendor_account.id
                        WHERE 
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                            AND NOT t_dp.locked --ACD&ASR control for DP
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    FROM step1
                    WHERE r=1
                    oRDER BY r2 ASC LIMIT 10
                ) LOOP
                RETURN QUERY 
                    /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}rel*/
                    /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}dbg*/
                end loop;
           END IF;
        ELSE
                RAISE NOTICE 'BUG: unknown sorting_id';
        END CASE;
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> Dialpeer search done',EXTRACT(MILLISECOND from v_end-v_start);
/*}dbg*/
    v_ret.disconnect_code_id=113; --No routes
    RETURN NEXT v_ret;
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> DONE.',EXTRACT(MILLISECOND from v_end-v_start);
/*}dbg*/
    RETURN;
END;
$$;


--
-- TOC entry 678 (class 1255 OID 19040)
-- Name: route_debug(integer, integer, inet, integer, inet, integer, character varying, character varying, character varying, integer, character varying, character varying, integer, character varying, character varying, integer, character varying, character varying, character varying, character varying, inet, integer); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION route_debug(i_node_id integer, i_pop_id integer, i_remote_ip inet, i_remote_port integer, i_local_ip inet, i_local_port integer, i_from_dsp character varying, i_from_name character varying, i_from_domain character varying, i_from_port integer, i_to_name character varying, i_to_domain character varying, i_to_port integer, i_contact_name character varying, i_contact_domain character varying, i_contact_port integer, i_uri_name character varying, i_uri_domain character varying, i_x_yeti_auth character varying, i_diversion character varying, i_x_orig_ip inet, i_x_orig_port integer) RETURNS SETOF callprofile35_ty
    LANGUAGE plpgsql SECURITY DEFINER ROWS 10
    AS $$
DECLARE
v_ret switch1.callprofile35_ty;
i integer;
v_ip inet;
v_remote_ip inet;
v_remote_port INTEGER;
v_customer_auth record;
v_destination class4.destinations%rowtype;
v_dialpeer record;
v_dst_gw class4.gateways%rowtype;
v_orig_gw class4.gateways%rowtype;
v_rg class4.routing_groups%rowtype;
v_customer_allowtime real;
v_vendor_allowtime real;
v_sorting_id integer;
v_customer_acc integer;
v_route_found boolean:=false;
v_c_acc billing.accounts%rowtype;
v_v_acc billing.accounts%rowtype;
routedata record;
/*dbg{*/
    v_start timestamp;
    v_end timestamp;
/*}dbg*/
v_rate NUMERIC;
v_now timestamp;
v_x_yeti_auth varchar;
v_uri_domain varchar;
BEGIN
/*dbg{*/
    v_start:=now();
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> Execution start',EXTRACT(MILLISECOND from v_end-v_start);
/*}dbg*/

    IF i_x_orig_ip IS NULL OR i_x_orig_port IS NULL THEN
        v_remote_ip:=i_remote_ip;
        v_remote_port:=i_remote_port;
        /*dbg{*/RAISE NOTICE '% ms -> Got originator address "%:%" from switch leg info',EXTRACT(MILLISECOND from v_end-v_start), v_remote_ip,v_remote_port;/*}dbg*/
    ELSE
        v_remote_ip:=i_x_orig_ip;
        v_remote_port:=i_x_orig_port;
        /*dbg{*/RAISE NOTICE '% ms -> Got originator address "%:%" from x-headers',EXTRACT(MILLISECOND from v_end-v_start), v_remote_ip,v_remote_port;/*}dbg*/
    END IF;

    v_now:=now();
    v_ret:=switch1.new_profile();
    v_ret.cache_time = 10;

    v_ret.diversion_in:=i_diversion;
    v_ret.diversion_out:=i_diversion; -- FIXME

    v_ret.auth_orig_ip = v_remote_ip;
    v_ret.auth_orig_port = v_remote_port;
    
    v_ret.src_name_in:=i_from_dsp;
    v_ret.src_name_out:=i_from_dsp; --FIXME

    v_ret.src_prefix_in:=i_from_name;
    v_ret.dst_prefix_in:=i_uri_name;
    v_ret.dst_prefix_out:=v_ret.dst_prefix_in;
    v_ret.src_prefix_out:=v_ret.src_prefix_in;
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> AUTH. lookup started',EXTRACT(MILLISECOND from v_end-v_start);
/*}dbg*/
    v_x_yeti_auth:=COALESCE(i_x_yeti_auth,'');
    v_uri_domain:=COALESCE(i_uri_domain,'');
    SELECT into v_customer_auth ca.*,acc.origination_capacity as acc_capacity, acc.id as acc_id from class4.customers_auth ca
        JOIN billing.accounts acc
            ON acc.id=ca.account_id
        WHERE ca.enabled AND 
            ca.ip>>=v_remote_ip AND
            prefix_range(ca.dst_prefix)@>prefix_range(v_ret.dst_prefix_in) AND
            prefix_range(ca.src_prefix)@>prefix_range(v_ret.src_prefix_in) AND
            (ca.pop_id=i_pop_id or ca.pop_id is null) and
            COALESCE(ca.x_yeti_auth,'')=v_x_yeti_auth AND
            COALESCE(nullif(ca.uri_domain,'')=v_uri_domain,true) AND
            acc.balance-acc.min_balance>0
        ORDER BY masklen(ca.ip) DESC, length(ca.dst_prefix) DESC, length(ca.src_prefix) DESC
        LIMIT 1;
    IF NOT FOUND THEN
/*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> AUTH.  disconnection with 110.Cant find customer or customer locked',EXTRACT(MILLISECOND from v_end-v_start);
/*}dbg*/
        v_ret.disconnect_code_id=110; --Cant find customer or customer locked
        RETURN NEXT v_ret;
        RETURN;
    END IF;

        -- log_rtp log_sip dumplevel description (must be the same in UI)
    --   f      f        0        nothing
    --   f      t        1        only sip
    --   t      f        2        only rtp
    --   t      t        3        both

    v_ret.dump_level_id:=v_customer_auth.dump_level_id;
    
    v_ret.resources:=v_ret.resources||'1:'||v_customer_auth.acc_id::varchar||':'||v_customer_auth.acc_capacity::varchar||':1;';
    v_ret.resources:=v_ret.resources||'3:'||v_customer_auth.id::varchar||':'||v_customer_auth.capacity::varchar||':1;';
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> AUTH. found: %',EXTRACT(MILLISECOND from v_end-v_start),hstore(v_customer_auth);
/*}dbg*/
    -- feel customer data
    v_ret.customer_auth_id:=v_customer_auth.id;
    v_ret.customer_id:=v_customer_auth.customer_id;
    v_ret.rateplan_id:=v_customer_auth.rateplan_id;
    v_ret.routing_group_id:=v_customer_auth.routing_group_id;
    v_ret.customer_acc_id:=v_customer_auth.account_id;
    v_ret.orig_gw_id:=v_customer_auth.gateway_id;

    SELECT INTO STRICT v_c_acc * FROM billing.accounts  WHERE id=v_customer_auth.account_id;
    SELECT into v_orig_gw * from class4.gateways WHERE id=v_customer_auth.gateway_id;

   
    /* 
        number rewriting _Before_ routing
    */
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> AUTH. Before rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.src_prefix_out,v_ret.dst_prefix_out;
/*}dbg*/
    IF (v_customer_auth.dst_rewrite_rule IS NOT NULL AND v_customer_auth.dst_rewrite_rule!='') THEN
        v_ret.dst_prefix_out=regexp_replace(v_ret.dst_prefix_out,v_customer_auth.dst_rewrite_rule,v_customer_auth.dst_rewrite_result);
    END IF;

    IF (v_customer_auth.src_rewrite_rule IS NOT NULL AND v_customer_auth.src_rewrite_rule!='') THEN
        v_ret.src_prefix_out=regexp_replace(v_ret.src_prefix_out,v_customer_auth.src_rewrite_rule,v_customer_auth.src_rewrite_result);
    END IF;
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> AUTH. After rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.src_prefix_out,v_ret.dst_prefix_out;
/*}dbg*/


--- Blacklist processing
    if v_customer_auth.dst_blacklist_id is not null then
        perform * from class4.blacklist_items bl 
        where bl.blacklist_id=v_customer_auth.dst_blacklist_id and bl.key=v_ret.dst_prefix_out;
        IF FOUND then
            v_ret.disconnect_code_id=115; --destination blacklisted
            RETURN NEXT v_ret;
            RETURN;
        end if;
    end if;
    if v_customer_auth.src_blacklist_id is not null then
        perform * from class4.blacklist_items bl 
        where bl.blacklist_id=v_customer_auth.src_blacklist_id and bl.key=v_ret.src_prefix_out;
        IF FOUND then
            v_ret.disconnect_code_id=116; --source blacklisted
            RETURN NEXT v_ret;
            RETURN;
        end if;
    end if;

/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> DST. search start',EXTRACT(MILLISECOND from v_end-v_start);
/*}dbg*/
    SELECT into v_destination d.*/*,switch.tracelog(d.*)*/ from class4.destinations d
    WHERE 
        prefix_range(prefix)@>prefix_range(v_ret.dst_prefix_out)
        AND rateplan_id=v_customer_auth.rateplan_id
        AND enabled
    ORDER BY length(prefix) DESC limit 1;
    IF NOT FOUND THEN
/*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> DST.  Destination not found',EXTRACT(MILLISECOND from v_end-v_start);
/*}dbg*/
        v_ret.disconnect_code_id=111; --Cant find destination prefix
        RETURN NEXT v_ret;
        RETURN;
    END IF;
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> DST. found: %',EXTRACT(MILLISECOND from v_end-v_start),hstore(v_destination);
/*}dbg*/
    v_ret.destination_id:=v_destination.id;
    v_ret.destination_initial_interval:=v_destination.initial_interval;
    v_ret.destination_fee:=v_destination.connect_fee::varchar;
    v_ret.destination_next_interval:=v_destination.next_interval;
    v_ret.destination_rate_policy_id:=v_destination.rate_policy_id;
    IF v_destination.reject_calls THEN
        v_ret.disconnect_code_id=112; --Rejected by destination
        RETURN NEXT v_ret;
        RETURN;
    END IF;

    /* 
                FIND dialpeers logic. Queries must use prefix index for best performance
    */
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> DP. search start',EXTRACT(MILLISECOND from v_end-v_start);
/*}dbg*/
    SELECT INTO v_rg * from class4.routing_groups WHERE id=v_customer_auth.routing_group_id;
    CASE v_rg.sorting_id
        WHEN'1' THEN -- LCR,Prio, ACD&ASR control
            IF v_rg.more_specific_per_vendor THEN
                FOR routedata IN (
                    WITH step1 AS(
                        SELECT
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            t_dp.priority as dp_next_rate,
                            t_dp.lcr_rate_multiplier AS dp_lcr_rate_multiplier,
                            t_dp.priority AS dp_priority,
                            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id = t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                            AND NOT t_dp.locked --ACD&ASR control for DP
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    from step1
                    WHERE r=1
                    ORDER BY dp_next_rate*dp_lcr_rate_multiplier, dp_priority DESC limit 10
                ) LOOP
                    RETURN QUERY 
                    
                    /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}dbg*/
                end LOOP;
            ELSE
                FOR routedata IN (
                    WITH step1 AS(
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            t_dp.priority as dp_next_rate,
                            t_dp.lcr_rate_multiplier AS dp_lcr_rate_multiplier,
                            t_dp.priority AS dp_priority,
                            rank() OVER (PARTITION BY length(t_dp.prefix) ORDER BY length(t_dp.prefix) desc) as r
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id = t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                            AND NOT t_dp.locked --ACD&ASR control for DP
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    from step1
                    WHERE r=1
                    ORDER BY dp_next_rate*dp_lcr_rate_multiplier, dp_priority DESC limit 10
                ) LOOP
                RETURN QUERY 
                    
                    /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}dbg*/
                end loop;
           END IF;
        WHEN '2' THEN --LCR, no prio, No ACD&ASR control
            IF v_rg.more_specific_per_vendor THEN
                FOR routedata IN (
                    WITH step1 AS( -- filtering
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_gateway.*)::class4.gateways as s1_vendor_gateway,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r,
                            t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    FROM step1
                    WHERE r=1
                    ORDER BY dp_metric limit 10
                ) LOOP
                    RETURN QUERY 
                    
                    /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}dbg*/
                END LOOP;
            ELSE
                FOR routedata IN (
                     WITH step1 AS( -- filtering
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            rank() OVER (PARTITION BY length(t_dp.prefix) ORDER BY length(t_dp.prefix) desc) as r,
                            t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    FROM step1
                    WHERE r=1
                    ORDER BY dp_metric limit 10
                ) LOOp
                    RETURN QUERY 
                    
                    /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}dbg*/
                end loop;
            END IF;
        WHEN '3' THEN --Prio, LCR, ACD&ASR control
            IF v_rg.more_specific_per_vendor THEN
                FOR routedata in(
                    WITH step1 AS( -- filtering
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r,
                            t_dp.priority as dp_metric_priority,
                            t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                            AND NOT t_dp.locked --ACD&ASR control for DP
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    FROM step1
                    WHERE r=1
                    ORDER BY dp_metric_priority DESC, dp_metric limit 10
                )LOOP
                    RETURN QUERY 
                    
                    /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}dbg*/
                END LOOP;
            ELSE
               FOR routedata IN (
                    WITH step1 AS( -- filtering
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_gateway.*)::class4.gateways as s1_vendor_gateway,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            rank() OVER (PARTITION BY length(t_dp.prefix) ORDER BY length(t_dp.prefix) desc) as r,
                            t_dp.priority as dp_metric_priority,
                            t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                            AND NOT t_dp.locked --ACD&ASR control for DP
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    FROM step1
                    WHERE r=1
                    ORDER BY dp_metric_priority DESC, dp_metric limit 10
                ) LOOp
                    RETURN QUERY 
                    
                    /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}dbg*/
                end loop;
            END IF;
        WHEN'4' THEN -- LCRD, Prio, ACD&ACR control
            IF v_rg.more_specific_per_vendor THEN
                FOR routedata IN (
                    WITH step1 AS(
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r,  
                            ((t_dp.next_rate - first_value(t_dp.next_rate) OVER(ORDER BY t_dp.next_rate ASC)) > v_rg.rate_delta_max)::INTEGER *(t_dp.next_rate + t_dp.priority) - t_dp.priority AS r2
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id = t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                            AND NOT t_dp.locked --ACD&ASR control for DP
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    from step1
                    WHERE r=1
                    ORDER BY r2 ASC limit 10
                ) LOOP
                    RETURN QUERY 
                    
                    /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}dbg*/
                end LOOP;
            ELSE
                FOR routedata IN (
                    WITH step1 AS(
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            rank() OVER (PARTITION BY length(t_dp.prefix) ORDER BY length(t_dp.prefix) desc) as r,
                            ((t_dp.next_rate - first_value(t_dp.next_rate) OVER(ORDER BY t_dp.next_rate ASC)) > v_rg.rate_delta_max)::INTEGER *(t_dp.next_rate + t_dp.priority) - t_dp.priority AS r2
                        from class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id = t_vendor_account.id
                        WHERE 
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                            AND NOT t_dp.locked --ACD&ASR control for DP
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    FROM step1
                    WHERE r=1
                    oRDER BY r2 ASC LIMIT 10
                ) LOOP
                RETURN QUERY 
                    
                    /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}dbg*/
                end loop;
           END IF;
        ELSE
                RAISE NOTICE 'BUG: unknown sorting_id';
        END CASE;
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> Dialpeer search done',EXTRACT(MILLISECOND from v_end-v_start);
/*}dbg*/
    v_ret.disconnect_code_id=113; --No routes
    RETURN NEXT v_ret;
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> DONE.',EXTRACT(MILLISECOND from v_end-v_start);
/*}dbg*/
    RETURN;
END;
$$;


--
-- TOC entry 679 (class 1255 OID 19042)
-- Name: route_release(integer, integer, inet, integer, inet, integer, character varying, character varying, character varying, integer, character varying, character varying, integer, character varying, character varying, integer, character varying, character varying, character varying, character varying, inet, integer); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION route_release(i_node_id integer, i_pop_id integer, i_remote_ip inet, i_remote_port integer, i_local_ip inet, i_local_port integer, i_from_dsp character varying, i_from_name character varying, i_from_domain character varying, i_from_port integer, i_to_name character varying, i_to_domain character varying, i_to_port integer, i_contact_name character varying, i_contact_domain character varying, i_contact_port integer, i_uri_name character varying, i_uri_domain character varying, i_x_yeti_auth character varying, i_diversion character varying, i_x_orig_ip inet, i_x_orig_port integer) RETURNS SETOF callprofile35_ty
    LANGUAGE plpgsql SECURITY DEFINER ROWS 10
    AS $$
DECLARE
v_ret switch1.callprofile35_ty;
i integer;
v_ip inet;
v_remote_ip inet;
v_remote_port INTEGER;
v_customer_auth record;
v_destination class4.destinations%rowtype;
v_dialpeer record;
v_dst_gw class4.gateways%rowtype;
v_orig_gw class4.gateways%rowtype;
v_rg class4.routing_groups%rowtype;
v_customer_allowtime real;
v_vendor_allowtime real;
v_sorting_id integer;
v_customer_acc integer;
v_route_found boolean:=false;
v_c_acc billing.accounts%rowtype;
v_v_acc billing.accounts%rowtype;
routedata record;

v_rate NUMERIC;
v_now timestamp;
v_x_yeti_auth varchar;
v_uri_domain varchar;
BEGIN


    IF i_x_orig_ip IS NULL OR i_x_orig_port IS NULL THEN
        v_remote_ip:=i_remote_ip;
        v_remote_port:=i_remote_port;
        
    ELSE
        v_remote_ip:=i_x_orig_ip;
        v_remote_port:=i_x_orig_port;
        
    END IF;

    v_now:=now();
    v_ret:=switch1.new_profile();
    v_ret.cache_time = 10;

    v_ret.diversion_in:=i_diversion;
    v_ret.diversion_out:=i_diversion; -- FIXME

    v_ret.auth_orig_ip = v_remote_ip;
    v_ret.auth_orig_port = v_remote_port;
    
    v_ret.src_name_in:=i_from_dsp;
    v_ret.src_name_out:=i_from_dsp; --FIXME

    v_ret.src_prefix_in:=i_from_name;
    v_ret.dst_prefix_in:=i_uri_name;
    v_ret.dst_prefix_out:=v_ret.dst_prefix_in;
    v_ret.src_prefix_out:=v_ret.src_prefix_in;

    v_x_yeti_auth:=COALESCE(i_x_yeti_auth,'');
    v_uri_domain:=COALESCE(i_uri_domain,'');
    SELECT into v_customer_auth ca.*,acc.origination_capacity as acc_capacity, acc.id as acc_id from class4.customers_auth ca
        JOIN billing.accounts acc
            ON acc.id=ca.account_id
        WHERE ca.enabled AND 
            ca.ip>>=v_remote_ip AND
            prefix_range(ca.dst_prefix)@>prefix_range(v_ret.dst_prefix_in) AND
            prefix_range(ca.src_prefix)@>prefix_range(v_ret.src_prefix_in) AND
            (ca.pop_id=i_pop_id or ca.pop_id is null) and
            COALESCE(ca.x_yeti_auth,'')=v_x_yeti_auth AND
            COALESCE(nullif(ca.uri_domain,'')=v_uri_domain,true) AND
            acc.balance-acc.min_balance>0
        ORDER BY masklen(ca.ip) DESC, length(ca.dst_prefix) DESC, length(ca.src_prefix) DESC
        LIMIT 1;
    IF NOT FOUND THEN

        v_ret.disconnect_code_id=110; --Cant find customer or customer locked
        RETURN NEXT v_ret;
        RETURN;
    END IF;

        -- log_rtp log_sip dumplevel description (must be the same in UI)
    --   f      f        0        nothing
    --   f      t        1        only sip
    --   t      f        2        only rtp
    --   t      t        3        both

    v_ret.dump_level_id:=v_customer_auth.dump_level_id;
    
    v_ret.resources:=v_ret.resources||'1:'||v_customer_auth.acc_id::varchar||':'||v_customer_auth.acc_capacity::varchar||':1;';
    v_ret.resources:=v_ret.resources||'3:'||v_customer_auth.id::varchar||':'||v_customer_auth.capacity::varchar||':1;';

    -- feel customer data
    v_ret.customer_auth_id:=v_customer_auth.id;
    v_ret.customer_id:=v_customer_auth.customer_id;
    v_ret.rateplan_id:=v_customer_auth.rateplan_id;
    v_ret.routing_group_id:=v_customer_auth.routing_group_id;
    v_ret.customer_acc_id:=v_customer_auth.account_id;
    v_ret.orig_gw_id:=v_customer_auth.gateway_id;

    SELECT INTO STRICT v_c_acc * FROM billing.accounts  WHERE id=v_customer_auth.account_id;
    SELECT into v_orig_gw * from class4.gateways WHERE id=v_customer_auth.gateway_id;

   
    /* 
        number rewriting _Before_ routing
    */

    IF (v_customer_auth.dst_rewrite_rule IS NOT NULL AND v_customer_auth.dst_rewrite_rule!='') THEN
        v_ret.dst_prefix_out=regexp_replace(v_ret.dst_prefix_out,v_customer_auth.dst_rewrite_rule,v_customer_auth.dst_rewrite_result);
    END IF;

    IF (v_customer_auth.src_rewrite_rule IS NOT NULL AND v_customer_auth.src_rewrite_rule!='') THEN
        v_ret.src_prefix_out=regexp_replace(v_ret.src_prefix_out,v_customer_auth.src_rewrite_rule,v_customer_auth.src_rewrite_result);
    END IF;



--- Blacklist processing
    if v_customer_auth.dst_blacklist_id is not null then
        perform * from class4.blacklist_items bl 
        where bl.blacklist_id=v_customer_auth.dst_blacklist_id and bl.key=v_ret.dst_prefix_out;
        IF FOUND then
            v_ret.disconnect_code_id=115; --destination blacklisted
            RETURN NEXT v_ret;
            RETURN;
        end if;
    end if;
    if v_customer_auth.src_blacklist_id is not null then
        perform * from class4.blacklist_items bl 
        where bl.blacklist_id=v_customer_auth.src_blacklist_id and bl.key=v_ret.src_prefix_out;
        IF FOUND then
            v_ret.disconnect_code_id=116; --source blacklisted
            RETURN NEXT v_ret;
            RETURN;
        end if;
    end if;


    SELECT into v_destination d.*/*,switch.tracelog(d.*)*/ from class4.destinations d
    WHERE 
        prefix_range(prefix)@>prefix_range(v_ret.dst_prefix_out)
        AND rateplan_id=v_customer_auth.rateplan_id
        AND enabled
    ORDER BY length(prefix) DESC limit 1;
    IF NOT FOUND THEN

        v_ret.disconnect_code_id=111; --Cant find destination prefix
        RETURN NEXT v_ret;
        RETURN;
    END IF;

    v_ret.destination_id:=v_destination.id;
    v_ret.destination_initial_interval:=v_destination.initial_interval;
    v_ret.destination_fee:=v_destination.connect_fee::varchar;
    v_ret.destination_next_interval:=v_destination.next_interval;
    v_ret.destination_rate_policy_id:=v_destination.rate_policy_id;
    IF v_destination.reject_calls THEN
        v_ret.disconnect_code_id=112; --Rejected by destination
        RETURN NEXT v_ret;
        RETURN;
    END IF;

    /* 
                FIND dialpeers logic. Queries must use prefix index for best performance
    */

    SELECT INTO v_rg * from class4.routing_groups WHERE id=v_customer_auth.routing_group_id;
    CASE v_rg.sorting_id
        WHEN'1' THEN -- LCR,Prio, ACD&ASR control
            IF v_rg.more_specific_per_vendor THEN
                FOR routedata IN (
                    WITH step1 AS(
                        SELECT
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            t_dp.priority as dp_next_rate,
                            t_dp.lcr_rate_multiplier AS dp_lcr_rate_multiplier,
                            t_dp.priority AS dp_priority,
                            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id = t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                            AND NOT t_dp.locked --ACD&ASR control for DP
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    from step1
                    WHERE r=1
                    ORDER BY dp_next_rate*dp_lcr_rate_multiplier, dp_priority DESC limit 10
                ) LOOP
                    RETURN QUERY 
                    /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}rel*/
                    
                end LOOP;
            ELSE
                FOR routedata IN (
                    WITH step1 AS(
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            t_dp.priority as dp_next_rate,
                            t_dp.lcr_rate_multiplier AS dp_lcr_rate_multiplier,
                            t_dp.priority AS dp_priority,
                            rank() OVER (PARTITION BY length(t_dp.prefix) ORDER BY length(t_dp.prefix) desc) as r
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id = t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                            AND NOT t_dp.locked --ACD&ASR control for DP
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    from step1
                    WHERE r=1
                    ORDER BY dp_next_rate*dp_lcr_rate_multiplier, dp_priority DESC limit 10
                ) LOOP
                RETURN QUERY 
                    /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}rel*/
                    
                end loop;
           END IF;
        WHEN '2' THEN --LCR, no prio, No ACD&ASR control
            IF v_rg.more_specific_per_vendor THEN
                FOR routedata IN (
                    WITH step1 AS( -- filtering
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_gateway.*)::class4.gateways as s1_vendor_gateway,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r,
                            t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    FROM step1
                    WHERE r=1
                    ORDER BY dp_metric limit 10
                ) LOOP
                    RETURN QUERY 
                    /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}rel*/
                    
                END LOOP;
            ELSE
                FOR routedata IN (
                     WITH step1 AS( -- filtering
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            rank() OVER (PARTITION BY length(t_dp.prefix) ORDER BY length(t_dp.prefix) desc) as r,
                            t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    FROM step1
                    WHERE r=1
                    ORDER BY dp_metric limit 10
                ) LOOp
                    RETURN QUERY 
                    /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}rel*/
                    
                end loop;
            END IF;
        WHEN '3' THEN --Prio, LCR, ACD&ASR control
            IF v_rg.more_specific_per_vendor THEN
                FOR routedata in(
                    WITH step1 AS( -- filtering
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r,
                            t_dp.priority as dp_metric_priority,
                            t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                            AND NOT t_dp.locked --ACD&ASR control for DP
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    FROM step1
                    WHERE r=1
                    ORDER BY dp_metric_priority DESC, dp_metric limit 10
                )LOOP
                    RETURN QUERY 
                    /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}rel*/
                    
                END LOOP;
            ELSE
               FOR routedata IN (
                    WITH step1 AS( -- filtering
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_gateway.*)::class4.gateways as s1_vendor_gateway,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            rank() OVER (PARTITION BY length(t_dp.prefix) ORDER BY length(t_dp.prefix) desc) as r,
                            t_dp.priority as dp_metric_priority,
                            t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                            AND NOT t_dp.locked --ACD&ASR control for DP
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    FROM step1
                    WHERE r=1
                    ORDER BY dp_metric_priority DESC, dp_metric limit 10
                ) LOOp
                    RETURN QUERY 
                    /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}rel*/
                    
                end loop;
            END IF;
        WHEN'4' THEN -- LCRD, Prio, ACD&ACR control
            IF v_rg.more_specific_per_vendor THEN
                FOR routedata IN (
                    WITH step1 AS(
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r,  
                            ((t_dp.next_rate - first_value(t_dp.next_rate) OVER(ORDER BY t_dp.next_rate ASC)) > v_rg.rate_delta_max)::INTEGER *(t_dp.next_rate + t_dp.priority) - t_dp.priority AS r2
                        FROM class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id = t_vendor_account.id
                        WHERE
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                            AND NOT t_dp.locked --ACD&ASR control for DP
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    from step1
                    WHERE r=1
                    ORDER BY r2 ASC limit 10
                ) LOOP
                    RETURN QUERY 
                    /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}rel*/
                    
                end LOOP;
            ELSE
                FOR routedata IN (
                    WITH step1 AS(
                        SELECT 
                            (t_dp.*)::class4.dialpeers as s1_dialpeer,
                            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                            rank() OVER (PARTITION BY length(t_dp.prefix) ORDER BY length(t_dp.prefix) desc) as r,
                            ((t_dp.next_rate - first_value(t_dp.next_rate) OVER(ORDER BY t_dp.next_rate ASC)) > v_rg.rate_delta_max)::INTEGER *(t_dp.next_rate + t_dp.priority) - t_dp.priority AS r2
                        from class4.dialpeers t_dp
                            JOIN billing.accounts t_vendor_account ON t_dp.account_id = t_vendor_account.id
                        WHERE 
                            prefix_range(t_dp.prefix)@>prefix_range(v_ret.dst_prefix_out) 
                            AND t_dp.routing_group_id=v_customer_auth.routing_group_id
                            AND t_dp.enabled
                            and t_dp.valid_from<=v_now
                            and t_dp.valid_till>=v_now
                            AND t_vendor_account.balance<t_vendor_account.max_balance
                            AND NOT t_dp.locked --ACD&ASR control for DP
                    )
                    SELECT s1_dialpeer as s2_dialpeer,
                           s1_vendor_account as s2_vendor_account
                    FROM step1
                    WHERE r=1
                    oRDER BY r2 ASC LIMIT 10
                ) LOOP
                RETURN QUERY 
                    /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id);/*}rel*/
                    
                end loop;
           END IF;
        ELSE
                RAISE NOTICE 'BUG: unknown sorting_id';
        END CASE;

    v_ret.disconnect_code_id=113; --No routes
    RETURN NEXT v_ret;

    RETURN;
END;
$$;


--
-- TOC entry 668 (class 1255 OID 18944)
-- Name: test(); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION test() RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
v_in VARCHAR[] = ARRAY[
    'sip:user:pass@host:5080/path',
    'sip:user.name@www.linphone.org:42',
    'user.name@www.linphone.org:42',
    'sip:www.linphone.org:42',
    'sip:user.name@www.linphone.org',
    'www.linphone.org',
    'sip:www.linphone.org',
    'user.name@www.linphone.org',
    'user.name@www.linphone.org:',
    '5684956856@www.linphone.org:',
    '41215103132:netcom07@voipgateway.org/41215103132',
    '41215103132@voipgateway.org/41215103132',
    '109074203115:109074203115!XX@109.74.203.115:5060',
    '109074203115:109074203115!XX@109.74.203.115:5060',
    'us:us@voip.picadoo.com/2345@from',
    '+{DID}@voice.delphistyle.com:5064'
];
v_src VARCHAR;
v_ret VARCHAR;
v_start timestamp;
v_end timestamp;

BEGIN
    v_start:=now();
    --FOR i IN 1..1e3 LOOP
    FOREACH v_src IN ARRAY v_in LOOP
        --                                                 [proto:]    [user:        [pass]]         host    [:port]     [/path]
        select * INTO v_ret from regexp_matches(v_src,'(?:(sip):)?(?:([\w\.{}+-]+)(?::([^:@]+))?@)?([\w\.-]+)(?::(\d+))?(?:/(.*))?');
        RAISE NOTICE '"%" -> %', v_src, v_ret;
    END LOOP;
    --END LOOP;
    --v_end:=clock_timestamp();
    --RAISE NOTICE 'delta % ms',EXTRACT(MILLISECOND from v_end-v_start);
END;
$$;


--
-- TOC entry 669 (class 1255 OID 18945)
-- Name: tracelog(class4.destinations); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION tracelog(i_in class4.destinations) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$
BEGIN    
    RAISE INFO'switch1.tracelog: % : %',clock_timestamp()::char(25),i_in;
END;
$$;


--
-- TOC entry 670 (class 1255 OID 18946)
-- Name: tracelog(class4.dialpeers); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION tracelog(i_in class4.dialpeers) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$
BEGIN    
    RAISE INFO 'switch1.tracelog: % : %',clock_timestamp()::char(25),i_in;
END;
$$;


SET search_path = sys, pg_catalog;

--
-- TOC entry 634 (class 1255 OID 17346)
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

        v_tbname:='cdrs_'||v_tdate;
        v_ftbname:='class4.'||v_tbname::varchar;
        
        -- CHECK if table exists
        SELECT into v_c count(*) from pg_tables where schemaname='class4' and tablename=v_tbname;
        IF v_c>0 THEN
                RAISE NOTICE 'sys.cdr_createtable: next table % already created',v_tbname;
                RETURN;
        ELSE
                v_sql:='CREATE TABLE '||v_ftbname||'(
                CONSTRAINT '||v_tbname||'_time_start_check CHECK (
                        time_start >= '''||v_start||'''::date
                        AND time_start < '''||v_end||'''::date
                )
                ) INHERITS (class4.cdrs)';
                EXECUTE v_sql;
                v_sql:='ALTER TABLE '||v_ftbname||' ADD PRIMARY KEY(id)';
                EXECUTE v_sql;
                RAISE NOTICE 'sys.cdr_createtable: next table % creating started',v_tbname;
                PERFORM sys.cdr_reindex(v_tbname);
                -- update trigger
                INSERT INTO sys.cdr_tables(date_start,date_stop,"name",writable,readable) VALUES (v_start,v_end,v_ftbname,'t','t');
                PERFORM sys.cdrtable_tgr_reload();
        END IF;
END;
$$;


--
-- TOC entry 635 (class 1255 OID 17347)
-- Name: cdr_drop_table(character varying); Type: FUNCTION; Schema: sys; Owner: -
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


--
-- TOC entry 636 (class 1255 OID 17348)
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
-- TOC entry 637 (class 1255 OID 17349)
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
-- TOC entry 638 (class 1255 OID 17350)
-- Name: cdr_reindex(character varying); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION cdr_reindex(i_tbname character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
v_c integer;
v_sql varchar;
v_indname varchar;
v_chname varchar:='class4';
BEGIN
        SELECT into v_c count(*) from pg_tables where schemaname='class4' and tablename=i_tbname;
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
                SELECT into v_indname indexname FROM pg_catalog.pg_indexes WHERE schemaname=v_chname AND tablename=i_tbname AND indexdef LIKE '%(out_call_id)%';
                IF NOT FOUND THEN
                        v_sql:='CREATE UNIQUE INDEX ON '||v_chname||'.'||i_tbname||' USING btree (out_call_id);';
                        RAISE NOTICE 'sys.cdr_reindex: % add index out_call_id' ,i_tbname;
                        EXECUTE v_sql;
                ELSE
                        v_sql:='CREATE UNIQUE INDEX ON '||v_chname||'.'||i_tbname||' USING btree (out_call_id);';
                        EXECUTE v_sql;
                        v_sql:='DROP INDEX cdrs.'||v_indname;
                        EXECUTE v_sql;
                        RAISE NOTICE 'sys.cdr_reindex: % reindex out_call_id' ,i_tbname;
                END IF;
*/
                -- index on time_inviteprocessed;
                SELECT into v_indname indexname FROM pg_catalog.pg_indexes WHERE schemaname=v_chname AND tablename=i_tbname AND indexdef LIKE '%(time_start)%';
                IF NOT FOUND THEN
                        v_sql:='CREATE INDEX ON '||v_chname||'.'||i_tbname||' USING btree (time_start);';
                        EXECUTE v_sql;
                        RAISE NOTICE 'sys.cdr_reindex: % add index time_start' ,i_tbname;
                ELSE
                        v_sql:='CREATE INDEX ON '||v_chname||'.'||i_tbname||' USING btree (time_start);';
                        EXECUTE v_sql;
                        v_sql:='DROP INDEX cdrs.'||v_indname;
                        EXECUTE v_sql;
                        RAISE NOTICE 'sys.cdr_reindex: % reindex time_invite' ,i_tbname;
                END IF;

        END IF;
        RETURN ;
END;
$$;


--
-- TOC entry 639 (class 1255 OID 17351)
-- Name: cdrtable_tgr_reload(); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION cdrtable_tgr_reload() RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
v_tbname varchar;
v_sql1 varchar:='CREATE OR REPLACE FUNCTION class4.cdrs_i_tgf() RETURNS trigger AS $trg$ 
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
        PERFORM * FROM sys.cdr_tables WHERE writable='t';
        IF NOT FOUND THEN
            RAISE EXCEPTION 'no tables for write data';
        end IF;
        FOR v_tb_row IN SELECT * FROM sys.cdr_tables WHERE writable='t' ORDER BY date_start LOOP
                IF v_counter=1 THEN
                        v_prfx='IF ';
                ELSE 
                        v_prfx='ELSIF ';
                END IF;
                v_meat:=v_meat||v_prfx||'( NEW.time_start >= DATE '''||v_tb_row.date_start||''' AND NEW.time_start < DATE '''||v_tb_row.date_stop||''' ) THEN INSERT INTO '||v_tb_row.name||' VALUES (NEW.*);'|| E'\n';
                v_counter:=v_counter+1;
        END LOOP;
        v_meat:=v_meat||' ELSE '|| E'\n'||' RAISE EXCEPTION ''class4.cdrs_i_tg: time_start out of range.''; '||E'\n'||' END IF;';
        v_sql1:=REPLACE(v_sql1,'[MEAT]',v_meat);
        set standard_conforming_strings=on;
        EXECUTE v_sql1;
      --  EXECUTE v_sql2;
        RAISE NOTICE 'sys.cdrtable_tgr_reload: CDR trigger reloaded';
       -- RETURN 'OK';
END;
$_$;


--
-- TOC entry 640 (class 1255 OID 17352)
-- Name: checkcode(); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION checkcode() RETURNS TABLE(o_schema character varying, o_name character varying, o_hash character varying)
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
BEGIN 
RETURN QUERY
SELECT pn.nspname::varchar,
pp.proname::varchar,
md5(pp.prosrc)::varchar
from pg_proc pp 
join pg_namespace pn on pp.pronamespace=pn.oid
join pg_roles pa ON pa.oid=proowner
WHERE pn.nspname !~ '^pg_' AND 
pn.nspname <> 'information_schema' AND
pa.rolname=current_user
ORDER BY pn.nspname,pp.proname,pp.proargtypes;
END;
$$;


--
-- TOC entry 641 (class 1255 OID 17353)
-- Name: checkstat(); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION checkstat() RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
        v_lock record;
BEGIN 
        /* DP  locking*/
        FOR v_lock IN SELECT  dp.id AS id,
                                dp.asr_limit AS asr_limit,
                                dp.acd_limit as acd_limit,
                                dp.vendor_id as vendor_id,
                                st.asr as asr,
                                st.acd as acd
                        FROM class4.dialpeers dp LEFT JOIN runtime_stats.dialpeers_stats st
                        ON dp.id=st.dialpeer_id
                        WHERE   (dp.asr_limit>0 AND asr<asr_limit AND NOT dp.locked) OR
                                (dp.acd_limit>0 AND acd<acd_limit AND NOT dp.locked) OR
                                (dp.locked AND st.asr IS NULL)
        LOOP
                IF NOT v_lock.locked THEN
                        -- locking
                        IF v_lock.asr<v_lock.asr_limit THEN
                                --process asr
                                --sys.dplock_event(v_lock,asr);
                        ELSE 
                                --sys.dplock_event(v_lock,acd);
                                --process acd
                        END IF;
                        UPDATE runtime_stats.dialpeers_stats set locked_at=now() where id=v_lock.id;
                        UPDATE class4.dialpeers set locked='t' where id=v_lock.id;
                 ELSE
                        --unlocking if good quality or stats not found
                        IF v_lock.asr>=v_lock.asr_limit OR v_lock.acd>=v_lock.acd_limit OR v_lock.asr IS NULL THEN
                                UPDATE runtime_stats.dialpeers_stats set unlocked_at=now() where id=v_lock.id;
                                UPDATE class4.dialpeers set locked='f' where id=v_lock.id;
                        END IF;
                 END IF;
        END LOOP;

        /* GW locking */
        FOR v_lock IN SELECT    gw.id AS id,
                                gw.asr_limit AS asr_limit,
                                gw.acd_limit as acd_limit,
                                gw.contractor_id AS contractor_id,
                                st.asr as asr,
                                st.acd as acd
                        FROM class4.gateways gw JOIN runtime_stats.gateways_stats st
                        ON gw.id=st.gateway_id
                        WHERE acd<acd_limit OR acd<acd_limit and not gw.locked
        LOOP
                IF v_lock.asr<v_lock.asr_limit THEN
                        --process asr
                ELSE 
                        --process acd
                END IF;
                UPDATE runtime_stats.gateways_stats set locked_at=now() where id=v_lock.id;
                UPDATE class4.gateways set locked='t' where id=v_lock.id;
        END LOOP;

        --FOR v_id in SELECT id from runtime_stats.dialpeers_stats WHERE locked)

END;
$$;


--
-- TOC entry 642 (class 1255 OID 17354)
-- Name: codecheck(); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION codecheck() RETURNS TABLE(o_schema character varying, o_name character varying, o_hash character varying)
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
BEGIN 
RETURN QUERY
SELECT pn.nspname::varchar,
pp.proname::varchar,
md5(pp.prosrc)::varchar
from pg_proc pp 
join pg_namespace pn on pp.pronamespace=pn.oid
join pg_roles pa ON pa.oid=proowner
WHERE pn.nspname !~ '^pg_' AND 
pn.nspname <> 'information_schema' AND
pa.rolname=current_user
ORDER BY pn.nspname,pp.proname;
END;
$$;


--
-- TOC entry 643 (class 1255 OID 17355)
-- Name: codediff(character varying, smallint, character varying, character varying, character varying); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION codediff(i_host character varying, i_port smallint, i_dbname character varying, i_username character varying, i_password character varying) RETURNS TABLE(o_schema character varying, o_name character varying, o_local_hash character varying, o_remote_hash character varying, o_need_update boolean)
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    v_DBLINK_CONNECT text:= 'dbname=''[DBNAME]'' user=''[USER]'' password=''[PASS]'' port=''[PORT]'' host=''[HOST]''';
BEGIN 
    v_DBLINK_CONNECT:=replace(v_DBLINK_CONNECT,'[HOST]',i_host::text);
    v_DBLINK_CONNECT:=replace(v_DBLINK_CONNECT,'[PORT]',i_port::text);
    v_DBLINK_CONNECT:=replace(v_DBLINK_CONNECT,'[USER]',i_username::text);
    v_DBLINK_CONNECT:=replace(v_DBLINK_CONNECT,'[PASS]',i_password::text);
    v_DBLINK_CONNECT:=replace(v_DBLINK_CONNECT,'[DBNAME]',i_dbname::text);
    BEGIN
        PERFORM public.dblink_connect('dblink_connamenum',v_DBLINK_CONNECT);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE WARNING 'reconnecting datalink';
            PERFORM dblink_disconnect ('dblink_connamenum');
    END;

    BEGIn
        PERFORM public.dblink_connect('dblink_connamenum',v_DBLINK_CONNECT);
        RETURN QUERY
            WITH r AS (
                SELECT * from public.dblink('dblink_connamenum','SELECT o_schema,o_name,o_hash from sys.codecheck();') AS H(o_schema varchar ,o_name varchar,o_hash varchar)
            ),
            l as (
                SELECT * from sys.codecheck()
            )
            SELECT COALESCE(l.o_schema,r.o_schema)::varchar as o_schema ,
            COALESCE(l.o_name,r.o_name)::varchar as o_name, 
            l.o_hash::varchar as o_local_hash,
            r.o_hash::varchar as o_remote_hash,
            COALESCE(l.o_hash!=r.o_hash,true) as need_update
            FROM l FULL JOIN r ON l.o_schema=r.o_schema AND l.o_name=r.o_name;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION 'Error';
    END;

END;
$$;


--
-- TOC entry 644 (class 1255 OID 17356)
-- Name: hex_to_int(text); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION hex_to_int(i_hex text, OUT o_dec integer) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$ 
BEGIN 
    EXECUTE 'SELECT x''' || i_hex || '''::integer' INTO o_dec; 
    RETURN; 
END $$;


--
-- TOC entry 645 (class 1255 OID 17357)
-- Name: logic_log(character varying, integer, character varying); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION logic_log(i_source character varying, i_level integer, i_msg character varying) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
BEGIN
    --TODO: loglevel checking;
    INSERT INTO logs.logic_log(source,txid,"level",msg,"timestamp") values (i_source,txid_current(),i_level,i_msg,clock_timestamp());
END;
$$;


--
-- TOC entry 646 (class 1255 OID 17358)
-- Name: system_clean(); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION system_clean() RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
BEGIN 
    delete from class4.cdrs;
    delete from billing.invoices;
    delete from class4.customers_auth;
    delete from runtime_stats.dialpeers_stats;
    delete from runtime_stats.gateways_stats;
    delete from class4.dialpeers;
    delete from class4.gateways;
    delete from class4.destinations;
    delete from class4.rateplans;
    delete from class4.routing_groups;
    delete from billing.payments;
    delete from billing.accounts;
    delete from logs.logic_log;
END;
$$;


--
-- TOC entry 647 (class 1255 OID 17359)
-- Name: version_check(integer); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION version_check(i_ver integer) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
v_num integer;
BEGIN 
    select into v_num "number" from sys.version ORDER BY "number" desc limit 1;
    if v_num=i_ver THEN
        RETURN;
    END IF;
    RAISE EXCEPTION 'Invalid version';
END;
$$;


--
-- TOC entry 648 (class 1255 OID 17360)
-- Name: version_up(integer, character varying); Type: FUNCTION; Schema: sys; Owner: -
--

CREATE FUNCTION version_up(i_ver integer, i_comment character varying) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
v_num integer;
BEGIN 
    select into v_num "number" from sys.version ORDER BY "number" desc limit 1;
    if NOT FOUND THEN
        RAISE WARNING 'first verstion';
    ELSE
        if v_num>i_ver THEN
            RAISE EXCEPTION 'database version too high';
        end if;
    END IF;
    INSERT INTO sys.version("number","comment") values(i_ver,i_comment);
END;
$$;


SET search_path = billing, pg_catalog;

--
-- TOC entry 185 (class 1259 OID 17361)
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: billing; Owner: -
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3531 (class 0 OID 0)
-- Dependencies: 185
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: -
--

ALTER SEQUENCE accounts_id_seq OWNED BY accounts.id;


--
-- TOC entry 317 (class 1259 OID 19093)
-- Name: cdr_batches; Type: TABLE; Schema: billing; Owner: -; Tablespace: 
--

CREATE TABLE cdr_batches (
    id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    batch_id bigint NOT NULL,
    batch_size integer NOT NULL,
    batch_raw_data text
);


--
-- TOC entry 316 (class 1259 OID 19091)
-- Name: cdr_batches_id_seq; Type: SEQUENCE; Schema: billing; Owner: -
--

CREATE SEQUENCE cdr_batches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3532 (class 0 OID 0)
-- Dependencies: 316
-- Name: cdr_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: -
--

ALTER SEQUENCE cdr_batches_id_seq OWNED BY cdr_batches.id;


--
-- TOC entry 299 (class 1259 OID 18876)
-- Name: invoice_templates; Type: TABLE; Schema: billing; Owner: -; Tablespace: 
--

CREATE TABLE invoice_templates (
    id integer NOT NULL,
    name character varying NOT NULL,
    filename character varying NOT NULL,
    data bytea,
    sha1 character varying,
    created_at timestamp without time zone
);


--
-- TOC entry 186 (class 1259 OID 17363)
-- Name: invoices; Type: TABLE; Schema: billing; Owner: -; Tablespace: 
--

CREATE TABLE invoices (
    id integer NOT NULL,
    account_id integer NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    amount numeric NOT NULL,
    vendor_invoice boolean DEFAULT false NOT NULL,
    cdrs bigint NOT NULL,
    first_cdr_date timestamp without time zone,
    last_cdr_date timestamp without time zone,
    contractor_id integer
);


--
-- TOC entry 187 (class 1259 OID 17370)
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: billing; Owner: -
--

CREATE SEQUENCE invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3533 (class 0 OID 0)
-- Dependencies: 187
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: -
--

ALTER SEQUENCE invoices_id_seq OWNED BY invoices.id;


--
-- TOC entry 298 (class 1259 OID 18874)
-- Name: invoices_templates_id_seq; Type: SEQUENCE; Schema: billing; Owner: -
--

CREATE SEQUENCE invoices_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3534 (class 0 OID 0)
-- Dependencies: 298
-- Name: invoices_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: -
--

ALTER SEQUENCE invoices_templates_id_seq OWNED BY invoice_templates.id;


--
-- TOC entry 188 (class 1259 OID 17372)
-- Name: payments; Type: TABLE; Schema: billing; Owner: -; Tablespace: 
--

CREATE TABLE payments (
    account_id integer NOT NULL,
    amount numeric NOT NULL,
    notes character varying,
    id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 189 (class 1259 OID 17379)
-- Name: payments_id_seq; Type: SEQUENCE; Schema: billing; Owner: -
--

CREATE SEQUENCE payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3535 (class 0 OID 0)
-- Dependencies: 189
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: -
--

ALTER SEQUENCE payments_id_seq OWNED BY payments.id;


SET search_path = class4, pg_catalog;

--
-- TOC entry 297 (class 1259 OID 18857)
-- Name: blacklist_items; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE blacklist_items (
    id integer NOT NULL,
    blacklist_id integer NOT NULL,
    key character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- TOC entry 296 (class 1259 OID 18855)
-- Name: blacklist_items_id_seq; Type: SEQUENCE; Schema: class4; Owner: -
--

CREATE SEQUENCE blacklist_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3536 (class 0 OID 0)
-- Dependencies: 296
-- Name: blacklist_items_id_seq; Type: SEQUENCE OWNED BY; Schema: class4; Owner: -
--

ALTER SEQUENCE blacklist_items_id_seq OWNED BY blacklist_items.id;


--
-- TOC entry 295 (class 1259 OID 18843)
-- Name: blacklists; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE blacklists (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- TOC entry 294 (class 1259 OID 18841)
-- Name: blacklists_id_seq; Type: SEQUENCE; Schema: class4; Owner: -
--

CREATE SEQUENCE blacklists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3537 (class 0 OID 0)
-- Dependencies: 294
-- Name: blacklists_id_seq; Type: SEQUENCE OWNED BY; Schema: class4; Owner: -
--

ALTER SEQUENCE blacklists_id_seq OWNED BY blacklists.id;


--
-- TOC entry 190 (class 1259 OID 17563)
-- Name: codec_group_codecs; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE codec_group_codecs (
    id integer NOT NULL,
    codec_group_id integer NOT NULL,
    codec_id integer NOT NULL,
    priority integer DEFAULT 100 NOT NULL,
    dynamic_payload_type integer,
    format_parameters character varying
);


--
-- TOC entry 191 (class 1259 OID 17567)
-- Name: codec_group_codecs_id_seq; Type: SEQUENCE; Schema: class4; Owner: -
--

CREATE SEQUENCE codec_group_codecs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3538 (class 0 OID 0)
-- Dependencies: 191
-- Name: codec_group_codecs_id_seq; Type: SEQUENCE OWNED BY; Schema: class4; Owner: -
--

ALTER SEQUENCE codec_group_codecs_id_seq OWNED BY codec_group_codecs.id;


--
-- TOC entry 192 (class 1259 OID 17569)
-- Name: codec_groups; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE codec_groups (
    id integer NOT NULL,
    name character varying NOT NULL
);


--
-- TOC entry 193 (class 1259 OID 17575)
-- Name: codec_groups_id_seq; Type: SEQUENCE; Schema: class4; Owner: -
--

CREATE SEQUENCE codec_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3539 (class 0 OID 0)
-- Dependencies: 193
-- Name: codec_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: class4; Owner: -
--

ALTER SEQUENCE codec_groups_id_seq OWNED BY codec_groups.id;


--
-- TOC entry 194 (class 1259 OID 17577)
-- Name: codecs; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE codecs (
    id integer NOT NULL,
    name character varying NOT NULL
);


--
-- TOC entry 195 (class 1259 OID 17583)
-- Name: codecs_id_seq; Type: SEQUENCE; Schema: class4; Owner: -
--

CREATE SEQUENCE codecs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3540 (class 0 OID 0)
-- Dependencies: 195
-- Name: codecs_id_seq; Type: SEQUENCE OWNED BY; Schema: class4; Owner: -
--

ALTER SEQUENCE codecs_id_seq OWNED BY codecs.id;


--
-- TOC entry 196 (class 1259 OID 17585)
-- Name: customers_auth; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE customers_auth (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    routing_group_id integer NOT NULL,
    rateplan_id integer NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    ip inet,
    account_id integer,
    gateway_id integer NOT NULL,
    src_rewrite_rule character varying,
    src_rewrite_result character varying,
    dst_rewrite_rule character varying,
    dst_rewrite_result character varying,
    src_prefix character varying DEFAULT ''::character varying NOT NULL,
    dst_prefix character varying DEFAULT ''::character varying NOT NULL,
    x_yeti_auth character varying,
    name character varying NOT NULL,
    dump_level_id integer DEFAULT 1 NOT NULL,
    capacity integer DEFAULT 0 NOT NULL,
    pop_id integer,
    uri_domain character varying,
    src_name_rewrite_rule character varying,
    src_name_rewrite_result character varying,
    diversion_policy_id integer DEFAULT 1 NOT NULL,
    diversion_rewrite_rule character varying,
    diversion_rewrite_result character varying,
    dst_blacklist_id integer,
    src_blacklist_id integer
);


--
-- TOC entry 197 (class 1259 OID 17597)
-- Name: customers_auth_id_seq; Type: SEQUENCE; Schema: class4; Owner: -
--

CREATE SEQUENCE customers_auth_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3541 (class 0 OID 0)
-- Dependencies: 197
-- Name: customers_auth_id_seq; Type: SEQUENCE OWNED BY; Schema: class4; Owner: -
--

ALTER SEQUENCE customers_auth_id_seq OWNED BY customers_auth.id;


--
-- TOC entry 198 (class 1259 OID 17599)
-- Name: destination_rate_policy; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE destination_rate_policy (
    id integer NOT NULL,
    name character varying NOT NULL
);


--
-- TOC entry 199 (class 1259 OID 17605)
-- Name: destinations_id_seq; Type: SEQUENCE; Schema: class4; Owner: -
--

CREATE SEQUENCE destinations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3542 (class 0 OID 0)
-- Dependencies: 199
-- Name: destinations_id_seq; Type: SEQUENCE OWNED BY; Schema: class4; Owner: -
--

ALTER SEQUENCE destinations_id_seq OWNED BY destinations.id;


--
-- TOC entry 200 (class 1259 OID 17607)
-- Name: dialpeers_id_seq; Type: SEQUENCE; Schema: class4; Owner: -
--

CREATE SEQUENCE dialpeers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3543 (class 0 OID 0)
-- Dependencies: 200
-- Name: dialpeers_id_seq; Type: SEQUENCE OWNED BY; Schema: class4; Owner: -
--

ALTER SEQUENCE dialpeers_id_seq OWNED BY dialpeers.id;


--
-- TOC entry 201 (class 1259 OID 17609)
-- Name: disconnect_code; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE disconnect_code (
    id integer NOT NULL,
    namespace_id integer NOT NULL,
    stop_hunting boolean DEFAULT true NOT NULL,
    pass_reason_to_originator boolean DEFAULT false NOT NULL,
    code integer NOT NULL,
    reason character varying NOT NULL,
    rewrited_code integer,
    rewrited_reason character varying,
    success boolean DEFAULT false NOT NULL,
    successnozerolen boolean DEFAULT false NOT NULL,
    store_cdr boolean DEFAULT true NOT NULL,
    silently_drop boolean DEFAULT false NOT NULL
);


--
-- TOC entry 202 (class 1259 OID 17621)
-- Name: disconnect_code_id_seq; Type: SEQUENCE; Schema: class4; Owner: -
--

CREATE SEQUENCE disconnect_code_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 202
-- Name: disconnect_code_id_seq; Type: SEQUENCE OWNED BY; Schema: class4; Owner: -
--

ALTER SEQUENCE disconnect_code_id_seq OWNED BY disconnect_code.id;


--
-- TOC entry 203 (class 1259 OID 17623)
-- Name: disconnect_policy_code; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE disconnect_policy_code (
    id integer NOT NULL,
    policy_id integer NOT NULL,
    code_id integer NOT NULL,
    stop_hunting boolean DEFAULT true NOT NULL,
    pass_reason_to_originator boolean DEFAULT false NOT NULL,
    rewrited_code integer,
    rewrited_reason character varying
);


--
-- TOC entry 204 (class 1259 OID 17631)
-- Name: disconnect_code_policy_codes_id_seq; Type: SEQUENCE; Schema: class4; Owner: -
--

CREATE SEQUENCE disconnect_code_policy_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3545 (class 0 OID 0)
-- Dependencies: 204
-- Name: disconnect_code_policy_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: class4; Owner: -
--

ALTER SEQUENCE disconnect_code_policy_codes_id_seq OWNED BY disconnect_policy_code.id;


--
-- TOC entry 205 (class 1259 OID 17633)
-- Name: disconnect_policy; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE disconnect_policy (
    id integer NOT NULL,
    name character varying
);


--
-- TOC entry 206 (class 1259 OID 17639)
-- Name: disconnect_code_policy_id_seq; Type: SEQUENCE; Schema: class4; Owner: -
--

CREATE SEQUENCE disconnect_code_policy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3546 (class 0 OID 0)
-- Dependencies: 206
-- Name: disconnect_code_policy_id_seq; Type: SEQUENCE OWNED BY; Schema: class4; Owner: -
--

ALTER SEQUENCE disconnect_code_policy_id_seq OWNED BY disconnect_policy.id;


--
-- TOC entry 207 (class 1259 OID 17641)
-- Name: disconnect_initiators; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE disconnect_initiators (
    id integer NOT NULL,
    name character varying
);


--
-- TOC entry 208 (class 1259 OID 17647)
-- Name: diversion_policy; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE diversion_policy (
    id integer NOT NULL,
    name character varying NOT NULL
);


--
-- TOC entry 209 (class 1259 OID 17653)
-- Name: dump_level; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE dump_level (
    id integer NOT NULL,
    name character varying NOT NULL,
    log_sip boolean DEFAULT false NOT NULL,
    log_rtp boolean DEFAULT false NOT NULL
);


--
-- TOC entry 210 (class 1259 OID 17661)
-- Name: filter_types; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE filter_types (
    id integer NOT NULL,
    name character varying
);


--
-- TOC entry 211 (class 1259 OID 17667)
-- Name: gateway_groups; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE gateway_groups (
    id integer NOT NULL,
    vendor_id integer NOT NULL,
    name character varying NOT NULL,
    prefer_same_pop boolean DEFAULT true NOT NULL
);


--
-- TOC entry 212 (class 1259 OID 17674)
-- Name: gateway_groups_id_seq; Type: SEQUENCE; Schema: class4; Owner: -
--

CREATE SEQUENCE gateway_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3547 (class 0 OID 0)
-- Dependencies: 212
-- Name: gateway_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: class4; Owner: -
--

ALTER SEQUENCE gateway_groups_id_seq OWNED BY gateway_groups.id;


--
-- TOC entry 213 (class 1259 OID 17676)
-- Name: gateways_id_seq; Type: SEQUENCE; Schema: class4; Owner: -
--

CREATE SEQUENCE gateways_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 213
-- Name: gateways_id_seq; Type: SEQUENCE OWNED BY; Schema: class4; Owner: -
--

ALTER SEQUENCE gateways_id_seq OWNED BY gateways.id;


--
-- TOC entry 214 (class 1259 OID 17678)
-- Name: rateplans; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE rateplans (
    id integer NOT NULL,
    name character varying
);


--
-- TOC entry 215 (class 1259 OID 17684)
-- Name: rateplans_id_seq; Type: SEQUENCE; Schema: class4; Owner: -
--

CREATE SEQUENCE rateplans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 215
-- Name: rateplans_id_seq; Type: SEQUENCE OWNED BY; Schema: class4; Owner: -
--

ALTER SEQUENCE rateplans_id_seq OWNED BY rateplans.id;


--
-- TOC entry 216 (class 1259 OID 17686)
-- Name: registrations; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE registrations (
    id integer NOT NULL,
    name character varying NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    pop_id integer,
    node_id integer,
    domain character varying,
    username character varying NOT NULL,
    display_username character varying,
    auth_user character varying,
    proxy character varying,
    contact character varying,
    auth_password character varying,
    expire integer,
    force_expire boolean DEFAULT false NOT NULL
);


--
-- TOC entry 217 (class 1259 OID 17694)
-- Name: registrations_id_seq; Type: SEQUENCE; Schema: class4; Owner: -
--

CREATE SEQUENCE registrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3550 (class 0 OID 0)
-- Dependencies: 217
-- Name: registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: class4; Owner: -
--

ALTER SEQUENCE registrations_id_seq OWNED BY registrations.id;


--
-- TOC entry 218 (class 1259 OID 17696)
-- Name: routing_groups; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE routing_groups (
    id integer NOT NULL,
    name character varying NOT NULL,
    sorting_id integer DEFAULT 1 NOT NULL,
    more_specific_per_vendor boolean DEFAULT true NOT NULL,
    rate_delta_max numeric DEFAULT 0 NOT NULL
);


--
-- TOC entry 219 (class 1259 OID 17705)
-- Name: routing_groups_id_seq; Type: SEQUENCE; Schema: class4; Owner: -
--

CREATE SEQUENCE routing_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3551 (class 0 OID 0)
-- Dependencies: 219
-- Name: routing_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: class4; Owner: -
--

ALTER SEQUENCE routing_groups_id_seq OWNED BY routing_groups.id;


--
-- TOC entry 293 (class 1259 OID 18795)
-- Name: sdp_c_location; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE sdp_c_location (
    id integer NOT NULL,
    name character varying NOT NULL
);


--
-- TOC entry 220 (class 1259 OID 17707)
-- Name: session_refresh_methods; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE session_refresh_methods (
    id integer NOT NULL,
    value character varying NOT NULL,
    name character varying
);


--
-- TOC entry 221 (class 1259 OID 17713)
-- Name: session_refresh_methods_id_seq; Type: SEQUENCE; Schema: class4; Owner: -
--

CREATE SEQUENCE session_refresh_methods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3552 (class 0 OID 0)
-- Dependencies: 221
-- Name: session_refresh_methods_id_seq; Type: SEQUENCE OWNED BY; Schema: class4; Owner: -
--

ALTER SEQUENCE session_refresh_methods_id_seq OWNED BY session_refresh_methods.id;


--
-- TOC entry 222 (class 1259 OID 17715)
-- Name: sortings; Type: TABLE; Schema: class4; Owner: -; Tablespace: 
--

CREATE TABLE sortings (
    id integer NOT NULL,
    name character varying,
    description character varying
);


--
-- TOC entry 223 (class 1259 OID 17721)
-- Name: sortings_id_seq; Type: SEQUENCE; Schema: class4; Owner: -
--

CREATE SEQUENCE sortings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3553 (class 0 OID 0)
-- Dependencies: 223
-- Name: sortings_id_seq; Type: SEQUENCE OWNED BY; Schema: class4; Owner: -
--

ALTER SEQUENCE sortings_id_seq OWNED BY sortings.id;


SET search_path = data_import, pg_catalog;

--
-- TOC entry 224 (class 1259 OID 17723)
-- Name: import_accounts; Type: TABLE; Schema: data_import; Owner: -; Tablespace: 
--

CREATE TABLE import_accounts (
    id bigint NOT NULL,
    o_id integer,
    contractor_name character varying,
    contractor_id integer,
    balance numeric,
    min_balance numeric,
    max_balance numeric,
    name character varying,
    origination_capacity integer,
    termination_capacity integer,
    error_string character varying
);


--
-- TOC entry 225 (class 1259 OID 17729)
-- Name: import_accounts_id_seq; Type: SEQUENCE; Schema: data_import; Owner: -
--

CREATE SEQUENCE import_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3554 (class 0 OID 0)
-- Dependencies: 225
-- Name: import_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: data_import; Owner: -
--

ALTER SEQUENCE import_accounts_id_seq OWNED BY import_accounts.id;


--
-- TOC entry 226 (class 1259 OID 17731)
-- Name: import_codec_group_codecs; Type: TABLE; Schema: data_import; Owner: -; Tablespace: 
--

CREATE TABLE import_codec_group_codecs (
    id bigint NOT NULL,
    o_id integer,
    codec_group_name character varying,
    codec_group_id integer,
    codec_name character varying,
    codec_id integer,
    priority integer,
    error_string character varying
);


--
-- TOC entry 227 (class 1259 OID 17737)
-- Name: import_codec_group_codecs_id_seq; Type: SEQUENCE; Schema: data_import; Owner: -
--

CREATE SEQUENCE import_codec_group_codecs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3555 (class 0 OID 0)
-- Dependencies: 227
-- Name: import_codec_group_codecs_id_seq; Type: SEQUENCE OWNED BY; Schema: data_import; Owner: -
--

ALTER SEQUENCE import_codec_group_codecs_id_seq OWNED BY import_codec_group_codecs.id;


--
-- TOC entry 228 (class 1259 OID 17739)
-- Name: import_codec_groups; Type: TABLE; Schema: data_import; Owner: -; Tablespace: 
--

CREATE TABLE import_codec_groups (
    id bigint NOT NULL,
    o_id integer,
    name character varying,
    error_string character varying
);


--
-- TOC entry 229 (class 1259 OID 17745)
-- Name: import_codec_groups_id_seq; Type: SEQUENCE; Schema: data_import; Owner: -
--

CREATE SEQUENCE import_codec_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3556 (class 0 OID 0)
-- Dependencies: 229
-- Name: import_codec_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: data_import; Owner: -
--

ALTER SEQUENCE import_codec_groups_id_seq OWNED BY import_codec_groups.id;


--
-- TOC entry 230 (class 1259 OID 17747)
-- Name: import_contractors; Type: TABLE; Schema: data_import; Owner: -; Tablespace: 
--

CREATE TABLE import_contractors (
    id bigint NOT NULL,
    o_id integer,
    name character varying,
    vendor boolean,
    customer boolean,
    enabled boolean,
    error_string character varying
);


--
-- TOC entry 231 (class 1259 OID 17753)
-- Name: import_contractors_id_seq; Type: SEQUENCE; Schema: data_import; Owner: -
--

CREATE SEQUENCE import_contractors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3557 (class 0 OID 0)
-- Dependencies: 231
-- Name: import_contractors_id_seq; Type: SEQUENCE OWNED BY; Schema: data_import; Owner: -
--

ALTER SEQUENCE import_contractors_id_seq OWNED BY import_contractors.id;


--
-- TOC entry 232 (class 1259 OID 17755)
-- Name: import_customers_auth; Type: TABLE; Schema: data_import; Owner: -; Tablespace: 
--

CREATE TABLE import_customers_auth (
    id bigint NOT NULL,
    o_id bigint,
    customer_name character varying,
    customer_id integer,
    routing_group_name character varying,
    routing_group_id integer,
    rateplan_name character varying,
    rateplan_id integer,
    enabled boolean,
    account_name character varying,
    account_id integer,
    gateway_name character varying,
    gateway_id integer,
    src_rewrite_rule character varying,
    src_rewrite_result character varying,
    dst_rewrite_rule character varying,
    dst_rewrite_result character varying,
    src_prefix character varying,
    dst_prefix character varying,
    x_yeti_auth character varying,
    name character varying,
    dump_level_id integer,
    dump_level_name character varying,
    capacity integer,
    ip inet,
    uri_domain character varying,
    pop_name character varying,
    pop_id integer,
    diversion_policy_id integer,
    diversion_policy_name character varying,
    diversion_rewrite_result character varying,
    diversion_rewrite_rule character varying,
    src_name_rewrite_result character varying,
    src_name_rewrite_rule character varying,
    error_string character varying
);


--
-- TOC entry 233 (class 1259 OID 17761)
-- Name: import_customers_auth_id_seq; Type: SEQUENCE; Schema: data_import; Owner: -
--

CREATE SEQUENCE import_customers_auth_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3558 (class 0 OID 0)
-- Dependencies: 233
-- Name: import_customers_auth_id_seq; Type: SEQUENCE OWNED BY; Schema: data_import; Owner: -
--

ALTER SEQUENCE import_customers_auth_id_seq OWNED BY import_customers_auth.id;


--
-- TOC entry 234 (class 1259 OID 17763)
-- Name: import_destinations; Type: TABLE; Schema: data_import; Owner: -; Tablespace: 
--

CREATE TABLE import_destinations (
    id bigint NOT NULL,
    o_id bigint,
    prefix character varying,
    rateplan_name character varying,
    rateplan_id integer,
    connect_fee numeric,
    enabled boolean,
    reject_calls boolean,
    initial_interval integer,
    next_interval integer,
    initial_rate numeric,
    next_rate numeric,
    rate_policy_id integer,
    dp_margin_fixed numeric,
    dp_margin_percent numeric,
    rate_policy_name character varying,
    use_dp_intervals boolean,
    error_string character varying
);


--
-- TOC entry 235 (class 1259 OID 17769)
-- Name: import_destinations_id_seq; Type: SEQUENCE; Schema: data_import; Owner: -
--

CREATE SEQUENCE import_destinations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3559 (class 0 OID 0)
-- Dependencies: 235
-- Name: import_destinations_id_seq; Type: SEQUENCE OWNED BY; Schema: data_import; Owner: -
--

ALTER SEQUENCE import_destinations_id_seq OWNED BY import_destinations.id;


--
-- TOC entry 236 (class 1259 OID 17771)
-- Name: import_dialpeers; Type: TABLE; Schema: data_import; Owner: -; Tablespace: 
--

CREATE TABLE import_dialpeers (
    id bigint NOT NULL,
    o_id bigint,
    enabled boolean,
    prefix character varying,
    src_rewrite_rule character varying,
    dst_rewrite_rule character varying,
    gateway_id integer,
    gateway_name character varying,
    routing_group_id integer,
    routing_group_name character varying,
    connect_fee numeric,
    vendor_id integer,
    vendor_name character varying,
    account_id integer,
    account_name character varying,
    src_rewrite_result character varying,
    dst_rewrite_result character varying,
    locked boolean,
    priority integer,
    asr_limit real,
    acd_limit real,
    initial_interval integer,
    next_interval integer,
    initial_rate numeric,
    next_rate numeric,
    lcr_rate_multiplier numeric,
    capacity integer,
    valid_from timestamp without time zone,
    valid_till timestamp without time zone,
    gateway_group_name character varying,
    gateway_group_id integer,
    error_string character varying
);


--
-- TOC entry 237 (class 1259 OID 17777)
-- Name: import_dialpeers_id_seq; Type: SEQUENCE; Schema: data_import; Owner: -
--

CREATE SEQUENCE import_dialpeers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3560 (class 0 OID 0)
-- Dependencies: 237
-- Name: import_dialpeers_id_seq; Type: SEQUENCE OWNED BY; Schema: data_import; Owner: -
--

ALTER SEQUENCE import_dialpeers_id_seq OWNED BY import_dialpeers.id;


--
-- TOC entry 238 (class 1259 OID 17779)
-- Name: import_disconnect_policies; Type: TABLE; Schema: data_import; Owner: -; Tablespace: 
--

CREATE TABLE import_disconnect_policies (
    id bigint NOT NULL,
    o_id integer,
    name character varying,
    error_string character varying
);


--
-- TOC entry 239 (class 1259 OID 17785)
-- Name: import_disconnect_policies_id_seq; Type: SEQUENCE; Schema: data_import; Owner: -
--

CREATE SEQUENCE import_disconnect_policies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3561 (class 0 OID 0)
-- Dependencies: 239
-- Name: import_disconnect_policies_id_seq; Type: SEQUENCE OWNED BY; Schema: data_import; Owner: -
--

ALTER SEQUENCE import_disconnect_policies_id_seq OWNED BY import_disconnect_policies.id;


--
-- TOC entry 240 (class 1259 OID 17787)
-- Name: import_gateway_groups; Type: TABLE; Schema: data_import; Owner: -; Tablespace: 
--

CREATE TABLE import_gateway_groups (
    id bigint NOT NULL,
    o_id integer,
    name character varying,
    vendor_name character varying,
    vendor_id integer,
    prefer_same_pop boolean,
    error_string character varying
);


--
-- TOC entry 241 (class 1259 OID 17793)
-- Name: import_gateway_groups_id_seq; Type: SEQUENCE; Schema: data_import; Owner: -
--

CREATE SEQUENCE import_gateway_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3562 (class 0 OID 0)
-- Dependencies: 241
-- Name: import_gateway_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: data_import; Owner: -
--

ALTER SEQUENCE import_gateway_groups_id_seq OWNED BY import_gateway_groups.id;


--
-- TOC entry 242 (class 1259 OID 17795)
-- Name: import_gateways; Type: TABLE; Schema: data_import; Owner: -; Tablespace: 
--

CREATE TABLE import_gateways (
    host character varying,
    port integer,
    src_rewrite_rule character varying,
    dst_rewrite_rule character varying,
    acd_limit real,
    asr_limit real,
    enabled boolean,
    name character varying,
    term_auth_enabled boolean,
    term_auth_user character varying,
    term_auth_pwd character varying,
    term_outbound_proxy character varying,
    term_next_hop_for_replies boolean,
    term_use_outbound_proxy boolean,
    contractor_id integer,
    allow_termination boolean,
    allow_origination boolean,
    anonymize_sdp boolean,
    proxy_media boolean,
    transparent_seqno boolean,
    transparent_ssrc boolean,
    sst_enabled boolean,
    sst_minimum_timer integer,
    sst_maximum_timer integer,
    sst_accept501 boolean,
    session_refresh_method_id integer,
    sst_session_expires integer,
    term_force_outbound_proxy boolean,
    locked boolean,
    codecs_payload_order character varying,
    codecs_prefer_transcoding_for character varying,
    src_rewrite_result character varying,
    dst_rewrite_result character varying,
    capacity integer,
    term_next_hop character varying,
    orig_next_hop character varying,
    orig_append_headers_req character varying,
    term_append_headers_req character varying,
    dialog_nat_handling boolean,
    orig_force_outbound_proxy boolean,
    orig_use_outbound_proxy boolean,
    orig_outbound_proxy character varying,
    prefer_existing_codecs boolean,
    force_symmetric_rtp boolean,
    transparent_dialog_id boolean,
    message_filter_type_id integer,
    sdp_filter_type_id integer,
    sdp_alines_filter_type_id integer,
    message_filter_list character varying,
    sdp_filter_list character varying,
    sdp_alines_filter_list character varying,
    gateway_group_id integer,
    orig_disconnect_policy_id integer,
    term_disconnect_policy_id integer,
    diversion_policy_id integer,
    diversion_rewrite_rule character varying,
    diversion_rewrite_result character varying,
    src_name_rewrite_rule character varying,
    src_name_rewrite_result character varying,
    priority integer,
    pop_id integer,
    id integer NOT NULL,
    o_id integer,
    gateway_group_name character varying,
    contractor_name character varying,
    pop_name character varying,
    session_refresh_method_name character varying,
    message_filter_type_name character varying,
    sdp_filter_type_name character varying,
    sdp_alines_filter_type_name character varying,
    orig_disconnect_policy_name character varying,
    term_disconnect_policy_name character varying,
    diversion_policy_name character varying,
    error_string character varying
);


--
-- TOC entry 243 (class 1259 OID 17801)
-- Name: import_gateways_id_seq; Type: SEQUENCE; Schema: data_import; Owner: -
--

CREATE SEQUENCE import_gateways_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 244 (class 1259 OID 17803)
-- Name: import_gateways_id_seq1; Type: SEQUENCE; Schema: data_import; Owner: -
--

CREATE SEQUENCE import_gateways_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3563 (class 0 OID 0)
-- Dependencies: 244
-- Name: import_gateways_id_seq1; Type: SEQUENCE OWNED BY; Schema: data_import; Owner: -
--

ALTER SEQUENCE import_gateways_id_seq1 OWNED BY import_gateways.id;


--
-- TOC entry 245 (class 1259 OID 17805)
-- Name: import_rateplans; Type: TABLE; Schema: data_import; Owner: -; Tablespace: 
--

CREATE TABLE import_rateplans (
    id bigint NOT NULL,
    o_id integer,
    name character varying,
    error_string character varying
);


--
-- TOC entry 246 (class 1259 OID 17811)
-- Name: import_rateplans_id_seq; Type: SEQUENCE; Schema: data_import; Owner: -
--

CREATE SEQUENCE import_rateplans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3564 (class 0 OID 0)
-- Dependencies: 246
-- Name: import_rateplans_id_seq; Type: SEQUENCE OWNED BY; Schema: data_import; Owner: -
--

ALTER SEQUENCE import_rateplans_id_seq OWNED BY import_rateplans.id;


--
-- TOC entry 247 (class 1259 OID 17813)
-- Name: import_registrations; Type: TABLE; Schema: data_import; Owner: -; Tablespace: 
--

CREATE TABLE import_registrations (
    id bigint NOT NULL,
    o_id integer,
    name character varying,
    enabled boolean,
    pop_name character varying,
    pop_id integer,
    node_name character varying,
    node_id integer,
    domain character varying,
    username character varying,
    display_username character varying,
    auth_user character varying,
    proxy character varying,
    contact character varying,
    auth_password character varying,
    expire integer,
    force_expire boolean,
    error_string character varying
);


--
-- TOC entry 248 (class 1259 OID 17819)
-- Name: import_registrations_id_seq; Type: SEQUENCE; Schema: data_import; Owner: -
--

CREATE SEQUENCE import_registrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3565 (class 0 OID 0)
-- Dependencies: 248
-- Name: import_registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: data_import; Owner: -
--

ALTER SEQUENCE import_registrations_id_seq OWNED BY import_registrations.id;


--
-- TOC entry 249 (class 1259 OID 17821)
-- Name: import_routing_groups; Type: TABLE; Schema: data_import; Owner: -; Tablespace: 
--

CREATE TABLE import_routing_groups (
    id bigint NOT NULL,
    o_id integer,
    name character varying,
    sorting_name character varying,
    sorting_id integer,
    more_specific_per_vendor boolean,
    rate_delta_max numeric DEFAULT 0 NOT NULL,
    error_string character varying
);


--
-- TOC entry 250 (class 1259 OID 17828)
-- Name: import_routing_groups_id_seq; Type: SEQUENCE; Schema: data_import; Owner: -
--

CREATE SEQUENCE import_routing_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3566 (class 0 OID 0)
-- Dependencies: 250
-- Name: import_routing_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: data_import; Owner: -
--

ALTER SEQUENCE import_routing_groups_id_seq OWNED BY import_routing_groups.id;


SET search_path = gui, pg_catalog;

--
-- TOC entry 251 (class 1259 OID 17830)
-- Name: active_admin_comments; Type: TABLE; Schema: gui; Owner: -; Tablespace: 
--

CREATE TABLE active_admin_comments (
    id integer NOT NULL,
    resource_id character varying(255) NOT NULL,
    resource_type character varying(255) NOT NULL,
    author_id integer,
    author_type character varying(255),
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    namespace character varying(255)
);


--
-- TOC entry 252 (class 1259 OID 17836)
-- Name: admin_notes_id_seq; Type: SEQUENCE; Schema: gui; Owner: -
--

CREATE SEQUENCE admin_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3567 (class 0 OID 0)
-- Dependencies: 252
-- Name: admin_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: gui; Owner: -
--

ALTER SEQUENCE admin_notes_id_seq OWNED BY active_admin_comments.id;


--
-- TOC entry 253 (class 1259 OID 17838)
-- Name: admin_users; Type: TABLE; Schema: gui; Owner: -; Tablespace: 
--

CREATE TABLE admin_users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "group" integer DEFAULT 0,
    enabled boolean DEFAULT true,
    username character varying
);


--
-- TOC entry 254 (class 1259 OID 17849)
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: gui; Owner: -
--

CREATE SEQUENCE admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3568 (class 0 OID 0)
-- Dependencies: 254
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: gui; Owner: -
--

ALTER SEQUENCE admin_users_id_seq OWNED BY admin_users.id;


--
-- TOC entry 255 (class 1259 OID 17851)
-- Name: background_threads; Type: TABLE; Schema: gui; Owner: -; Tablespace: 
--

CREATE TABLE background_threads (
    id integer NOT NULL,
    name character varying,
    num integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    data_count bigint,
    data_processed bigint,
    exception text
);


--
-- TOC entry 256 (class 1259 OID 17857)
-- Name: background_threads_id_seq; Type: SEQUENCE; Schema: gui; Owner: -
--

CREATE SEQUENCE background_threads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3569 (class 0 OID 0)
-- Dependencies: 256
-- Name: background_threads_id_seq; Type: SEQUENCE OWNED BY; Schema: gui; Owner: -
--

ALTER SEQUENCE background_threads_id_seq OWNED BY background_threads.id;


--
-- TOC entry 257 (class 1259 OID 17859)
-- Name: schema_migrations; Type: TABLE; Schema: gui; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- TOC entry 258 (class 1259 OID 17862)
-- Name: versions; Type: TABLE; Schema: gui; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    item_id integer NOT NULL,
    event character varying(255) NOT NULL,
    whodunnit character varying(255),
    object text,
    created_at timestamp without time zone,
    ip character varying(255)
);


--
-- TOC entry 259 (class 1259 OID 17868)
-- Name: versions_id_seq; Type: SEQUENCE; Schema: gui; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3570 (class 0 OID 0)
-- Dependencies: 259
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: gui; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


SET search_path = logs, pg_catalog;

--
-- TOC entry 260 (class 1259 OID 17870)
-- Name: logic_log; Type: TABLE; Schema: logs; Owner: -; Tablespace: 
--

CREATE TABLE logic_log (
    id bigint NOT NULL,
    source character varying NOT NULL,
    level integer NOT NULL,
    msg text,
    txid bigint DEFAULT txid_current() NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 261 (class 1259 OID 17878)
-- Name: logic_log_id_seq; Type: SEQUENCE; Schema: logs; Owner: -
--

CREATE SEQUENCE logic_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3571 (class 0 OID 0)
-- Dependencies: 261
-- Name: logic_log_id_seq; Type: SEQUENCE OWNED BY; Schema: logs; Owner: -
--

ALTER SEQUENCE logic_log_id_seq OWNED BY logic_log.id;


SET search_path = public, pg_catalog;

--
-- TOC entry 262 (class 1259 OID 17880)
-- Name: contractors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contractors (
    id integer NOT NULL,
    name character varying,
    enabled boolean,
    vendor boolean,
    customer boolean
);


--
-- TOC entry 263 (class 1259 OID 17886)
-- Name: contractors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contractors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3572 (class 0 OID 0)
-- Dependencies: 263
-- Name: contractors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contractors_id_seq OWNED BY contractors.id;


SET search_path = reports, pg_catalog;

--
-- TOC entry 264 (class 1259 OID 17888)
-- Name: cdr_custom_report; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE cdr_custom_report (
    id integer NOT NULL,
    date_start timestamp without time zone,
    date_end timestamp without time zone,
    filter character varying,
    group_by character varying,
    created_at timestamp without time zone
);


--
-- TOC entry 265 (class 1259 OID 17894)
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
    time_start timestamp without time zone,
    time_connect timestamp without time zone,
    time_end timestamp without time zone,
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
    lega_rx_payloads character varying,
    lega_tx_payloads character varying,
    legb_rx_payloads character varying,
    legb_tx_payloads character varying,
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
-- TOC entry 266 (class 1259 OID 17900)
-- Name: cdr_custom_report_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE cdr_custom_report_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3573 (class 0 OID 0)
-- Dependencies: 266
-- Name: cdr_custom_report_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE cdr_custom_report_data_id_seq OWNED BY cdr_custom_report_data.id;


--
-- TOC entry 267 (class 1259 OID 17902)
-- Name: cdr_custom_report_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE cdr_custom_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3574 (class 0 OID 0)
-- Dependencies: 267
-- Name: cdr_custom_report_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE cdr_custom_report_id_seq OWNED BY cdr_custom_report.id;


--
-- TOC entry 268 (class 1259 OID 17904)
-- Name: cdr_interval_report; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE cdr_interval_report (
    id integer NOT NULL,
    date_start timestamp without time zone NOT NULL,
    date_end timestamp without time zone NOT NULL,
    filter character varying,
    group_by character varying,
    created_at timestamp without time zone NOT NULL,
    interval_length integer NOT NULL,
    aggregator_id integer NOT NULL,
    aggregate_by character varying NOT NULL
);


--
-- TOC entry 269 (class 1259 OID 17910)
-- Name: cdr_interval_report_aggrerator; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE cdr_interval_report_aggrerator (
    id integer NOT NULL,
    name character varying NOT NULL
);


--
-- TOC entry 270 (class 1259 OID 17916)
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
    time_start timestamp without time zone,
    time_connect timestamp without time zone,
    time_end timestamp without time zone,
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
    lega_rx_payloads character varying,
    lega_tx_payloads character varying,
    legb_rx_payloads character varying,
    legb_tx_payloads character varying,
    legb_disconnect_code integer,
    legb_disconnect_reason character varying,
    id bigint NOT NULL,
    report_id integer NOT NULL,
    "timestamp" timestamp without time zone,
    aggregated_value numeric
);


--
-- TOC entry 271 (class 1259 OID 17922)
-- Name: cdr_interval_report_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE cdr_interval_report_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3575 (class 0 OID 0)
-- Dependencies: 271
-- Name: cdr_interval_report_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE cdr_interval_report_data_id_seq OWNED BY cdr_interval_report_data.id;


--
-- TOC entry 272 (class 1259 OID 17924)
-- Name: cdr_interval_report_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE cdr_interval_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3576 (class 0 OID 0)
-- Dependencies: 272
-- Name: cdr_interval_report_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE cdr_interval_report_id_seq OWNED BY cdr_interval_report.id;


--
-- TOC entry 273 (class 1259 OID 17926)
-- Name: report_vendors; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE report_vendors (
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL
);


--
-- TOC entry 274 (class 1259 OID 17930)
-- Name: report_vendors_data; Type: TABLE; Schema: reports; Owner: -; Tablespace: 
--

CREATE TABLE report_vendors_data (
    id bigint NOT NULL,
    report_id integer NOT NULL,
    calls_count bigint
);


--
-- TOC entry 275 (class 1259 OID 17933)
-- Name: report_vendors_data_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE report_vendors_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3577 (class 0 OID 0)
-- Dependencies: 275
-- Name: report_vendors_data_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE report_vendors_data_id_seq OWNED BY report_vendors_data.id;


--
-- TOC entry 276 (class 1259 OID 17935)
-- Name: report_vendors_id_seq; Type: SEQUENCE; Schema: reports; Owner: -
--

CREATE SEQUENCE report_vendors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3578 (class 0 OID 0)
-- Dependencies: 276
-- Name: report_vendors_id_seq; Type: SEQUENCE OWNED BY; Schema: reports; Owner: -
--

ALTER SEQUENCE report_vendors_id_seq OWNED BY report_vendors.id;


SET search_path = runtime_stats, pg_catalog;

--
-- TOC entry 277 (class 1259 OID 17937)
-- Name: dialpeers_stats; Type: TABLE; Schema: runtime_stats; Owner: -; Tablespace: 
--

CREATE UNLOGGED TABLE dialpeers_stats (
    dialpeer_id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    calls bigint NOT NULL,
    calls_success bigint NOT NULL,
    calls_fail bigint NOT NULL,
    total_duration bigint NOT NULL,
    asr real,
    acd real,
    locked_at timestamp without time zone,
    unlocked_at timestamp without time zone,
    id bigint NOT NULL
);


--
-- TOC entry 278 (class 1259 OID 17942)
-- Name: dialpeers_stats_id_seq; Type: SEQUENCE; Schema: runtime_stats; Owner: -
--

CREATE SEQUENCE dialpeers_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 278
-- Name: dialpeers_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: runtime_stats; Owner: -
--

ALTER SEQUENCE dialpeers_stats_id_seq OWNED BY dialpeers_stats.id;


--
-- TOC entry 279 (class 1259 OID 17944)
-- Name: gateways_stats; Type: TABLE; Schema: runtime_stats; Owner: -; Tablespace: 
--

CREATE UNLOGGED TABLE gateways_stats (
    id integer NOT NULL,
    gateway_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    calls bigint NOT NULL,
    calls_success bigint NOT NULL,
    calls_fail bigint NOT NULL,
    total_duration bigint NOT NULL,
    asr real,
    acd real,
    locked_at timestamp without time zone,
    unlocked_at timestamp without time zone
);


--
-- TOC entry 280 (class 1259 OID 17949)
-- Name: gateways_stats_id_seq; Type: SEQUENCE; Schema: runtime_stats; Owner: -
--

CREATE SEQUENCE gateways_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 280
-- Name: gateways_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: runtime_stats; Owner: -
--

ALTER SEQUENCE gateways_stats_id_seq OWNED BY gateways_stats.id;


SET search_path = switch1, pg_catalog;

--
-- TOC entry 302 (class 1259 OID 18947)
-- Name: events_id_seq; Type: SEQUENCE; Schema: switch1; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 303 (class 1259 OID 18949)
-- Name: resource_action; Type: TABLE; Schema: switch1; Owner: -; Tablespace: 
--

CREATE TABLE resource_action (
    id integer NOT NULL,
    name character varying NOT NULL
);


--
-- TOC entry 304 (class 1259 OID 18955)
-- Name: resource_type_id_seq; Type: SEQUENCE; Schema: switch1; Owner: -
--

CREATE SEQUENCE resource_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 304
-- Name: resource_type_id_seq; Type: SEQUENCE OWNED BY; Schema: switch1; Owner: -
--

ALTER SEQUENCE resource_type_id_seq OWNED BY resource_type.id;


--
-- TOC entry 305 (class 1259 OID 18957)
-- Name: switch_in_interface_id_seq; Type: SEQUENCE; Schema: switch1; Owner: -
--

CREATE SEQUENCE switch_in_interface_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 306 (class 1259 OID 18959)
-- Name: switch_interface_out; Type: TABLE; Schema: switch1; Owner: -; Tablespace: 
--

CREATE TABLE switch_interface_out (
    id integer NOT NULL,
    name character varying,
    type character varying,
    custom boolean NOT NULL,
    rank integer NOT NULL
);


--
-- TOC entry 307 (class 1259 OID 18965)
-- Name: switch_interface_id_seq; Type: SEQUENCE; Schema: switch1; Owner: -
--

CREATE SEQUENCE switch_interface_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 307
-- Name: switch_interface_id_seq; Type: SEQUENCE OWNED BY; Schema: switch1; Owner: -
--

ALTER SEQUENCE switch_interface_id_seq OWNED BY switch_interface_out.id;


--
-- TOC entry 308 (class 1259 OID 18967)
-- Name: switch_interface_in; Type: TABLE; Schema: switch1; Owner: -; Tablespace: 
--

CREATE TABLE switch_interface_in (
    id integer DEFAULT nextval('switch_in_interface_id_seq'::regclass) NOT NULL,
    name character varying,
    type character varying,
    rank integer NOT NULL,
    format character varying,
    hashkey boolean DEFAULT false NOT NULL
);


--
-- TOC entry 309 (class 1259 OID 18975)
-- Name: trusted_headers; Type: TABLE; Schema: switch1; Owner: -; Tablespace: 
--

CREATE TABLE trusted_headers (
    id integer NOT NULL,
    name character varying,
    rank integer NOT NULL
);


--
-- TOC entry 310 (class 1259 OID 18981)
-- Name: trusted_headers_id_seq; Type: SEQUENCE; Schema: switch1; Owner: -
--

CREATE SEQUENCE trusted_headers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3583 (class 0 OID 0)
-- Dependencies: 310
-- Name: trusted_headers_id_seq; Type: SEQUENCE OWNED BY; Schema: switch1; Owner: -
--

ALTER SEQUENCE trusted_headers_id_seq OWNED BY trusted_headers.id;


SET search_path = sys, pg_catalog;

--
-- TOC entry 315 (class 1259 OID 19079)
-- Name: api_log_config; Type: TABLE; Schema: sys; Owner: -; Tablespace: 
--

CREATE TABLE api_log_config (
    id integer NOT NULL,
    controller character varying NOT NULL,
    debug boolean DEFAULT true NOT NULL
);


--
-- TOC entry 314 (class 1259 OID 19077)
-- Name: api_log_config_id_seq; Type: SEQUENCE; Schema: sys; Owner: -
--

CREATE SEQUENCE api_log_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 314
-- Name: api_log_config_id_seq; Type: SEQUENCE OWNED BY; Schema: sys; Owner: -
--

ALTER SEQUENCE api_log_config_id_seq OWNED BY api_log_config.id;


--
-- TOC entry 281 (class 1259 OID 17987)
-- Name: cdr_tables; Type: TABLE; Schema: sys; Owner: -; Tablespace: 
--

CREATE TABLE cdr_tables (
    id integer NOT NULL,
    name character varying NOT NULL,
    readable boolean DEFAULT true NOT NULL,
    writable boolean DEFAULT false NOT NULL,
    date_start character varying NOT NULL,
    date_stop character varying NOT NULL
);


--
-- TOC entry 282 (class 1259 OID 17995)
-- Name: cdrtables_id_seq; Type: SEQUENCE; Schema: sys; Owner: -
--

CREATE SEQUENCE cdrtables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 282
-- Name: cdrtables_id_seq; Type: SEQUENCE OWNED BY; Schema: sys; Owner: -
--

ALTER SEQUENCE cdrtables_id_seq OWNED BY cdr_tables.id;


--
-- TOC entry 283 (class 1259 OID 17997)
-- Name: events; Type: TABLE; Schema: sys; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    command character varying NOT NULL,
    retries integer DEFAULT 0 NOT NULL,
    node_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone,
    last_error character varying
);


--
-- TOC entry 284 (class 1259 OID 18006)
-- Name: guiconfig; Type: TABLE; Schema: sys; Owner: -; Tablespace: 
--

CREATE TABLE guiconfig (
    rows_per_page character varying,
    id integer NOT NULL,
    cdr_unload_dir character varying,
    cdr_unload_uri character varying,
    max_records integer DEFAULT 100500 NOT NULL,
    rowsperpage character varying DEFAULT '50,100'::character varying NOT NULL,
    import_max_threads integer DEFAULT 4 NOT NULL,
    import_helpers_dir character varying DEFAULT '/tmp'::character varying
);


--
-- TOC entry 285 (class 1259 OID 18016)
-- Name: guiconfig_id_seq; Type: SEQUENCE; Schema: sys; Owner: -
--

CREATE SEQUENCE guiconfig_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 285
-- Name: guiconfig_id_seq; Type: SEQUENCE OWNED BY; Schema: sys; Owner: -
--

ALTER SEQUENCE guiconfig_id_seq OWNED BY guiconfig.id;


--
-- TOC entry 313 (class 1259 OID 19052)
-- Name: jobs; Type: TABLE; Schema: sys; Owner: -; Tablespace: 
--

CREATE TABLE jobs (
    id integer NOT NULL,
    type character varying NOT NULL,
    description character varying,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    running boolean DEFAULT false NOT NULL
);


--
-- TOC entry 312 (class 1259 OID 19050)
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: sys; Owner: -
--

CREATE SEQUENCE jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3587 (class 0 OID 0)
-- Dependencies: 312
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: sys; Owner: -
--

ALTER SEQUENCE jobs_id_seq OWNED BY jobs.id;


--
-- TOC entry 286 (class 1259 OID 18018)
-- Name: nodes; Type: TABLE; Schema: sys; Owner: -; Tablespace: 
--

CREATE TABLE nodes (
    id integer NOT NULL,
    signalling_ip character varying,
    signalling_port integer,
    rpc_uri character varying,
    name character varying,
    pop_id integer NOT NULL
);


--
-- TOC entry 287 (class 1259 OID 18024)
-- Name: node_id_seq; Type: SEQUENCE; Schema: sys; Owner: -
--

CREATE SEQUENCE node_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 287
-- Name: node_id_seq; Type: SEQUENCE OWNED BY; Schema: sys; Owner: -
--

ALTER SEQUENCE node_id_seq OWNED BY nodes.id;


--
-- TOC entry 288 (class 1259 OID 18026)
-- Name: pops; Type: TABLE; Schema: sys; Owner: -; Tablespace: 
--

CREATE TABLE pops (
    id integer NOT NULL,
    name character varying NOT NULL
);


--
-- TOC entry 289 (class 1259 OID 18032)
-- Name: pop_id_seq; Type: SEQUENCE; Schema: sys; Owner: -
--

CREATE SEQUENCE pop_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3589 (class 0 OID 0)
-- Dependencies: 289
-- Name: pop_id_seq; Type: SEQUENCE OWNED BY; Schema: sys; Owner: -
--

ALTER SEQUENCE pop_id_seq OWNED BY pops.id;


--
-- TOC entry 290 (class 1259 OID 18034)
-- Name: version; Type: TABLE; Schema: sys; Owner: -; Tablespace: 
--

CREATE TABLE version (
    id bigint NOT NULL,
    number integer NOT NULL,
    apply_date timestamp without time zone DEFAULT now() NOT NULL,
    comment character varying
);


--
-- TOC entry 291 (class 1259 OID 18041)
-- Name: version_id_seq; Type: SEQUENCE; Schema: sys; Owner: -
--

CREATE SEQUENCE version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3590 (class 0 OID 0)
-- Dependencies: 291
-- Name: version_id_seq; Type: SEQUENCE OWNED BY; Schema: sys; Owner: -
--

ALTER SEQUENCE version_id_seq OWNED BY version.id;


SET search_path = billing, pg_catalog;

--
-- TOC entry 2819 (class 2604 OID 18043)
-- Name: id; Type: DEFAULT; Schema: billing; Owner: -
--

ALTER TABLE ONLY accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq'::regclass);


--
-- TOC entry 2998 (class 2604 OID 19096)
-- Name: id; Type: DEFAULT; Schema: billing; Owner: -
--

ALTER TABLE ONLY cdr_batches ALTER COLUMN id SET DEFAULT nextval('cdr_batches_id_seq'::regclass);


--
-- TOC entry 2986 (class 2604 OID 18879)
-- Name: id; Type: DEFAULT; Schema: billing; Owner: -
--

ALTER TABLE ONLY invoice_templates ALTER COLUMN id SET DEFAULT nextval('invoices_templates_id_seq'::regclass);


--
-- TOC entry 2891 (class 2604 OID 18044)
-- Name: id; Type: DEFAULT; Schema: billing; Owner: -
--

ALTER TABLE ONLY invoices ALTER COLUMN id SET DEFAULT nextval('invoices_id_seq'::regclass);


--
-- TOC entry 2893 (class 2604 OID 18045)
-- Name: id; Type: DEFAULT; Schema: billing; Owner: -
--

ALTER TABLE ONLY payments ALTER COLUMN id SET DEFAULT nextval('payments_id_seq'::regclass);


SET search_path = class4, pg_catalog;

--
-- TOC entry 2985 (class 2604 OID 18860)
-- Name: id; Type: DEFAULT; Schema: class4; Owner: -
--

ALTER TABLE ONLY blacklist_items ALTER COLUMN id SET DEFAULT nextval('blacklist_items_id_seq'::regclass);


--
-- TOC entry 2984 (class 2604 OID 18846)
-- Name: id; Type: DEFAULT; Schema: class4; Owner: -
--

ALTER TABLE ONLY blacklists ALTER COLUMN id SET DEFAULT nextval('blacklists_id_seq'::regclass);


--
-- TOC entry 2895 (class 2604 OID 18119)
-- Name: id; Type: DEFAULT; Schema: class4; Owner: -
--

ALTER TABLE ONLY codec_group_codecs ALTER COLUMN id SET DEFAULT nextval('codec_group_codecs_id_seq'::regclass);


--
-- TOC entry 2896 (class 2604 OID 18120)
-- Name: id; Type: DEFAULT; Schema: class4; Owner: -
--

ALTER TABLE ONLY codec_groups ALTER COLUMN id SET DEFAULT nextval('codec_groups_id_seq'::regclass);


--
-- TOC entry 2897 (class 2604 OID 18121)
-- Name: id; Type: DEFAULT; Schema: class4; Owner: -
--

ALTER TABLE ONLY codecs ALTER COLUMN id SET DEFAULT nextval('codecs_id_seq'::regclass);


--
-- TOC entry 2904 (class 2604 OID 18122)
-- Name: id; Type: DEFAULT; Schema: class4; Owner: -
--

ALTER TABLE ONLY customers_auth ALTER COLUMN id SET DEFAULT nextval('customers_auth_id_seq'::regclass);


--
-- TOC entry 2830 (class 2604 OID 18123)
-- Name: id; Type: DEFAULT; Schema: class4; Owner: -
--

ALTER TABLE ONLY destinations ALTER COLUMN id SET DEFAULT nextval('destinations_id_seq'::regclass);


--
-- TOC entry 2844 (class 2604 OID 18124)
-- Name: id; Type: DEFAULT; Schema: class4; Owner: -
--

ALTER TABLE ONLY dialpeers ALTER COLUMN id SET DEFAULT nextval('dialpeers_id_seq'::regclass);


--
-- TOC entry 2911 (class 2604 OID 18125)
-- Name: id; Type: DEFAULT; Schema: class4; Owner: -
--

ALTER TABLE ONLY disconnect_code ALTER COLUMN id SET DEFAULT nextval('disconnect_code_id_seq'::regclass);


--
-- TOC entry 2915 (class 2604 OID 18126)
-- Name: id; Type: DEFAULT; Schema: class4; Owner: -
--

ALTER TABLE ONLY disconnect_policy ALTER COLUMN id SET DEFAULT nextval('disconnect_code_policy_id_seq'::regclass);


--
-- TOC entry 2914 (class 2604 OID 18127)
-- Name: id; Type: DEFAULT; Schema: class4; Owner: -
--

ALTER TABLE ONLY disconnect_policy_code ALTER COLUMN id SET DEFAULT nextval('disconnect_code_policy_codes_id_seq'::regclass);


--
-- TOC entry 2919 (class 2604 OID 18128)
-- Name: id; Type: DEFAULT; Schema: class4; Owner: -
--

ALTER TABLE ONLY gateway_groups ALTER COLUMN id SET DEFAULT nextval('gateway_groups_id_seq'::regclass);


--
-- TOC entry 2889 (class 2604 OID 18129)
-- Name: id; Type: DEFAULT; Schema: class4; Owner: -
--

ALTER TABLE ONLY gateways ALTER COLUMN id SET DEFAULT nextval('gateways_id_seq'::regclass);


--
-- TOC entry 2920 (class 2604 OID 18130)
-- Name: id; Type: DEFAULT; Schema: class4; Owner: -
--

ALTER TABLE ONLY rateplans ALTER COLUMN id SET DEFAULT nextval('rateplans_id_seq'::regclass);


--
-- TOC entry 2923 (class 2604 OID 18131)
-- Name: id; Type: DEFAULT; Schema: class4; Owner: -
--

ALTER TABLE ONLY registrations ALTER COLUMN id SET DEFAULT nextval('registrations_id_seq'::regclass);


--
-- TOC entry 2927 (class 2604 OID 18132)
-- Name: id; Type: DEFAULT; Schema: class4; Owner: -
--

ALTER TABLE ONLY routing_groups ALTER COLUMN id SET DEFAULT nextval('routing_groups_id_seq'::regclass);


--
-- TOC entry 2928 (class 2604 OID 18133)
-- Name: id; Type: DEFAULT; Schema: class4; Owner: -
--

ALTER TABLE ONLY session_refresh_methods ALTER COLUMN id SET DEFAULT nextval('session_refresh_methods_id_seq'::regclass);


--
-- TOC entry 2929 (class 2604 OID 18134)
-- Name: id; Type: DEFAULT; Schema: class4; Owner: -
--

ALTER TABLE ONLY sortings ALTER COLUMN id SET DEFAULT nextval('sortings_id_seq'::regclass);


SET search_path = data_import, pg_catalog;

--
-- TOC entry 2930 (class 2604 OID 18135)
-- Name: id; Type: DEFAULT; Schema: data_import; Owner: -
--

ALTER TABLE ONLY import_accounts ALTER COLUMN id SET DEFAULT nextval('import_accounts_id_seq'::regclass);


--
-- TOC entry 2931 (class 2604 OID 18136)
-- Name: id; Type: DEFAULT; Schema: data_import; Owner: -
--

ALTER TABLE ONLY import_codec_group_codecs ALTER COLUMN id SET DEFAULT nextval('import_codec_group_codecs_id_seq'::regclass);


--
-- TOC entry 2932 (class 2604 OID 18137)
-- Name: id; Type: DEFAULT; Schema: data_import; Owner: -
--

ALTER TABLE ONLY import_codec_groups ALTER COLUMN id SET DEFAULT nextval('import_codec_groups_id_seq'::regclass);


--
-- TOC entry 2933 (class 2604 OID 18138)
-- Name: id; Type: DEFAULT; Schema: data_import; Owner: -
--

ALTER TABLE ONLY import_contractors ALTER COLUMN id SET DEFAULT nextval('import_contractors_id_seq'::regclass);


--
-- TOC entry 2934 (class 2604 OID 18139)
-- Name: id; Type: DEFAULT; Schema: data_import; Owner: -
--

ALTER TABLE ONLY import_customers_auth ALTER COLUMN id SET DEFAULT nextval('import_customers_auth_id_seq'::regclass);


--
-- TOC entry 2935 (class 2604 OID 18140)
-- Name: id; Type: DEFAULT; Schema: data_import; Owner: -
--

ALTER TABLE ONLY import_destinations ALTER COLUMN id SET DEFAULT nextval('import_destinations_id_seq'::regclass);


--
-- TOC entry 2936 (class 2604 OID 18141)
-- Name: id; Type: DEFAULT; Schema: data_import; Owner: -
--

ALTER TABLE ONLY import_dialpeers ALTER COLUMN id SET DEFAULT nextval('import_dialpeers_id_seq'::regclass);


--
-- TOC entry 2937 (class 2604 OID 18142)
-- Name: id; Type: DEFAULT; Schema: data_import; Owner: -
--

ALTER TABLE ONLY import_disconnect_policies ALTER COLUMN id SET DEFAULT nextval('import_disconnect_policies_id_seq'::regclass);


--
-- TOC entry 2938 (class 2604 OID 18143)
-- Name: id; Type: DEFAULT; Schema: data_import; Owner: -
--

ALTER TABLE ONLY import_gateway_groups ALTER COLUMN id SET DEFAULT nextval('import_gateway_groups_id_seq'::regclass);


--
-- TOC entry 2939 (class 2604 OID 18144)
-- Name: id; Type: DEFAULT; Schema: data_import; Owner: -
--

ALTER TABLE ONLY import_gateways ALTER COLUMN id SET DEFAULT nextval('import_gateways_id_seq1'::regclass);


--
-- TOC entry 2940 (class 2604 OID 18145)
-- Name: id; Type: DEFAULT; Schema: data_import; Owner: -
--

ALTER TABLE ONLY import_rateplans ALTER COLUMN id SET DEFAULT nextval('import_rateplans_id_seq'::regclass);


--
-- TOC entry 2941 (class 2604 OID 18146)
-- Name: id; Type: DEFAULT; Schema: data_import; Owner: -
--

ALTER TABLE ONLY import_registrations ALTER COLUMN id SET DEFAULT nextval('import_registrations_id_seq'::regclass);


--
-- TOC entry 2943 (class 2604 OID 18147)
-- Name: id; Type: DEFAULT; Schema: data_import; Owner: -
--

ALTER TABLE ONLY import_routing_groups ALTER COLUMN id SET DEFAULT nextval('import_routing_groups_id_seq'::regclass);


SET search_path = gui, pg_catalog;

--
-- TOC entry 2944 (class 2604 OID 18148)
-- Name: id; Type: DEFAULT; Schema: gui; Owner: -
--

ALTER TABLE ONLY active_admin_comments ALTER COLUMN id SET DEFAULT nextval('admin_notes_id_seq'::regclass);


--
-- TOC entry 2950 (class 2604 OID 18149)
-- Name: id; Type: DEFAULT; Schema: gui; Owner: -
--

ALTER TABLE ONLY admin_users ALTER COLUMN id SET DEFAULT nextval('admin_users_id_seq'::regclass);


--
-- TOC entry 2951 (class 2604 OID 18150)
-- Name: id; Type: DEFAULT; Schema: gui; Owner: -
--

ALTER TABLE ONLY background_threads ALTER COLUMN id SET DEFAULT nextval('background_threads_id_seq'::regclass);


--
-- TOC entry 2952 (class 2604 OID 18151)
-- Name: id; Type: DEFAULT; Schema: gui; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


SET search_path = logs, pg_catalog;

--
-- TOC entry 2955 (class 2604 OID 18152)
-- Name: id; Type: DEFAULT; Schema: logs; Owner: -
--

ALTER TABLE ONLY logic_log ALTER COLUMN id SET DEFAULT nextval('logic_log_id_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- TOC entry 2956 (class 2604 OID 18153)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contractors ALTER COLUMN id SET DEFAULT nextval('contractors_id_seq'::regclass);


SET search_path = reports, pg_catalog;

--
-- TOC entry 2957 (class 2604 OID 18154)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_custom_report ALTER COLUMN id SET DEFAULT nextval('cdr_custom_report_id_seq'::regclass);


--
-- TOC entry 2958 (class 2604 OID 18155)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_custom_report_data ALTER COLUMN id SET DEFAULT nextval('cdr_custom_report_data_id_seq'::regclass);


--
-- TOC entry 2959 (class 2604 OID 18156)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_interval_report ALTER COLUMN id SET DEFAULT nextval('cdr_interval_report_id_seq'::regclass);


--
-- TOC entry 2960 (class 2604 OID 18157)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_interval_report_data ALTER COLUMN id SET DEFAULT nextval('cdr_interval_report_data_id_seq'::regclass);


--
-- TOC entry 2962 (class 2604 OID 18158)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY report_vendors ALTER COLUMN id SET DEFAULT nextval('report_vendors_id_seq'::regclass);


--
-- TOC entry 2963 (class 2604 OID 18159)
-- Name: id; Type: DEFAULT; Schema: reports; Owner: -
--

ALTER TABLE ONLY report_vendors_data ALTER COLUMN id SET DEFAULT nextval('report_vendors_data_id_seq'::regclass);


SET search_path = runtime_stats, pg_catalog;

--
-- TOC entry 2966 (class 2604 OID 18160)
-- Name: id; Type: DEFAULT; Schema: runtime_stats; Owner: -
--

ALTER TABLE ONLY dialpeers_stats ALTER COLUMN id SET DEFAULT nextval('dialpeers_stats_id_seq'::regclass);


--
-- TOC entry 2969 (class 2604 OID 18161)
-- Name: id; Type: DEFAULT; Schema: runtime_stats; Owner: -
--

ALTER TABLE ONLY gateways_stats ALTER COLUMN id SET DEFAULT nextval('gateways_stats_id_seq'::regclass);


SET search_path = switch1, pg_catalog;

--
-- TOC entry 2987 (class 2604 OID 18983)
-- Name: id; Type: DEFAULT; Schema: switch1; Owner: -
--

ALTER TABLE ONLY resource_type ALTER COLUMN id SET DEFAULT nextval('resource_type_id_seq'::regclass);


--
-- TOC entry 2989 (class 2604 OID 18984)
-- Name: id; Type: DEFAULT; Schema: switch1; Owner: -
--

ALTER TABLE ONLY switch_interface_out ALTER COLUMN id SET DEFAULT nextval('switch_interface_id_seq'::regclass);


--
-- TOC entry 2992 (class 2604 OID 18985)
-- Name: id; Type: DEFAULT; Schema: switch1; Owner: -
--

ALTER TABLE ONLY trusted_headers ALTER COLUMN id SET DEFAULT nextval('trusted_headers_id_seq'::regclass);


SET search_path = sys, pg_catalog;

--
-- TOC entry 2996 (class 2604 OID 19082)
-- Name: id; Type: DEFAULT; Schema: sys; Owner: -
--

ALTER TABLE ONLY api_log_config ALTER COLUMN id SET DEFAULT nextval('api_log_config_id_seq'::regclass);


--
-- TOC entry 2972 (class 2604 OID 18165)
-- Name: id; Type: DEFAULT; Schema: sys; Owner: -
--

ALTER TABLE ONLY cdr_tables ALTER COLUMN id SET DEFAULT nextval('cdrtables_id_seq'::regclass);


--
-- TOC entry 2979 (class 2604 OID 18166)
-- Name: id; Type: DEFAULT; Schema: sys; Owner: -
--

ALTER TABLE ONLY guiconfig ALTER COLUMN id SET DEFAULT nextval('guiconfig_id_seq'::regclass);


--
-- TOC entry 2993 (class 2604 OID 19055)
-- Name: id; Type: DEFAULT; Schema: sys; Owner: -
--

ALTER TABLE ONLY jobs ALTER COLUMN id SET DEFAULT nextval('jobs_id_seq'::regclass);


--
-- TOC entry 2980 (class 2604 OID 18167)
-- Name: id; Type: DEFAULT; Schema: sys; Owner: -
--

ALTER TABLE ONLY nodes ALTER COLUMN id SET DEFAULT nextval('node_id_seq'::regclass);


--
-- TOC entry 2981 (class 2604 OID 18168)
-- Name: id; Type: DEFAULT; Schema: sys; Owner: -
--

ALTER TABLE ONLY pops ALTER COLUMN id SET DEFAULT nextval('pop_id_seq'::regclass);


--
-- TOC entry 2983 (class 2604 OID 18169)
-- Name: id; Type: DEFAULT; Schema: sys; Owner: -
--

ALTER TABLE ONLY version ALTER COLUMN id SET DEFAULT nextval('version_id_seq'::regclass);


SET search_path = billing, pg_catalog;

--
-- TOC entry 3386 (class 0 OID 17245)
-- Dependencies: 181
-- Data for Name: accounts; Type: TABLE DATA; Schema: billing; Owner: -
--



--
-- TOC entry 3591 (class 0 OID 0)
-- Dependencies: 185
-- Name: accounts_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: -
--

SELECT pg_catalog.setval('accounts_id_seq', 19, true);


--
-- TOC entry 3519 (class 0 OID 19093)
-- Dependencies: 317
-- Data for Name: cdr_batches; Type: TABLE DATA; Schema: billing; Owner: -
--



--
-- TOC entry 3592 (class 0 OID 0)
-- Dependencies: 316
-- Name: cdr_batches_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: -
--

SELECT pg_catalog.setval('cdr_batches_id_seq', 1, false);


--
-- TOC entry 3503 (class 0 OID 18876)
-- Dependencies: 299
-- Data for Name: invoice_templates; Type: TABLE DATA; Schema: billing; Owner: -
--



--
-- TOC entry 3391 (class 0 OID 17363)
-- Dependencies: 186
-- Data for Name: invoices; Type: TABLE DATA; Schema: billing; Owner: -
--



--
-- TOC entry 3593 (class 0 OID 0)
-- Dependencies: 187
-- Name: invoices_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: -
--

SELECT pg_catalog.setval('invoices_id_seq', 82, true);


--
-- TOC entry 3594 (class 0 OID 0)
-- Dependencies: 298
-- Name: invoices_templates_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: -
--

SELECT pg_catalog.setval('invoices_templates_id_seq', 2, true);


--
-- TOC entry 3393 (class 0 OID 17372)
-- Dependencies: 188
-- Data for Name: payments; Type: TABLE DATA; Schema: billing; Owner: -
--



--
-- TOC entry 3595 (class 0 OID 0)
-- Dependencies: 189
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: billing; Owner: -
--

SELECT pg_catalog.setval('payments_id_seq', 30, true);


SET search_path = class4, pg_catalog;

--
-- TOC entry 3501 (class 0 OID 18857)
-- Dependencies: 297
-- Data for Name: blacklist_items; Type: TABLE DATA; Schema: class4; Owner: -
--



--
-- TOC entry 3596 (class 0 OID 0)
-- Dependencies: 296
-- Name: blacklist_items_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: -
--

SELECT pg_catalog.setval('blacklist_items_id_seq', 1, true);


--
-- TOC entry 3499 (class 0 OID 18843)
-- Dependencies: 295
-- Data for Name: blacklists; Type: TABLE DATA; Schema: class4; Owner: -
--



--
-- TOC entry 3597 (class 0 OID 0)
-- Dependencies: 294
-- Name: blacklists_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: -
--

SELECT pg_catalog.setval('blacklists_id_seq', 1, true);


--
-- TOC entry 3395 (class 0 OID 17563)
-- Dependencies: 190
-- Data for Name: codec_group_codecs; Type: TABLE DATA; Schema: class4; Owner: -
--

INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (19, 1, 6, 64, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (20, 1, 7, 27, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (21, 1, 8, 66, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (22, 1, 9, 99, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (23, 1, 10, 40, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (24, 1, 11, 93, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (25, 1, 12, 32, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (26, 1, 13, 8, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (27, 1, 14, 68, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (28, 1, 15, 23, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (29, 1, 16, 33, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (30, 1, 17, 59, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (31, 1, 18, 95, NULL, NULL);
INSERT INTO codec_group_codecs (id, codec_group_id, codec_id, priority, dynamic_payload_type, format_parameters) VALUES (32, 1, 19, 6, NULL, NULL);


--
-- TOC entry 3598 (class 0 OID 0)
-- Dependencies: 191
-- Name: codec_group_codecs_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: -
--

SELECT pg_catalog.setval('codec_group_codecs_id_seq', 93, true);


--
-- TOC entry 3397 (class 0 OID 17569)
-- Dependencies: 192
-- Data for Name: codec_groups; Type: TABLE DATA; Schema: class4; Owner: -
--

INSERT INTO codec_groups (id, name) VALUES (1, 'Default codec group');


--
-- TOC entry 3599 (class 0 OID 0)
-- Dependencies: 193
-- Name: codec_groups_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: -
--

SELECT pg_catalog.setval('codec_groups_id_seq', 11, true);


--
-- TOC entry 3399 (class 0 OID 17577)
-- Dependencies: 194
-- Data for Name: codecs; Type: TABLE DATA; Schema: class4; Owner: -
--

INSERT INTO codecs (id, name) VALUES (6, 'telephone-event/8000');
INSERT INTO codecs (id, name) VALUES (7, 'G723/8000');
INSERT INTO codecs (id, name) VALUES (8, 'G729/8000');
INSERT INTO codecs (id, name) VALUES (9, 'PCMU/8000');
INSERT INTO codecs (id, name) VALUES (10, 'PCMA/8000');
INSERT INTO codecs (id, name) VALUES (11, 'iLBC/8000');
INSERT INTO codecs (id, name) VALUES (12, 'speex/8000');
INSERT INTO codecs (id, name) VALUES (13, 'GSM/8000');
INSERT INTO codecs (id, name) VALUES (14, 'G726-32/8000');
INSERT INTO codecs (id, name) VALUES (15, 'G721/8000');
INSERT INTO codecs (id, name) VALUES (16, 'G726-24/8000');
INSERT INTO codecs (id, name) VALUES (17, 'G726-40/8000');
INSERT INTO codecs (id, name) VALUES (18, 'G726-16/8000');
INSERT INTO codecs (id, name) VALUES (19, 'L16/8000');


--
-- TOC entry 3600 (class 0 OID 0)
-- Dependencies: 195
-- Name: codecs_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: -
--

SELECT pg_catalog.setval('codecs_id_seq', 19, true);


--
-- TOC entry 3401 (class 0 OID 17585)
-- Dependencies: 196
-- Data for Name: customers_auth; Type: TABLE DATA; Schema: class4; Owner: -
--



--
-- TOC entry 3601 (class 0 OID 0)
-- Dependencies: 197
-- Name: customers_auth_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: -
--

SELECT pg_catalog.setval('customers_auth_id_seq', 20083, true);


--
-- TOC entry 3403 (class 0 OID 17599)
-- Dependencies: 198
-- Data for Name: destination_rate_policy; Type: TABLE DATA; Schema: class4; Owner: -
--

INSERT INTO destination_rate_policy (id, name) VALUES (1, 'Fixed');
INSERT INTO destination_rate_policy (id, name) VALUES (2, 'Based on used dialpeer');
INSERT INTO destination_rate_policy (id, name) VALUES (3, 'MIN(Fixed,Based on used dialpeer)');
INSERT INTO destination_rate_policy (id, name) VALUES (4, 'MAX(Fixed,Based on used dialpeer)');


--
-- TOC entry 3387 (class 0 OID 17253)
-- Dependencies: 182
-- Data for Name: destinations; Type: TABLE DATA; Schema: class4; Owner: -
--



--
-- TOC entry 3602 (class 0 OID 0)
-- Dependencies: 199
-- Name: destinations_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: -
--

SELECT pg_catalog.setval('destinations_id_seq', 4201530, true);


--
-- TOC entry 3388 (class 0 OID 17271)
-- Dependencies: 183
-- Data for Name: dialpeers; Type: TABLE DATA; Schema: class4; Owner: -
--



--
-- TOC entry 3603 (class 0 OID 0)
-- Dependencies: 200
-- Name: dialpeers_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: -
--

SELECT pg_catalog.setval('dialpeers_id_seq', 1376783, true);


--
-- TOC entry 3406 (class 0 OID 17609)
-- Dependencies: 201
-- Data for Name: disconnect_code; Type: TABLE DATA; Schema: class4; Owner: -
--

INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (126, 1, true, false, 200, 'NoAck', NULL, NULL, false, true, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (127, 1, true, false, 200, 'NoPrack', NULL, NULL, false, true, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (128, 1, true, false, 200, 'Session Timeout', NULL, NULL, false, true, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (129, 1, true, false, 200, 'Internal Error', NULL, NULL, false, true, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (113, 0, false, false, 404, 'No routes', NULL, '', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (57, 2, false, false, 401, 'Unauthorized', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (59, 2, false, false, 403, 'Forbidden', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (65, 2, false, false, 409, 'Conflict', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (66, 2, false, false, 410, 'Gone', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (89, 2, false, false, 485, 'Ambiguous', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (95, 2, false, false, 493, 'Undecipherable', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (106, 2, false, false, 603, 'Decline', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (110, 0, false, false, 403, 'Cant find customer or customer locked', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (111, 0, false, false, 404, 'Cant find destination prefix', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (62, 2, false, false, 406, 'Not Acceptable', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (63, 2, false, false, 407, 'Proxy Authentication Required', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (109, 2, true, false, 200, 'OK', NULL, '', true, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (64, 2, false, false, 408, 'Request Timeout', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (67, 2, false, false, 412, 'Conditional Request Failed', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (93, 2, false, false, 489, 'Bad Event', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (68, 2, false, false, 413, 'Request Entity Too Large', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (69, 2, false, false, 414, 'Request-URI Too Long', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (51, 2, false, false, 300, 'Multiple Choices', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (52, 2, false, false, 301, 'Moved Permanently', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (53, 2, false, false, 302, 'Moved Temporarily', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (54, 2, false, false, 305, 'Use Proxy', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (55, 2, false, false, 380, 'Alternative Service', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (56, 2, false, false, 400, 'Bad Request', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (58, 2, false, false, 402, 'Payment Required', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (61, 2, false, false, 405, 'Method Not Allowed', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (140, 1, true, false, 488, 'Codecs group $cg not found', NULL, 'Not Acceptable Here', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (141, 1, true, false, 488, 'Codecs not matched', NULL, 'Not Acceptable Here', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (70, 2, false, false, 415, 'Unsupported Media Type', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (71, 2, false, false, 416, 'Unsupported URI Scheme', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (72, 2, false, false, 417, 'Unknown Resource-Priority', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (73, 2, false, false, 420, 'Bad Extension', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (74, 2, false, false, 421, 'Extension Required', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (75, 2, false, false, 422, 'Session Interval Too Small', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (76, 2, false, false, 423, 'Interval Too Brief', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (77, 2, false, false, 424, 'Bad Location Information', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (78, 2, false, false, 428, 'Use Identity Header', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (79, 2, false, false, 429, 'Provide Referrer Identity', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (80, 2, false, false, 433, 'Anonymity Disallowed', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (81, 2, false, false, 436, 'Bad Identity-Info', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (82, 2, false, false, 437, 'Unsupported Certificate', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (83, 2, false, false, 438, 'Invalid Identity Header', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (84, 2, false, false, 480, 'Temporarily Unavailable', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (85, 2, false, false, 481, 'Call/Transaction Does Not Exist', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (86, 2, false, false, 482, 'Loop Detected', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (87, 2, false, false, 483, 'Too Many Hops', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (88, 2, false, false, 484, 'Address Incomplete', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (91, 2, false, false, 487, 'Request Terminated', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (92, 2, false, false, 488, 'Not Acceptable Here', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (94, 2, false, false, 491, 'Request Pending', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (96, 2, false, false, 494, 'Security Agreement Required', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (97, 2, false, false, 500, 'Server Internal Error', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (98, 2, false, false, 501, 'Not Implemented', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (99, 2, false, false, 502, 'Bad Gateway', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (101, 2, false, false, 504, 'Server Time-out', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (102, 2, false, false, 505, 'Version Not Supported', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (103, 2, false, false, 513, 'Message Too Large', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (104, 2, false, false, 580, 'Precondition Failure', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (105, 2, false, false, 600, 'Busy Everywhere', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (107, 2, false, false, 604, 'Does Not Exist Anywhere', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (108, 2, false, false, 606, 'Not Acceptable', NULL, NULL, false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (125, 1, true, false, 200, 'Rtp timeout', NULL, '', false, true, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (100, 2, false, false, 503, 'Service Unavailable', NULL, '', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (90, 2, true, false, 486, 'Busy Here', NULL, '', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (114, 1, true, false, 400, 'cant parse From in req', NULL, 'Bad Request', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (115, 1, true, false, 400, 'cant parse To in req', NULL, 'Bad Request', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (116, 1, true, false, 400, 'cant parse Contact in req', NULL, 'Bad Request', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (112, 0, false, true, 403, 'Rejected by destination', NULL, 'Rejected by dst', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (121, 1, true, false, 500, 'failed to get active connection', NULL, 'Internal Server Error', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (122, 1, true, false, 500, 'db broken connection', NULL, 'Internal Server Error', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (123, 1, true, false, 500, 'db conversion exception', NULL, 'Internal Server Error', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (124, 1, true, false, 500, 'db base exception', NULL, 'Internal Server Error', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (60, 2, false, false, 404, 'Not Found', NULL, '', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (117, 1, true, false, 500, 'no such prepared query', NULL, 'Internal Server Error', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (118, 1, true, false, 500, 'empty response from database', NULL, 'Internal Server Error', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (119, 1, true, false, 500, 'read from tuple failed', NULL, 'Internal Server Error', false, false, true, false);
INSERT INTO disconnect_code (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop) VALUES (120, 1, true, false, 500, 'profile evaluation failed', NULL, 'Internal Server Error', false, false, true, false);


--
-- TOC entry 3604 (class 0 OID 0)
-- Dependencies: 202
-- Name: disconnect_code_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: -
--

SELECT pg_catalog.setval('disconnect_code_id_seq', 122, true);


--
-- TOC entry 3385 (class 0 OID 17217)
-- Dependencies: 180
-- Data for Name: disconnect_code_namespace; Type: TABLE DATA; Schema: class4; Owner: -
--

INSERT INTO disconnect_code_namespace (id, name) VALUES (2, 'SIP');
INSERT INTO disconnect_code_namespace (id, name) VALUES (0, 'TM');
INSERT INTO disconnect_code_namespace (id, name) VALUES (1, 'TS');


--
-- TOC entry 3605 (class 0 OID 0)
-- Dependencies: 204
-- Name: disconnect_code_policy_codes_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: -
--

SELECT pg_catalog.setval('disconnect_code_policy_codes_id_seq', 3, true);


--
-- TOC entry 3606 (class 0 OID 0)
-- Dependencies: 206
-- Name: disconnect_code_policy_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: -
--

SELECT pg_catalog.setval('disconnect_code_policy_id_seq', 2, true);


--
-- TOC entry 3412 (class 0 OID 17641)
-- Dependencies: 207
-- Data for Name: disconnect_initiators; Type: TABLE DATA; Schema: class4; Owner: -
--

INSERT INTO disconnect_initiators (id, name) VALUES (0, 'Traffic manager');
INSERT INTO disconnect_initiators (id, name) VALUES (1, 'Traffic switch');
INSERT INTO disconnect_initiators (id, name) VALUES (2, 'Destination');
INSERT INTO disconnect_initiators (id, name) VALUES (3, 'Origination');


--
-- TOC entry 3410 (class 0 OID 17633)
-- Dependencies: 205
-- Data for Name: disconnect_policy; Type: TABLE DATA; Schema: class4; Owner: -
--



--
-- TOC entry 3408 (class 0 OID 17623)
-- Dependencies: 203
-- Data for Name: disconnect_policy_code; Type: TABLE DATA; Schema: class4; Owner: -
--



--
-- TOC entry 3413 (class 0 OID 17647)
-- Dependencies: 208
-- Data for Name: diversion_policy; Type: TABLE DATA; Schema: class4; Owner: -
--

INSERT INTO diversion_policy (id, name) VALUES (1, 'Clear header');


--
-- TOC entry 3414 (class 0 OID 17653)
-- Dependencies: 209
-- Data for Name: dump_level; Type: TABLE DATA; Schema: class4; Owner: -
--

INSERT INTO dump_level (id, name, log_sip, log_rtp) VALUES (3, 'Capture all traffic', true, true);
INSERT INTO dump_level (id, name, log_sip, log_rtp) VALUES (0, 'Capture nothing', false, false);
INSERT INTO dump_level (id, name, log_sip, log_rtp) VALUES (2, 'Capture rtp traffic', true, false);
INSERT INTO dump_level (id, name, log_sip, log_rtp) VALUES (1, 'Capture signaling traffic', true, false);


--
-- TOC entry 3415 (class 0 OID 17661)
-- Dependencies: 210
-- Data for Name: filter_types; Type: TABLE DATA; Schema: class4; Owner: -
--

INSERT INTO filter_types (id, name) VALUES (0, 'Transparent');
INSERT INTO filter_types (id, name) VALUES (1, 'Blacklist');
INSERT INTO filter_types (id, name) VALUES (2, 'Whitelist');


--
-- TOC entry 3416 (class 0 OID 17667)
-- Dependencies: 211
-- Data for Name: gateway_groups; Type: TABLE DATA; Schema: class4; Owner: -
--



--
-- TOC entry 3607 (class 0 OID 0)
-- Dependencies: 212
-- Name: gateway_groups_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: -
--

SELECT pg_catalog.setval('gateway_groups_id_seq', 2, true);


--
-- TOC entry 3389 (class 0 OID 17290)
-- Dependencies: 184
-- Data for Name: gateways; Type: TABLE DATA; Schema: class4; Owner: -
--



--
-- TOC entry 3608 (class 0 OID 0)
-- Dependencies: 213
-- Name: gateways_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: -
--

SELECT pg_catalog.setval('gateways_id_seq', 15, true);


--
-- TOC entry 3419 (class 0 OID 17678)
-- Dependencies: 214
-- Data for Name: rateplans; Type: TABLE DATA; Schema: class4; Owner: -
--



--
-- TOC entry 3609 (class 0 OID 0)
-- Dependencies: 215
-- Name: rateplans_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: -
--

SELECT pg_catalog.setval('rateplans_id_seq', 13, true);


--
-- TOC entry 3421 (class 0 OID 17686)
-- Dependencies: 216
-- Data for Name: registrations; Type: TABLE DATA; Schema: class4; Owner: -
--



--
-- TOC entry 3610 (class 0 OID 0)
-- Dependencies: 217
-- Name: registrations_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: -
--

SELECT pg_catalog.setval('registrations_id_seq', 4, true);


--
-- TOC entry 3423 (class 0 OID 17696)
-- Dependencies: 218
-- Data for Name: routing_groups; Type: TABLE DATA; Schema: class4; Owner: -
--



--
-- TOC entry 3611 (class 0 OID 0)
-- Dependencies: 219
-- Name: routing_groups_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: -
--

SELECT pg_catalog.setval('routing_groups_id_seq', 16, true);


--
-- TOC entry 3497 (class 0 OID 18795)
-- Dependencies: 293
-- Data for Name: sdp_c_location; Type: TABLE DATA; Schema: class4; Owner: -
--

INSERT INTO sdp_c_location (id, name) VALUES (0, 'On session and media level');
INSERT INTO sdp_c_location (id, name) VALUES (1, 'On session level');
INSERT INTO sdp_c_location (id, name) VALUES (2, 'On media level');


--
-- TOC entry 3425 (class 0 OID 17707)
-- Dependencies: 220
-- Data for Name: session_refresh_methods; Type: TABLE DATA; Schema: class4; Owner: -
--

INSERT INTO session_refresh_methods (id, value, name) VALUES (1, 'INVITE', 'Invite');
INSERT INTO session_refresh_methods (id, value, name) VALUES (2, 'UPDATE', 'Update request');
INSERT INTO session_refresh_methods (id, value, name) VALUES (3, 'UPDATE_FALLBACK_INVITE', 'Update request and invite if unsupported');


--
-- TOC entry 3612 (class 0 OID 0)
-- Dependencies: 221
-- Name: session_refresh_methods_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: -
--

SELECT pg_catalog.setval('session_refresh_methods_id_seq', 3, true);


--
-- TOC entry 3427 (class 0 OID 17715)
-- Dependencies: 222
-- Data for Name: sortings; Type: TABLE DATA; Schema: class4; Owner: -
--

INSERT INTO sortings (id, name, description) VALUES (2, 'LCR, No ACD&ASR control', 'Without ACD&ASR control');
INSERT INTO sortings (id, name, description) VALUES (3, 'Prio,LCR, ACD&ASR control', 'Same as default, but priotity has more weight');
INSERT INTO sortings (id, name, description) VALUES (1, 'LCR,Prio, ACD&ASR control', 'Default dialpeer sorting method');
INSERT INTO sortings (id, name, description) VALUES (4, 'LCRD, Prio, ACD&ASR control', 'Same as default, but take in account diff between costs');


--
-- TOC entry 3613 (class 0 OID 0)
-- Dependencies: 223
-- Name: sortings_id_seq; Type: SEQUENCE SET; Schema: class4; Owner: -
--

SELECT pg_catalog.setval('sortings_id_seq', 3, true);


SET search_path = data_import, pg_catalog;

--
-- TOC entry 3429 (class 0 OID 17723)
-- Dependencies: 224
-- Data for Name: import_accounts; Type: TABLE DATA; Schema: data_import; Owner: -
--



--
-- TOC entry 3614 (class 0 OID 0)
-- Dependencies: 225
-- Name: import_accounts_id_seq; Type: SEQUENCE SET; Schema: data_import; Owner: -
--

SELECT pg_catalog.setval('import_accounts_id_seq', 6, true);


--
-- TOC entry 3431 (class 0 OID 17731)
-- Dependencies: 226
-- Data for Name: import_codec_group_codecs; Type: TABLE DATA; Schema: data_import; Owner: -
--



--
-- TOC entry 3615 (class 0 OID 0)
-- Dependencies: 227
-- Name: import_codec_group_codecs_id_seq; Type: SEQUENCE SET; Schema: data_import; Owner: -
--

SELECT pg_catalog.setval('import_codec_group_codecs_id_seq', 1, false);


--
-- TOC entry 3433 (class 0 OID 17739)
-- Dependencies: 228
-- Data for Name: import_codec_groups; Type: TABLE DATA; Schema: data_import; Owner: -
--



--
-- TOC entry 3616 (class 0 OID 0)
-- Dependencies: 229
-- Name: import_codec_groups_id_seq; Type: SEQUENCE SET; Schema: data_import; Owner: -
--

SELECT pg_catalog.setval('import_codec_groups_id_seq', 1, false);


--
-- TOC entry 3435 (class 0 OID 17747)
-- Dependencies: 230
-- Data for Name: import_contractors; Type: TABLE DATA; Schema: data_import; Owner: -
--



--
-- TOC entry 3617 (class 0 OID 0)
-- Dependencies: 231
-- Name: import_contractors_id_seq; Type: SEQUENCE SET; Schema: data_import; Owner: -
--

SELECT pg_catalog.setval('import_contractors_id_seq', 27, true);


--
-- TOC entry 3437 (class 0 OID 17755)
-- Dependencies: 232
-- Data for Name: import_customers_auth; Type: TABLE DATA; Schema: data_import; Owner: -
--



--
-- TOC entry 3618 (class 0 OID 0)
-- Dependencies: 233
-- Name: import_customers_auth_id_seq; Type: SEQUENCE SET; Schema: data_import; Owner: -
--

SELECT pg_catalog.setval('import_customers_auth_id_seq', 391797, true);


--
-- TOC entry 3439 (class 0 OID 17763)
-- Dependencies: 234
-- Data for Name: import_destinations; Type: TABLE DATA; Schema: data_import; Owner: -
--



--
-- TOC entry 3619 (class 0 OID 0)
-- Dependencies: 235
-- Name: import_destinations_id_seq; Type: SEQUENCE SET; Schema: data_import; Owner: -
--

SELECT pg_catalog.setval('import_destinations_id_seq', 71248, true);


--
-- TOC entry 3441 (class 0 OID 17771)
-- Dependencies: 236
-- Data for Name: import_dialpeers; Type: TABLE DATA; Schema: data_import; Owner: -
--



--
-- TOC entry 3620 (class 0 OID 0)
-- Dependencies: 237
-- Name: import_dialpeers_id_seq; Type: SEQUENCE SET; Schema: data_import; Owner: -
--

SELECT pg_catalog.setval('import_dialpeers_id_seq', 929472, true);


--
-- TOC entry 3443 (class 0 OID 17779)
-- Dependencies: 238
-- Data for Name: import_disconnect_policies; Type: TABLE DATA; Schema: data_import; Owner: -
--



--
-- TOC entry 3621 (class 0 OID 0)
-- Dependencies: 239
-- Name: import_disconnect_policies_id_seq; Type: SEQUENCE SET; Schema: data_import; Owner: -
--

SELECT pg_catalog.setval('import_disconnect_policies_id_seq', 6, true);


--
-- TOC entry 3445 (class 0 OID 17787)
-- Dependencies: 240
-- Data for Name: import_gateway_groups; Type: TABLE DATA; Schema: data_import; Owner: -
--



--
-- TOC entry 3622 (class 0 OID 0)
-- Dependencies: 241
-- Name: import_gateway_groups_id_seq; Type: SEQUENCE SET; Schema: data_import; Owner: -
--

SELECT pg_catalog.setval('import_gateway_groups_id_seq', 3, true);


--
-- TOC entry 3447 (class 0 OID 17795)
-- Dependencies: 242
-- Data for Name: import_gateways; Type: TABLE DATA; Schema: data_import; Owner: -
--



--
-- TOC entry 3623 (class 0 OID 0)
-- Dependencies: 243
-- Name: import_gateways_id_seq; Type: SEQUENCE SET; Schema: data_import; Owner: -
--

SELECT pg_catalog.setval('import_gateways_id_seq', 1, true);


--
-- TOC entry 3624 (class 0 OID 0)
-- Dependencies: 244
-- Name: import_gateways_id_seq1; Type: SEQUENCE SET; Schema: data_import; Owner: -
--

SELECT pg_catalog.setval('import_gateways_id_seq1', 14, true);


--
-- TOC entry 3450 (class 0 OID 17805)
-- Dependencies: 245
-- Data for Name: import_rateplans; Type: TABLE DATA; Schema: data_import; Owner: -
--



--
-- TOC entry 3625 (class 0 OID 0)
-- Dependencies: 246
-- Name: import_rateplans_id_seq; Type: SEQUENCE SET; Schema: data_import; Owner: -
--

SELECT pg_catalog.setval('import_rateplans_id_seq', 55, true);


--
-- TOC entry 3452 (class 0 OID 17813)
-- Dependencies: 247
-- Data for Name: import_registrations; Type: TABLE DATA; Schema: data_import; Owner: -
--



--
-- TOC entry 3626 (class 0 OID 0)
-- Dependencies: 248
-- Name: import_registrations_id_seq; Type: SEQUENCE SET; Schema: data_import; Owner: -
--

SELECT pg_catalog.setval('import_registrations_id_seq', 12, true);


--
-- TOC entry 3454 (class 0 OID 17821)
-- Dependencies: 249
-- Data for Name: import_routing_groups; Type: TABLE DATA; Schema: data_import; Owner: -
--



--
-- TOC entry 3627 (class 0 OID 0)
-- Dependencies: 250
-- Name: import_routing_groups_id_seq; Type: SEQUENCE SET; Schema: data_import; Owner: -
--

SELECT pg_catalog.setval('import_routing_groups_id_seq', 37, true);


SET search_path = gui, pg_catalog;

--
-- TOC entry 3456 (class 0 OID 17830)
-- Dependencies: 251
-- Data for Name: active_admin_comments; Type: TABLE DATA; Schema: gui; Owner: -
--



--
-- TOC entry 3628 (class 0 OID 0)
-- Dependencies: 252
-- Name: admin_notes_id_seq; Type: SEQUENCE SET; Schema: gui; Owner: -
--

SELECT pg_catalog.setval('admin_notes_id_seq', 19, true);


--
-- TOC entry 3458 (class 0 OID 17838)
-- Dependencies: 253
-- Data for Name: admin_users; Type: TABLE DATA; Schema: gui; Owner: -
--

INSERT INTO admin_users (id, email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, created_at, updated_at, "group", enabled, username) VALUES (3, 'admin@example.com', '$2a$10$2346aIc.UfYbcoRUET4Fwuaqg573IrYcK2dnmxtdg2JC6OqJxK4U2', NULL, NULL, NULL, 478, '2014-10-13 11:34:08.58971', '2014-08-30 20:10:17.957932', '127.0.0.1', '127.0.0.1', '2012-09-07 15:20:21.93699', '2014-10-13 11:34:08.594442', 1, true, 'admin');


--
-- TOC entry 3629 (class 0 OID 0)
-- Dependencies: 254
-- Name: admin_users_id_seq; Type: SEQUENCE SET; Schema: gui; Owner: -
--

SELECT pg_catalog.setval('admin_users_id_seq', 11, true);


--
-- TOC entry 3460 (class 0 OID 17851)
-- Dependencies: 255
-- Data for Name: background_threads; Type: TABLE DATA; Schema: gui; Owner: -
--



--
-- TOC entry 3630 (class 0 OID 0)
-- Dependencies: 256
-- Name: background_threads_id_seq; Type: SEQUENCE SET; Schema: gui; Owner: -
--

SELECT pg_catalog.setval('background_threads_id_seq', 142, true);


--
-- TOC entry 3462 (class 0 OID 17859)
-- Dependencies: 257
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: gui; Owner: -
--

INSERT INTO schema_migrations (version) VALUES ('20120907095248');
INSERT INTO schema_migrations (version) VALUES ('20120907095254');
INSERT INTO schema_migrations (version) VALUES ('20120907095255');
INSERT INTO schema_migrations (version) VALUES ('20121009201653');
INSERT INTO schema_migrations (version) VALUES ('20121009202153');
INSERT INTO schema_migrations (version) VALUES ('20121010090537');
INSERT INTO schema_migrations (version) VALUES ('20121104095920');


--
-- TOC entry 3463 (class 0 OID 17862)
-- Dependencies: 258
-- Data for Name: versions; Type: TABLE DATA; Schema: gui; Owner: -
--



--
-- TOC entry 3631 (class 0 OID 0)
-- Dependencies: 259
-- Name: versions_id_seq; Type: SEQUENCE SET; Schema: gui; Owner: -
--

SELECT pg_catalog.setval('versions_id_seq', 458850, true);


SET search_path = logs, pg_catalog;

--
-- TOC entry 3465 (class 0 OID 17870)
-- Dependencies: 260
-- Data for Name: logic_log; Type: TABLE DATA; Schema: logs; Owner: -
--



--
-- TOC entry 3632 (class 0 OID 0)
-- Dependencies: 261
-- Name: logic_log_id_seq; Type: SEQUENCE SET; Schema: logs; Owner: -
--

SELECT pg_catalog.setval('logic_log_id_seq', 74, true);


SET search_path = public, pg_catalog;

--
-- TOC entry 3467 (class 0 OID 17880)
-- Dependencies: 262
-- Data for Name: contractors; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3633 (class 0 OID 0)
-- Dependencies: 263
-- Name: contractors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('contractors_id_seq', 21, true);


SET search_path = reports, pg_catalog;

--
-- TOC entry 3469 (class 0 OID 17888)
-- Dependencies: 264
-- Data for Name: cdr_custom_report; Type: TABLE DATA; Schema: reports; Owner: -
--



--
-- TOC entry 3470 (class 0 OID 17894)
-- Dependencies: 265
-- Data for Name: cdr_custom_report_data; Type: TABLE DATA; Schema: reports; Owner: -
--



--
-- TOC entry 3634 (class 0 OID 0)
-- Dependencies: 266
-- Name: cdr_custom_report_data_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: -
--

SELECT pg_catalog.setval('cdr_custom_report_data_id_seq', 30, true);


--
-- TOC entry 3635 (class 0 OID 0)
-- Dependencies: 267
-- Name: cdr_custom_report_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: -
--

SELECT pg_catalog.setval('cdr_custom_report_id_seq', 81, true);


--
-- TOC entry 3473 (class 0 OID 17904)
-- Dependencies: 268
-- Data for Name: cdr_interval_report; Type: TABLE DATA; Schema: reports; Owner: -
--



--
-- TOC entry 3474 (class 0 OID 17910)
-- Dependencies: 269
-- Data for Name: cdr_interval_report_aggrerator; Type: TABLE DATA; Schema: reports; Owner: -
--

INSERT INTO cdr_interval_report_aggrerator (id, name) VALUES (1, 'Sum');
INSERT INTO cdr_interval_report_aggrerator (id, name) VALUES (2, 'Count');
INSERT INTO cdr_interval_report_aggrerator (id, name) VALUES (3, 'Avg');
INSERT INTO cdr_interval_report_aggrerator (id, name) VALUES (4, 'Max');
INSERT INTO cdr_interval_report_aggrerator (id, name) VALUES (5, 'Min');


--
-- TOC entry 3475 (class 0 OID 17916)
-- Dependencies: 270
-- Data for Name: cdr_interval_report_data; Type: TABLE DATA; Schema: reports; Owner: -
--



--
-- TOC entry 3636 (class 0 OID 0)
-- Dependencies: 271
-- Name: cdr_interval_report_data_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: -
--

SELECT pg_catalog.setval('cdr_interval_report_data_id_seq', 1, false);


--
-- TOC entry 3637 (class 0 OID 0)
-- Dependencies: 272
-- Name: cdr_interval_report_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: -
--

SELECT pg_catalog.setval('cdr_interval_report_id_seq', 16, true);


--
-- TOC entry 3478 (class 0 OID 17926)
-- Dependencies: 273
-- Data for Name: report_vendors; Type: TABLE DATA; Schema: reports; Owner: -
--



--
-- TOC entry 3479 (class 0 OID 17930)
-- Dependencies: 274
-- Data for Name: report_vendors_data; Type: TABLE DATA; Schema: reports; Owner: -
--



--
-- TOC entry 3638 (class 0 OID 0)
-- Dependencies: 275
-- Name: report_vendors_data_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: -
--

SELECT pg_catalog.setval('report_vendors_data_id_seq', 1, false);


--
-- TOC entry 3639 (class 0 OID 0)
-- Dependencies: 276
-- Name: report_vendors_id_seq; Type: SEQUENCE SET; Schema: reports; Owner: -
--

SELECT pg_catalog.setval('report_vendors_id_seq', 1, false);


SET search_path = runtime_stats, pg_catalog;

--
-- TOC entry 3482 (class 0 OID 17937)
-- Dependencies: 277
-- Data for Name: dialpeers_stats; Type: TABLE DATA; Schema: runtime_stats; Owner: -
--



--
-- TOC entry 3640 (class 0 OID 0)
-- Dependencies: 278
-- Name: dialpeers_stats_id_seq; Type: SEQUENCE SET; Schema: runtime_stats; Owner: -
--

SELECT pg_catalog.setval('dialpeers_stats_id_seq', 154, true);


--
-- TOC entry 3484 (class 0 OID 17944)
-- Dependencies: 279
-- Data for Name: gateways_stats; Type: TABLE DATA; Schema: runtime_stats; Owner: -
--



--
-- TOC entry 3641 (class 0 OID 0)
-- Dependencies: 280
-- Name: gateways_stats_id_seq; Type: SEQUENCE SET; Schema: runtime_stats; Owner: -
--

SELECT pg_catalog.setval('gateways_stats_id_seq', 142, true);


SET search_path = switch1, pg_catalog;

--
-- TOC entry 3642 (class 0 OID 0)
-- Dependencies: 302
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: switch1; Owner: -
--

SELECT pg_catalog.setval('events_id_seq', 280, true);


--
-- TOC entry 3506 (class 0 OID 18949)
-- Dependencies: 303
-- Data for Name: resource_action; Type: TABLE DATA; Schema: switch1; Owner: -
--

INSERT INTO resource_action (id, name) VALUES (1, 'Reject');
INSERT INTO resource_action (id, name) VALUES (2, 'Try next route');
INSERT INTO resource_action (id, name) VALUES (3, 'Accept');


--
-- TOC entry 3504 (class 0 OID 18922)
-- Dependencies: 301
-- Data for Name: resource_type; Type: TABLE DATA; Schema: switch1; Owner: -
--

INSERT INTO resource_type (id, name, reject_code, reject_reason, action_id) VALUES (1, 'Customer account', 503, 'Resource $name $id overloaded', 1);
INSERT INTO resource_type (id, name, reject_code, reject_reason, action_id) VALUES (3, 'Customer auth', 503, 'Resource $name $id overloaded', 1);
INSERT INTO resource_type (id, name, reject_code, reject_reason, action_id) VALUES (4, 'Customer gateway', 503, 'Resource $name $id overloaded', 1);
INSERT INTO resource_type (id, name, reject_code, reject_reason, action_id) VALUES (2, 'Vendor account', 503, 'Resource $name $id overloaded', 2);
INSERT INTO resource_type (id, name, reject_code, reject_reason, action_id) VALUES (5, 'Vendor gateway', 503, 'Resource $name $id overloaded', 2);
INSERT INTO resource_type (id, name, reject_code, reject_reason, action_id) VALUES (6, 'Dialpeer', 503, 'Resource $name $id overloaded', 2);


--
-- TOC entry 3643 (class 0 OID 0)
-- Dependencies: 304
-- Name: resource_type_id_seq; Type: SEQUENCE SET; Schema: switch1; Owner: -
--

SELECT pg_catalog.setval('resource_type_id_seq', 6, true);


--
-- TOC entry 3644 (class 0 OID 0)
-- Dependencies: 305
-- Name: switch_in_interface_id_seq; Type: SEQUENCE SET; Schema: switch1; Owner: -
--

SELECT pg_catalog.setval('switch_in_interface_id_seq', 4, true);


--
-- TOC entry 3645 (class 0 OID 0)
-- Dependencies: 307
-- Name: switch_interface_id_seq; Type: SEQUENCE SET; Schema: switch1; Owner: -
--

SELECT pg_catalog.setval('switch_interface_id_seq', 853, true);


--
-- TOC entry 3511 (class 0 OID 18967)
-- Dependencies: 308
-- Data for Name: switch_interface_in; Type: TABLE DATA; Schema: switch1; Owner: -
--

INSERT INTO switch_interface_in (id, name, type, rank, format, hashkey) VALUES (2, 'Diversion', 'varchar', 2, 'uri_user', false);
INSERT INTO switch_interface_in (id, name, type, rank, format, hashkey) VALUES (1, 'X-YETI-AUTH', 'varchar', 1, NULL, true);
INSERT INTO switch_interface_in (id, name, type, rank, format, hashkey) VALUES (3, 'X-ORIG-IP', 'varchar', 3, NULL, true);
INSERT INTO switch_interface_in (id, name, type, rank, format, hashkey) VALUES (4, 'X-ORIG-PORT', 'integer', 4, NULL, true);


--
-- TOC entry 3509 (class 0 OID 18959)
-- Dependencies: 306
-- Data for Name: switch_interface_out; Type: TABLE DATA; Schema: switch1; Owner: -
--

INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (739, 'ruri', 'varchar', false, 10);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (740, 'ruri_host', 'varchar', false, 20);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (741, 'from', 'varchar', false, 30);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (744, 'call_id', 'varchar', false, 60);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (745, 'transparent_dlg_id', 'boolean', false, 70);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (746, 'dlg_nat_handling', 'boolean', false, 80);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (747, 'force_outbound_proxy', 'boolean', false, 90);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (748, 'outbound_proxy', 'varchar', false, 100);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (749, 'aleg_force_outbound_proxy', 'boolean', false, 110);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (750, 'aleg_outbound_proxy', 'varchar', false, 120);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (751, 'next_hop', 'varchar', false, 130);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (752, 'next_hop_1st_req', 'boolean', false, 140);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (753, 'aleg_next_hop', 'varchar', false, 150);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (762, 'enable_session_timer', 'boolean', false, 240);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (763, 'enable_aleg_session_timer', 'boolean', false, 250);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (764, 'session_expires', 'integer', false, 260);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (765, 'minimum_timer', 'integer', false, 270);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (766, 'maximum_timer', 'integer', false, 280);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (768, 'accept_501_reply', 'varchar', false, 300);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (769, 'aleg_session_expires', 'integer', false, 310);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (770, 'aleg_minimum_timer', 'integer', false, 320);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (771, 'aleg_maximum_timer', 'integer', false, 330);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (773, 'aleg_accept_501_reply', 'varchar', false, 350);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (774, 'enable_auth', 'boolean', false, 360);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (775, 'auth_user', 'varchar', false, 370);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (776, 'auth_pwd', 'varchar', false, 380);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (777, 'enable_aleg_auth', 'boolean', false, 390);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (778, 'auth_aleg_user', 'varchar', false, 400);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (779, 'auth_aleg_pwd', 'varchar', false, 410);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (780, 'append_headers', 'varchar', false, 420);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (781, 'append_headers_req', 'varchar', false, 430);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (782, 'aleg_append_headers_req', 'varchar', false, 440);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (784, 'enable_rtprelay', 'boolean', false, 460);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (786, 'rtprelay_msgflags_symmetric_rtp', 'boolean', false, 480);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (787, 'rtprelay_interface', 'varchar', false, 490);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (788, 'aleg_rtprelay_interface', 'varchar', false, 500);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (789, 'rtprelay_transparent_seqno', 'boolean', false, 510);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (790, 'rtprelay_transparent_ssrc', 'boolean', false, 520);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (791, 'outbound_interface', 'varchar', false, 530);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (792, 'aleg_outbound_interface', 'varchar', false, 540);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (793, 'contact_displayname', 'varchar', false, 550);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (794, 'contact_user', 'varchar', false, 560);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (795, 'contact_host', 'varchar', false, 570);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (796, 'contact_port', 'smallint', false, 580);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (797, 'enable_contact_hiding', 'boolean', false, 590);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (798, 'contact_hiding_prefix', 'varchar', false, 600);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (799, 'contact_hiding_vars', 'varchar', false, 610);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (807, 'dtmf_transcoding', 'varchar', false, 690);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (808, 'lowfi_codecs', 'varchar', false, 700);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (814, 'enable_reg_caching', 'boolean', false, 760);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (815, 'min_reg_expires', 'integer', false, 770);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (816, 'max_ua_expires', 'integer', false, 780);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (817, 'time_limit', 'integer', false, 790);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (818, 'resources', 'varchar', false, 800);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (742, 'to', 'varchar', false, 40);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (783, 'disconnect_code_id', 'integer', false, 450);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (772, 'aleg_session_refresh_method_id', 'integer', false, 340);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (812, 'dump_level_id', 'integer', false, 740);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (767, 'session_refresh_method_id', 'integer', false, 290);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (836, 'anonymize_sdp', 'boolean', false, 195);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (837, 'src_name_in', 'varchar', true, 1880);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (838, 'src_name_out', 'varchar', true, 1890);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (839, 'diversion_in', 'varchar', true, 1900);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (840, 'diversion_out', 'varchar', true, 1910);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (754, 'header_filter_type_id', 'integer', false, 160);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (845, 'aleg_single_codec_in_200ok', 'boolean', false, 911);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (756, 'message_filter_type_id', 'integer', false, 180);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (846, 'auth_orig_ip', 'inet', true, 1920);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (758, 'sdp_filter_type_id', 'integer', false, 200);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (847, 'auth_orig_port', 'integer', true, 1930);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (760, 'sdp_alines_filter_type_id', 'integer', false, 220);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (755, 'header_filter_list', 'varchar', false, 170);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (757, 'message_filter_list', 'varchar', false, 190);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (759, 'sdp_filter_list', 'varchar', false, 210);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (761, 'sdp_alines_filter_list', 'varchar', false, 230);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (841, 'aleg_policy_id', 'integer', false, 840);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (842, 'bleg_policy_id', 'integer', false, 850);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (843, 'aleg_codecs_group_id', 'integer', false, 900);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (844, 'bleg_codecs_group_id', 'integer', false, 910);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (848, 'bleg_single_codec_in_200ok', 'boolean', false, 912);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (709, 'customer_id', 'varchar', true, 1650);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (710, 'vendor_id', 'varchar', true, 1660);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (711, 'customer_acc_id', 'varchar', true, 1670);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (712, 'vendor_acc_id', 'varchar', true, 1690);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (827, 'destination_next_rate', 'varchar', true, 1771);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (831, 'destination_next_interval', 'integer', true, 1773);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (830, 'destination_initial_interval', 'integer', true, 1772);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (832, 'destination_rate_policy_id', 'integer', true, 1774);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (833, 'dialpeer_initial_interval', 'integer', true, 1775);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (834, 'dialpeer_next_interval', 'integer', true, 1776);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (835, 'dialpeer_next_rate', 'varchar', true, 1777);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (821, 'cache_time', 'integer', false, 810);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (849, 'ringing_timeout', 'integer', false, 913);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (924, 'try_avoid_transcoding', 'boolean', false, 620);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (925, 'rtprelay_dtmf_filtering', 'boolean', false, 630);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (926, 'rtprelay_dtmf_detection', 'boolean', false, 640);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (927, 'patch_ruri_next_hop', 'boolean', false, 920);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (929, 'rtprelay_force_dtmf_relay', 'boolean', false, 930);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (933, 'aleg_force_symmetric_rtp', 'boolean', false, 935);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (934, 'bleg_force_symmetric_rtp', 'boolean', false, 940);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (937, 'aleg_symmetric_rtp_nonstop', 'boolean', false, 945);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (939, 'bleg_symmetric_rtp_nonstop', 'boolean', false, 950);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (940, 'aleg_symmetric_rtp_ignore_rtcp', 'boolean', false, 955);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (941, 'bleg_symmetric_rtp_ignore_rtcp', 'boolean', false, 960);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (942, 'aleg_rtp_ping', 'boolean', false, 965);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (943, 'bleg_rtp_ping', 'boolean', false, 970);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (946, 'aleg_relay_options', 'boolean', false, 975);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (948, 'bleg_relay_options', 'boolean', false, 980);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (949, 'filter_noaudio_streams', 'boolean', false, 985);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (954, 'aleg_sdp_c_location_id', 'integer', false, 996);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (955, 'bleg_sdp_c_location_id', 'integer', false, 997);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (958, 'trusted_hdrs_gw', 'boolean', false, 998);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (959, 'aleg_append_headers_reply', 'varchar', false, 999);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (951, 'relay_reinvite', 'boolean', false, 990);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (961, 'bleg_sdp_alines_filter_list', 'varchar', false, 1000);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (963, 'bleg_sdp_alines_filter_type_id', 'integer', false, 1001);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (713, 'customer_auth_id', 'varchar', true, 1700);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (714, 'destination_id', 'varchar', true, 1710);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (715, 'dialpeer_id', 'varchar', true, 1720);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (716, 'orig_gw_id', 'varchar', true, 1730);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (717, 'term_gw_id', 'varchar', true, 1740);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (718, 'routing_group_id', 'varchar', true, 1750);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (719, 'rateplan_id', 'varchar', true, 1760);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (721, 'destination_fee', 'varchar', true, 1780);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (723, 'dialpeer_fee', 'varchar', true, 1800);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (726, 'dst_prefix_in', 'varchar', true, 1840);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (727, 'dst_prefix_out', 'varchar', true, 1850);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (728, 'src_prefix_in', 'varchar', true, 1860);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (729, 'src_prefix_out', 'varchar', true, 1870);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (824, 'reply_translations', 'varchar', false, 820);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (720, 'destination_initial_rate', 'varchar', true, 1770);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (722, 'dialpeer_initial_rate', 'varchar', true, 1790);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (850, 'global_tag', 'varchar', false, 914);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (851, 'relay_hold', 'boolean', false, 1002);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (852, 'dead_rtp_time', 'integer', false, 1003);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (853, 'relay_prack', 'boolean', false, 1004);


--
-- TOC entry 3512 (class 0 OID 18975)
-- Dependencies: 309
-- Data for Name: trusted_headers; Type: TABLE DATA; Schema: switch1; Owner: -
--



--
-- TOC entry 3646 (class 0 OID 0)
-- Dependencies: 310
-- Name: trusted_headers_id_seq; Type: SEQUENCE SET; Schema: switch1; Owner: -
--

SELECT pg_catalog.setval('trusted_headers_id_seq', 2, true);


SET search_path = sys, pg_catalog;

--
-- TOC entry 3517 (class 0 OID 19079)
-- Dependencies: 315
-- Data for Name: api_log_config; Type: TABLE DATA; Schema: sys; Owner: -
--

INSERT INTO api_log_config (id, controller, debug) VALUES (1, 'Api::Rest::System::JobsController', false);


--
-- TOC entry 3647 (class 0 OID 0)
-- Dependencies: 314
-- Name: api_log_config_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: -
--

SELECT pg_catalog.setval('api_log_config_id_seq', 1, true);


--
-- TOC entry 3486 (class 0 OID 17987)
-- Dependencies: 281
-- Data for Name: cdr_tables; Type: TABLE DATA; Schema: sys; Owner: -
--

INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (13, 'class4.cdrs_201303', true, true, '2013-03-01', '2013-04-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (14, 'class4.cdrs_201302', true, true, '2013-02-01', '2013-03-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (15, 'class4.cdrs_201301', true, true, '2013-01-01', '2013-02-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (16, 'class4.cdrs_201308', true, true, '2013-08-01', '2013-09-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (17, 'class4.cdrs_201306', true, true, '2013-06-01', '2013-07-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (18, 'class4.cdrs_201307', true, true, '2013-07-01', '2013-08-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (19, 'class4.cdrs_201309', true, true, '2013-09-01', '2013-10-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (20, 'class4.cdrs_201311', true, true, '2013-11-01', '2013-12-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (21, 'class4.cdrs_201312', true, true, '2013-12-01', '2014-01-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (22, 'class4.cdrs_201401', true, true, '2014-01-01', '2014-02-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (23, 'class4.cdrs_201310', true, true, '2013-10-01', '2013-11-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (24, 'class4.cdrs_201403', true, true, '2014-03-01', '2014-04-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (25, 'class4.cdrs_201402', true, true, '2014-02-01', '2014-03-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (26, 'class4.cdrs_201405', true, true, '2014-05-01', '2014-06-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (27, 'class4.cdrs_201404', true, true, '2014-04-01', '2014-05-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (28, 'class4.cdrs_201406', true, true, '2014-06-01', '2014-07-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (29, 'class4.cdrs_201407', true, true, '2014-07-01', '2014-08-01');
INSERT INTO cdr_tables (id, name, readable, writable, date_start, date_stop) VALUES (30, 'class4.cdrs_201408', true, true, '2014-08-01', '2014-09-01');


--
-- TOC entry 3648 (class 0 OID 0)
-- Dependencies: 282
-- Name: cdrtables_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: -
--

SELECT pg_catalog.setval('cdrtables_id_seq', 30, true);


--
-- TOC entry 3488 (class 0 OID 17997)
-- Dependencies: 283
-- Data for Name: events; Type: TABLE DATA; Schema: sys; Owner: -
--



--
-- TOC entry 3489 (class 0 OID 18006)
-- Dependencies: 284
-- Data for Name: guiconfig; Type: TABLE DATA; Schema: sys; Owner: -
--

INSERT INTO guiconfig (rows_per_page, id, cdr_unload_dir, cdr_unload_uri, max_records, rowsperpage, import_max_threads, import_helpers_dir) VALUES ('30,50,100', 1, '/tmp', 'https://127.0.0.1/tmexport', 100500, '50,100', 4, '/tmp/yeti-xml2rates');


--
-- TOC entry 3649 (class 0 OID 0)
-- Dependencies: 285
-- Name: guiconfig_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: -
--

SELECT pg_catalog.setval('guiconfig_id_seq', 1, true);


--
-- TOC entry 3515 (class 0 OID 19052)
-- Dependencies: 313
-- Data for Name: jobs; Type: TABLE DATA; Schema: sys; Owner: -
--

INSERT INTO jobs (id, type, description, updated_at, running) VALUES (1, 'CdrPartitioning', NULL, '2014-08-30 21:42:51.904755', false);
INSERT INTO jobs (id, type, description, updated_at, running) VALUES (2, 'EventProcessor', NULL, '2014-08-30 22:16:02.393718', false);
INSERT INTO jobs (id, type, description, updated_at, running) VALUES (3, 'CdrBatchCleaner', NULL, '2014-08-30 22:34:21.645614', false);


--
-- TOC entry 3650 (class 0 OID 0)
-- Dependencies: 312
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: -
--

SELECT pg_catalog.setval('jobs_id_seq', 3, true);


--
-- TOC entry 3651 (class 0 OID 0)
-- Dependencies: 287
-- Name: node_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: -
--

SELECT pg_catalog.setval('node_id_seq', 7, true);


--
-- TOC entry 3491 (class 0 OID 18018)
-- Dependencies: 286
-- Data for Name: nodes; Type: TABLE DATA; Schema: sys; Owner: -
--



--
-- TOC entry 3652 (class 0 OID 0)
-- Dependencies: 289
-- Name: pop_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: -
--

SELECT pg_catalog.setval('pop_id_seq', 3, true);


--
-- TOC entry 3493 (class 0 OID 18026)
-- Dependencies: 288
-- Data for Name: pops; Type: TABLE DATA; Schema: sys; Owner: -
--



--
-- TOC entry 3495 (class 0 OID 18034)
-- Dependencies: 290
-- Data for Name: version; Type: TABLE DATA; Schema: sys; Owner: -
--

INSERT INTO version (id, number, apply_date, comment) VALUES (1, 1, '2013-08-05 16:20:44.604363', 'version tracking added');
INSERT INTO version (id, number, apply_date, comment) VALUES (2, 2, '2013-08-05 18:01:12.222722', 'sys.system_clean() added');
INSERT INTO version (id, number, apply_date, comment) VALUES (4, 3, '2013-08-05 19:08:28.009416', 'getprofile capacity fix');
INSERT INTO version (id, number, apply_date, comment) VALUES (6, 4, '2013-08-06 11:39:17.450765', 'dump filename fix');


--
-- TOC entry 3653 (class 0 OID 0)
-- Dependencies: 291
-- Name: version_id_seq; Type: SEQUENCE SET; Schema: sys; Owner: -
--

SELECT pg_catalog.setval('version_id_seq', 8, true);


SET search_path = billing, pg_catalog;

--
-- TOC entry 3005 (class 2606 OID 18172)
-- Name: accounts_name_key; Type: CONSTRAINT; Schema: billing; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_name_key UNIQUE (name);


--
-- TOC entry 3007 (class 2606 OID 18174)
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: billing; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- TOC entry 3225 (class 2606 OID 19104)
-- Name: cdr_batches_batch_id_key; Type: CONSTRAINT; Schema: billing; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_batches
    ADD CONSTRAINT cdr_batches_batch_id_key UNIQUE (batch_id);


--
-- TOC entry 3227 (class 2606 OID 19102)
-- Name: cdr_batches_pkey; Type: CONSTRAINT; Schema: billing; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_batches
    ADD CONSTRAINT cdr_batches_pkey PRIMARY KEY (id);


--
-- TOC entry 3022 (class 2606 OID 18176)
-- Name: invoices_pkey; Type: CONSTRAINT; Schema: billing; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- TOC entry 3195 (class 2606 OID 18886)
-- Name: invoices_templates_name_key; Type: CONSTRAINT; Schema: billing; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invoice_templates
    ADD CONSTRAINT invoices_templates_name_key UNIQUE (name);


--
-- TOC entry 3197 (class 2606 OID 18884)
-- Name: invoices_templates_pkey; Type: CONSTRAINT; Schema: billing; Owner: -; Tablespace: 
--

ALTER TABLE ONLY invoice_templates
    ADD CONSTRAINT invoices_templates_pkey PRIMARY KEY (id);


--
-- TOC entry 3024 (class 2606 OID 18178)
-- Name: payments_pkey; Type: CONSTRAINT; Schema: billing; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


SET search_path = class4, pg_catalog;

--
-- TOC entry 3193 (class 2606 OID 18865)
-- Name: blacklist_items_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY blacklist_items
    ADD CONSTRAINT blacklist_items_pkey PRIMARY KEY (id);


--
-- TOC entry 3188 (class 2606 OID 18853)
-- Name: blacklists_name_key; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY blacklists
    ADD CONSTRAINT blacklists_name_key UNIQUE (name);


--
-- TOC entry 3190 (class 2606 OID 18851)
-- Name: blacklists_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY blacklists
    ADD CONSTRAINT blacklists_pkey PRIMARY KEY (id);


--
-- TOC entry 3026 (class 2606 OID 18218)
-- Name: codec_group_codecs_codec_group_id_codec_id_key; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY codec_group_codecs
    ADD CONSTRAINT codec_group_codecs_codec_group_id_codec_id_key UNIQUE (codec_group_id, codec_id);


--
-- TOC entry 3028 (class 2606 OID 18220)
-- Name: codec_group_codecs_codec_group_id_priority_key; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY codec_group_codecs
    ADD CONSTRAINT codec_group_codecs_codec_group_id_priority_key UNIQUE (codec_group_id, priority);


--
-- TOC entry 3030 (class 2606 OID 18222)
-- Name: codec_group_codecs_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY codec_group_codecs
    ADD CONSTRAINT codec_group_codecs_pkey PRIMARY KEY (id);


--
-- TOC entry 3032 (class 2606 OID 18224)
-- Name: codec_groups_name_key; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY codec_groups
    ADD CONSTRAINT codec_groups_name_key UNIQUE (name);


--
-- TOC entry 3034 (class 2606 OID 18226)
-- Name: codec_groups_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY codec_groups
    ADD CONSTRAINT codec_groups_pkey PRIMARY KEY (id);


--
-- TOC entry 3036 (class 2606 OID 18228)
-- Name: codecs_name_key; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY codecs
    ADD CONSTRAINT codecs_name_key UNIQUE (name);


--
-- TOC entry 3038 (class 2606 OID 18230)
-- Name: codecs_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY codecs
    ADD CONSTRAINT codecs_pkey PRIMARY KEY (id);


--
-- TOC entry 3041 (class 2606 OID 18232)
-- Name: customers_auth_name_key; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY customers_auth
    ADD CONSTRAINT customers_auth_name_key UNIQUE (name);


--
-- TOC entry 3043 (class 2606 OID 18234)
-- Name: customers_auth_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY customers_auth
    ADD CONSTRAINT customers_auth_pkey PRIMARY KEY (id);


--
-- TOC entry 3046 (class 2606 OID 18236)
-- Name: destination_rate_policy_name_key; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY destination_rate_policy
    ADD CONSTRAINT destination_rate_policy_name_key UNIQUE (name);


--
-- TOC entry 3048 (class 2606 OID 18238)
-- Name: destination_rate_policy_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY destination_rate_policy
    ADD CONSTRAINT destination_rate_policy_pkey PRIMARY KEY (id);


--
-- TOC entry 3009 (class 2606 OID 18240)
-- Name: destinations_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY destinations
    ADD CONSTRAINT destinations_pkey PRIMARY KEY (id);


--
-- TOC entry 3013 (class 2606 OID 18242)
-- Name: dialpeers_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dialpeers
    ADD CONSTRAINT dialpeers_pkey PRIMARY KEY (id);


--
-- TOC entry 3001 (class 2606 OID 18244)
-- Name: disconnect_code_namespace_name_key; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY disconnect_code_namespace
    ADD CONSTRAINT disconnect_code_namespace_name_key UNIQUE (name);


--
-- TOC entry 3003 (class 2606 OID 18246)
-- Name: disconnect_code_namespace_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY disconnect_code_namespace
    ADD CONSTRAINT disconnect_code_namespace_pkey PRIMARY KEY (id);


--
-- TOC entry 3051 (class 2606 OID 18248)
-- Name: disconnect_code_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY disconnect_code
    ADD CONSTRAINT disconnect_code_pkey PRIMARY KEY (id);


--
-- TOC entry 3053 (class 2606 OID 18250)
-- Name: disconnect_code_policy_codes_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY disconnect_policy_code
    ADD CONSTRAINT disconnect_code_policy_codes_pkey PRIMARY KEY (id);


--
-- TOC entry 3055 (class 2606 OID 18252)
-- Name: disconnect_code_policy_name_key; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY disconnect_policy
    ADD CONSTRAINT disconnect_code_policy_name_key UNIQUE (name);


--
-- TOC entry 3057 (class 2606 OID 18254)
-- Name: disconnect_code_policy_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY disconnect_policy
    ADD CONSTRAINT disconnect_code_policy_pkey PRIMARY KEY (id);


--
-- TOC entry 3059 (class 2606 OID 18256)
-- Name: disconnect_initiators_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY disconnect_initiators
    ADD CONSTRAINT disconnect_initiators_pkey PRIMARY KEY (id);


--
-- TOC entry 3061 (class 2606 OID 18258)
-- Name: diversion_policy_name_key; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY diversion_policy
    ADD CONSTRAINT diversion_policy_name_key UNIQUE (name);


--
-- TOC entry 3063 (class 2606 OID 18260)
-- Name: diversion_policy_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY diversion_policy
    ADD CONSTRAINT diversion_policy_pkey PRIMARY KEY (id);


--
-- TOC entry 3065 (class 2606 OID 18262)
-- Name: dump_level_name_key; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dump_level
    ADD CONSTRAINT dump_level_name_key UNIQUE (name);


--
-- TOC entry 3067 (class 2606 OID 18264)
-- Name: dump_level_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dump_level
    ADD CONSTRAINT dump_level_pkey PRIMARY KEY (id);


--
-- TOC entry 3069 (class 2606 OID 18266)
-- Name: filter_types_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY filter_types
    ADD CONSTRAINT filter_types_pkey PRIMARY KEY (id);


--
-- TOC entry 3071 (class 2606 OID 18268)
-- Name: gateway_groups_name_key; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY gateway_groups
    ADD CONSTRAINT gateway_groups_name_key UNIQUE (name);


--
-- TOC entry 3073 (class 2606 OID 18270)
-- Name: gateway_groups_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY gateway_groups
    ADD CONSTRAINT gateway_groups_pkey PRIMARY KEY (id);


--
-- TOC entry 3018 (class 2606 OID 18272)
-- Name: gateways_name_unique; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY gateways
    ADD CONSTRAINT gateways_name_unique UNIQUE (name);


--
-- TOC entry 3020 (class 2606 OID 18274)
-- Name: gateways_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY gateways
    ADD CONSTRAINT gateways_pkey PRIMARY KEY (id);


--
-- TOC entry 3075 (class 2606 OID 18276)
-- Name: rateplans_name_unique; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rateplans
    ADD CONSTRAINT rateplans_name_unique UNIQUE (name);


--
-- TOC entry 3077 (class 2606 OID 18278)
-- Name: rateplans_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rateplans
    ADD CONSTRAINT rateplans_pkey PRIMARY KEY (id);


--
-- TOC entry 3079 (class 2606 OID 18280)
-- Name: registrations_name_key; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY registrations
    ADD CONSTRAINT registrations_name_key UNIQUE (name);


--
-- TOC entry 3081 (class 2606 OID 18282)
-- Name: registrations_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY registrations
    ADD CONSTRAINT registrations_pkey PRIMARY KEY (id);


--
-- TOC entry 3083 (class 2606 OID 18284)
-- Name: routing_groups_name_unique; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY routing_groups
    ADD CONSTRAINT routing_groups_name_unique UNIQUE (name);


--
-- TOC entry 3085 (class 2606 OID 18286)
-- Name: routing_groups_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY routing_groups
    ADD CONSTRAINT routing_groups_pkey PRIMARY KEY (id);


--
-- TOC entry 3184 (class 2606 OID 18804)
-- Name: sdp_c_location_name_key; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sdp_c_location
    ADD CONSTRAINT sdp_c_location_name_key UNIQUE (name);


--
-- TOC entry 3186 (class 2606 OID 18802)
-- Name: sdp_c_location_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sdp_c_location
    ADD CONSTRAINT sdp_c_location_pkey PRIMARY KEY (id);


--
-- TOC entry 3087 (class 2606 OID 18288)
-- Name: session_refresh_methods_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY session_refresh_methods
    ADD CONSTRAINT session_refresh_methods_pkey PRIMARY KEY (id);


--
-- TOC entry 3089 (class 2606 OID 18290)
-- Name: sortings_pkey; Type: CONSTRAINT; Schema: class4; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sortings
    ADD CONSTRAINT sortings_pkey PRIMARY KEY (id);


SET search_path = data_import, pg_catalog;

--
-- TOC entry 3091 (class 2606 OID 18293)
-- Name: import_accounts_pkey; Type: CONSTRAINT; Schema: data_import; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import_accounts
    ADD CONSTRAINT import_accounts_pkey PRIMARY KEY (id);


--
-- TOC entry 3093 (class 2606 OID 18295)
-- Name: import_codec_group_codecs_pkey; Type: CONSTRAINT; Schema: data_import; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import_codec_group_codecs
    ADD CONSTRAINT import_codec_group_codecs_pkey PRIMARY KEY (id);


--
-- TOC entry 3095 (class 2606 OID 18297)
-- Name: import_codec_groups_pkey; Type: CONSTRAINT; Schema: data_import; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import_codec_groups
    ADD CONSTRAINT import_codec_groups_pkey PRIMARY KEY (id);


--
-- TOC entry 3097 (class 2606 OID 18299)
-- Name: import_contractors_pkey; Type: CONSTRAINT; Schema: data_import; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import_contractors
    ADD CONSTRAINT import_contractors_pkey PRIMARY KEY (id);


--
-- TOC entry 3099 (class 2606 OID 18301)
-- Name: import_customers_auth_pkey; Type: CONSTRAINT; Schema: data_import; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import_customers_auth
    ADD CONSTRAINT import_customers_auth_pkey PRIMARY KEY (id);


--
-- TOC entry 3101 (class 2606 OID 18307)
-- Name: import_destinations_pkey; Type: CONSTRAINT; Schema: data_import; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import_destinations
    ADD CONSTRAINT import_destinations_pkey PRIMARY KEY (id);


--
-- TOC entry 3103 (class 2606 OID 18309)
-- Name: import_dialpeers_pkey; Type: CONSTRAINT; Schema: data_import; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import_dialpeers
    ADD CONSTRAINT import_dialpeers_pkey PRIMARY KEY (id);


--
-- TOC entry 3105 (class 2606 OID 18311)
-- Name: import_disconnect_policies_pkey; Type: CONSTRAINT; Schema: data_import; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import_disconnect_policies
    ADD CONSTRAINT import_disconnect_policies_pkey PRIMARY KEY (id);


--
-- TOC entry 3107 (class 2606 OID 18313)
-- Name: import_gateway_groups_pkey; Type: CONSTRAINT; Schema: data_import; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import_gateway_groups
    ADD CONSTRAINT import_gateway_groups_pkey PRIMARY KEY (id);


--
-- TOC entry 3109 (class 2606 OID 18315)
-- Name: import_gateways_pkey; Type: CONSTRAINT; Schema: data_import; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import_gateways
    ADD CONSTRAINT import_gateways_pkey PRIMARY KEY (id);


--
-- TOC entry 3111 (class 2606 OID 18317)
-- Name: import_rateplans_pkey; Type: CONSTRAINT; Schema: data_import; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import_rateplans
    ADD CONSTRAINT import_rateplans_pkey PRIMARY KEY (id);


--
-- TOC entry 3113 (class 2606 OID 18319)
-- Name: import_registrations_pkey; Type: CONSTRAINT; Schema: data_import; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import_registrations
    ADD CONSTRAINT import_registrations_pkey PRIMARY KEY (id);


--
-- TOC entry 3115 (class 2606 OID 18321)
-- Name: import_routing_groups_pkey; Type: CONSTRAINT; Schema: data_import; Owner: -; Tablespace: 
--

ALTER TABLE ONLY import_routing_groups
    ADD CONSTRAINT import_routing_groups_pkey PRIMARY KEY (id);


SET search_path = gui, pg_catalog;

--
-- TOC entry 3117 (class 2606 OID 18324)
-- Name: admin_notes_pkey; Type: CONSTRAINT; Schema: gui; Owner: -; Tablespace: 
--

ALTER TABLE ONLY active_admin_comments
    ADD CONSTRAINT admin_notes_pkey PRIMARY KEY (id);


--
-- TOC entry 3122 (class 2606 OID 18326)
-- Name: admin_users_pkey; Type: CONSTRAINT; Schema: gui; Owner: -; Tablespace: 
--

ALTER TABLE ONLY admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- TOC entry 3124 (class 2606 OID 18328)
-- Name: admin_users_username_key; Type: CONSTRAINT; Schema: gui; Owner: -; Tablespace: 
--

ALTER TABLE ONLY admin_users
    ADD CONSTRAINT admin_users_username_key UNIQUE (username);


--
-- TOC entry 3128 (class 2606 OID 18330)
-- Name: background_threads_pkey; Type: CONSTRAINT; Schema: gui; Owner: -; Tablespace: 
--

ALTER TABLE ONLY background_threads
    ADD CONSTRAINT background_threads_pkey PRIMARY KEY (id);


--
-- TOC entry 3132 (class 2606 OID 18332)
-- Name: versions_pkey; Type: CONSTRAINT; Schema: gui; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


SET search_path = logs, pg_catalog;

--
-- TOC entry 3134 (class 2606 OID 18346)
-- Name: logic_log_pkey; Type: CONSTRAINT; Schema: logs; Owner: -; Tablespace: 
--

ALTER TABLE ONLY logic_log
    ADD CONSTRAINT logic_log_pkey PRIMARY KEY (id);


SET search_path = public, pg_catalog;

--
-- TOC entry 3136 (class 2606 OID 18348)
-- Name: contractors_name_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contractors
    ADD CONSTRAINT contractors_name_unique UNIQUE (name);


--
-- TOC entry 3138 (class 2606 OID 18350)
-- Name: contractors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contractors
    ADD CONSTRAINT contractors_pkey PRIMARY KEY (id);


SET search_path = reports, pg_catalog;

--
-- TOC entry 3143 (class 2606 OID 18356)
-- Name: cdr_custom_report_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_custom_report_data
    ADD CONSTRAINT cdr_custom_report_data_pkey PRIMARY KEY (id);


--
-- TOC entry 3141 (class 2606 OID 18358)
-- Name: cdr_custom_report_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_custom_report
    ADD CONSTRAINT cdr_custom_report_pkey PRIMARY KEY (id);


--
-- TOC entry 3147 (class 2606 OID 18360)
-- Name: cdr_interval_report_aggrerator_name_key; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_interval_report_aggrerator
    ADD CONSTRAINT cdr_interval_report_aggrerator_name_key UNIQUE (name);


--
-- TOC entry 3149 (class 2606 OID 18362)
-- Name: cdr_interval_report_aggrerator_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_interval_report_aggrerator
    ADD CONSTRAINT cdr_interval_report_aggrerator_pkey PRIMARY KEY (id);


--
-- TOC entry 3151 (class 2606 OID 18364)
-- Name: cdr_interval_report_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_interval_report_data
    ADD CONSTRAINT cdr_interval_report_data_pkey PRIMARY KEY (id);


--
-- TOC entry 3145 (class 2606 OID 18366)
-- Name: cdr_interval_report_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_interval_report
    ADD CONSTRAINT cdr_interval_report_pkey PRIMARY KEY (id);


--
-- TOC entry 3155 (class 2606 OID 18368)
-- Name: report_vendors_data_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY report_vendors_data
    ADD CONSTRAINT report_vendors_data_pkey PRIMARY KEY (id);


--
-- TOC entry 3153 (class 2606 OID 18370)
-- Name: report_vendors_pkey; Type: CONSTRAINT; Schema: reports; Owner: -; Tablespace: 
--

ALTER TABLE ONLY report_vendors
    ADD CONSTRAINT report_vendors_pkey PRIMARY KEY (id);


SET search_path = runtime_stats, pg_catalog;

--
-- TOC entry 3157 (class 2606 OID 18372)
-- Name: dialpeers_stats_pkey; Type: CONSTRAINT; Schema: runtime_stats; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dialpeers_stats
    ADD CONSTRAINT dialpeers_stats_pkey PRIMARY KEY (id);


--
-- TOC entry 3161 (class 2606 OID 18374)
-- Name: gateways_stats_pkey; Type: CONSTRAINT; Schema: runtime_stats; Owner: -; Tablespace: 
--

ALTER TABLE ONLY gateways_stats
    ADD CONSTRAINT gateways_stats_pkey PRIMARY KEY (id);


--
-- TOC entry 3159 (class 2606 OID 18376)
-- Name: unique_dp; Type: CONSTRAINT; Schema: runtime_stats; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dialpeers_stats
    ADD CONSTRAINT unique_dp UNIQUE (dialpeer_id);


--
-- TOC entry 3163 (class 2606 OID 18378)
-- Name: unique_gw; Type: CONSTRAINT; Schema: runtime_stats; Owner: -; Tablespace: 
--

ALTER TABLE ONLY gateways_stats
    ADD CONSTRAINT unique_gw UNIQUE (gateway_id);


SET search_path = switch1, pg_catalog;

--
-- TOC entry 3203 (class 2606 OID 18987)
-- Name: resource_action_name_key; Type: CONSTRAINT; Schema: switch1; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resource_action
    ADD CONSTRAINT resource_action_name_key UNIQUE (name);


--
-- TOC entry 3205 (class 2606 OID 18989)
-- Name: resource_action_pkey; Type: CONSTRAINT; Schema: switch1; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resource_action
    ADD CONSTRAINT resource_action_pkey PRIMARY KEY (id);


--
-- TOC entry 3199 (class 2606 OID 18991)
-- Name: resource_type_name_key; Type: CONSTRAINT; Schema: switch1; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resource_type
    ADD CONSTRAINT resource_type_name_key UNIQUE (name);


--
-- TOC entry 3201 (class 2606 OID 18993)
-- Name: resource_type_pkey; Type: CONSTRAINT; Schema: switch1; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resource_type
    ADD CONSTRAINT resource_type_pkey PRIMARY KEY (id);


--
-- TOC entry 3211 (class 2606 OID 18995)
-- Name: switch_in_interface_pkey; Type: CONSTRAINT; Schema: switch1; Owner: -; Tablespace: 
--

ALTER TABLE ONLY switch_interface_in
    ADD CONSTRAINT switch_in_interface_pkey PRIMARY KEY (id);


--
-- TOC entry 3213 (class 2606 OID 18997)
-- Name: switch_in_interface_rank_key; Type: CONSTRAINT; Schema: switch1; Owner: -; Tablespace: 
--

ALTER TABLE ONLY switch_interface_in
    ADD CONSTRAINT switch_in_interface_rank_key UNIQUE (rank);


--
-- TOC entry 3207 (class 2606 OID 18999)
-- Name: switch_interface_pkey; Type: CONSTRAINT; Schema: switch1; Owner: -; Tablespace: 
--

ALTER TABLE ONLY switch_interface_out
    ADD CONSTRAINT switch_interface_pkey PRIMARY KEY (id);


--
-- TOC entry 3209 (class 2606 OID 19001)
-- Name: switch_interface_rank_key; Type: CONSTRAINT; Schema: switch1; Owner: -; Tablespace: 
--

ALTER TABLE ONLY switch_interface_out
    ADD CONSTRAINT switch_interface_rank_key UNIQUE (rank);


--
-- TOC entry 3215 (class 2606 OID 19003)
-- Name: trusted_headers_pkey; Type: CONSTRAINT; Schema: switch1; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trusted_headers
    ADD CONSTRAINT trusted_headers_pkey PRIMARY KEY (id);


SET search_path = sys, pg_catalog;

--
-- TOC entry 3221 (class 2606 OID 19090)
-- Name: api_log_config_controller_key; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY api_log_config
    ADD CONSTRAINT api_log_config_controller_key UNIQUE (controller);


--
-- TOC entry 3223 (class 2606 OID 19088)
-- Name: api_log_config_pkey; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY api_log_config
    ADD CONSTRAINT api_log_config_pkey PRIMARY KEY (id);


--
-- TOC entry 3166 (class 2606 OID 18398)
-- Name: cdrtables_pkey; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cdr_tables
    ADD CONSTRAINT cdrtables_pkey PRIMARY KEY (id);


--
-- TOC entry 3168 (class 2606 OID 18400)
-- Name: events_pkey; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- TOC entry 3170 (class 2606 OID 18402)
-- Name: guiconfig_pkey; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY guiconfig
    ADD CONSTRAINT guiconfig_pkey PRIMARY KEY (id);


--
-- TOC entry 3217 (class 2606 OID 19062)
-- Name: jobs_pkey; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- TOC entry 3219 (class 2606 OID 19064)
-- Name: jobs_type_key; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_type_key UNIQUE (type);


--
-- TOC entry 3172 (class 2606 OID 18404)
-- Name: node_name_key; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT node_name_key UNIQUE (name);


--
-- TOC entry 3174 (class 2606 OID 18406)
-- Name: node_pkey; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT node_pkey PRIMARY KEY (id);


--
-- TOC entry 3176 (class 2606 OID 18408)
-- Name: pop_name_key; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pops
    ADD CONSTRAINT pop_name_key UNIQUE (name);


--
-- TOC entry 3178 (class 2606 OID 18410)
-- Name: pop_pkey; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pops
    ADD CONSTRAINT pop_pkey PRIMARY KEY (id);


--
-- TOC entry 3180 (class 2606 OID 18412)
-- Name: version_number_key; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY version
    ADD CONSTRAINT version_number_key UNIQUE (number);


--
-- TOC entry 3182 (class 2606 OID 18414)
-- Name: version_pkey; Type: CONSTRAINT; Schema: sys; Owner: -; Tablespace: 
--

ALTER TABLE ONLY version
    ADD CONSTRAINT version_pkey PRIMARY KEY (id);


SET search_path = class4, pg_catalog;

--
-- TOC entry 3191 (class 1259 OID 18873)
-- Name: blacklist_items_blacklist_id_key_idx; Type: INDEX; Schema: class4; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX blacklist_items_blacklist_id_key_idx ON blacklist_items USING btree (blacklist_id, key);


--
-- TOC entry 3039 (class 1259 OID 18446)
-- Name: customers_auth_ip_prefix_range_prefix_range1_idx; Type: INDEX; Schema: class4; Owner: -; Tablespace: 
--

CREATE INDEX customers_auth_ip_prefix_range_prefix_range1_idx ON customers_auth USING gist (ip, ((dst_prefix)::public.prefix_range), ((src_prefix)::public.prefix_range));


--
-- TOC entry 3044 (class 1259 OID 18447)
-- Name: customers_auth_prefix_range_prefix_range1_idx; Type: INDEX; Schema: class4; Owner: -; Tablespace: 
--

CREATE INDEX customers_auth_prefix_range_prefix_range1_idx ON customers_auth USING gist (((dst_prefix)::public.prefix_range), ((src_prefix)::public.prefix_range)) WHERE enabled;


--
-- TOC entry 3010 (class 1259 OID 18448)
-- Name: destinations_prefix_range_idx; Type: INDEX; Schema: class4; Owner: -; Tablespace: 
--

CREATE INDEX destinations_prefix_range_idx ON destinations USING gist (((prefix)::public.prefix_range));


--
-- TOC entry 3011 (class 1259 OID 18449)
-- Name: destinations_prefix_rateplan_id_idx; Type: INDEX; Schema: class4; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX destinations_prefix_rateplan_id_idx ON destinations USING btree (prefix, rateplan_id);


--
-- TOC entry 3014 (class 1259 OID 18450)
-- Name: dialpeers_prefix_range_idx; Type: INDEX; Schema: class4; Owner: -; Tablespace: 
--

CREATE INDEX dialpeers_prefix_range_idx ON dialpeers USING gist (((prefix)::public.prefix_range));


--
-- TOC entry 3015 (class 1259 OID 18452)
-- Name: dialpeers_prefix_range_valid_from_valid_till_idx; Type: INDEX; Schema: class4; Owner: -; Tablespace: 
--

CREATE INDEX dialpeers_prefix_range_valid_from_valid_till_idx ON dialpeers USING gist (((prefix)::public.prefix_range), valid_from, valid_till) WHERE enabled;


--
-- TOC entry 3016 (class 1259 OID 18453)
-- Name: dialpeers_prefix_range_valid_from_valid_till_idx1; Type: INDEX; Schema: class4; Owner: -; Tablespace: 
--

CREATE INDEX dialpeers_prefix_range_valid_from_valid_till_idx1 ON dialpeers USING gist (((prefix)::public.prefix_range), valid_from, valid_till) WHERE (enabled AND (NOT locked));


--
-- TOC entry 3049 (class 1259 OID 18454)
-- Name: disconnect_code_code_success_successnozerolen_idx; Type: INDEX; Schema: class4; Owner: -; Tablespace: 
--

CREATE INDEX disconnect_code_code_success_successnozerolen_idx ON disconnect_code USING btree (code, success, successnozerolen);


SET search_path = gui, pg_catalog;

--
-- TOC entry 3118 (class 1259 OID 18455)
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: gui; Owner: -; Tablespace: 
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON active_admin_comments USING btree (author_type, author_id);


--
-- TOC entry 3119 (class 1259 OID 18456)
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: gui; Owner: -; Tablespace: 
--

CREATE INDEX index_active_admin_comments_on_namespace ON active_admin_comments USING btree (namespace);


--
-- TOC entry 3120 (class 1259 OID 18457)
-- Name: index_admin_notes_on_resource_type_and_resource_id; Type: INDEX; Schema: gui; Owner: -; Tablespace: 
--

CREATE INDEX index_admin_notes_on_resource_type_and_resource_id ON active_admin_comments USING btree (resource_type, resource_id);


--
-- TOC entry 3125 (class 1259 OID 18458)
-- Name: index_admin_users_on_email; Type: INDEX; Schema: gui; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admin_users_on_email ON admin_users USING btree (email);


--
-- TOC entry 3126 (class 1259 OID 18459)
-- Name: index_admin_users_on_reset_password_token; Type: INDEX; Schema: gui; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admin_users_on_reset_password_token ON admin_users USING btree (reset_password_token);


--
-- TOC entry 3130 (class 1259 OID 18460)
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: gui; Owner: -; Tablespace: 
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- TOC entry 3129 (class 1259 OID 18461)
-- Name: unique_schema_migrations; Type: INDEX; Schema: gui; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


SET search_path = reports, pg_catalog;

--
-- TOC entry 3139 (class 1259 OID 18462)
-- Name: cdr_custom_report_id_idx; Type: INDEX; Schema: reports; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX cdr_custom_report_id_idx ON cdr_custom_report USING btree (id) WHERE (id IS NOT NULL);


SET search_path = sys, pg_catalog;

--
-- TOC entry 3164 (class 1259 OID 18463)
-- Name: cdr_tables_name_idx; Type: INDEX; Schema: sys; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX cdr_tables_name_idx ON cdr_tables USING btree (name);


SET search_path = billing, pg_catalog;

--
-- TOC entry 3228 (class 2606 OID 18465)
-- Name: accounts_contractor_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_contractor_id_fkey FOREIGN KEY (contractor_id) REFERENCES public.contractors(id);


--
-- TOC entry 3246 (class 2606 OID 18470)
-- Name: invoices_account_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY invoices
    ADD CONSTRAINT invoices_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- TOC entry 3247 (class 2606 OID 18475)
-- Name: invoices_contractor_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY invoices
    ADD CONSTRAINT invoices_contractor_id_fkey FOREIGN KEY (contractor_id) REFERENCES public.contractors(id);


--
-- TOC entry 3248 (class 2606 OID 18480)
-- Name: payments_account_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(id);


SET search_path = class4, pg_catalog;

--
-- TOC entry 3276 (class 2606 OID 18868)
-- Name: blacklist_items_blacklist_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY blacklist_items
    ADD CONSTRAINT blacklist_items_blacklist_id_fkey FOREIGN KEY (blacklist_id) REFERENCES blacklists(id);


--
-- TOC entry 3249 (class 2606 OID 18485)
-- Name: codec_group_codecs_codec_group_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY codec_group_codecs
    ADD CONSTRAINT codec_group_codecs_codec_group_id_fkey FOREIGN KEY (codec_group_id) REFERENCES codec_groups(id);


--
-- TOC entry 3250 (class 2606 OID 18490)
-- Name: codec_group_codecs_codec_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY codec_group_codecs
    ADD CONSTRAINT codec_group_codecs_codec_id_fkey FOREIGN KEY (codec_id) REFERENCES codecs(id);


--
-- TOC entry 3251 (class 2606 OID 18495)
-- Name: customers_auth_account_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY customers_auth
    ADD CONSTRAINT customers_auth_account_id_fkey FOREIGN KEY (account_id) REFERENCES billing.accounts(id);


--
-- TOC entry 3252 (class 2606 OID 18500)
-- Name: customers_auth_customer_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY customers_auth
    ADD CONSTRAINT customers_auth_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.contractors(id);


--
-- TOC entry 3253 (class 2606 OID 18505)
-- Name: customers_auth_diversion_policy_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY customers_auth
    ADD CONSTRAINT customers_auth_diversion_policy_id_fkey FOREIGN KEY (diversion_policy_id) REFERENCES diversion_policy(id);


--
-- TOC entry 3259 (class 2606 OID 18889)
-- Name: customers_auth_dst_blacklist_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY customers_auth
    ADD CONSTRAINT customers_auth_dst_blacklist_id_fkey FOREIGN KEY (dst_blacklist_id) REFERENCES blacklists(id);


--
-- TOC entry 3254 (class 2606 OID 18510)
-- Name: customers_auth_dump_level_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY customers_auth
    ADD CONSTRAINT customers_auth_dump_level_id_fkey FOREIGN KEY (dump_level_id) REFERENCES dump_level(id);


--
-- TOC entry 3255 (class 2606 OID 18515)
-- Name: customers_auth_gateway_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY customers_auth
    ADD CONSTRAINT customers_auth_gateway_id_fkey FOREIGN KEY (gateway_id) REFERENCES gateways(id);


--
-- TOC entry 3256 (class 2606 OID 18520)
-- Name: customers_auth_pop_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY customers_auth
    ADD CONSTRAINT customers_auth_pop_id_fkey FOREIGN KEY (pop_id) REFERENCES sys.pops(id);


--
-- TOC entry 3257 (class 2606 OID 18525)
-- Name: customers_auth_rateplan_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY customers_auth
    ADD CONSTRAINT customers_auth_rateplan_id_fkey FOREIGN KEY (rateplan_id) REFERENCES rateplans(id);


--
-- TOC entry 3258 (class 2606 OID 18530)
-- Name: customers_auth_routing_group_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY customers_auth
    ADD CONSTRAINT customers_auth_routing_group_id_fkey FOREIGN KEY (routing_group_id) REFERENCES routing_groups(id);


--
-- TOC entry 3260 (class 2606 OID 18894)
-- Name: customers_auth_src_blacklist_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY customers_auth
    ADD CONSTRAINT customers_auth_src_blacklist_id_fkey FOREIGN KEY (src_blacklist_id) REFERENCES blacklists(id);


--
-- TOC entry 3229 (class 2606 OID 18535)
-- Name: destinations_rate_policy_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY destinations
    ADD CONSTRAINT destinations_rate_policy_id_fkey FOREIGN KEY (rate_policy_id) REFERENCES destination_rate_policy(id);


--
-- TOC entry 3230 (class 2606 OID 18540)
-- Name: destinations_rateplan_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY destinations
    ADD CONSTRAINT destinations_rateplan_id_fkey FOREIGN KEY (rateplan_id) REFERENCES rateplans(id);


--
-- TOC entry 3231 (class 2606 OID 18545)
-- Name: dialpeers_account_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY dialpeers
    ADD CONSTRAINT dialpeers_account_id_fkey FOREIGN KEY (account_id) REFERENCES billing.accounts(id);


--
-- TOC entry 3232 (class 2606 OID 18550)
-- Name: dialpeers_gateway_group_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY dialpeers
    ADD CONSTRAINT dialpeers_gateway_group_id_fkey FOREIGN KEY (gateway_group_id) REFERENCES gateway_groups(id);


--
-- TOC entry 3233 (class 2606 OID 18555)
-- Name: dialpeers_gateway_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY dialpeers
    ADD CONSTRAINT dialpeers_gateway_id_fkey FOREIGN KEY (gateway_id) REFERENCES gateways(id);


--
-- TOC entry 3234 (class 2606 OID 18560)
-- Name: dialpeers_routing_group_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY dialpeers
    ADD CONSTRAINT dialpeers_routing_group_id_fkey FOREIGN KEY (routing_group_id) REFERENCES routing_groups(id);


--
-- TOC entry 3235 (class 2606 OID 18565)
-- Name: dialpeers_vendor_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY dialpeers
    ADD CONSTRAINT dialpeers_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.contractors(id);


--
-- TOC entry 3261 (class 2606 OID 18570)
-- Name: disconnect_code_namespace_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY disconnect_code
    ADD CONSTRAINT disconnect_code_namespace_id_fkey FOREIGN KEY (namespace_id) REFERENCES disconnect_code_namespace(id);


--
-- TOC entry 3262 (class 2606 OID 18575)
-- Name: disconnect_code_policy_codes_code_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY disconnect_policy_code
    ADD CONSTRAINT disconnect_code_policy_codes_code_id_fkey FOREIGN KEY (code_id) REFERENCES disconnect_code(id);


--
-- TOC entry 3263 (class 2606 OID 18580)
-- Name: disconnect_code_policy_codes_policy_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY disconnect_policy_code
    ADD CONSTRAINT disconnect_code_policy_codes_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES disconnect_policy(id);


--
-- TOC entry 3264 (class 2606 OID 18585)
-- Name: gateway_groups_contractor_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY gateway_groups
    ADD CONSTRAINT gateway_groups_contractor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.contractors(id);


--
-- TOC entry 3236 (class 2606 OID 18590)
-- Name: gateways_codec_group_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY gateways
    ADD CONSTRAINT gateways_codec_group_id_fkey FOREIGN KEY (codec_group_id) REFERENCES codec_groups(id);


--
-- TOC entry 3237 (class 2606 OID 18595)
-- Name: gateways_contractor_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY gateways
    ADD CONSTRAINT gateways_contractor_id_fkey FOREIGN KEY (contractor_id) REFERENCES public.contractors(id);


--
-- TOC entry 3238 (class 2606 OID 18600)
-- Name: gateways_diversion_policy_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY gateways
    ADD CONSTRAINT gateways_diversion_policy_id_fkey FOREIGN KEY (diversion_policy_id) REFERENCES diversion_policy(id);


--
-- TOC entry 3239 (class 2606 OID 18605)
-- Name: gateways_gateway_group_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY gateways
    ADD CONSTRAINT gateways_gateway_group_id_fkey FOREIGN KEY (gateway_group_id) REFERENCES gateway_groups(id);


--
-- TOC entry 3240 (class 2606 OID 18615)
-- Name: gateways_orig_disconnect_policy_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY gateways
    ADD CONSTRAINT gateways_orig_disconnect_policy_id_fkey FOREIGN KEY (orig_disconnect_policy_id) REFERENCES disconnect_policy(id);


--
-- TOC entry 3241 (class 2606 OID 18620)
-- Name: gateways_pop_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY gateways
    ADD CONSTRAINT gateways_pop_id_fkey FOREIGN KEY (pop_id) REFERENCES sys.pops(id);


--
-- TOC entry 3242 (class 2606 OID 18625)
-- Name: gateways_sdp_alines_filter_type_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY gateways
    ADD CONSTRAINT gateways_sdp_alines_filter_type_id_fkey FOREIGN KEY (sdp_alines_filter_type_id) REFERENCES filter_types(id);


--
-- TOC entry 3245 (class 2606 OID 18807)
-- Name: gateways_sdp_c_location_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY gateways
    ADD CONSTRAINT gateways_sdp_c_location_id_fkey FOREIGN KEY (sdp_c_location_id) REFERENCES sdp_c_location(id);


--
-- TOC entry 3243 (class 2606 OID 18635)
-- Name: gateways_session_refresh_method_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY gateways
    ADD CONSTRAINT gateways_session_refresh_method_id_fkey FOREIGN KEY (session_refresh_method_id) REFERENCES session_refresh_methods(id);


--
-- TOC entry 3244 (class 2606 OID 18640)
-- Name: gateways_term_disconnect_policy_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY gateways
    ADD CONSTRAINT gateways_term_disconnect_policy_id_fkey FOREIGN KEY (term_disconnect_policy_id) REFERENCES disconnect_policy(id);


--
-- TOC entry 3265 (class 2606 OID 18645)
-- Name: registrations_node_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY registrations
    ADD CONSTRAINT registrations_node_id_fkey FOREIGN KEY (node_id) REFERENCES sys.nodes(id);


--
-- TOC entry 3266 (class 2606 OID 18650)
-- Name: registrations_pop_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY registrations
    ADD CONSTRAINT registrations_pop_id_fkey FOREIGN KEY (pop_id) REFERENCES sys.pops(id);


--
-- TOC entry 3267 (class 2606 OID 18655)
-- Name: routing_groups_sorting_id_fkey; Type: FK CONSTRAINT; Schema: class4; Owner: -
--

ALTER TABLE ONLY routing_groups
    ADD CONSTRAINT routing_groups_sorting_id_fkey FOREIGN KEY (sorting_id) REFERENCES sortings(id);


SET search_path = reports, pg_catalog;

--
-- TOC entry 3268 (class 2606 OID 18660)
-- Name: cdr_custom_report_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_custom_report_data
    ADD CONSTRAINT cdr_custom_report_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES cdr_custom_report(id);


--
-- TOC entry 3269 (class 2606 OID 18665)
-- Name: cdr_interval_report_aggregator_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_interval_report
    ADD CONSTRAINT cdr_interval_report_aggregator_id_fkey FOREIGN KEY (aggregator_id) REFERENCES cdr_interval_report_aggrerator(id);


--
-- TOC entry 3270 (class 2606 OID 18670)
-- Name: cdr_interval_report_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY cdr_interval_report_data
    ADD CONSTRAINT cdr_interval_report_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES cdr_interval_report(id);


--
-- TOC entry 3271 (class 2606 OID 18675)
-- Name: report_vendors_data_report_id_fkey; Type: FK CONSTRAINT; Schema: reports; Owner: -
--

ALTER TABLE ONLY report_vendors_data
    ADD CONSTRAINT report_vendors_data_report_id_fkey FOREIGN KEY (report_id) REFERENCES report_vendors(id);


SET search_path = runtime_stats, pg_catalog;

--
-- TOC entry 3272 (class 2606 OID 18680)
-- Name: dialpeers_stats_dialpeer_id_fkey; Type: FK CONSTRAINT; Schema: runtime_stats; Owner: -
--

ALTER TABLE ONLY dialpeers_stats
    ADD CONSTRAINT dialpeers_stats_dialpeer_id_fkey FOREIGN KEY (dialpeer_id) REFERENCES class4.dialpeers(id);


--
-- TOC entry 3273 (class 2606 OID 18685)
-- Name: gateways_stats_gateway_id_fkey; Type: FK CONSTRAINT; Schema: runtime_stats; Owner: -
--

ALTER TABLE ONLY gateways_stats
    ADD CONSTRAINT gateways_stats_gateway_id_fkey FOREIGN KEY (gateway_id) REFERENCES class4.gateways(id);


SET search_path = switch1, pg_catalog;

--
-- TOC entry 3277 (class 2606 OID 19004)
-- Name: resource_type_action_id_fkey; Type: FK CONSTRAINT; Schema: switch1; Owner: -
--

ALTER TABLE ONLY resource_type
    ADD CONSTRAINT resource_type_action_id_fkey FOREIGN KEY (action_id) REFERENCES resource_action(id);


SET search_path = sys, pg_catalog;

--
-- TOC entry 3274 (class 2606 OID 18695)
-- Name: events_node_id_fkey; Type: FK CONSTRAINT; Schema: sys; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_node_id_fkey FOREIGN KEY (node_id) REFERENCES nodes(id);


--
-- TOC entry 3275 (class 2606 OID 18700)
-- Name: node_pop_id_fkey; Type: FK CONSTRAINT; Schema: sys; Owner: -
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT node_pop_id_fkey FOREIGN KEY (pop_id) REFERENCES pops(id);


-- Completed on 2014-10-13 15:09:40 EEST

--
-- PostgreSQL database dump complete
--
commit;
