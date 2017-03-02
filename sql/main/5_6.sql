begin;
insert into sys.version(number,comment) values(6,'Fix switch1.load_interface_in()');
INSERT INTO class4.disconnect_code(id,namespace_id,stop_hunting,pass_reason_to_originator,code,reason,rewrited_code,rewrited_reason,success,successnozerolen,store_cdr,silently_drop) values(130,1,true,false,408,'SIP transaction timeout',null,null,false,true,true,false);

ALTER TABLE billing.cdr_batches DROP COLUMN  batch_id ;
ALTER TABLE billing.cdr_batches RENAME batch_size TO size;
ALTER TABLE billing.cdr_batches RENAME batch_raw_data TO raw_data;
ALTER TABLE billing.cdr_batches ALTER COLUMN id DROP DEFAULT ;
DROP SEQUENCE billing.cdr_batches_id_seq;



CREATE OR REPLACE FUNCTION billing.clean_cdr_batch()
  RETURNS void AS
$BODY$
DECLARE
BEGIN
    DELETE FROM billing.cdr_batches where id not in (SELECT id from billing.cdr_batches order by id desc limit 50);
    return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 10;


DROP FUNCTION runtime_stats.update_dp(billing.cdr_v1);

CREATE OR REPLACE FUNCTION runtime_stats.update_dp(i_destination_id bigint ,i_dialpeer_id bigint,i_success boolean, i_duration integer)
  RETURNS void AS
$BODY$

DECLARE
i integer;
v_id bigint;
v_success integer;
v_duration integer;
BEGIN
        v_success=i_success::integer;
        IF i_success THEN
                v_duration=i_duration;
        ELSE
                v_duration=0;
        END IF;
        UPDATE runtime_stats.dialpeers_stats SET
                calls=calls+1,calls_success=calls_success+v_success,calls_fail=calls_fail+(1-v_success),
                total_duration=total_duration+v_duration,
                acd=(total_duration+v_duration)::real/(calls+1)::real,
                asr=(calls_success+v_success)::real/(calls+1)::real
        WHERE dialpeer_id=i_dialpeer_id;
        IF NOT FOUND THEN
                -- we can get lost update in this case if row deleted in concurrent transaction. but this is minor issue;
                BEGIN
                        INSERT into runtime_stats.dialpeers_stats(dialpeer_id,calls,calls_success,calls_fail,total_duration,acd,asr) 
                        VALUES(i_dialpeer_id,1,v_success,1-v_success,v_duration,v_duration::real/1,v_success::real/1);
                EXCEPTION
                        WHEN OTHERS THEN
                                UPDATE runtime_stats.dialpeers_stats SET
                                calls=calls+1,calls_success=calls_success+v_success,calls_fail=calls_fail+(1-v_success),
                                total_duration=total_duration+v_duration,
                                acd=(total_duration+v_duration)::real/(calls+1)::real,
                                asr=(calls_success+v_success)::real/(calls+1)::real
                                WHERE dialpeer_id=i_dialpeer_id;
                END;
        END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 10;



DROP FUNCTION runtime_stats.update_gw(billing.cdr_v1);

CREATE OR REPLACE FUNCTION runtime_stats.update_gw(i_orig_gw_id integer,i_term_gw_id integer,i_success boolean,i_duration integer)
  RETURNS void AS
$BODY$

DECLARE
i integer;
v_id bigint;
v_success integer;
v_duration integer;
BEGIN
        v_success=i_success::integer;
        IF i_success THEN
                v_duration=i_duration;
        ELSE
                v_duration=0;
        END IF;
        UPDATE runtime_stats.gateways_stats SET
                calls=calls+1,calls_success=calls_success+v_success,calls_fail=calls_fail+(1-v_success),
                total_duration=total_duration+v_duration,
                acd=(total_duration+v_duration)::real/(calls+1)::real,
                asr=(calls_success+v_success)::real/(calls+1)::real
        WHERE gateway_id=i_term_gw_id;
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
                                acd=(total_duration+v_duration)::real/(calls+1)::real,
                                asr=(calls_success+v_success)::real/(calls+1)::real
                                WHERE gateway_id=i_term_gw_id;
                END;
        END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 10;

CREATE TYPE billing.cdr_v2 AS
   (id bigint,
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


CREATE OR REPLACE FUNCTION billing.bill_cdr_batch(i_batch_id bigint, i_data text, i_data_version integer DEFAULT 2)
  RETURNS void AS
$BODY$
DECLARE
    v_batch_data billing.cdr_v2;
    v_batch_id bigint;
    _j_data json;
BEGIN
    begin
        _j_data:=i_data::json;
    exception
        when others then
            RAISE exception 'billing.bill_cdr_batch: Invalid json payload';
    end;
    
    BEGIN
        insert into billing.cdr_batches(id,size,raw_data) values( i_batch_id, json_array_length(_j_data),i_data) returning id into v_batch_id;
    exception
        WHEN unique_violation then
            RAISE WARNING 'billing.bill_cdr_batch:  Data batch % already billed. Skip it.',i_batch_id;
            return; -- batch already processed;
    end ;

    if i_data_version=2 then
        --- ok;
    else
        RAISE EXCEPTION 'billing.bill_cdr_batch: No logic for this data version';
    end if;
    
    for v_batch_data IN select * from json_populate_recordset(null::billing.cdr_v2,_j_data) LOOP
        if v_batch_data.customer_price >0  or v_batch_data.vendor_price>0 then
            perform billing.bill_cdr(v_batch_data);
        end if;
        -- update runtime statistics

        perform runtime_stats.update_dp(v_batch_data.destination_id,v_batch_data.dialpeer_id,
            v_batch_data.success,v_batch_data.duration
            );
            
        perform runtime_stats.update_gw(v_batch_data.orig_gw_id,v_batch_data.term_gw_id,
            v_batch_data.success,v_batch_data.duration
            );
        
       
    end LOOp;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 10;

DROP FUNCTION billing.bill_cdr(billing.cdr_v1);

CREATE OR REPLACE FUNCTION billing.bill_cdr(i_cdr billing.cdr_v2)
  RETURNS void AS
$BODY$
DECLARE
BEGIN
    UPDATE billing.accounts SET balance=balance+i_cdr.vendor_price WHERE id=i_cdr.vendor_account_id;
    UPDATE billing.accounts SET balance=balance-i_cdr.customer_price WHERE id=i_cdr.customer_account_id;
    return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 10;


CREATE OR REPLACE FUNCTION billing.clean_cdr_batch()
  RETURNS void AS
$BODY$
DECLARE
BEGIN
    DELETE FROM billing.cdr_batches where id not in (SELECT id from billing.cdr_batches order by id desc limit 50);
    return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 10;

ALTER TABLE class4.gateways add relay_prack boolean not null default false;
ALTER TABLE class4.gateways add rtp_relay_timestamp_aligning boolean not null default false;
ALTER TABLE class4.gateways add allow_1xx_without_to_tag boolean not null default false;
ALTER TABLE class4.gateways add sip_timer_b integer not null default 8000;
ALTER TABLE class4.gateways add dns_srv_failover_timer integer not null default 2000;
ALTER TABLE class4.gateways add rtp_force_relay_cn boolean not null default true;


drop schema switch1 cascade;



CREATE SCHEMA switch1;


SET search_path = switch1, pg_catalog;

--
-- TOC entry 1277 (class 1247 OID 18902)
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
-- TOC entry 1305 (class 1247 OID 19012)
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


--
-- TOC entry 1321 (class 1247 OID 19123)
-- Name: callprofile36_ty; Type: TYPE; Schema: switch1; Owner: -
--

CREATE TYPE callprofile36_ty AS (
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
	rtp_relay_timestamp_aligning boolean,
	allow_1xx_wo2tag boolean,
	invite_timeout integer,
	srv_failover_timeout integer,
	rtp_force_relay_cn boolean,
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
-- TOC entry 649 (class 1255 OID 18903)
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
-- TOC entry 665 (class 1255 OID 18904)
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
-- TOC entry 650 (class 1255 OID 18911)
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


--
-- TOC entry 651 (class 1255 OID 18912)
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
-- TOC entry 652 (class 1255 OID 18913)
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
-- TOC entry 653 (class 1255 OID 18914)
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
-- TOC entry 648 (class 1255 OID 18915)
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
-- TOC entry 654 (class 1255 OID 18916)
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
-- TOC entry 655 (class 1255 OID 18917)
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
-- TOC entry 656 (class 1255 OID 18918)
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
-- TOC entry 667 (class 1255 OID 19106)
-- Name: load_interface_in(); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION load_interface_in() RETURNS TABLE(varname character varying, vartype character varying, varformat character varying, varhashkey boolean, varparam character varying)
    LANGUAGE plpgsql COST 10
    AS $$
BEGIN
    RETURN QUERY SELECT "name","type","format","hashkey","param" from switch_interface_in order by rank asc;
END;
$$;


--
-- TOC entry 657 (class 1255 OID 18920)
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
-- TOC entry 658 (class 1255 OID 18921)
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


SET default_tablespace = '';

SET default_with_oids = false;

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
-- TOC entry 659 (class 1255 OID 18929)
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
-- TOC entry 660 (class 1255 OID 18930)
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
-- TOC entry 672 (class 1255 OID 19124)
-- Name: new_profile(); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION new_profile() RETURNS callprofile36_ty
    LANGUAGE plpgsql COST 10
    AS $_$
DECLARE
    v_ret switch1.callprofile36_ty;
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
-- TOC entry 661 (class 1255 OID 18932)
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
-- TOC entry 666 (class 1255 OID 18933)
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


--
-- TOC entry 673 (class 1255 OID 19126)
-- Name: process_dp(callprofile36_ty, class4.destinations, class4.dialpeers, billing.accounts, class4.gateways, billing.accounts, integer); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION process_dp(i_profile callprofile36_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_pop_id integer) RETURNS SETOF callprofile36_ty
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
-- TOC entry 681 (class 1255 OID 19220)
-- Name: process_dp_debug(callprofile36_ty, class4.destinations, class4.dialpeers, billing.accounts, class4.gateways, billing.accounts, integer); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION process_dp_debug(i_profile callprofile36_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_pop_id integer) RETURNS SETOF callprofile36_ty
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
-- TOC entry 682 (class 1255 OID 19221)
-- Name: process_dp_release(callprofile36_ty, class4.destinations, class4.dialpeers, billing.accounts, class4.gateways, billing.accounts, integer); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION process_dp_release(i_profile callprofile36_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_pop_id integer) RETURNS SETOF callprofile36_ty
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
-- TOC entry 676 (class 1255 OID 19127)
-- Name: process_gw(callprofile36_ty, class4.destinations, class4.dialpeers, billing.accounts, class4.gateways, billing.accounts, class4.gateways); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION process_gw(i_profile callprofile36_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_vendor_gw class4.gateways) RETURNS callprofile36_ty
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

    i_profile.enable_auth:=i_vendor_gw.auth_enabled;
    i_profile.auth_pwd:=i_vendor_gw.auth_password;
    i_profile.auth_user:=i_vendor_gw.auth_user;
    i_profile.enable_aleg_auth:=false;
    i_profile.auth_aleg_pwd:='';
    i_profile.auth_aleg_user:='';
    
    i_profile.next_hop_1st_req=i_vendor_gw.auth_enabled; -- use low delay dns srv if auth enabled
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

    
    i_profile.message_filter_type_id:=1;
    i_profile.message_filter_list:='';

    i_profile.sdp_filter_type_id:=0;
    i_profile.sdp_filter_list:='';
    
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
    i_profile.bleg_symmetric_rtp_nonstop=i_vendor_gw.symmetric_rtp_nonstop;
    i_profile.bleg_symmetric_rtp_ignore_rtcp=i_vendor_gw.symmetric_rtp_ignore_rtcp;
    
    i_profile.aleg_force_symmetric_rtp:=i_customer_gw.force_symmetric_rtp;
    i_profile.aleg_symmetric_rtp_nonstop=i_customer_gw.symmetric_rtp_nonstop;
    i_profile.aleg_symmetric_rtp_ignore_rtcp=i_customer_gw.symmetric_rtp_ignore_rtcp;

    i_profile.bleg_rtp_ping=i_vendor_gw.rtp_ping;
    i_profile.aleg_rtp_ping=i_customer_gw.rtp_ping;

    i_profile.bleg_relay_options = i_vendor_gw.relay_options;
    i_profile.aleg_relay_options = i_customer_gw.relay_options;


    i_profile.filter_noaudio_streams = i_vendor_gw.filter_noaudio_streams OR i_customer_gw.filter_noaudio_streams;
    i_profile.relay_reinvite = i_vendor_gw.relay_reinvite OR i_customer_gw.relay_reinvite;
    i_profile.relay_hold= i_vendor_gw.relay_hold OR i_customer_gw.relay_hold;
    i_profile.relay_prack= i_vendor_gw.relay_prack OR i_customer_gw.relay_prack;

    i_profile.rtp_relay_timestamp_aligning=i_vendor_gw.rtp_relay_timestamp_aligning OR i_customer_gw.rtp_relay_timestamp_aligning;
    i_profile.allow_1xx_wo2tag=i_vendor_gw.allow_1xx_without_to_tag OR i_customer_gw.allow_1xx_without_to_tag;

    i_profile.aleg_sdp_c_location_id=i_customer_gw.sdp_c_location_id;
    i_profile.bleg_sdp_c_location_id=i_vendor_gw.sdp_c_location_id;
    i_profile.trusted_hdrs_gw=false;
    
    
    
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
    i_profile.dead_rtp_time=GREATEST(i_vendor_gw.rtp_timeout,i_customer_gw.rtp_timeout);
    i_profile.invite_timeout=i_vendor_gw.sip_timer_b;
    i_profile.srv_failover_timeout=i_vendor_gw.dns_srv_failover_timer;
    i_profile.rtp_force_relay_cn=i_vendor_gw.rtp_force_relay_cn OR i_customer_gw.rtp_force_relay_cn;
    i_profile.patch_ruri_next_hop=i_vendor_gw.resolve_ruri;
    
    
    
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> DP. Finished: % ',EXTRACT(MILLISECOND from v_end-v_start),hstore(i_profile);
/*}dbg*/
    RETURN i_profile;
END;
$_$;


--
-- TOC entry 679 (class 1255 OID 19222)
-- Name: process_gw_debug(callprofile36_ty, class4.destinations, class4.dialpeers, billing.accounts, class4.gateways, billing.accounts, class4.gateways); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION process_gw_debug(i_profile callprofile36_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_vendor_gw class4.gateways) RETURNS callprofile36_ty
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

    i_profile.enable_auth:=i_vendor_gw.auth_enabled;
    i_profile.auth_pwd:=i_vendor_gw.auth_password;
    i_profile.auth_user:=i_vendor_gw.auth_user;
    i_profile.enable_aleg_auth:=false;
    i_profile.auth_aleg_pwd:='';
    i_profile.auth_aleg_user:='';
    
    i_profile.next_hop_1st_req=i_vendor_gw.auth_enabled; -- use low delay dns srv if auth enabled
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

    
    i_profile.message_filter_type_id:=1;
    i_profile.message_filter_list:='';

    i_profile.sdp_filter_type_id:=0;
    i_profile.sdp_filter_list:='';
    
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
    i_profile.bleg_symmetric_rtp_nonstop=i_vendor_gw.symmetric_rtp_nonstop;
    i_profile.bleg_symmetric_rtp_ignore_rtcp=i_vendor_gw.symmetric_rtp_ignore_rtcp;
    
    i_profile.aleg_force_symmetric_rtp:=i_customer_gw.force_symmetric_rtp;
    i_profile.aleg_symmetric_rtp_nonstop=i_customer_gw.symmetric_rtp_nonstop;
    i_profile.aleg_symmetric_rtp_ignore_rtcp=i_customer_gw.symmetric_rtp_ignore_rtcp;

    i_profile.bleg_rtp_ping=i_vendor_gw.rtp_ping;
    i_profile.aleg_rtp_ping=i_customer_gw.rtp_ping;

    i_profile.bleg_relay_options = i_vendor_gw.relay_options;
    i_profile.aleg_relay_options = i_customer_gw.relay_options;


    i_profile.filter_noaudio_streams = i_vendor_gw.filter_noaudio_streams OR i_customer_gw.filter_noaudio_streams;
    i_profile.relay_reinvite = i_vendor_gw.relay_reinvite OR i_customer_gw.relay_reinvite;
    i_profile.relay_hold= i_vendor_gw.relay_hold OR i_customer_gw.relay_hold;
    i_profile.relay_prack= i_vendor_gw.relay_prack OR i_customer_gw.relay_prack;

    i_profile.rtp_relay_timestamp_aligning=i_vendor_gw.rtp_relay_timestamp_aligning OR i_customer_gw.rtp_relay_timestamp_aligning;
    i_profile.allow_1xx_wo2tag=i_vendor_gw.allow_1xx_without_to_tag OR i_customer_gw.allow_1xx_without_to_tag;

    i_profile.aleg_sdp_c_location_id=i_customer_gw.sdp_c_location_id;
    i_profile.bleg_sdp_c_location_id=i_vendor_gw.sdp_c_location_id;
    i_profile.trusted_hdrs_gw=false;
    
    
    
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
    i_profile.dead_rtp_time=GREATEST(i_vendor_gw.rtp_timeout,i_customer_gw.rtp_timeout);
    i_profile.invite_timeout=i_vendor_gw.sip_timer_b;
    i_profile.srv_failover_timeout=i_vendor_gw.dns_srv_failover_timer;
    i_profile.rtp_force_relay_cn=i_vendor_gw.rtp_force_relay_cn OR i_customer_gw.rtp_force_relay_cn;
    i_profile.patch_ruri_next_hop=i_vendor_gw.resolve_ruri;
    
    
    
/*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> DP. Finished: % ',EXTRACT(MILLISECOND from v_end-v_start),hstore(i_profile);
/*}dbg*/
    RETURN i_profile;
END;
$_$;


--
-- TOC entry 680 (class 1255 OID 19224)
-- Name: process_gw_release(callprofile36_ty, class4.destinations, class4.dialpeers, billing.accounts, class4.gateways, billing.accounts, class4.gateways); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION process_gw_release(i_profile callprofile36_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_vendor_gw class4.gateways) RETURNS callprofile36_ty
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

    i_profile.enable_auth:=i_vendor_gw.auth_enabled;
    i_profile.auth_pwd:=i_vendor_gw.auth_password;
    i_profile.auth_user:=i_vendor_gw.auth_user;
    i_profile.enable_aleg_auth:=false;
    i_profile.auth_aleg_pwd:='';
    i_profile.auth_aleg_user:='';
    
    i_profile.next_hop_1st_req=i_vendor_gw.auth_enabled; -- use low delay dns srv if auth enabled
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

    
    i_profile.message_filter_type_id:=1;
    i_profile.message_filter_list:='';

    i_profile.sdp_filter_type_id:=0;
    i_profile.sdp_filter_list:='';
    
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
    i_profile.bleg_symmetric_rtp_nonstop=i_vendor_gw.symmetric_rtp_nonstop;
    i_profile.bleg_symmetric_rtp_ignore_rtcp=i_vendor_gw.symmetric_rtp_ignore_rtcp;
    
    i_profile.aleg_force_symmetric_rtp:=i_customer_gw.force_symmetric_rtp;
    i_profile.aleg_symmetric_rtp_nonstop=i_customer_gw.symmetric_rtp_nonstop;
    i_profile.aleg_symmetric_rtp_ignore_rtcp=i_customer_gw.symmetric_rtp_ignore_rtcp;

    i_profile.bleg_rtp_ping=i_vendor_gw.rtp_ping;
    i_profile.aleg_rtp_ping=i_customer_gw.rtp_ping;

    i_profile.bleg_relay_options = i_vendor_gw.relay_options;
    i_profile.aleg_relay_options = i_customer_gw.relay_options;


    i_profile.filter_noaudio_streams = i_vendor_gw.filter_noaudio_streams OR i_customer_gw.filter_noaudio_streams;
    i_profile.relay_reinvite = i_vendor_gw.relay_reinvite OR i_customer_gw.relay_reinvite;
    i_profile.relay_hold= i_vendor_gw.relay_hold OR i_customer_gw.relay_hold;
    i_profile.relay_prack= i_vendor_gw.relay_prack OR i_customer_gw.relay_prack;

    i_profile.rtp_relay_timestamp_aligning=i_vendor_gw.rtp_relay_timestamp_aligning OR i_customer_gw.rtp_relay_timestamp_aligning;
    i_profile.allow_1xx_wo2tag=i_vendor_gw.allow_1xx_without_to_tag OR i_customer_gw.allow_1xx_without_to_tag;

    i_profile.aleg_sdp_c_location_id=i_customer_gw.sdp_c_location_id;
    i_profile.bleg_sdp_c_location_id=i_vendor_gw.sdp_c_location_id;
    i_profile.trusted_hdrs_gw=false;
    
    
    
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
    i_profile.dead_rtp_time=GREATEST(i_vendor_gw.rtp_timeout,i_customer_gw.rtp_timeout);
    i_profile.invite_timeout=i_vendor_gw.sip_timer_b;
    i_profile.srv_failover_timeout=i_vendor_gw.dns_srv_failover_timer;
    i_profile.rtp_force_relay_cn=i_vendor_gw.rtp_force_relay_cn OR i_customer_gw.rtp_force_relay_cn;
    i_profile.patch_ruri_next_hop=i_vendor_gw.resolve_ruri;
    
    
    

    RETURN i_profile;
END;
$_$;


--
-- TOC entry 662 (class 1255 OID 18943)
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
-- TOC entry 674 (class 1255 OID 19129)
-- Name: route(integer, integer, inet, integer, inet, integer, character varying, character varying, character varying, integer, character varying, character varying, integer, character varying, character varying, integer, character varying, character varying, character varying, character varying, inet, integer); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION route(i_node_id integer, i_pop_id integer, i_remote_ip inet, i_remote_port integer, i_local_ip inet, i_local_port integer, i_from_dsp character varying, i_from_name character varying, i_from_domain character varying, i_from_port integer, i_to_name character varying, i_to_domain character varying, i_to_port integer, i_contact_name character varying, i_contact_domain character varying, i_contact_port integer, i_uri_name character varying, i_uri_domain character varying, i_x_yeti_auth character varying, i_diversion character varying, i_x_orig_ip inet, i_x_orig_port integer) RETURNS SETOF callprofile36_ty
    LANGUAGE plpgsql SECURITY DEFINER ROWS 10
    AS $$
DECLARE
v_ret switch1.callprofile36_ty;
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
-- TOC entry 677 (class 1255 OID 19216)
-- Name: route_debug(integer, integer, inet, integer, inet, integer, character varying, character varying, character varying, integer, character varying, character varying, integer, character varying, character varying, integer, character varying, character varying, character varying, character varying, inet, integer); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION route_debug(i_node_id integer, i_pop_id integer, i_remote_ip inet, i_remote_port integer, i_local_ip inet, i_local_port integer, i_from_dsp character varying, i_from_name character varying, i_from_domain character varying, i_from_port integer, i_to_name character varying, i_to_domain character varying, i_to_port integer, i_contact_name character varying, i_contact_domain character varying, i_contact_port integer, i_uri_name character varying, i_uri_domain character varying, i_x_yeti_auth character varying, i_diversion character varying, i_x_orig_ip inet, i_x_orig_port integer) RETURNS SETOF callprofile36_ty
    LANGUAGE plpgsql SECURITY DEFINER ROWS 10
    AS $$
DECLARE
v_ret switch1.callprofile36_ty;
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
-- TOC entry 675 (class 1255 OID 19218)
-- Name: route_release(integer, integer, inet, integer, inet, integer, character varying, character varying, character varying, integer, character varying, character varying, integer, character varying, character varying, integer, character varying, character varying, character varying, character varying, inet, integer); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION route_release(i_node_id integer, i_pop_id integer, i_remote_ip inet, i_remote_port integer, i_local_ip inet, i_local_port integer, i_from_dsp character varying, i_from_name character varying, i_from_domain character varying, i_from_port integer, i_to_name character varying, i_to_domain character varying, i_to_port integer, i_contact_name character varying, i_contact_domain character varying, i_contact_port integer, i_uri_name character varying, i_uri_domain character varying, i_x_yeti_auth character varying, i_diversion character varying, i_x_orig_ip inet, i_x_orig_port integer) RETURNS SETOF callprofile36_ty
    LANGUAGE plpgsql SECURITY DEFINER ROWS 10
    AS $$
DECLARE
v_ret switch1.callprofile36_ty;
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
-- TOC entry 663 (class 1255 OID 18945)
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
-- TOC entry 664 (class 1255 OID 18946)
-- Name: tracelog(class4.dialpeers); Type: FUNCTION; Schema: switch1; Owner: -
--

CREATE FUNCTION tracelog(i_in class4.dialpeers) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$
BEGIN    
    RAISE INFO 'switch1.tracelog: % : %',clock_timestamp()::char(25),i_in;
END;
$$;


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
-- TOC entry 2882 (class 0 OID 0)
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
-- TOC entry 2883 (class 0 OID 0)
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
    hashkey boolean DEFAULT false NOT NULL,
    param character varying
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
-- TOC entry 2884 (class 0 OID 0)
-- Dependencies: 310
-- Name: trusted_headers_id_seq; Type: SEQUENCE OWNED BY; Schema: switch1; Owner: -
--

ALTER SEQUENCE trusted_headers_id_seq OWNED BY trusted_headers.id;


--
-- TOC entry 2736 (class 2604 OID 18983)
-- Name: id; Type: DEFAULT; Schema: switch1; Owner: -
--

ALTER TABLE ONLY resource_type ALTER COLUMN id SET DEFAULT nextval('resource_type_id_seq'::regclass);


--
-- TOC entry 2738 (class 2604 OID 18984)
-- Name: id; Type: DEFAULT; Schema: switch1; Owner: -
--

ALTER TABLE ONLY switch_interface_out ALTER COLUMN id SET DEFAULT nextval('switch_interface_id_seq'::regclass);


--
-- TOC entry 2741 (class 2604 OID 18985)
-- Name: id; Type: DEFAULT; Schema: switch1; Owner: -
--

ALTER TABLE ONLY trusted_headers ALTER COLUMN id SET DEFAULT nextval('trusted_headers_id_seq'::regclass);


--
-- TOC entry 2885 (class 0 OID 0)
-- Dependencies: 302
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: switch1; Owner: -
--

SELECT pg_catalog.setval('events_id_seq', 280, true);


--
-- TOC entry 2870 (class 0 OID 18949)
-- Dependencies: 303
-- Data for Name: resource_action; Type: TABLE DATA; Schema: switch1; Owner: -
--

INSERT INTO resource_action (id, name) VALUES (1, 'Reject');
INSERT INTO resource_action (id, name) VALUES (2, 'Try next route');
INSERT INTO resource_action (id, name) VALUES (3, 'Accept');


--
-- TOC entry 2868 (class 0 OID 18922)
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
-- TOC entry 2886 (class 0 OID 0)
-- Dependencies: 304
-- Name: resource_type_id_seq; Type: SEQUENCE SET; Schema: switch1; Owner: -
--

SELECT pg_catalog.setval('resource_type_id_seq', 6, true);


--
-- TOC entry 2887 (class 0 OID 0)
-- Dependencies: 305
-- Name: switch_in_interface_id_seq; Type: SEQUENCE SET; Schema: switch1; Owner: -
--

SELECT pg_catalog.setval('switch_in_interface_id_seq', 4, true);


--
-- TOC entry 2888 (class 0 OID 0)
-- Dependencies: 307
-- Name: switch_interface_id_seq; Type: SEQUENCE SET; Schema: switch1; Owner: -
--

SELECT pg_catalog.setval('switch_interface_id_seq', 859, true);


--
-- TOC entry 2875 (class 0 OID 18967)
-- Dependencies: 308
-- Data for Name: switch_interface_in; Type: TABLE DATA; Schema: switch1; Owner: -
--

INSERT INTO switch_interface_in (id, name, type, rank, format, hashkey, param) VALUES (2, 'Diversion', 'varchar', 2, 'uri_user', false, NULL);
INSERT INTO switch_interface_in (id, name, type, rank, format, hashkey, param) VALUES (1, 'X-YETI-AUTH', 'varchar', 1, NULL, true, NULL);
INSERT INTO switch_interface_in (id, name, type, rank, format, hashkey, param) VALUES (3, 'X-ORIG-IP', 'varchar', 3, NULL, true, NULL);
INSERT INTO switch_interface_in (id, name, type, rank, format, hashkey, param) VALUES (4, 'X-ORIG-PORT', 'integer', 4, NULL, true, NULL);


--
-- TOC entry 2873 (class 0 OID 18959)
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
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (854, 'rtp_relay_timestamp_aligning', 'boolean', false, 1005);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (855, 'allow_1xx_wo2tag', 'boolean', false, 1006);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (856, 'invite_timeout', 'integer', false, 1007);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (857, 'srv_failover_timeout', 'integer', false, 1008);
INSERT INTO switch_interface_out (id, name, type, custom, rank) VALUES (859, 'rtp_force_relay_cn', 'boolean', false, 1009);


--
-- TOC entry 2876 (class 0 OID 18975)
-- Dependencies: 309
-- Data for Name: trusted_headers; Type: TABLE DATA; Schema: switch1; Owner: -
--



--
-- TOC entry 2889 (class 0 OID 0)
-- Dependencies: 310
-- Name: trusted_headers_id_seq; Type: SEQUENCE SET; Schema: switch1; Owner: -
--

SELECT pg_catalog.setval('trusted_headers_id_seq', 2, true);


--
-- TOC entry 2747 (class 2606 OID 18987)
-- Name: resource_action_name_key; Type: CONSTRAINT; Schema: switch1; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resource_action
    ADD CONSTRAINT resource_action_name_key UNIQUE (name);


--
-- TOC entry 2749 (class 2606 OID 18989)
-- Name: resource_action_pkey; Type: CONSTRAINT; Schema: switch1; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resource_action
    ADD CONSTRAINT resource_action_pkey PRIMARY KEY (id);


--
-- TOC entry 2743 (class 2606 OID 18991)
-- Name: resource_type_name_key; Type: CONSTRAINT; Schema: switch1; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resource_type
    ADD CONSTRAINT resource_type_name_key UNIQUE (name);


--
-- TOC entry 2745 (class 2606 OID 18993)
-- Name: resource_type_pkey; Type: CONSTRAINT; Schema: switch1; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resource_type
    ADD CONSTRAINT resource_type_pkey PRIMARY KEY (id);


--
-- TOC entry 2755 (class 2606 OID 18995)
-- Name: switch_in_interface_pkey; Type: CONSTRAINT; Schema: switch1; Owner: -; Tablespace: 
--

ALTER TABLE ONLY switch_interface_in
    ADD CONSTRAINT switch_in_interface_pkey PRIMARY KEY (id);


--
-- TOC entry 2757 (class 2606 OID 18997)
-- Name: switch_in_interface_rank_key; Type: CONSTRAINT; Schema: switch1; Owner: -; Tablespace: 
--

ALTER TABLE ONLY switch_interface_in
    ADD CONSTRAINT switch_in_interface_rank_key UNIQUE (rank);


--
-- TOC entry 2751 (class 2606 OID 18999)
-- Name: switch_interface_pkey; Type: CONSTRAINT; Schema: switch1; Owner: -; Tablespace: 
--

ALTER TABLE ONLY switch_interface_out
    ADD CONSTRAINT switch_interface_pkey PRIMARY KEY (id);


--
-- TOC entry 2753 (class 2606 OID 19001)
-- Name: switch_interface_rank_key; Type: CONSTRAINT; Schema: switch1; Owner: -; Tablespace: 
--

ALTER TABLE ONLY switch_interface_out
    ADD CONSTRAINT switch_interface_rank_key UNIQUE (rank);


--
-- TOC entry 2759 (class 2606 OID 19003)
-- Name: trusted_headers_pkey; Type: CONSTRAINT; Schema: switch1; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trusted_headers
    ADD CONSTRAINT trusted_headers_pkey PRIMARY KEY (id);


--
-- TOC entry 2760 (class 2606 OID 19004)
-- Name: resource_type_action_id_fkey; Type: FK CONSTRAINT; Schema: switch1; Owner: -
--

ALTER TABLE ONLY resource_type
    ADD CONSTRAINT resource_type_action_id_fkey FOREIGN KEY (action_id) REFERENCES resource_action(id);


-- Completed on 2014-10-17 19:03:26 EEST

--
-- PostgreSQL database dump complete
--


commit;
