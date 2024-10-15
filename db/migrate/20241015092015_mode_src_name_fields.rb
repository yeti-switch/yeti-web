class ModeSrcNameFields < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      insert into class4.customers_auth_src_name_fields(id,name) values(2,'From header userpart');

CREATE or replace FUNCTION switch21.route(i_node_id integer, i_pop_id integer, i_protocol_id smallint, i_remote_ip inet, i_remote_port integer, i_local_ip inet, i_local_port integer, i_from_dsp character varying, i_from_name character varying, i_from_domain character varying, i_from_port integer, i_to_name character varying, i_to_domain character varying, i_to_port integer, i_contact_name character varying, i_contact_domain character varying, i_contact_port integer, i_uri_name character varying, i_uri_domain character varying, i_auth_id integer, i_identity_data json, i_interface character varying, i_x_yeti_auth character varying, i_diversion character varying, i_x_orig_ip inet, i_x_orig_port integer, i_x_orig_protocol_id smallint, i_pai character varying, i_ppi character varying, i_privacy character varying, i_rpid character varying, i_rpid_privacy character varying) RETURNS SETOF switch21.callprofile_ty
    LANGUAGE plpgsql SECURITY DEFINER ROWS 10
    AS $_$
      DECLARE
        v_ret switch21.callprofile_ty;
        i integer;
        v_ip inet;
        v_remote_ip inet;
        v_remote_port INTEGER;
        v_transport_protocol_id smallint;
        v_customer_auth_normalized class4.customers_auth_normalized;
        v_destination class4.destinations%rowtype;
        v_dialpeer record;
        v_rateplan class4.rateplans%rowtype;
        v_dst_gw class4.gateways%rowtype;
        v_orig_gw class4.gateways%rowtype;
        v_rp class4.routing_plans%rowtype;
        v_customer_allowtime real;
        v_vendor_allowtime real;
        v_sorting_id integer;
        v_customer_acc integer;
        v_route_found boolean:=false;
        v_c_acc billing.accounts%rowtype;
        v_v_acc billing.accounts%rowtype;
        v_network sys.network_prefixes%rowtype;
        v_src_network sys.network_prefixes%rowtype;
        routedata record;
        /*dbg{*/
        v_start timestamp;
        v_end timestamp;
        /*}dbg*/
        v_rate NUMERIC;
        v_now timestamp;
        v_x_yeti_auth varchar;
        --  v_uri_domain varchar;
        v_rate_limit float:='Infinity'::float;
        v_destination_rate_limit float:='Infinity'::float;
        v_test_vendor_id integer;
        v_random float;
        v_max_call_length integer;
        v_routing_key varchar;
        v_lnp_key varchar;
        v_lnp_rule class4.routing_plan_lnp_rules%rowtype;
        v_numberlist record;
        v_numberlist_item record;
        v_call_tags smallint[]:='{}'::smallint[];
        v_area_direction class4.routing_tag_detection_rules%rowtype;
        v_numberlist_size integer;
        v_lua_context switch21.lua_call_context;
        v_identity_data switch21.identity_data_ty[];
        v_identity_record switch21.identity_data_ty;
        v_pai varchar[];
        v_ppi varchar;
        v_privacy varchar[];
        v_diversion varchar[] not null default ARRAY[]::varchar[];
        v_cnam_req_json json;
        v_cnam_resp_json json;
        v_cnam_lua_resp switch21.cnam_lua_resp;
        v_cnam_database class4.cnam_databases%rowtype;
        v_rewrite switch21.defered_rewrite;
        v_defered_src_rewrites switch21.defered_rewrite[] not null default ARRAY[]::switch21.defered_rewrite[];
        v_defered_dst_rewrites switch21.defered_rewrite[] not null default ARRAY[]::switch21.defered_rewrite[];
        v_rate_groups integer[];
        v_routing_groups integer[];
        v_package billing.package_counters%rowtype;
        v_ss_src varchar;
        v_ss_dst varchar;
        v_stir_dst_tn varchar;
      BEGIN
        /*dbg{*/
        v_start:=now();
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> Execution start',EXTRACT(MILLISECOND from v_end-v_start);
        /*}dbg*/

        perform id from sys.load_balancers where signalling_ip=host(i_remote_ip)::varchar;
        IF FOUND and i_x_orig_ip IS not NULL AND i_x_orig_port IS not NULL THEN
          v_remote_ip:=i_x_orig_ip;
          v_remote_port:=i_x_orig_port;
          v_transport_protocol_id=i_x_orig_protocol_id;
          /*dbg{*/RAISE NOTICE '% ms -> Got originator address "%:%, proto: %" from x-headers',EXTRACT(MILLISECOND from v_end-v_start), v_remote_ip,v_remote_port, v_transport_protocol_id;/*}dbg*/
        else
          v_remote_ip:=i_remote_ip;
          v_remote_port:=i_remote_port;
          v_transport_protocol_id:=i_protocol_id;
          /*dbg{*/RAISE NOTICE '% ms -> Got originator address "%:%, proto: %" from switch leg info',EXTRACT(MILLISECOND from v_end-v_start), v_remote_ip,v_remote_port, v_transport_protocol_id;/*}dbg*/
        end if;

        v_now:=now();
        v_ret:=switch21.new_profile();

        v_ret.diversion_in:=i_diversion;

        v_ret.auth_orig_protocol_id =v_transport_protocol_id;
        v_ret.auth_orig_ip = v_remote_ip;
        v_ret.auth_orig_port = v_remote_port;

        v_ret.src_name_in:=i_from_dsp;
        v_ret.src_name_out:=v_ret.src_name_in;

        v_ret.src_prefix_in:=i_from_name;
        v_ret.src_prefix_out:=v_ret.src_prefix_in;

        v_ret.dst_prefix_in:=i_uri_name;
        v_ret.dst_prefix_out:=v_ret.dst_prefix_in;


        v_ret.ruri_domain=i_uri_domain;
        v_ret.from_domain=i_from_domain;
        v_ret.to_domain=i_to_domain;

        v_ret.pai_in=i_pai;
        v_pai=string_to_array(COALESCE(i_pai,''),',');
        v_ret.ppi_in=i_ppi;
        v_ppi=i_ppi;
        v_ret.privacy_in=i_privacy;
        v_privacy = string_to_array(COALESCE(i_privacy,''),';');
        v_ret.rpid_in=i_rpid;
        v_ret.rpid_privacy_in=i_rpid_privacy;

        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> AUTH. lookup started',EXTRACT(MILLISECOND from v_end-v_start);
        /*}dbg*/
        v_x_yeti_auth:=COALESCE(i_x_yeti_auth,'');
        --  v_uri_domain:=COALESCE(i_uri_domain,'');

        if i_auth_id is null then
            SELECT into v_customer_auth_normalized ca.*
            from class4.customers_auth_normalized ca
                JOIN public.contractors c ON c.id=ca.customer_id
            WHERE ca.enabled AND
              ca.ip>>=v_remote_ip AND
              prefix_range(ca.dst_prefix)@>prefix_range(v_ret.dst_prefix_in) AND
              prefix_range(ca.src_prefix)@>prefix_range(v_ret.src_prefix_in) AND
              (ca.pop_id=i_pop_id or ca.pop_id is null) and
              COALESCE(ca.x_yeti_auth,'')=v_x_yeti_auth AND
              COALESCE(nullif(ca.uri_domain,'')=i_uri_domain,true) AND
              COALESCE(nullif(ca.to_domain,'')=i_to_domain,true) AND
              COALESCE(nullif(ca.from_domain,'')=i_from_domain,true) AND
              (ca.interface is null or ca.interface = i_interface ) AND
              (ca.transport_protocol_id is null or ca.transport_protocol_id=v_transport_protocol_id) AND
              length(v_ret.dst_prefix_in) between ca.dst_number_min_length and ca.dst_number_max_length and
              length(v_ret.src_prefix_in) between ca.src_number_min_length and ca.src_number_max_length and
              c.enabled and c.customer
            ORDER BY
                masklen(ca.ip) DESC,
                ca.transport_protocol_id is null,
                length(prefix_range(ca.dst_prefix)) DESC,
                length(prefix_range(ca.src_prefix)) DESC,
                ca.pop_id is null,
                ca.uri_domain is null,
                ca.to_domain is null,
                ca.from_domain is null,
                ca.require_incoming_auth
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
            if v_customer_auth_normalized.require_incoming_auth then
            /*dbg{*/
                v_end:=clock_timestamp();
                RAISE NOTICE '% ms -> AUTH. Incoming auth required. Respond 401',EXTRACT(MILLISECOND from v_end-v_start);
            /*}dbg*/
                v_ret.aleg_auth_required=true;
                RETURN NEXT v_ret;
                RETURN;
            end IF;
            if v_customer_auth_normalized.reject_calls then
            /*dbg{*/
                v_end:=clock_timestamp();
                RAISE NOTICE '% ms -> AUTH.  disconnection with 8004. Reject by customers auth',EXTRACT(MILLISECOND from v_end-v_start);
            /*}dbg*/
                v_ret.disconnect_code_id=8004; -- call rejected by authorization

                v_ret.customer_auth_id:=v_customer_auth_normalized.customers_auth_id;
                v_ret.customer_auth_external_id:=v_customer_auth_normalized.external_id;
                v_ret.customer_auth_external_type:=v_customer_auth_normalized.external_type;

                v_ret.customer_id:=v_customer_auth_normalized.customer_id;
                select into strict v_ret.customer_external_id external_id from public.contractors where id=v_ret.customer_id;

                v_ret.rateplan_id:=v_customer_auth_normalized.rateplan_id;
                v_ret.routing_plan_id:=v_customer_auth_normalized.routing_plan_id;

                v_ret.customer_acc_id:=v_customer_auth_normalized.account_id;
                SELECT INTO STRICT v_ret.customer_acc_external_id external_id FROM billing.accounts WHERE id=v_customer_auth_normalized.account_id;

                RETURN NEXT v_ret;
                RETURN;
            end if;
        else
            SELECT into v_customer_auth_normalized ca.*
            from class4.customers_auth_normalized ca
                JOIN public.contractors c ON c.id=ca.customer_id
            WHERE ca.enabled AND
              ca.ip>>=v_remote_ip AND
              prefix_range(ca.dst_prefix)@>prefix_range(v_ret.dst_prefix_in) AND
              prefix_range(ca.src_prefix)@>prefix_range(v_ret.src_prefix_in) AND
              (ca.pop_id=i_pop_id or ca.pop_id is null) and
              COALESCE(ca.x_yeti_auth,'')=v_x_yeti_auth AND
              COALESCE(nullif(ca.uri_domain,'')=i_uri_domain,true) AND
              COALESCE(nullif(ca.to_domain,'')=i_to_domain,true) AND
              COALESCE(nullif(ca.from_domain,'')=i_from_domain,true) AND
              (ca.interface is null or ca.interface = i_interface ) AND
              (ca.transport_protocol_id is null or ca.transport_protocol_id=v_transport_protocol_id) AND
              length(v_ret.dst_prefix_in) between ca.dst_number_min_length and ca.dst_number_max_length and
              length(v_ret.src_prefix_in) between ca.src_number_min_length and ca.src_number_max_length and
              c.enabled and c.customer and
              ca.require_incoming_auth and gateway_id = i_auth_id
            ORDER BY
                masklen(ca.ip) DESC,
                ca.transport_protocol_id is null,
                length(prefix_range(ca.dst_prefix)) DESC,
                length(prefix_range(ca.src_prefix)) DESC,
                ca.pop_id is null,
                ca.uri_domain is null,
                ca.to_domain is null,
                ca.from_domain is null
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
            if v_customer_auth_normalized.reject_calls then
            /*dbg{*/
                v_end:=clock_timestamp();
                RAISE NOTICE '% ms -> AUTH.  disconnection with 8004. Reject by customers auth',EXTRACT(MILLISECOND from v_end-v_start);
            /*}dbg*/
                v_ret.disconnect_code_id=8004; -- call rejected by authorization

                v_ret.customer_auth_id:=v_customer_auth_normalized.customers_auth_id;
                v_ret.customer_auth_external_id:=v_customer_auth_normalized.external_id;
                v_ret.customer_auth_external_type:=v_customer_auth_normalized.external_type;

                v_ret.customer_id:=v_customer_auth_normalized.customer_id;
                select into strict v_ret.customer_external_id external_id from public.contractors where id=v_ret.customer_id;

                v_ret.rateplan_id:=v_customer_auth_normalized.rateplan_id;
                v_ret.routing_plan_id:=v_customer_auth_normalized.routing_plan_id;

                v_ret.customer_acc_id:=v_customer_auth_normalized.account_id;
                SELECT INTO STRICT v_ret.customer_acc_external_id external_id FROM billing.accounts WHERE id=v_customer_auth_normalized.account_id;

                RETURN NEXT v_ret;
                RETURN;
            end if;
        end IF;

        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> AUTH. found: %',EXTRACT(MILLISECOND from v_end-v_start),row_to_json(v_customer_auth_normalized, true);
        /*}dbg*/

        -- redefine call SRC/DST numbers

        IF v_customer_auth_normalized.src_name_field_id=1 THEN  /* default - from uri display name */
          v_ret.src_name_in=i_from_dsp;
        ELSIF v_customer_auth_normalized.src_name_field_id=2 THEN /* from uri userpart */
          v_ret.src_name_in=i_from_name;
        END IF;
        v_ret.src_name_out:=v_ret.src_name_in;

        IF v_customer_auth_normalized.src_number_field_id=1 THEN  /* default - from uri userpart */
          v_ret.src_prefix_in:=i_from_name;
        ELSIF v_customer_auth_normalized.src_number_field_id=2 THEN /* From uri Display name */
          v_ret.src_prefix_in:=i_from_dsp;
        END IF;
        v_ret.src_prefix_out:=v_ret.src_prefix_in;

        IF v_customer_auth_normalized.dst_number_field_id=1 THEN /* default  - RURI userpart*/
          v_ret.dst_prefix_in:=i_uri_name;
        ELSIF v_customer_auth_normalized.dst_number_field_id=2 THEN /* TO URI userpart */
          v_ret.dst_prefix_in:=i_to_name;
        ELSIF v_customer_auth_normalized.dst_number_field_id=3 THEN /* Top-Most Diversion header userpart */
          v_ret.dst_prefix_in:=COALESCE(i_diversion,'');
        END IF;
        v_ret.dst_prefix_out:=v_ret.dst_prefix_in;

        IF v_customer_auth_normalized.diversion_policy_id = 2 THEN /* accept diversion */
          v_diversion = string_to_array(COALESCE(i_diversion,''),',');
          v_diversion = yeti_ext.regexp_replace_rand(
            v_diversion,
            v_customer_auth_normalized.diversion_rewrite_rule,
            v_customer_auth_normalized.diversion_rewrite_result
          );
        END IF;

        -- feel customer data ;-)
        v_ret.dump_level_id:=v_customer_auth_normalized.dump_level_id;
        v_ret.customer_auth_id:=v_customer_auth_normalized.customers_auth_id;
        v_ret.customer_auth_external_id:=v_customer_auth_normalized.external_id;
        v_ret.customer_auth_external_type:=v_customer_auth_normalized.external_type;

        v_ret.customer_id:=v_customer_auth_normalized.customer_id;
        select into strict v_ret.customer_external_id external_id from public.contractors where id=v_customer_auth_normalized.customer_id;

        v_ret.rateplan_id:=v_customer_auth_normalized.rateplan_id;
        v_ret.routing_plan_id:=v_customer_auth_normalized.routing_plan_id;
        v_ret.customer_acc_id:=v_customer_auth_normalized.account_id;

        v_ret.orig_gw_id:=v_customer_auth_normalized.gateway_id;
        SELECT into v_orig_gw * from class4.gateways WHERE id=v_customer_auth_normalized.gateway_id;
        -- we have to set disconnect policy to allow rewrite internal reject when call rejected before gw processing
        v_ret.aleg_policy_id = v_orig_gw.orig_disconnect_policy_id;

        if not v_orig_gw.enabled then
          v_ret.disconnect_code_id=8005; -- Origination gateway is disabled
          RETURN NEXT v_ret;
          RETURN;
        end if;

        CASE v_customer_auth_normalized.privacy_mode_id
            WHEN 1 THEN
              -- allow all
            WHEN 2 THEN
              IF cardinality(array_remove(v_privacy,'none')) > 0 THEN
                v_ret.disconnect_code_id = 8013;
                RETURN NEXT v_ret;
                RETURN;
              END IF;
            WHEN 3 THEN
              IF 'critical' = ANY(v_privacy) THEN
                v_ret.disconnect_code_id = 8014;
                RETURN NEXT v_ret;
                RETURN;
              END IF;
            WHEN 4 THEN
              IF lower(v_ret.src_prefix_in)='anonymous' AND COALESCE(cardinality(v_pai),0) = 0 AND ( v_ppi is null or v_ppi='') THEN
                v_ret.disconnect_code_id = 8015;
                RETURN NEXT v_ret;
                RETURN;
              END IF;
        END CASE;

        ---- Identity validation ----
        select into v_identity_data array_agg(d) from  json_populate_recordset(null::switch21.identity_data_ty, i_identity_data) d;
        IF v_customer_auth_normalized.ss_mode_id = 1 THEN
          /* validate */
          v_ret.lega_ss_status_id = 0; -- none
          v_ss_src = yeti_ext.regexp_replace_rand(
            v_ret.src_prefix_in,
            v_customer_auth_normalized.ss_src_rewrite_rule,
            v_customer_auth_normalized.ss_src_rewrite_result
          );
          v_ss_dst = yeti_ext.regexp_replace_rand(
            v_ret.dst_prefix_in,
            v_customer_auth_normalized.ss_dst_rewrite_rule,
            v_customer_auth_normalized.ss_dst_rewrite_result
          );
          FOREACH v_identity_record IN ARRAY COALESCE(v_identity_data,'{}'::switch21.identity_data_ty[]) LOOP
            IF v_identity_record is null OR v_identity_record.parsed = false THEN
              -- no valid stir/shaken
              v_ret.lega_ss_status_id = 0; -- none
            ELSIF v_identity_record.parsed = true AND v_identity_record.verified = true AND ((v_identity_record.payload).orig).tn = v_ss_src THEN
              v_ret.lega_ss_status_id = -1; -- invalid
              FOREACH v_stir_dst_tn IN ARRAY COALESCE(((v_identity_record.payload).dest).tn,'{}'::varchar[]) LOOP
                IF v_stir_dst_tn = v_ss_dst THEN
                  CASE (v_identity_record.payload).attest
                    WHEN 'A' THEN
                      v_ret.lega_ss_status_id = 1;
                    WHEN 'B' THEN
                      v_ret.lega_ss_status_id = 2;
                    WHEN 'C' THEN
                      v_ret.lega_ss_status_id = 3;
                    ELSE
                      v_ret.lega_ss_status_id = -1;
                  END CASE;
                  exit; -- exit from DST checking loop
                ELSE
                  v_ret.lega_ss_status_id = -1; -- invalid
                END IF;
              END LOOP;
            ELSE
              -- parsed but not verified
              v_ret.lega_ss_status_id = -1; -- invalid
            END IF;
          END LOOP;

          IF v_ret.lega_ss_status_id = -1 THEN
              IF v_customer_auth_normalized.ss_invalid_identity_action_id = 1 THEN
                v_ret.disconnect_code_id=8019; --Identity invalid
                RETURN NEXT v_ret;
                RETURN;
              ELSIF v_customer_auth_normalized.ss_invalid_identity_action_id = 2 THEN
                v_ret.ss_attest_id = v_customer_auth_normalized.rewrite_ss_status_id;
              END IF;
          ELSIF v_ret.lega_ss_status_id = 0 THEN
              IF v_customer_auth_normalized.ss_no_identity_action_id = 1 THEN
                v_ret.disconnect_code_id=8018; --Identity required
                RETURN NEXT v_ret;
                RETURN;
              ELSIF v_customer_auth_normalized.ss_no_identity_action_id = 2 THEN
                v_ret.ss_attest_id = v_customer_auth_normalized.rewrite_ss_status_id;
              END IF;
          END IF;

        ELSIF v_customer_auth_normalized.ss_mode_id=2 THEN
          v_ret.ss_attest_id = v_customer_auth_normalized.rewrite_ss_status_id;
        END IF;

        v_ret.radius_auth_profile_id=v_customer_auth_normalized.radius_auth_profile_id;
        v_ret.aleg_radius_acc_profile_id=v_customer_auth_normalized.radius_accounting_profile_id;
        v_ret.record_audio=v_customer_auth_normalized.enable_audio_recording;

        v_ret.customer_acc_check_balance=v_customer_auth_normalized.check_account_balance;

        SELECT INTO STRICT v_c_acc * FROM billing.accounts  WHERE id=v_customer_auth_normalized.account_id;
        v_ret.customer_acc_external_id=v_c_acc.external_id;
        v_ret.customer_acc_vat=v_c_acc.vat;
        v_destination_rate_limit=coalesce(v_c_acc.destination_rate_limit::float,'Infinity'::float);

        select into v_max_call_length max_call_duration from sys.guiconfig limit 1;

        if NOT v_customer_auth_normalized.check_account_balance then
          v_ret.time_limit = LEAST(v_max_call_length, v_c_acc.max_call_duration);
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> AUTH. No customer acc balance checking. customer time limit set to max value: % ',EXTRACT(MILLISECOND from v_end-v_start), v_ret.time_limit;
          /*}dbg*/
        elsif v_customer_auth_normalized.check_account_balance AND v_c_acc.balance<=v_c_acc.min_balance then
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> AUTH. Customer acc balance checking. Call blocked before routing',EXTRACT(MILLISECOND from v_end-v_start);
          /*}dbg*/
          v_ret.disconnect_code_id=8000; --No enough customer balance
          RETURN NEXT v_ret;
          RETURN;
        end if;

        v_ret.customer_acc_external_id=v_c_acc.external_id;
        v_ret.customer_acc_vat=v_c_acc.vat;

        v_ret.lega_res='';
        if v_customer_auth_normalized.capacity is not null then
          v_ret.lega_res='3:'||v_customer_auth_normalized.customers_auth_id||':'||v_customer_auth_normalized.capacity::varchar||':1;';
        end if;

        if v_c_acc.origination_capacity is not null then
          v_ret.lega_res:=v_ret.lega_res||'1:'||v_c_acc.id::varchar||':'||v_c_acc.origination_capacity::varchar||':1;';
        end if;

        if v_c_acc.total_capacity is not null then
          v_ret.lega_res:=v_ret.lega_res||'7:'||v_c_acc.id::varchar||':'||v_c_acc.total_capacity::varchar||':1;';
        end if;

        if v_orig_gw.origination_capacity is not null then
          v_ret.lega_res:=v_ret.lega_res||'4:'||v_orig_gw.id::varchar||':'||v_orig_gw.origination_capacity::varchar||':1;';
        end if;

        if v_customer_auth_normalized.cps_limit is not null then
          if not yeti_ext.tbf_rate_check(1::integer,v_customer_auth_normalized.customers_auth_id::bigint, v_customer_auth_normalized.cps_limit::real) then
            v_ret.disconnect_code_id=8012; -- CPS limit on customer auth
            RETURN NEXT v_ret;
            RETURN;
          end if;
        end if;

        -- Tag processing CA
        v_call_tags=yeti_ext.tag_action(v_customer_auth_normalized.tag_action_id, v_call_tags, v_customer_auth_normalized.tag_action_value);

        /*
            number rewriting _Before_ routing
        */
        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> AUTH. Before rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.src_prefix_out,v_ret.dst_prefix_out;
        /*}dbg*/
        v_ret.dst_prefix_out=yeti_ext.regexp_replace_rand(v_ret.dst_prefix_out,v_customer_auth_normalized.dst_rewrite_rule,v_customer_auth_normalized.dst_rewrite_result);
        v_ret.src_prefix_out=yeti_ext.regexp_replace_rand(v_ret.src_prefix_out,v_customer_auth_normalized.src_rewrite_rule,v_customer_auth_normalized.src_rewrite_result);
        v_ret.src_name_out=yeti_ext.regexp_replace_rand(v_ret.src_name_out,v_customer_auth_normalized.src_name_rewrite_rule,v_customer_auth_normalized.src_name_rewrite_result, true);

        --  if v_ret.radius_auth_profile_id is not null then
        v_ret.src_number_radius:=i_from_name;
        v_ret.dst_number_radius:=i_uri_name;
        v_ret.src_number_radius=yeti_ext.regexp_replace_rand(
            v_ret.src_number_radius,
            v_customer_auth_normalized.src_number_radius_rewrite_rule,
            v_customer_auth_normalized.src_number_radius_rewrite_result
        );

        v_ret.dst_number_radius=yeti_ext.regexp_replace_rand(
            v_ret.dst_number_radius,
            v_customer_auth_normalized.dst_number_radius_rewrite_rule,
            v_customer_auth_normalized.dst_number_radius_rewrite_result
        );
        v_ret.customer_auth_name=v_customer_auth_normalized."name";
        v_ret.customer_name=(select "name" from public.contractors where id=v_customer_auth_normalized.customer_id limit 1);
        --  end if;
/**
        if v_customer_auth_normalized.lua_script_id is not null then
          v_lua_context.src_name_in = v_ret.src_name_in;
	        v_lua_context.src_number_in = v_ret.src_prefix_in;
	        v_lua_context.dst_number_in = v_ret.dst_prefix_in;
	        v_lua_context.src_name_out = v_ret.src_name_out;
	        v_lua_context.src_number_out = v_ret.src_prefix_out;
	        v_lua_context.dst_number_out = v_ret.dst_prefix_out;
	        -- v_lua_context.src_name_routing
	        -- v_lua_context.src_number_routing
	        -- v_lua_context.dst_number_routing
          -- #arrays
	        -- v_lua_context.diversion_in
	        -- v_lua_context.diversion_routing
	        -- v_lua_context.diversion_out
          select into v_lua_context switch21.lua_exec(v_customer_auth_normalized.lua_script_id, v_lua_context);
          v_ret.src_name_out =  v_lua_context.src_name_out;
          v_ret.src_prefix_out = v_lua_context.src_number_out;
          v_ret.dst_prefix_out = v_lua_context.dst_number_out;
        end if;
**/
        if v_customer_auth_normalized.cnam_database_id is not null then
          select into v_cnam_database * from class4.cnam_databases where id=v_customer_auth_normalized.cnam_database_id;

          select into v_cnam_req_json * from switch21.cnam_lua_build_request(v_cnam_database.request_lua, row_to_json(v_ret)::text);
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> CNAM. Lua generated request: %',EXTRACT(MILLISECOND from v_end-v_start),v_cnam_req_json;
          /*}dbg*/

          select into v_cnam_resp_json yeti_ext.lnp_resolve_cnam(v_cnam_database.id, v_cnam_req_json);

          /*dbg{*/
          v_end=clock_timestamp();
          RAISE NOTICE '% ms -> CNAM. resolver response: %',EXTRACT(MILLISECOND from v_end-v_start),v_cnam_resp_json;
          /*}dbg*/

          if json_extract_path_text(v_cnam_resp_json,'error') is not null then
            /*dbg{*/
            v_end=clock_timestamp();
            RAISE NOTICE '% ms -> CNAM. error',EXTRACT(MILLISECOND from v_end-v_start);
            /*}dbg*/
            if v_cnam_database.drop_call_on_error then
              v_ret.disconnect_code_id=8009; -- CNAM Error
              RETURN NEXT v_ret;
              RETURN;
            end if;
          else
            select into v_cnam_lua_resp * from switch21.cnam_lua_response_exec(v_cnam_database.response_lua, json_extract_path_text(v_cnam_resp_json,'response'));

            /*dbg{*/
            v_end=clock_timestamp();
            RAISE NOTICE '% ms -> CNAM. Lua parsed response: %',EXTRACT(MILLISECOND from v_end-v_start),row_to_json(v_cnam_lua_resp);
            /*}dbg*/
            if v_cnam_lua_resp.metadata is not null then
                v_ret.metadata = json_build_object('cnam_resp', v_cnam_lua_resp.metadata::json)::varchar;
            end if;
            v_ret.src_name_out = coalesce(v_cnam_lua_resp.src_name,v_ret.src_name_out);
            v_ret.src_prefix_out = coalesce(v_cnam_lua_resp.src_number,v_ret.src_prefix_out);
            v_ret.dst_prefix_out = coalesce(v_cnam_lua_resp.dst_number,v_ret.dst_prefix_out);
            v_ret.pai_out = coalesce(v_cnam_lua_resp.pai,v_ret.pai_out);
            v_ret.ppi_out = coalesce(v_cnam_lua_resp.ppi,v_ret.ppi_out);
            v_call_tags = coalesce(v_cnam_lua_resp.routing_tag_ids,v_call_tags);
          end if;

        end if;

        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> AUTH. After rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.src_prefix_out,v_ret.dst_prefix_out;
        /*}dbg*/

        ----- Numberlist processing-------------------------------------------------------------------------------------------------------
        if v_customer_auth_normalized.dst_numberlist_id is not null then
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> DST Numberlist processing. Lookup by key: %',EXTRACT(MILLISECOND from v_end-v_start), v_ret.dst_prefix_out;
          /*}dbg*/

          v_numberlist_item=switch21.match_numberlist(v_customer_auth_normalized.dst_numberlist_id, v_ret.dst_prefix_out);
          select into v_numberlist * from class4.numberlists where id=v_customer_auth_normalized.dst_numberlist_id;

          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> DST Numberlist. key found: %',EXTRACT(MILLISECOND from v_end-v_start), row_to_json(v_numberlist_item);
          /*}dbg*/
          IF v_numberlist_item.action_id is not null and v_numberlist_item.action_id=1 then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> DST Numberlist. Drop by key action. Key: %',EXTRACT(MILLISECOND from v_end-v_start), v_numberlist_item.key;
            /*}dbg*/
            v_ret.disconnect_code_id=8001; --destination blacklisted
            RETURN NEXT v_ret;
            RETURN;
          elsif v_numberlist_item.action_id is not null and v_numberlist_item.action_id=2 then
            IF v_numberlist_item.defer_src_rewrite THEN
                v_defered_src_rewrites = array_append(
                    v_defered_src_rewrites,
                    (v_numberlist_item.src_rewrite_rule, v_numberlist_item.src_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.src_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.src_prefix_out,
                    v_numberlist_item.src_rewrite_rule,
                    v_numberlist_item.src_rewrite_result
                );
            END IF;
            IF v_numberlist_item.defer_dst_rewrite THEN
                v_defered_dst_rewrites = array_append(
                    v_defered_dst_rewrites,
                    (v_numberlist_item.dst_rewrite_rule, v_numberlist_item.dst_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.dst_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.dst_prefix_out,
                    v_numberlist_item.dst_rewrite_rule,
                    v_numberlist_item.dst_rewrite_result
                );
            END IF;
            v_call_tags=yeti_ext.tag_action(v_numberlist_item.tag_action_id, v_call_tags, v_numberlist_item.tag_action_value);
            -- pass call NOP.
          elsif v_numberlist_item.action_id is null and v_numberlist.default_action_id=1 then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> DST Numberlist. Drop by default action',EXTRACT(MILLISECOND from v_end-v_start);
            /*}dbg*/
            -- drop by default
            v_ret.disconnect_code_id=8001; --destination blacklisted
            RETURN NEXT v_ret;
            RETURN;
          elsif v_numberlist_item.action_id is null and v_numberlist.default_action_id=2 then
            IF v_numberlist.defer_src_rewrite THEN
                v_defered_src_rewrites = array_append(
                    v_defered_src_rewrites,
                    (v_numberlist.default_src_rewrite_rule, v_numberlist.default_src_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.src_prefix_out=yeti_ext.regexp_replace_rand(
                v_ret.src_prefix_out,
                v_numberlist.default_src_rewrite_rule,
                v_numberlist.default_src_rewrite_result
                );
            END IF;
            IF v_numberlist.defer_dst_rewrite THEN
                v_defered_dst_rewrites = array_append(
                    v_defered_dst_rewrites,
                    (v_numberlist.default_dst_rewrite_rule, v_numberlist.default_dst_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.dst_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.dst_prefix_out,
                    v_numberlist.default_dst_rewrite_rule,
                    v_numberlist.default_dst_rewrite_result
                );
            END IF;
            v_call_tags=yeti_ext.tag_action(v_numberlist.tag_action_id, v_call_tags, v_numberlist.tag_action_value);
            -- pass by default
          end if;
        end if;

        if v_customer_auth_normalized.src_numberlist_id is not null then

          if v_customer_auth_normalized.src_numberlist_use_diversion AND v_diversion[1] is not null then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> SRC Numberlist processing. Lookup by key %, fallback to %', EXTRACT(MILLISECOND from v_end-v_start), v_ret.src_prefix_out, v_diversion[1];
            /*}dbg*/
            v_numberlist_item=switch21.match_numberlist(v_customer_auth_normalized.src_numberlist_id, v_ret.src_prefix_out, v_diversion[1]);
          else
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> SRC Numberlist processing. Lookup by key %, no fallback', EXTRACT(MILLISECOND from v_end-v_start), v_ret.src_prefix_out;
            /*}dbg*/
            v_numberlist_item=switch21.match_numberlist(v_customer_auth_normalized.src_numberlist_id, v_ret.src_prefix_out);
          end if;

          select into v_numberlist * from class4.numberlists where id=v_customer_auth_normalized.src_numberlist_id;

          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> SRC Numberlist. key found: %',EXTRACT(MILLISECOND from v_end-v_start), row_to_json(v_numberlist_item);
          /*}dbg*/
          IF v_numberlist_item.action_id is not null and v_numberlist_item.action_id=1 then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> SRC Numberlist. Drop by key action. Key: %',EXTRACT(MILLISECOND from v_end-v_start), v_numberlist_item.key;
            /*}dbg*/
            v_ret.disconnect_code_id=8002; --source blacklisted
            RETURN NEXT v_ret;
            RETURN;
          elsif v_numberlist_item.action_id is not null and v_numberlist_item.action_id=2 then
            IF v_numberlist_item.defer_src_rewrite THEN
                v_defered_src_rewrites = array_append(
                    v_defered_src_rewrites,
                    (v_numberlist_item.src_rewrite_rule, v_numberlist_item.src_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.src_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.src_prefix_out,
                    v_numberlist_item.src_rewrite_rule,
                    v_numberlist_item.src_rewrite_result
                );
            END IF;
            IF v_numberlist_item.defer_dst_rewrite THEN
                v_defered_dst_rewrites = array_append(
                    v_defered_dst_rewrites,
                    (v_numberlist_item.dst_rewrite_rule, v_numberlist_item.dst_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.dst_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.dst_prefix_out,
                    v_numberlist_item.dst_rewrite_rule,
                    v_numberlist_item.dst_rewrite_result
                );
            END IF;
            v_call_tags=yeti_ext.tag_action(v_numberlist_item.tag_action_id, v_call_tags, v_numberlist_item.tag_action_value);
            -- pass call NOP.
          elsif v_numberlist_item.action_id is null and v_numberlist.default_action_id=1 then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> SRC Numberlist. Drop by default action',EXTRACT(MILLISECOND from v_end-v_start);
            /*}dbg*/
            v_ret.disconnect_code_id=8002; --source blacklisted
            RETURN NEXT v_ret;
            RETURN;
          elsif v_numberlist_item.action_id is null and v_numberlist.default_action_id=2 then
            IF v_numberlist.defer_src_rewrite THEN
                v_defered_src_rewrites = array_append(
                    v_defered_src_rewrites,
                    (v_numberlist.default_src_rewrite_rule, v_numberlist.default_src_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.src_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.src_prefix_out,
                    v_numberlist.default_src_rewrite_rule,
                    v_numberlist.default_src_rewrite_result
                );
            END IF;
            IF v_numberlist.defer_dst_rewrite THEN
                v_defered_dst_rewrites = array_append(
                    v_defered_dst_rewrites,
                    (v_numberlist.default_dst_rewrite_rule, v_numberlist.default_dst_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.dst_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.dst_prefix_out,
                    v_numberlist.default_dst_rewrite_rule,
                    v_numberlist.default_dst_rewrite_result
                );
            END IF;
            v_call_tags=yeti_ext.tag_action(v_numberlist.tag_action_id, v_call_tags, v_numberlist.tag_action_value);
            -- pass by default
          end if;
        end if;

        SELECT INTO v_rp * from class4.routing_plans WHERE id=v_customer_auth_normalized.routing_plan_id;

        ---- Routing Plan Numberlist processing ----
        if v_rp.dst_numberlist_id is not null then
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> RP DST Numberlist processing. Lookup by key: %',EXTRACT(MILLISECOND from v_end-v_start), v_ret.dst_prefix_out;
          /*}dbg*/

          v_numberlist_item=switch21.match_numberlist(v_rp.dst_numberlist_id, v_ret.dst_prefix_out);
          select into v_numberlist * from class4.numberlists where id=v_rp.dst_numberlist_id;

          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> RP DST Numberlist. key found: %',EXTRACT(MILLISECOND from v_end-v_start), row_to_json(v_numberlist_item);
          /*}dbg*/
          IF v_numberlist_item.action_id is not null and v_numberlist_item.action_id=1 then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> RP DST Numberlist. Drop by key action. Key: %',EXTRACT(MILLISECOND from v_end-v_start), v_numberlist_item.key;
            /*}dbg*/
            v_ret.disconnect_code_id=8016; --destination blacklisted by routing plan
            RETURN NEXT v_ret;
            RETURN;
          elsif v_numberlist_item.action_id is not null and v_numberlist_item.action_id=2 then
            IF v_numberlist_item.defer_src_rewrite THEN
                v_defered_src_rewrites = array_append(
                    v_defered_src_rewrites,
                    (v_numberlist_item.src_rewrite_rule, v_numberlist_item.src_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.src_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.src_prefix_out,
                    v_numberlist_item.src_rewrite_rule,
                    v_numberlist_item.src_rewrite_result
                );
            END IF;
            IF v_numberlist_item.defer_dst_rewrite THEN
                v_defered_dst_rewrites = array_append(
                    v_defered_dst_rewrites,
                    (v_numberlist_item.dst_rewrite_rule, v_numberlist_item.dst_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.dst_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.dst_prefix_out,
                    v_numberlist_item.dst_rewrite_rule,
                    v_numberlist_item.dst_rewrite_result
                );
            END IF;
            v_call_tags=yeti_ext.tag_action(v_numberlist_item.tag_action_id, v_call_tags, v_numberlist_item.tag_action_value);
            -- pass call NOP.
          elsif v_numberlist_item.action_id is null and v_numberlist.default_action_id=1 then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> RP DST Numberlist. Drop by default action',EXTRACT(MILLISECOND from v_end-v_start);
            /*}dbg*/
            -- drop by default
            v_ret.disconnect_code_id=8016; --destination blacklisted by routing plan
            RETURN NEXT v_ret;
            RETURN;
          elsif v_numberlist_item.action_id is null and v_numberlist.default_action_id=2 then
            IF v_numberlist.defer_src_rewrite THEN
                v_defered_src_rewrites = array_append(
                    v_defered_src_rewrites,
                    (v_numberlist.default_src_rewrite_rule, v_numberlist.default_src_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.src_prefix_out=yeti_ext.regexp_replace_rand(
                v_ret.src_prefix_out,
                v_numberlist.default_src_rewrite_rule,
                v_numberlist.default_src_rewrite_result
                );
            END IF;
            IF v_numberlist.defer_dst_rewrite THEN
                v_defered_dst_rewrites = array_append(
                    v_defered_dst_rewrites,
                    (v_numberlist.default_dst_rewrite_rule, v_numberlist.default_dst_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.dst_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.dst_prefix_out,
                    v_numberlist.default_dst_rewrite_rule,
                    v_numberlist.default_dst_rewrite_result
                );
            END IF;
            v_call_tags=yeti_ext.tag_action(v_numberlist.tag_action_id, v_call_tags, v_numberlist.tag_action_value);
            -- pass by default
          end if;
        end if;

        if v_rp.src_numberlist_id is not null then
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> RP SRC Numberlist processing. Lookup by key %, no fallback', EXTRACT(MILLISECOND from v_end-v_start), v_ret.src_prefix_out;
          /*}dbg*/
          v_numberlist_item=switch21.match_numberlist(v_rp.src_numberlist_id, v_ret.src_prefix_out);

          select into v_numberlist * from class4.numberlists where id=v_rp.src_numberlist_id;

          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> RP SRC Numberlist. key found: %',EXTRACT(MILLISECOND from v_end-v_start), row_to_json(v_numberlist_item);
          /*}dbg*/
          IF v_numberlist_item.action_id is not null and v_numberlist_item.action_id=1 then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> RP SRC Numberlist. Drop by key action. Key: %',EXTRACT(MILLISECOND from v_end-v_start), v_numberlist_item.key;
            /*}dbg*/
            v_ret.disconnect_code_id=8017; --source blacklisted by routing plan
            RETURN NEXT v_ret;
            RETURN;
          elsif v_numberlist_item.action_id is not null and v_numberlist_item.action_id=2 then
            IF v_numberlist_item.defer_src_rewrite THEN
                v_defered_src_rewrites = array_append(
                    v_defered_src_rewrites,
                    (v_numberlist_item.src_rewrite_rule, v_numberlist_item.src_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.src_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.src_prefix_out,
                    v_numberlist_item.src_rewrite_rule,
                    v_numberlist_item.src_rewrite_result
                );
            END IF;
            IF v_numberlist_item.defer_dst_rewrite THEN
                v_defered_dst_rewrites = array_append(
                    v_defered_dst_rewrites,
                    (v_numberlist_item.dst_rewrite_rule, v_numberlist_item.dst_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.dst_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.dst_prefix_out,
                    v_numberlist_item.dst_rewrite_rule,
                    v_numberlist_item.dst_rewrite_result
                );
            END IF;
            v_call_tags=yeti_ext.tag_action(v_numberlist_item.tag_action_id, v_call_tags, v_numberlist_item.tag_action_value);
            -- pass call NOP.
          elsif v_numberlist_item.action_id is null and v_numberlist.default_action_id=1 then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> RP SRC Numberlist. Drop by default action',EXTRACT(MILLISECOND from v_end-v_start);
            /*}dbg*/
            v_ret.disconnect_code_id=8017; --source blacklisted by routing plan
            RETURN NEXT v_ret;
            RETURN;
          elsif v_numberlist_item.action_id is null and v_numberlist.default_action_id=2 then
            IF v_numberlist.defer_src_rewrite THEN
                v_defered_src_rewrites = array_append(
                    v_defered_src_rewrites,
                    (v_numberlist.default_src_rewrite_rule, v_numberlist.default_src_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.src_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.src_prefix_out,
                    v_numberlist.default_src_rewrite_rule,
                    v_numberlist.default_src_rewrite_result
                );
            END IF;
            IF v_numberlist.defer_dst_rewrite THEN
                v_defered_dst_rewrites = array_append(
                    v_defered_dst_rewrites,
                    (v_numberlist.default_dst_rewrite_rule, v_numberlist.default_dst_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.dst_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.dst_prefix_out,
                    v_numberlist.default_dst_rewrite_rule,
                    v_numberlist.default_dst_rewrite_result
                );
            END IF;
            v_call_tags=yeti_ext.tag_action(v_numberlist.tag_action_id, v_call_tags, v_numberlist.tag_action_value);
            -- pass by default
          end if;
        end if;
        ---- END of routing plan Numberlist processing

        --  setting numbers used for routing & billing
        v_ret.src_prefix_routing=v_ret.src_prefix_out;
        v_ret.dst_prefix_routing=v_ret.dst_prefix_out;
        v_routing_key=v_ret.dst_prefix_out;

        -- Areas and Tag detection-------------------------------------------
        v_ret.src_area_id:=(
          select area_id from class4.area_prefixes where prefix_range(prefix)@>prefix_range(v_ret.src_prefix_routing)
          order by length(prefix_range(prefix)) desc limit 1
        );

        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> SRC Area found: %',EXTRACT(MILLISECOND from v_end-v_start), v_ret.src_area_id;
        /*}dbg*/

        v_ret.dst_area_id:=(
          select area_id from class4.area_prefixes where prefix_range(prefix)@>prefix_range(v_ret.dst_prefix_routing)
          order by length(prefix_range(prefix)) desc limit 1
        );

        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> DST Area found: %',EXTRACT(MILLISECOND from v_end-v_start), v_ret.dst_area_id;
        /*}dbg*/


        select into v_area_direction * from class4.routing_tag_detection_rules
        where
          (src_area_id is null OR src_area_id = v_ret.src_area_id) AND
          (dst_area_id is null OR dst_area_id = v_ret.dst_area_id) AND
          prefix_range(src_prefix) @> prefix_range(v_ret.src_prefix_routing) AND
          prefix_range(dst_prefix) @> prefix_range(v_ret.dst_prefix_routing) AND
          yeti_ext.tag_compare(routing_tag_ids, v_call_tags, routing_tag_mode_id ) > 0
        order by
          yeti_ext.tag_compare(routing_tag_ids, v_call_tags, routing_tag_mode_id) desc,
          length(prefix_range(src_prefix)) desc,
          length(prefix_range(dst_prefix)) desc,
          src_area_id is null,
          dst_area_id is null
        limit 1;
        if found then
            /*dbg{*/
            RAISE NOTICE '% ms -> Routing tag detection rule found: %',EXTRACT(MILLISECOND from clock_timestamp() - v_start), row_to_json(v_area_direction);
            /*}dbg*/
            v_call_tags=yeti_ext.tag_action(v_area_direction.tag_action_id, v_call_tags, v_area_direction.tag_action_value);
        end if;

        v_ret.routing_tag_ids:=v_call_tags;

        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> Routing tags: %',EXTRACT(MILLISECOND from v_end-v_start), v_ret.routing_tag_ids;
        /*}dbg*/
        ----------------------------------------------------------------------

        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> Routing plan processing',EXTRACT(MILLISECOND from v_end-v_start);
        /*}dbg*/

        v_routing_key=v_ret.dst_prefix_routing;

        if v_rp.sorting_id=5 then -- route testing
          v_test_vendor_id=regexp_replace(v_routing_key,'(.*)\*(.*)','\1')::integer;
          v_routing_key=regexp_replace(v_routing_key,'(.*)\*(.*)','\2');
          v_ret.dst_prefix_out=v_routing_key;
          v_ret.dst_prefix_routing=v_routing_key;
        end if;

        if v_rp.use_lnp then
          select into v_lnp_rule rules.*
          from class4.routing_plan_lnp_rules rules
          WHERE prefix_range(rules.dst_prefix)@>prefix_range(v_ret.dst_prefix_routing) and rules.routing_plan_id=v_rp.id
          order by length(prefix_range(rules.dst_prefix)) desc limit 1;
          if found then
            v_ret.lnp_database_id=v_lnp_rule.database_id;
            v_lnp_key=v_ret.dst_prefix_routing;
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> LNP. Need LNP lookup, LNP key: %',EXTRACT(MILLISECOND from v_end-v_start),v_lnp_key;
            /*}dbg*/
            v_lnp_key=yeti_ext.regexp_replace_rand(v_lnp_key,v_lnp_rule.req_dst_rewrite_rule,v_lnp_rule.req_dst_rewrite_result);
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> LNP key translation. LNP key: %',EXTRACT(MILLISECOND from v_end-v_start),v_lnp_key;
            /*}dbg*/
            -- try cache
            select into v_ret.lrn lrn from class4.lnp_cache where dst=v_lnp_key AND database_id=v_lnp_rule.database_id and expires_at>v_now;
            if found then
              /*dbg{*/
              v_end:=clock_timestamp();
              RAISE NOTICE '% ms -> LNP. Data found in cache, lrn: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.lrn;
              /*}dbg*/
              -- TRANSLATING response from cache
              v_ret.lrn=yeti_ext.regexp_replace_rand(v_ret.lrn,v_lnp_rule.lrn_rewrite_rule,v_lnp_rule.lrn_rewrite_result);
              /*dbg{*/
              v_end:=clock_timestamp();
              RAISE NOTICE '% ms -> LNP. Translation. lrn: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.lrn;
              /*}dbg*/
              v_routing_key=v_ret.lrn;
              if v_lnp_rule.rewrite_call_destination then
                v_ret.dst_prefix_out=v_ret.lrn;
                v_ret.dst_prefix_routing=v_ret.lrn;
                -- TODO shouldn't we perform tag detection again there? Call destination changed.
              end if;
            else
              v_ret.lrn=switch21.lnp_resolve(v_ret.lnp_database_id,v_lnp_key);
              if v_ret.lrn is null then -- fail
                /*dbg{*/
                v_end:=clock_timestamp();
                RAISE NOTICE '% ms -> LNP. Query failed',EXTRACT(MILLISECOND from v_end-v_start);
                /*}dbg*/
                if v_lnp_rule.drop_call_on_error then
                  /*dbg{*/
                  v_end:=clock_timestamp();
                  RAISE NOTICE '% ms -> LNP. Dropping call',EXTRACT(MILLISECOND from v_end-v_start);
                  /*}dbg*/
                  v_ret.disconnect_code_id=8003; --No response from LNP DB
                  RETURN NEXT v_ret;
                  RETURN;
                end if;
              else
                /*dbg{*/
                v_end:=clock_timestamp();
                RAISE NOTICE '% ms -> LNP. Success, lrn: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.lrn;
                /*}dbg*/
                -- TRANSLATING response from LNP DB
                v_ret.lrn=yeti_ext.regexp_replace_rand(v_ret.lrn,v_lnp_rule.lrn_rewrite_rule,v_lnp_rule.lrn_rewrite_result);
                /*dbg{*/
                v_end:=clock_timestamp();
                RAISE NOTICE '% ms -> LNP. Translation. lrn: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.lrn;
                /*}dbg*/
                v_routing_key=v_ret.lrn;
                if v_lnp_rule.rewrite_call_destination then
                  v_ret.dst_prefix_out=v_ret.lrn;
                  v_ret.dst_prefix_routing=v_ret.lrn;
                  -- TODO shouldn't we perform tag detection again there? Call destination changed.
                end if;
              end if;
            end if;
          end if;
        end if;



        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> DST. search start. Routing key: %. Routing tags: %, Rate limit: %',EXTRACT(MILLISECOND from v_end-v_start), v_routing_key, v_ret.routing_tag_ids, v_destination_rate_limit;
        /*}dbg*/
        v_src_network:=switch21.detect_network(v_ret.src_prefix_routing);
        v_ret.src_network_id=v_src_network.network_id;
        v_ret.src_country_id=v_src_network.country_id;

        v_network:=switch21.detect_network(v_ret.dst_prefix_routing);
        v_ret.dst_network_id=v_network.network_id;
        v_ret.dst_country_id=v_network.country_id;

        IF v_rp.validate_dst_number_network AND v_ret.dst_network_id is null THEN
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> Network detection. DST network validation enabled and DST network was not found. Rejecting call',EXTRACT(MILLISECOND from v_end-v_start);
          /*}dbg*/

          v_ret.disconnect_code_id=8007; --No network detected for DST number
          RETURN NEXT v_ret;
          RETURN;
        END IF;

        IF v_rp.validate_dst_number_format AND NOT (v_routing_key ~ '^[0-9]+$') THEN
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> Dst number format is not valid. DST number: %s',EXTRACT(MILLISECOND from v_end-v_start), v_routing_key;
          /*}dbg*/

          v_ret.disconnect_code_id=8008; --Invalid DST number format
          RETURN NEXT v_ret;
          RETURN;
        END IF;

        IF v_rp.validate_src_number_network AND v_ret.src_network_id is null AND lower(v_ret.src_prefix_routing)!='anonymous' THEN
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> Network detection. SRC network validation enabled and SRC network was not found. Rejecting call',EXTRACT(MILLISECOND from v_end-v_start);
          /*}dbg*/

          v_ret.disconnect_code_id=8010; --No network detected for SRC number
          RETURN NEXT v_ret;
          RETURN;
        END IF;

        IF v_rp.validate_src_number_format AND lower(v_ret.src_prefix_routing)!='anonymous' AND NOT (v_ret.src_prefix_routing ~ '^[0-9]+$') THEN
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> SRC number format is not valid. SRC number: %s',EXTRACT(MILLISECOND from v_end-v_start), v_ret.src_prefix_routing;
          /*}dbg*/

          v_ret.disconnect_code_id=8011; --Invalid SRC number format
          RETURN NEXT v_ret;
          RETURN;
        END IF;

        --- rateplan lookup
        SELECT INTO v_rate_groups array_agg(rate_group_id) from class4.rate_plan_groups where rateplan_id = v_customer_auth_normalized.rateplan_id;

        SELECT into v_destination d.*/*,switch.tracelog(d.*)*/
        FROM class4.destinations d
        WHERE
          prefix_range(prefix)@>prefix_range(v_routing_key)
          AND length(v_routing_key) between d.dst_number_min_length and d.dst_number_max_length
          AND d.rate_group_id = ANY(v_rate_groups)
          AND enabled
          AND valid_from <= v_now
          AND valid_till >= v_now
          AND yeti_ext.tag_compare(d.routing_tag_ids, v_call_tags, d.routing_tag_mode_id)>0
        ORDER BY length(prefix_range(prefix)) DESC, yeti_ext.tag_compare(d.routing_tag_ids, v_call_tags) desc
        limit 1;
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
        RAISE NOTICE '% ms -> DST. found: %',EXTRACT(MILLISECOND from v_end-v_start),row_to_json(v_destination, true);
        /*}dbg*/

        v_ret.destination_id = v_destination.id;
        v_ret.destination_prefix = v_destination.prefix;
        v_ret.destination_initial_interval = v_destination.initial_interval;
        v_ret.destination_next_interval = v_destination.next_interval;

        IF v_destination.allow_package_billing THEN
          SELECT INTO v_package * FROM billing.package_counters pc
          WHERE pc.account_id = v_customer_auth_normalized.account_id AND
              prefix_range(pc.prefix)@>prefix_range(v_routing_key)
          ORDER BY length(prefix_range(pc.prefix)) DESC LIMIT 1;
        END IF;
        IF v_package.id is not null AND v_package.duration > 0 AND NOT v_package.exclude THEN
            v_ret.package_counter_id = v_package.id;
            v_ret.time_limit = v_package.duration;
        ELSE
          v_ret.destination_fee = v_destination.connect_fee::varchar;
          v_ret.destination_rate_policy_id = v_destination.rate_policy_id;
          v_ret.destination_reverse_billing = v_destination.reverse_billing;
          if v_destination.next_rate::float > v_destination_rate_limit then
            v_ret.disconnect_code_id=8006; -- No destination with appropriate rate found
            RETURN NEXT v_ret;
            RETURN;
          end if;
        END IF;

        IF v_destination.reject_calls THEN
          v_ret.disconnect_code_id=112; --Rejected by destination
          RETURN NEXT v_ret;
          RETURN;
        END IF;

        select into v_rateplan * from class4.rateplans where id=v_customer_auth_normalized.rateplan_id;
        if COALESCE(v_destination.profit_control_mode_id,v_rateplan.profit_control_mode_id)=2 then -- per call
          v_rate_limit=v_destination.next_rate::float;
        end if;


        /*
                    FIND dialpeers logic. Queries must use prefix index for best performance
        */
        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> DP. search start. Routing key: %. Rate limit: %. Routing tag: %',EXTRACT(MILLISECOND from v_end-v_start), v_routing_key, v_rate_limit, v_ret.routing_tag_ids;
        /*}dbg*/


        /* apply defered rewrites there, not really after routing, but without affecting v_routing_key */

        FOREACH v_rewrite IN ARRAY v_defered_src_rewrites LOOP
            v_ret.src_prefix_out = yeti_ext.regexp_replace_rand(
                v_ret.src_prefix_out,
                v_rewrite.rule,
                v_rewrite.result
            );
        END LOOP;

        FOREACH v_rewrite IN ARRAY v_defered_dst_rewrites LOOP
            v_ret.dst_prefix_out = yeti_ext.regexp_replace_rand(
                v_ret.dst_prefix_out,
                v_rewrite.rule,
                v_rewrite.result
            );
        END LOOP;

        SELECT INTO v_routing_groups array_agg(routing_group_id) from class4.routing_plan_groups where routing_plan_id = v_customer_auth_normalized.routing_plan_id;

        CASE v_rp.sorting_id
          WHEN '1' THEN -- LCR,Prio, ACD&ASR control
          FOR routedata IN (
            WITH step1 AS(
                SELECT
                  (t_dp.*)::class4.dialpeers as s1_dialpeer,
                  t_dp.vendor_id as s1_vendor_id,
                  t_dp.account_id as s1_vendor_account_id,
                  t_dp.next_rate as dp_next_rate,
                  t_dp.lcr_rate_multiplier AS dp_lcr_rate_multiplier,
                  t_dp.priority AS dp_priority,
                  t_dp.locked as dp_locked,
                  t_dp.enabled as dp_enabled,
                  rank() OVER (
                    PARTITION BY t_dp.vendor_id, t_dp.routeset_discriminator_id
                    ORDER BY
                      length(prefix_range(t_dp.prefix)) desc,
                      yeti_ext.tag_compare(t_dp.routing_tag_ids, v_call_tags, t_dp.routing_tag_mode_id) desc,
                      t_dp.exclusive_route desc -- in case when we have two identical prefixes with different exclusive flag value, we should lift up exclusive route, otherwise it will be filtered at WHERE r=1  and exclusive_rank=1
                    ) as r,
                  rank() OVER (
                    ORDER BY t_dp.exclusive_route desc -- force top rank for exclusive route
                    ) as exclusive_rank
                FROM class4.dialpeers t_dp
                WHERE
                  prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
                  AND length(v_routing_key) between t_dp.dst_number_min_length and t_dp.dst_number_max_length
                  AND t_dp.routing_group_id = ANY(v_routing_groups)
                  and t_dp.valid_from<=v_now
                  and t_dp.valid_till>=v_now
                  AND yeti_ext.tag_compare(t_dp.routing_tag_ids, v_call_tags, t_dp.routing_tag_mode_id) > 0
            )
            SELECT
                s1_dialpeer as s2_dialpeer,
                (t_vendor_account.*)::billing.accounts as s2_vendor_account
            FROM step1
            JOIN public.contractors t_vendor ON step1.s1_vendor_id = t_vendor.id
            JOIN billing.accounts t_vendor_account ON step1.s1_vendor_account_id = t_vendor_account.id
            WHERE
              r=1
              and exclusive_rank=1
              AND dp_next_rate<=v_rate_limit
              AND dp_enabled
              and not dp_locked --ACD&ASR control for DP
              AND t_vendor_account.balance < t_vendor_account.max_balance
              AND t_vendor.enabled AND t_vendor.vendor
            ORDER BY dp_next_rate*dp_lcr_rate_multiplier, dp_priority DESC
            LIMIT v_rp.max_rerouting_attempts
          ) LOOP
            RETURN QUERY
            /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}rel*/
            /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}dbg*/
          end LOOP;
          WHEN '2' THEN --LCR, no prio, No ACD&ASR control
          FOR routedata IN (
            WITH step1 AS( -- filtering
                SELECT
                  (t_dp.*)::class4.dialpeers as s1_dialpeer,
                  t_dp.vendor_id as s1_vendor_id,
                  t_dp.account_id as s1_vendor_account_id,
                  rank() OVER (
                    PARTITION BY t_dp.vendor_id, t_dp.routeset_discriminator_id
                    ORDER BY
                      length(prefix_range(t_dp.prefix)) desc,
                      yeti_ext.tag_compare(t_dp.routing_tag_ids, v_call_tags, t_dp.routing_tag_mode_id) desc,
                      t_dp.exclusive_route desc -- in case when we have two identical prefixes with different exclusive flag value, we should lift up exclusive route, otherwise it will be filtered at WHERE r=1  and exclusive_rank=1
                    ) as r,
                  rank() OVER (
                    ORDER BY t_dp.exclusive_route desc -- force top rank for exclusive route
                    ) as exclusive_rank,
                  t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric,
                  t_dp.next_rate as dp_next_rate,
                  t_dp.enabled as dp_enabled
                FROM class4.dialpeers t_dp
                WHERE
                  prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
                  AND length(v_routing_key) between t_dp.dst_number_min_length and t_dp.dst_number_max_length
                  AND t_dp.routing_group_id = ANY(v_routing_groups)
                  and t_dp.valid_from<=v_now
                  and t_dp.valid_till>=v_now
                  AND yeti_ext.tag_compare(t_dp.routing_tag_ids,v_call_tags, t_dp.routing_tag_mode_id)>0
            )
            SELECT
                s1_dialpeer as s2_dialpeer,
                (t_vendor_account.*)::billing.accounts as s2_vendor_account
            FROM step1
            JOIN public.contractors t_vendor ON step1.s1_vendor_id = t_vendor.id
            JOIN billing.accounts t_vendor_account ON step1.s1_vendor_account_id = t_vendor_account.id
            WHERE
              r=1
              and exclusive_rank=1
              AND dp_enabled
              and dp_next_rate<=v_rate_limit
              AND t_vendor_account.balance < t_vendor_account.max_balance
              AND t_vendor.enabled AND t_vendor.vendor
            ORDER BY dp_metric
            LIMIT v_rp.max_rerouting_attempts
          ) LOOP
            RETURN QUERY
            /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}rel*/
            /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}dbg*/
          END LOOP;
          WHEN '3' THEN --Prio, LCR, ACD&ASR control
          FOR routedata in(
            WITH step1 AS( -- filtering
                SELECT
                  (t_dp.*)::class4.dialpeers as s1_dialpeer,
                  t_dp.vendor_id as s1_vendor_id,
                  t_dp.account_id as s1_vendor_account_id,
                  rank() OVER (
                    PARTITION BY t_dp.vendor_id, t_dp.routeset_discriminator_id
                    ORDER BY
                      length(prefix_range(t_dp.prefix)) desc,
                      yeti_ext.tag_compare(t_dp.routing_tag_ids, v_call_tags, t_dp.routing_tag_mode_id) desc,
                      t_dp.exclusive_route desc -- in case when we have two identical prefixes with different exclusive flag value, we should lift up exclusive route, otherwise it will be filtered at WHERE r=1  and exclusive_rank=1
                    ) as r,
                  rank() OVER (
                    ORDER BY t_dp.exclusive_route desc -- force top rank for exclusive route
                    ) as exclusive_rank,
                  t_dp.priority as dp_metric_priority,
                  t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric,
                  t_dp.next_rate as dp_next_rate,
                  t_dp.locked as dp_locked,
                  t_dp.enabled as dp_enabled
                FROM class4.dialpeers t_dp
                WHERE
                  prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
                  AND length(v_routing_key) between t_dp.dst_number_min_length and t_dp.dst_number_max_length
                  AND t_dp.routing_group_id = ANY(v_routing_groups)
                  and t_dp.valid_from<=v_now
                  and t_dp.valid_till>=v_now
                  AND yeti_ext.tag_compare(t_dp.routing_tag_ids, v_call_tags, t_dp.routing_tag_mode_id) > 0
            )
            SELECT
                    s1_dialpeer as s2_dialpeer,
                    (t_vendor_account.*)::billing.accounts as s2_vendor_account
            FROM step1
            JOIN public.contractors t_vendor ON step1.s1_vendor_id = t_vendor.id
            JOIN billing.accounts t_vendor_account ON step1.s1_vendor_account_id = t_vendor_account.id
            WHERE
              r=1
              AND exclusive_rank=1
              AND dp_next_rate<=v_rate_limit
              AND dp_enabled
              AND NOT dp_locked
              AND t_vendor_account.balance < t_vendor_account.max_balance
              AND t_vendor.enabled AND t_vendor.vendor
            ORDER BY dp_metric_priority DESC, dp_metric
            LIMIT v_rp.max_rerouting_attempts
          )LOOP
            RETURN QUERY
            /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}rel*/
            /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}dbg*/
          END LOOP;
          WHEN'4' THEN -- LCRD, Prio, ACD&ACR control
          FOR routedata IN (
            WITH step1 AS(
                SELECT
                  (t_dp.*)::class4.dialpeers as s1_dialpeer,
                  t_dp.vendor_id as s1_vendor_id,
                  t_dp.account_id as s1_vendor_account_id,
                  rank() OVER (
                    PARTITION BY t_dp.vendor_id, t_dp.routeset_discriminator_id
                    ORDER BY
                      length(prefix_range(t_dp.prefix)) desc,
                      yeti_ext.tag_compare(t_dp.routing_tag_ids, v_call_tags, t_dp.routing_tag_mode_id) desc,
                      t_dp.exclusive_route desc -- in case when we have two identical prefixes with different exclusive flag value, we should lift up exclusive route, otherwise it will be filtered at WHERE r=1  and exclusive_rank=1
                  ) as r,
                  rank() OVER (
                    ORDER BY t_dp.exclusive_route desc -- force top rank for exclusive route
                  ) as exclusive_rank,
                  ((t_dp.next_rate - first_value(t_dp.next_rate) OVER(ORDER BY t_dp.next_rate ASC)) > v_rp.rate_delta_max)::INTEGER *(t_dp.next_rate + t_dp.priority) - t_dp.priority AS r2,
                  t_dp.next_rate as dp_next_rate,
                  t_dp.locked as dp_locked,
                  t_dp.enabled as dp_enabled
                FROM class4.dialpeers t_dp
                WHERE
                  prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
                  AND length(v_routing_key) between t_dp.dst_number_min_length and t_dp.dst_number_max_length
                  AND t_dp.routing_group_id = ANY(v_routing_groups)
                  and t_dp.valid_from<=v_now
                  and t_dp.valid_till>=v_now
                  AND yeti_ext.tag_compare(t_dp.routing_tag_ids,v_call_tags, t_dp.routing_tag_mode_id)>0
            )
            SELECT
                    s1_dialpeer as s2_dialpeer,
                    (t_vendor_account.*)::billing.accounts as s2_vendor_account
            FROM step1
            JOIN public.contractors t_vendor ON step1.s1_vendor_id = t_vendor.id
            JOIN billing.accounts t_vendor_account ON step1.s1_vendor_account_id = t_vendor_account.id
            WHERE
              r=1
              and exclusive_rank=1
              and dp_next_rate <= v_rate_limit
              and dp_enabled
              and not dp_locked --ACD&ASR control for DP
              AND t_vendor_account.balance < t_vendor_account.max_balance
              AND t_vendor.enabled AND t_vendor.vendor
            ORDER BY r2 ASC
            LIMIT v_rp.max_rerouting_attempts
          ) LOOP
            RETURN QUERY
            /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}rel*/
            /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}dbg*/
          end LOOP;
          WHEN'5' THEN -- Route test
          FOR routedata IN (
            WITH step1 AS( -- filtering
                SELECT
                  (t_dp.*)::class4.dialpeers as s1_dialpeer,
                  t_dp.vendor_id as s1_vendor_id,
                  t_dp.account_id as s1_vendor_account_id,
                  rank() OVER (
                    PARTITION BY t_dp.vendor_id, t_dp.routeset_discriminator_id
                    ORDER BY
                      length(prefix_range(t_dp.prefix)) desc,
                      yeti_ext.tag_compare(t_dp.routing_tag_ids, v_call_tags, t_dp.routing_tag_mode_id) desc,
                      t_dp.exclusive_route desc -- in case when we have two identical prefixes with different exclusive flag value, we should lift up exclusive route, otherwise it will be filtered at WHERE r=1  and exclusive_rank=1
                  ) as r,
                  rank() OVER (
                    ORDER BY t_dp.exclusive_route desc -- force top rank for exclusive route
                  ) as exclusive_rank,
                  t_dp.priority as dp_metric_priority,
                  t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric,
                  t_dp.next_rate as dp_next_rate,
                  t_dp.enabled as dp_enabled
                FROM class4.dialpeers t_dp
                WHERE
                  prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
                  AND length(v_routing_key) between t_dp.dst_number_min_length and t_dp.dst_number_max_length
                  AND t_dp.routing_group_id = ANY(v_routing_groups)
                  and t_dp.valid_from<=v_now
                  and t_dp.valid_till>=v_now
                  and t_dp.vendor_id = v_test_vendor_id
                  AND yeti_ext.tag_compare(t_dp.routing_tag_ids,v_call_tags, t_dp.routing_tag_mode_id) > 0
            )
            SELECT
                s1_dialpeer as s2_dialpeer,
                (t_vendor_account.*)::billing.accounts as s2_vendor_account
            FROM step1
            JOIN public.contractors t_vendor ON step1.s1_vendor_id = t_vendor.id
            JOIN billing.accounts t_vendor_account ON step1.s1_vendor_account_id = t_vendor_account.id
            WHERE
              r=1
              and exclusive_rank=1
              and dp_enabled
              and dp_next_rate<=v_rate_limit
              AND t_vendor_account.balance < t_vendor_account.max_balance
              AND t_vendor.enabled AND t_vendor.vendor
            ORDER BY dp_metric_priority DESC, dp_metric
            LIMIT v_rp.max_rerouting_attempts
          )LOOP
            RETURN QUERY
            /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}rel*/
            /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}dbg*/
          END LOOP;
          WHEN'6' THEN -- QD.Static,LCR,ACD&ACR control
          v_random:=random();
          FOR routedata in(
            WITH step1 AS( -- filtering
                SELECT
                  (t_dp.*)::class4.dialpeers as s1_dialpeer,
                  (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                  rank() OVER (
                    PARTITION BY t_dp.vendor_id, t_dp.routeset_discriminator_id
                    ORDER BY
                      length(prefix_range(t_dp.prefix)) desc,
                      yeti_ext.tag_compare(t_dp.routing_tag_ids, v_call_tags, t_dp.routing_tag_mode_id) desc,
                      t_dp.exclusive_route desc -- in case when we have two identical prefixes with different exclusive flag value, we should lift up exclusive route, otherwise it will be filtered at WHERE r=1  and exclusive_rank=1
                  ) as r,
                  rank() OVER (
                    ORDER BY t_dp.exclusive_route desc -- force top rank for exclusive route
                  ) as exclusive_rank,
                  rank() OVER (
                    PARTITION BY t_dp.vendor_id, t_dp.routeset_discriminator_id
                    ORDER BY length(prefix_range(coalesce(rpsr.prefix,''))) desc
                  ) as r2,
                  t_dp.priority as dp_metric_priority,
                  t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric,
                  t_dp.next_rate as dp_next_rate,
                  t_dp.locked as dp_locked,
                  t_dp.enabled as dp_enabled,
                  t_dp.force_hit_rate as dp_force_hit_rate,
                  COALESCE(rpsr.priority, t_dp.priority) as rpsr_priority,
                  COALESCE(rpsr.weight, 100) as rpsr_weight
                FROM class4.dialpeers t_dp
                  JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
                  join public.contractors t_vendor on t_dp.vendor_id=t_vendor.id
                  left join class4.routing_plan_static_routes rpsr
                    ON rpsr.routing_plan_id=v_customer_auth_normalized.routing_plan_id
                      and rpsr.vendor_id=t_dp.vendor_id
                      AND prefix_range(rpsr.prefix)@>prefix_range(v_routing_key)
                WHERE
                  prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
                  AND length(v_routing_key) between t_dp.dst_number_min_length and t_dp.dst_number_max_length
                  AND t_dp.routing_group_id = ANY(v_routing_groups)
                  and t_dp.valid_from<=v_now
                  and t_dp.valid_till>=v_now
                  AND t_vendor_account.balance<t_vendor_account.max_balance
                  and t_vendor.enabled and t_vendor.vendor
                  AND yeti_ext.tag_compare(t_dp.routing_tag_ids,v_call_tags, t_dp.routing_tag_mode_id) > 0
            )
            SELECT s1_dialpeer as s2_dialpeer,
                  s1_vendor_account as s2_vendor_account
            FROM step1
            WHERE
              r=1
              and exclusive_rank=1
              and r2=1
              and dp_next_rate<=v_rate_limit
              and dp_enabled
              and not dp_locked
            ORDER BY
              coalesce(v_random<=dp_force_hit_rate,false) desc,
              rpsr_priority,
              yeti_ext.rank_dns_srv(rpsr_weight) over ( partition by rpsr_priority order by rpsr_weight),
              dp_metric
            LIMIT v_rp.max_rerouting_attempts
          )LOOP
            RETURN QUERY
            /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}rel*/
            /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}dbg*/
          END LOOP;
          WHEN'7' THEN -- QD.Static, No ACD&ACR control
          v_random:=random();
          FOR routedata in(
            WITH step1 AS( -- filtering
                SELECT
                  (t_dp.*)::class4.dialpeers as s1_dialpeer,
                  (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                  rank() OVER (
                    PARTITION BY t_dp.vendor_id, t_dp.routeset_discriminator_id
                    ORDER BY
                      length(prefix_range(t_dp.prefix)) desc,
                      yeti_ext.tag_compare(t_dp.routing_tag_ids, v_call_tags, t_dp.routing_tag_mode_id) desc,
                      t_dp.exclusive_route desc -- in case when we have two identical prefixes with different exclusive flag value, we should lift up exclusive route, otherwise it will be filtered at WHERE r=1  and exclusive_rank=1
                  ) as r,
                  rank() OVER (
                    ORDER BY t_dp.exclusive_route desc -- force top rank for exclusive route
                  ) as exclusive_rank,
                  rank() OVER (
                    PARTITION BY t_dp.vendor_id, t_dp.routeset_discriminator_id
                    ORDER BY length(prefix_range(coalesce(rpsr.prefix,''))) desc
                  ) as r2,
                  t_dp.priority as dp_metric_priority,
                  t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric,
                  t_dp.next_rate as dp_next_rate,
                  t_dp.enabled as dp_enabled,
                  t_dp.force_hit_rate as dp_force_hit_rate,
                  rpsr.priority as rpsr_priority,
                  rpsr.weight as rpsr_weight
                FROM class4.dialpeers t_dp
                  JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
                  join public.contractors t_vendor on t_dp.vendor_id=t_vendor.id
                  join class4.routing_plan_static_routes rpsr
                    ON rpsr.routing_plan_id=v_customer_auth_normalized.routing_plan_id
                      and rpsr.vendor_id=t_dp.vendor_id
                      AND prefix_range(rpsr.prefix)@>prefix_range(v_routing_key)
                WHERE
                  prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
                  AND length(v_routing_key) between t_dp.dst_number_min_length and t_dp.dst_number_max_length
                  AND t_dp.routing_group_id = ANY(v_routing_groups)
                  and t_dp.valid_from<=v_now
                  and t_dp.valid_till>=v_now
                  AND t_vendor_account.balance<t_vendor_account.max_balance
                  and t_vendor.enabled and t_vendor.vendor
                  AND yeti_ext.tag_compare(t_dp.routing_tag_ids,v_call_tags, t_dp.routing_tag_mode_id) > 0
            )
            SELECT s1_dialpeer as s2_dialpeer,
                  s1_vendor_account as s2_vendor_account
            FROM step1
            WHERE
              r=1
              and exclusive_rank=1
              and r2=1
              and dp_next_rate<=v_rate_limit
              and dp_enabled
            ORDER BY
              coalesce(v_random<=dp_force_hit_rate,false) desc,
              rpsr_priority,
              yeti_ext.rank_dns_srv(rpsr_weight) over ( partition by rpsr_priority order by rpsr_weight),
              dp_metric
            LIMIT v_rp.max_rerouting_attempts
          )LOOP
            RETURN QUERY
            /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}rel*/
            /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}dbg*/
          END LOOP;

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
      $_$;

      set search_path TO switch21;
      SELECT * from switch21.preprocess_all();
      set search_path TO gui, public, switch, billing, class4, runtime_stats, sys, logs, data_import;

    }
  end

  def down
    execute %q{
      delete from class4.customers_auth_src_name_fields where id = 2;

CREATE or replace FUNCTION switch21.route(i_node_id integer, i_pop_id integer, i_protocol_id smallint, i_remote_ip inet, i_remote_port integer, i_local_ip inet, i_local_port integer, i_from_dsp character varying, i_from_name character varying, i_from_domain character varying, i_from_port integer, i_to_name character varying, i_to_domain character varying, i_to_port integer, i_contact_name character varying, i_contact_domain character varying, i_contact_port integer, i_uri_name character varying, i_uri_domain character varying, i_auth_id integer, i_identity_data json, i_interface character varying, i_x_yeti_auth character varying, i_diversion character varying, i_x_orig_ip inet, i_x_orig_port integer, i_x_orig_protocol_id smallint, i_pai character varying, i_ppi character varying, i_privacy character varying, i_rpid character varying, i_rpid_privacy character varying) RETURNS SETOF switch21.callprofile_ty
    LANGUAGE plpgsql SECURITY DEFINER ROWS 10
    AS $_$
      DECLARE
        v_ret switch21.callprofile_ty;
        i integer;
        v_ip inet;
        v_remote_ip inet;
        v_remote_port INTEGER;
        v_transport_protocol_id smallint;
        v_customer_auth_normalized class4.customers_auth_normalized;
        v_destination class4.destinations%rowtype;
        v_dialpeer record;
        v_rateplan class4.rateplans%rowtype;
        v_dst_gw class4.gateways%rowtype;
        v_orig_gw class4.gateways%rowtype;
        v_rp class4.routing_plans%rowtype;
        v_customer_allowtime real;
        v_vendor_allowtime real;
        v_sorting_id integer;
        v_customer_acc integer;
        v_route_found boolean:=false;
        v_c_acc billing.accounts%rowtype;
        v_v_acc billing.accounts%rowtype;
        v_network sys.network_prefixes%rowtype;
        v_src_network sys.network_prefixes%rowtype;
        routedata record;
        /*dbg{*/
        v_start timestamp;
        v_end timestamp;
        /*}dbg*/
        v_rate NUMERIC;
        v_now timestamp;
        v_x_yeti_auth varchar;
        --  v_uri_domain varchar;
        v_rate_limit float:='Infinity'::float;
        v_destination_rate_limit float:='Infinity'::float;
        v_test_vendor_id integer;
        v_random float;
        v_max_call_length integer;
        v_routing_key varchar;
        v_lnp_key varchar;
        v_lnp_rule class4.routing_plan_lnp_rules%rowtype;
        v_numberlist record;
        v_numberlist_item record;
        v_call_tags smallint[]:='{}'::smallint[];
        v_area_direction class4.routing_tag_detection_rules%rowtype;
        v_numberlist_size integer;
        v_lua_context switch21.lua_call_context;
        v_identity_data switch21.identity_data_ty[];
        v_identity_record switch21.identity_data_ty;
        v_pai varchar[];
        v_ppi varchar;
        v_privacy varchar[];
        v_diversion varchar[] not null default ARRAY[]::varchar[];
        v_cnam_req_json json;
        v_cnam_resp_json json;
        v_cnam_lua_resp switch21.cnam_lua_resp;
        v_cnam_database class4.cnam_databases%rowtype;
        v_rewrite switch21.defered_rewrite;
        v_defered_src_rewrites switch21.defered_rewrite[] not null default ARRAY[]::switch21.defered_rewrite[];
        v_defered_dst_rewrites switch21.defered_rewrite[] not null default ARRAY[]::switch21.defered_rewrite[];
        v_rate_groups integer[];
        v_routing_groups integer[];
        v_package billing.package_counters%rowtype;
        v_ss_src varchar;
        v_ss_dst varchar;
        v_stir_dst_tn varchar;
      BEGIN
        /*dbg{*/
        v_start:=now();
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> Execution start',EXTRACT(MILLISECOND from v_end-v_start);
        /*}dbg*/

        perform id from sys.load_balancers where signalling_ip=host(i_remote_ip)::varchar;
        IF FOUND and i_x_orig_ip IS not NULL AND i_x_orig_port IS not NULL THEN
          v_remote_ip:=i_x_orig_ip;
          v_remote_port:=i_x_orig_port;
          v_transport_protocol_id=i_x_orig_protocol_id;
          /*dbg{*/RAISE NOTICE '% ms -> Got originator address "%:%, proto: %" from x-headers',EXTRACT(MILLISECOND from v_end-v_start), v_remote_ip,v_remote_port, v_transport_protocol_id;/*}dbg*/
        else
          v_remote_ip:=i_remote_ip;
          v_remote_port:=i_remote_port;
          v_transport_protocol_id:=i_protocol_id;
          /*dbg{*/RAISE NOTICE '% ms -> Got originator address "%:%, proto: %" from switch leg info',EXTRACT(MILLISECOND from v_end-v_start), v_remote_ip,v_remote_port, v_transport_protocol_id;/*}dbg*/
        end if;

        v_now:=now();
        v_ret:=switch21.new_profile();

        v_ret.diversion_in:=i_diversion;

        v_ret.auth_orig_protocol_id =v_transport_protocol_id;
        v_ret.auth_orig_ip = v_remote_ip;
        v_ret.auth_orig_port = v_remote_port;

        v_ret.src_name_in:=i_from_dsp;
        v_ret.src_name_out:=v_ret.src_name_in;

        v_ret.src_prefix_in:=i_from_name;
        v_ret.src_prefix_out:=v_ret.src_prefix_in;

        v_ret.dst_prefix_in:=i_uri_name;
        v_ret.dst_prefix_out:=v_ret.dst_prefix_in;


        v_ret.ruri_domain=i_uri_domain;
        v_ret.from_domain=i_from_domain;
        v_ret.to_domain=i_to_domain;

        v_ret.pai_in=i_pai;
        v_pai=string_to_array(COALESCE(i_pai,''),',');
        v_ret.ppi_in=i_ppi;
        v_ppi=i_ppi;
        v_ret.privacy_in=i_privacy;
        v_privacy = string_to_array(COALESCE(i_privacy,''),';');
        v_ret.rpid_in=i_rpid;
        v_ret.rpid_privacy_in=i_rpid_privacy;

        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> AUTH. lookup started',EXTRACT(MILLISECOND from v_end-v_start);
        /*}dbg*/
        v_x_yeti_auth:=COALESCE(i_x_yeti_auth,'');
        --  v_uri_domain:=COALESCE(i_uri_domain,'');

        if i_auth_id is null then
            SELECT into v_customer_auth_normalized ca.*
            from class4.customers_auth_normalized ca
                JOIN public.contractors c ON c.id=ca.customer_id
            WHERE ca.enabled AND
              ca.ip>>=v_remote_ip AND
              prefix_range(ca.dst_prefix)@>prefix_range(v_ret.dst_prefix_in) AND
              prefix_range(ca.src_prefix)@>prefix_range(v_ret.src_prefix_in) AND
              (ca.pop_id=i_pop_id or ca.pop_id is null) and
              COALESCE(ca.x_yeti_auth,'')=v_x_yeti_auth AND
              COALESCE(nullif(ca.uri_domain,'')=i_uri_domain,true) AND
              COALESCE(nullif(ca.to_domain,'')=i_to_domain,true) AND
              COALESCE(nullif(ca.from_domain,'')=i_from_domain,true) AND
              (ca.interface is null or ca.interface = i_interface ) AND
              (ca.transport_protocol_id is null or ca.transport_protocol_id=v_transport_protocol_id) AND
              length(v_ret.dst_prefix_in) between ca.dst_number_min_length and ca.dst_number_max_length and
              length(v_ret.src_prefix_in) between ca.src_number_min_length and ca.src_number_max_length and
              c.enabled and c.customer
            ORDER BY
                masklen(ca.ip) DESC,
                ca.transport_protocol_id is null,
                length(prefix_range(ca.dst_prefix)) DESC,
                length(prefix_range(ca.src_prefix)) DESC,
                ca.pop_id is null,
                ca.uri_domain is null,
                ca.to_domain is null,
                ca.from_domain is null,
                ca.require_incoming_auth
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
            if v_customer_auth_normalized.require_incoming_auth then
            /*dbg{*/
                v_end:=clock_timestamp();
                RAISE NOTICE '% ms -> AUTH. Incoming auth required. Respond 401',EXTRACT(MILLISECOND from v_end-v_start);
            /*}dbg*/
                v_ret.aleg_auth_required=true;
                RETURN NEXT v_ret;
                RETURN;
            end IF;
            if v_customer_auth_normalized.reject_calls then
            /*dbg{*/
                v_end:=clock_timestamp();
                RAISE NOTICE '% ms -> AUTH.  disconnection with 8004. Reject by customers auth',EXTRACT(MILLISECOND from v_end-v_start);
            /*}dbg*/
                v_ret.disconnect_code_id=8004; -- call rejected by authorization

                v_ret.customer_auth_id:=v_customer_auth_normalized.customers_auth_id;
                v_ret.customer_auth_external_id:=v_customer_auth_normalized.external_id;
                v_ret.customer_auth_external_type:=v_customer_auth_normalized.external_type;

                v_ret.customer_id:=v_customer_auth_normalized.customer_id;
                select into strict v_ret.customer_external_id external_id from public.contractors where id=v_ret.customer_id;

                v_ret.rateplan_id:=v_customer_auth_normalized.rateplan_id;
                v_ret.routing_plan_id:=v_customer_auth_normalized.routing_plan_id;

                v_ret.customer_acc_id:=v_customer_auth_normalized.account_id;
                SELECT INTO STRICT v_ret.customer_acc_external_id external_id FROM billing.accounts WHERE id=v_customer_auth_normalized.account_id;

                RETURN NEXT v_ret;
                RETURN;
            end if;
        else
            SELECT into v_customer_auth_normalized ca.*
            from class4.customers_auth_normalized ca
                JOIN public.contractors c ON c.id=ca.customer_id
            WHERE ca.enabled AND
              ca.ip>>=v_remote_ip AND
              prefix_range(ca.dst_prefix)@>prefix_range(v_ret.dst_prefix_in) AND
              prefix_range(ca.src_prefix)@>prefix_range(v_ret.src_prefix_in) AND
              (ca.pop_id=i_pop_id or ca.pop_id is null) and
              COALESCE(ca.x_yeti_auth,'')=v_x_yeti_auth AND
              COALESCE(nullif(ca.uri_domain,'')=i_uri_domain,true) AND
              COALESCE(nullif(ca.to_domain,'')=i_to_domain,true) AND
              COALESCE(nullif(ca.from_domain,'')=i_from_domain,true) AND
              (ca.interface is null or ca.interface = i_interface ) AND
              (ca.transport_protocol_id is null or ca.transport_protocol_id=v_transport_protocol_id) AND
              length(v_ret.dst_prefix_in) between ca.dst_number_min_length and ca.dst_number_max_length and
              length(v_ret.src_prefix_in) between ca.src_number_min_length and ca.src_number_max_length and
              c.enabled and c.customer and
              ca.require_incoming_auth and gateway_id = i_auth_id
            ORDER BY
                masklen(ca.ip) DESC,
                ca.transport_protocol_id is null,
                length(prefix_range(ca.dst_prefix)) DESC,
                length(prefix_range(ca.src_prefix)) DESC,
                ca.pop_id is null,
                ca.uri_domain is null,
                ca.to_domain is null,
                ca.from_domain is null
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
            if v_customer_auth_normalized.reject_calls then
            /*dbg{*/
                v_end:=clock_timestamp();
                RAISE NOTICE '% ms -> AUTH.  disconnection with 8004. Reject by customers auth',EXTRACT(MILLISECOND from v_end-v_start);
            /*}dbg*/
                v_ret.disconnect_code_id=8004; -- call rejected by authorization

                v_ret.customer_auth_id:=v_customer_auth_normalized.customers_auth_id;
                v_ret.customer_auth_external_id:=v_customer_auth_normalized.external_id;
                v_ret.customer_auth_external_type:=v_customer_auth_normalized.external_type;

                v_ret.customer_id:=v_customer_auth_normalized.customer_id;
                select into strict v_ret.customer_external_id external_id from public.contractors where id=v_ret.customer_id;

                v_ret.rateplan_id:=v_customer_auth_normalized.rateplan_id;
                v_ret.routing_plan_id:=v_customer_auth_normalized.routing_plan_id;

                v_ret.customer_acc_id:=v_customer_auth_normalized.account_id;
                SELECT INTO STRICT v_ret.customer_acc_external_id external_id FROM billing.accounts WHERE id=v_customer_auth_normalized.account_id;

                RETURN NEXT v_ret;
                RETURN;
            end if;
        end IF;

        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> AUTH. found: %',EXTRACT(MILLISECOND from v_end-v_start),row_to_json(v_customer_auth_normalized, true);
        /*}dbg*/

        -- redefine call SRC/DST numbers

        IF v_customer_auth_normalized.src_name_field_id=1 THEN  /* default - from uri display name */
          v_ret.src_name_in:=i_from_dsp;
        END IF;
        v_ret.src_name_out:=v_ret.src_name_in;

        IF v_customer_auth_normalized.src_number_field_id=1 THEN  /* default - from uri userpart */
          v_ret.src_prefix_in:=i_from_name;
        ELSIF v_customer_auth_normalized.src_number_field_id=2 THEN /* From uri Display name */
          v_ret.src_prefix_in:=i_from_dsp;
        END IF;
        v_ret.src_prefix_out:=v_ret.src_prefix_in;

        IF v_customer_auth_normalized.dst_number_field_id=1 THEN /* default  - RURI userpart*/
          v_ret.dst_prefix_in:=i_uri_name;
        ELSIF v_customer_auth_normalized.dst_number_field_id=2 THEN /* TO URI userpart */
          v_ret.dst_prefix_in:=i_to_name;
        ELSIF v_customer_auth_normalized.dst_number_field_id=3 THEN /* Top-Most Diversion header userpart */
          v_ret.dst_prefix_in:=COALESCE(i_diversion,'');
        END IF;
        v_ret.dst_prefix_out:=v_ret.dst_prefix_in;

        IF v_customer_auth_normalized.diversion_policy_id = 2 THEN /* accept diversion */
          v_diversion = string_to_array(COALESCE(i_diversion,''),',');
          v_diversion = yeti_ext.regexp_replace_rand(
            v_diversion,
            v_customer_auth_normalized.diversion_rewrite_rule,
            v_customer_auth_normalized.diversion_rewrite_result
          );
        END IF;

        -- feel customer data ;-)
        v_ret.dump_level_id:=v_customer_auth_normalized.dump_level_id;
        v_ret.customer_auth_id:=v_customer_auth_normalized.customers_auth_id;
        v_ret.customer_auth_external_id:=v_customer_auth_normalized.external_id;
        v_ret.customer_auth_external_type:=v_customer_auth_normalized.external_type;

        v_ret.customer_id:=v_customer_auth_normalized.customer_id;
        select into strict v_ret.customer_external_id external_id from public.contractors where id=v_customer_auth_normalized.customer_id;

        v_ret.rateplan_id:=v_customer_auth_normalized.rateplan_id;
        v_ret.routing_plan_id:=v_customer_auth_normalized.routing_plan_id;
        v_ret.customer_acc_id:=v_customer_auth_normalized.account_id;

        v_ret.orig_gw_id:=v_customer_auth_normalized.gateway_id;
        SELECT into v_orig_gw * from class4.gateways WHERE id=v_customer_auth_normalized.gateway_id;
        -- we have to set disconnect policy to allow rewrite internal reject when call rejected before gw processing
        v_ret.aleg_policy_id = v_orig_gw.orig_disconnect_policy_id;

        if not v_orig_gw.enabled then
          v_ret.disconnect_code_id=8005; -- Origination gateway is disabled
          RETURN NEXT v_ret;
          RETURN;
        end if;

        CASE v_customer_auth_normalized.privacy_mode_id
            WHEN 1 THEN
              -- allow all
            WHEN 2 THEN
              IF cardinality(array_remove(v_privacy,'none')) > 0 THEN
                v_ret.disconnect_code_id = 8013;
                RETURN NEXT v_ret;
                RETURN;
              END IF;
            WHEN 3 THEN
              IF 'critical' = ANY(v_privacy) THEN
                v_ret.disconnect_code_id = 8014;
                RETURN NEXT v_ret;
                RETURN;
              END IF;
            WHEN 4 THEN
              IF lower(v_ret.src_prefix_in)='anonymous' AND COALESCE(cardinality(v_pai),0) = 0 AND ( v_ppi is null or v_ppi='') THEN
                v_ret.disconnect_code_id = 8015;
                RETURN NEXT v_ret;
                RETURN;
              END IF;
        END CASE;

        ---- Identity validation ----
        select into v_identity_data array_agg(d) from  json_populate_recordset(null::switch21.identity_data_ty, i_identity_data) d;
        IF v_customer_auth_normalized.ss_mode_id = 1 THEN
          /* validate */
          v_ret.lega_ss_status_id = 0; -- none
          v_ss_src = yeti_ext.regexp_replace_rand(
            v_ret.src_prefix_in,
            v_customer_auth_normalized.ss_src_rewrite_rule,
            v_customer_auth_normalized.ss_src_rewrite_result
          );
          v_ss_dst = yeti_ext.regexp_replace_rand(
            v_ret.dst_prefix_in,
            v_customer_auth_normalized.ss_dst_rewrite_rule,
            v_customer_auth_normalized.ss_dst_rewrite_result
          );
          FOREACH v_identity_record IN ARRAY COALESCE(v_identity_data,'{}'::switch21.identity_data_ty[]) LOOP
            IF v_identity_record is null OR v_identity_record.parsed = false THEN
              -- no valid stir/shaken
              v_ret.lega_ss_status_id = 0; -- none
            ELSIF v_identity_record.parsed = true AND v_identity_record.verified = true AND ((v_identity_record.payload).orig).tn = v_ss_src THEN
              v_ret.lega_ss_status_id = -1; -- invalid
              FOREACH v_stir_dst_tn IN ARRAY COALESCE(((v_identity_record.payload).dest).tn,'{}'::varchar[]) LOOP
                IF v_stir_dst_tn = v_ss_dst THEN
                  CASE (v_identity_record.payload).attest
                    WHEN 'A' THEN
                      v_ret.lega_ss_status_id = 1;
                    WHEN 'B' THEN
                      v_ret.lega_ss_status_id = 2;
                    WHEN 'C' THEN
                      v_ret.lega_ss_status_id = 3;
                    ELSE
                      v_ret.lega_ss_status_id = -1;
                  END CASE;
                  exit; -- exit from DST checking loop
                ELSE
                  v_ret.lega_ss_status_id = -1; -- invalid
                END IF;
              END LOOP;
            ELSE
              -- parsed but not verified
              v_ret.lega_ss_status_id = -1; -- invalid
            END IF;
          END LOOP;

          IF v_ret.lega_ss_status_id = -1 THEN
              IF v_customer_auth_normalized.ss_invalid_identity_action_id = 1 THEN
                v_ret.disconnect_code_id=8019; --Identity invalid
                RETURN NEXT v_ret;
                RETURN;
              ELSIF v_customer_auth_normalized.ss_invalid_identity_action_id = 2 THEN
                v_ret.ss_attest_id = v_customer_auth_normalized.rewrite_ss_status_id;
              END IF;
          ELSIF v_ret.lega_ss_status_id = 0 THEN
              IF v_customer_auth_normalized.ss_no_identity_action_id = 1 THEN
                v_ret.disconnect_code_id=8018; --Identity required
                RETURN NEXT v_ret;
                RETURN;
              ELSIF v_customer_auth_normalized.ss_no_identity_action_id = 2 THEN
                v_ret.ss_attest_id = v_customer_auth_normalized.rewrite_ss_status_id;
              END IF;
          END IF;

        ELSIF v_customer_auth_normalized.ss_mode_id=2 THEN
          v_ret.ss_attest_id = v_customer_auth_normalized.rewrite_ss_status_id;
        END IF;

        v_ret.radius_auth_profile_id=v_customer_auth_normalized.radius_auth_profile_id;
        v_ret.aleg_radius_acc_profile_id=v_customer_auth_normalized.radius_accounting_profile_id;
        v_ret.record_audio=v_customer_auth_normalized.enable_audio_recording;

        v_ret.customer_acc_check_balance=v_customer_auth_normalized.check_account_balance;

        SELECT INTO STRICT v_c_acc * FROM billing.accounts  WHERE id=v_customer_auth_normalized.account_id;
        v_ret.customer_acc_external_id=v_c_acc.external_id;
        v_ret.customer_acc_vat=v_c_acc.vat;
        v_destination_rate_limit=coalesce(v_c_acc.destination_rate_limit::float,'Infinity'::float);

        select into v_max_call_length max_call_duration from sys.guiconfig limit 1;

        if NOT v_customer_auth_normalized.check_account_balance then
          v_ret.time_limit = LEAST(v_max_call_length, v_c_acc.max_call_duration);
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> AUTH. No customer acc balance checking. customer time limit set to max value: % ',EXTRACT(MILLISECOND from v_end-v_start), v_ret.time_limit;
          /*}dbg*/
        elsif v_customer_auth_normalized.check_account_balance AND v_c_acc.balance<=v_c_acc.min_balance then
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> AUTH. Customer acc balance checking. Call blocked before routing',EXTRACT(MILLISECOND from v_end-v_start);
          /*}dbg*/
          v_ret.disconnect_code_id=8000; --No enough customer balance
          RETURN NEXT v_ret;
          RETURN;
        end if;

        v_ret.customer_acc_external_id=v_c_acc.external_id;
        v_ret.customer_acc_vat=v_c_acc.vat;

        v_ret.lega_res='';
        if v_customer_auth_normalized.capacity is not null then
          v_ret.lega_res='3:'||v_customer_auth_normalized.customers_auth_id||':'||v_customer_auth_normalized.capacity::varchar||':1;';
        end if;

        if v_c_acc.origination_capacity is not null then
          v_ret.lega_res:=v_ret.lega_res||'1:'||v_c_acc.id::varchar||':'||v_c_acc.origination_capacity::varchar||':1;';
        end if;

        if v_c_acc.total_capacity is not null then
          v_ret.lega_res:=v_ret.lega_res||'7:'||v_c_acc.id::varchar||':'||v_c_acc.total_capacity::varchar||':1;';
        end if;

        if v_orig_gw.origination_capacity is not null then
          v_ret.lega_res:=v_ret.lega_res||'4:'||v_orig_gw.id::varchar||':'||v_orig_gw.origination_capacity::varchar||':1;';
        end if;

        if v_customer_auth_normalized.cps_limit is not null then
          if not yeti_ext.tbf_rate_check(1::integer,v_customer_auth_normalized.customers_auth_id::bigint, v_customer_auth_normalized.cps_limit::real) then
            v_ret.disconnect_code_id=8012; -- CPS limit on customer auth
            RETURN NEXT v_ret;
            RETURN;
          end if;
        end if;

        -- Tag processing CA
        v_call_tags=yeti_ext.tag_action(v_customer_auth_normalized.tag_action_id, v_call_tags, v_customer_auth_normalized.tag_action_value);

        /*
            number rewriting _Before_ routing
        */
        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> AUTH. Before rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.src_prefix_out,v_ret.dst_prefix_out;
        /*}dbg*/
        v_ret.dst_prefix_out=yeti_ext.regexp_replace_rand(v_ret.dst_prefix_out,v_customer_auth_normalized.dst_rewrite_rule,v_customer_auth_normalized.dst_rewrite_result);
        v_ret.src_prefix_out=yeti_ext.regexp_replace_rand(v_ret.src_prefix_out,v_customer_auth_normalized.src_rewrite_rule,v_customer_auth_normalized.src_rewrite_result);
        v_ret.src_name_out=yeti_ext.regexp_replace_rand(v_ret.src_name_out,v_customer_auth_normalized.src_name_rewrite_rule,v_customer_auth_normalized.src_name_rewrite_result, true);

        --  if v_ret.radius_auth_profile_id is not null then
        v_ret.src_number_radius:=i_from_name;
        v_ret.dst_number_radius:=i_uri_name;
        v_ret.src_number_radius=yeti_ext.regexp_replace_rand(
            v_ret.src_number_radius,
            v_customer_auth_normalized.src_number_radius_rewrite_rule,
            v_customer_auth_normalized.src_number_radius_rewrite_result
        );

        v_ret.dst_number_radius=yeti_ext.regexp_replace_rand(
            v_ret.dst_number_radius,
            v_customer_auth_normalized.dst_number_radius_rewrite_rule,
            v_customer_auth_normalized.dst_number_radius_rewrite_result
        );
        v_ret.customer_auth_name=v_customer_auth_normalized."name";
        v_ret.customer_name=(select "name" from public.contractors where id=v_customer_auth_normalized.customer_id limit 1);
        --  end if;
/**
        if v_customer_auth_normalized.lua_script_id is not null then
          v_lua_context.src_name_in = v_ret.src_name_in;
	        v_lua_context.src_number_in = v_ret.src_prefix_in;
	        v_lua_context.dst_number_in = v_ret.dst_prefix_in;
	        v_lua_context.src_name_out = v_ret.src_name_out;
	        v_lua_context.src_number_out = v_ret.src_prefix_out;
	        v_lua_context.dst_number_out = v_ret.dst_prefix_out;
	        -- v_lua_context.src_name_routing
	        -- v_lua_context.src_number_routing
	        -- v_lua_context.dst_number_routing
          -- #arrays
	        -- v_lua_context.diversion_in
	        -- v_lua_context.diversion_routing
	        -- v_lua_context.diversion_out
          select into v_lua_context switch21.lua_exec(v_customer_auth_normalized.lua_script_id, v_lua_context);
          v_ret.src_name_out =  v_lua_context.src_name_out;
          v_ret.src_prefix_out = v_lua_context.src_number_out;
          v_ret.dst_prefix_out = v_lua_context.dst_number_out;
        end if;
**/
        if v_customer_auth_normalized.cnam_database_id is not null then
          select into v_cnam_database * from class4.cnam_databases where id=v_customer_auth_normalized.cnam_database_id;

          select into v_cnam_req_json * from switch21.cnam_lua_build_request(v_cnam_database.request_lua, row_to_json(v_ret)::text);
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> CNAM. Lua generated request: %',EXTRACT(MILLISECOND from v_end-v_start),v_cnam_req_json;
          /*}dbg*/

          select into v_cnam_resp_json yeti_ext.lnp_resolve_cnam(v_cnam_database.id, v_cnam_req_json);

          /*dbg{*/
          v_end=clock_timestamp();
          RAISE NOTICE '% ms -> CNAM. resolver response: %',EXTRACT(MILLISECOND from v_end-v_start),v_cnam_resp_json;
          /*}dbg*/

          if json_extract_path_text(v_cnam_resp_json,'error') is not null then
            /*dbg{*/
            v_end=clock_timestamp();
            RAISE NOTICE '% ms -> CNAM. error',EXTRACT(MILLISECOND from v_end-v_start);
            /*}dbg*/
            if v_cnam_database.drop_call_on_error then
              v_ret.disconnect_code_id=8009; -- CNAM Error
              RETURN NEXT v_ret;
              RETURN;
            end if;
          else
            select into v_cnam_lua_resp * from switch21.cnam_lua_response_exec(v_cnam_database.response_lua, json_extract_path_text(v_cnam_resp_json,'response'));

            /*dbg{*/
            v_end=clock_timestamp();
            RAISE NOTICE '% ms -> CNAM. Lua parsed response: %',EXTRACT(MILLISECOND from v_end-v_start),row_to_json(v_cnam_lua_resp);
            /*}dbg*/
            if v_cnam_lua_resp.metadata is not null then
                v_ret.metadata = json_build_object('cnam_resp', v_cnam_lua_resp.metadata::json)::varchar;
            end if;
            v_ret.src_name_out = coalesce(v_cnam_lua_resp.src_name,v_ret.src_name_out);
            v_ret.src_prefix_out = coalesce(v_cnam_lua_resp.src_number,v_ret.src_prefix_out);
            v_ret.dst_prefix_out = coalesce(v_cnam_lua_resp.dst_number,v_ret.dst_prefix_out);
            v_ret.pai_out = coalesce(v_cnam_lua_resp.pai,v_ret.pai_out);
            v_ret.ppi_out = coalesce(v_cnam_lua_resp.ppi,v_ret.ppi_out);
            v_call_tags = coalesce(v_cnam_lua_resp.routing_tag_ids,v_call_tags);
          end if;

        end if;

        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> AUTH. After rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.src_prefix_out,v_ret.dst_prefix_out;
        /*}dbg*/

        ----- Numberlist processing-------------------------------------------------------------------------------------------------------
        if v_customer_auth_normalized.dst_numberlist_id is not null then
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> DST Numberlist processing. Lookup by key: %',EXTRACT(MILLISECOND from v_end-v_start), v_ret.dst_prefix_out;
          /*}dbg*/

          v_numberlist_item=switch21.match_numberlist(v_customer_auth_normalized.dst_numberlist_id, v_ret.dst_prefix_out);
          select into v_numberlist * from class4.numberlists where id=v_customer_auth_normalized.dst_numberlist_id;

          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> DST Numberlist. key found: %',EXTRACT(MILLISECOND from v_end-v_start), row_to_json(v_numberlist_item);
          /*}dbg*/
          IF v_numberlist_item.action_id is not null and v_numberlist_item.action_id=1 then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> DST Numberlist. Drop by key action. Key: %',EXTRACT(MILLISECOND from v_end-v_start), v_numberlist_item.key;
            /*}dbg*/
            v_ret.disconnect_code_id=8001; --destination blacklisted
            RETURN NEXT v_ret;
            RETURN;
          elsif v_numberlist_item.action_id is not null and v_numberlist_item.action_id=2 then
            IF v_numberlist_item.defer_src_rewrite THEN
                v_defered_src_rewrites = array_append(
                    v_defered_src_rewrites,
                    (v_numberlist_item.src_rewrite_rule, v_numberlist_item.src_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.src_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.src_prefix_out,
                    v_numberlist_item.src_rewrite_rule,
                    v_numberlist_item.src_rewrite_result
                );
            END IF;
            IF v_numberlist_item.defer_dst_rewrite THEN
                v_defered_dst_rewrites = array_append(
                    v_defered_dst_rewrites,
                    (v_numberlist_item.dst_rewrite_rule, v_numberlist_item.dst_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.dst_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.dst_prefix_out,
                    v_numberlist_item.dst_rewrite_rule,
                    v_numberlist_item.dst_rewrite_result
                );
            END IF;
            v_call_tags=yeti_ext.tag_action(v_numberlist_item.tag_action_id, v_call_tags, v_numberlist_item.tag_action_value);
            -- pass call NOP.
          elsif v_numberlist_item.action_id is null and v_numberlist.default_action_id=1 then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> DST Numberlist. Drop by default action',EXTRACT(MILLISECOND from v_end-v_start);
            /*}dbg*/
            -- drop by default
            v_ret.disconnect_code_id=8001; --destination blacklisted
            RETURN NEXT v_ret;
            RETURN;
          elsif v_numberlist_item.action_id is null and v_numberlist.default_action_id=2 then
            IF v_numberlist.defer_src_rewrite THEN
                v_defered_src_rewrites = array_append(
                    v_defered_src_rewrites,
                    (v_numberlist.default_src_rewrite_rule, v_numberlist.default_src_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.src_prefix_out=yeti_ext.regexp_replace_rand(
                v_ret.src_prefix_out,
                v_numberlist.default_src_rewrite_rule,
                v_numberlist.default_src_rewrite_result
                );
            END IF;
            IF v_numberlist.defer_dst_rewrite THEN
                v_defered_dst_rewrites = array_append(
                    v_defered_dst_rewrites,
                    (v_numberlist.default_dst_rewrite_rule, v_numberlist.default_dst_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.dst_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.dst_prefix_out,
                    v_numberlist.default_dst_rewrite_rule,
                    v_numberlist.default_dst_rewrite_result
                );
            END IF;
            v_call_tags=yeti_ext.tag_action(v_numberlist.tag_action_id, v_call_tags, v_numberlist.tag_action_value);
            -- pass by default
          end if;
        end if;

        if v_customer_auth_normalized.src_numberlist_id is not null then

          if v_customer_auth_normalized.src_numberlist_use_diversion AND v_diversion[1] is not null then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> SRC Numberlist processing. Lookup by key %, fallback to %', EXTRACT(MILLISECOND from v_end-v_start), v_ret.src_prefix_out, v_diversion[1];
            /*}dbg*/
            v_numberlist_item=switch21.match_numberlist(v_customer_auth_normalized.src_numberlist_id, v_ret.src_prefix_out, v_diversion[1]);
          else
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> SRC Numberlist processing. Lookup by key %, no fallback', EXTRACT(MILLISECOND from v_end-v_start), v_ret.src_prefix_out;
            /*}dbg*/
            v_numberlist_item=switch21.match_numberlist(v_customer_auth_normalized.src_numberlist_id, v_ret.src_prefix_out);
          end if;

          select into v_numberlist * from class4.numberlists where id=v_customer_auth_normalized.src_numberlist_id;

          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> SRC Numberlist. key found: %',EXTRACT(MILLISECOND from v_end-v_start), row_to_json(v_numberlist_item);
          /*}dbg*/
          IF v_numberlist_item.action_id is not null and v_numberlist_item.action_id=1 then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> SRC Numberlist. Drop by key action. Key: %',EXTRACT(MILLISECOND from v_end-v_start), v_numberlist_item.key;
            /*}dbg*/
            v_ret.disconnect_code_id=8002; --source blacklisted
            RETURN NEXT v_ret;
            RETURN;
          elsif v_numberlist_item.action_id is not null and v_numberlist_item.action_id=2 then
            IF v_numberlist_item.defer_src_rewrite THEN
                v_defered_src_rewrites = array_append(
                    v_defered_src_rewrites,
                    (v_numberlist_item.src_rewrite_rule, v_numberlist_item.src_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.src_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.src_prefix_out,
                    v_numberlist_item.src_rewrite_rule,
                    v_numberlist_item.src_rewrite_result
                );
            END IF;
            IF v_numberlist_item.defer_dst_rewrite THEN
                v_defered_dst_rewrites = array_append(
                    v_defered_dst_rewrites,
                    (v_numberlist_item.dst_rewrite_rule, v_numberlist_item.dst_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.dst_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.dst_prefix_out,
                    v_numberlist_item.dst_rewrite_rule,
                    v_numberlist_item.dst_rewrite_result
                );
            END IF;
            v_call_tags=yeti_ext.tag_action(v_numberlist_item.tag_action_id, v_call_tags, v_numberlist_item.tag_action_value);
            -- pass call NOP.
          elsif v_numberlist_item.action_id is null and v_numberlist.default_action_id=1 then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> SRC Numberlist. Drop by default action',EXTRACT(MILLISECOND from v_end-v_start);
            /*}dbg*/
            v_ret.disconnect_code_id=8002; --source blacklisted
            RETURN NEXT v_ret;
            RETURN;
          elsif v_numberlist_item.action_id is null and v_numberlist.default_action_id=2 then
            IF v_numberlist.defer_src_rewrite THEN
                v_defered_src_rewrites = array_append(
                    v_defered_src_rewrites,
                    (v_numberlist.default_src_rewrite_rule, v_numberlist.default_src_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.src_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.src_prefix_out,
                    v_numberlist.default_src_rewrite_rule,
                    v_numberlist.default_src_rewrite_result
                );
            END IF;
            IF v_numberlist.defer_dst_rewrite THEN
                v_defered_dst_rewrites = array_append(
                    v_defered_dst_rewrites,
                    (v_numberlist.default_dst_rewrite_rule, v_numberlist.default_dst_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.dst_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.dst_prefix_out,
                    v_numberlist.default_dst_rewrite_rule,
                    v_numberlist.default_dst_rewrite_result
                );
            END IF;
            v_call_tags=yeti_ext.tag_action(v_numberlist.tag_action_id, v_call_tags, v_numberlist.tag_action_value);
            -- pass by default
          end if;
        end if;

        SELECT INTO v_rp * from class4.routing_plans WHERE id=v_customer_auth_normalized.routing_plan_id;

        ---- Routing Plan Numberlist processing ----
        if v_rp.dst_numberlist_id is not null then
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> RP DST Numberlist processing. Lookup by key: %',EXTRACT(MILLISECOND from v_end-v_start), v_ret.dst_prefix_out;
          /*}dbg*/

          v_numberlist_item=switch21.match_numberlist(v_rp.dst_numberlist_id, v_ret.dst_prefix_out);
          select into v_numberlist * from class4.numberlists where id=v_rp.dst_numberlist_id;

          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> RP DST Numberlist. key found: %',EXTRACT(MILLISECOND from v_end-v_start), row_to_json(v_numberlist_item);
          /*}dbg*/
          IF v_numberlist_item.action_id is not null and v_numberlist_item.action_id=1 then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> RP DST Numberlist. Drop by key action. Key: %',EXTRACT(MILLISECOND from v_end-v_start), v_numberlist_item.key;
            /*}dbg*/
            v_ret.disconnect_code_id=8016; --destination blacklisted by routing plan
            RETURN NEXT v_ret;
            RETURN;
          elsif v_numberlist_item.action_id is not null and v_numberlist_item.action_id=2 then
            IF v_numberlist_item.defer_src_rewrite THEN
                v_defered_src_rewrites = array_append(
                    v_defered_src_rewrites,
                    (v_numberlist_item.src_rewrite_rule, v_numberlist_item.src_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.src_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.src_prefix_out,
                    v_numberlist_item.src_rewrite_rule,
                    v_numberlist_item.src_rewrite_result
                );
            END IF;
            IF v_numberlist_item.defer_dst_rewrite THEN
                v_defered_dst_rewrites = array_append(
                    v_defered_dst_rewrites,
                    (v_numberlist_item.dst_rewrite_rule, v_numberlist_item.dst_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.dst_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.dst_prefix_out,
                    v_numberlist_item.dst_rewrite_rule,
                    v_numberlist_item.dst_rewrite_result
                );
            END IF;
            v_call_tags=yeti_ext.tag_action(v_numberlist_item.tag_action_id, v_call_tags, v_numberlist_item.tag_action_value);
            -- pass call NOP.
          elsif v_numberlist_item.action_id is null and v_numberlist.default_action_id=1 then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> RP DST Numberlist. Drop by default action',EXTRACT(MILLISECOND from v_end-v_start);
            /*}dbg*/
            -- drop by default
            v_ret.disconnect_code_id=8016; --destination blacklisted by routing plan
            RETURN NEXT v_ret;
            RETURN;
          elsif v_numberlist_item.action_id is null and v_numberlist.default_action_id=2 then
            IF v_numberlist.defer_src_rewrite THEN
                v_defered_src_rewrites = array_append(
                    v_defered_src_rewrites,
                    (v_numberlist.default_src_rewrite_rule, v_numberlist.default_src_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.src_prefix_out=yeti_ext.regexp_replace_rand(
                v_ret.src_prefix_out,
                v_numberlist.default_src_rewrite_rule,
                v_numberlist.default_src_rewrite_result
                );
            END IF;
            IF v_numberlist.defer_dst_rewrite THEN
                v_defered_dst_rewrites = array_append(
                    v_defered_dst_rewrites,
                    (v_numberlist.default_dst_rewrite_rule, v_numberlist.default_dst_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.dst_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.dst_prefix_out,
                    v_numberlist.default_dst_rewrite_rule,
                    v_numberlist.default_dst_rewrite_result
                );
            END IF;
            v_call_tags=yeti_ext.tag_action(v_numberlist.tag_action_id, v_call_tags, v_numberlist.tag_action_value);
            -- pass by default
          end if;
        end if;

        if v_rp.src_numberlist_id is not null then
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> RP SRC Numberlist processing. Lookup by key %, no fallback', EXTRACT(MILLISECOND from v_end-v_start), v_ret.src_prefix_out;
          /*}dbg*/
          v_numberlist_item=switch21.match_numberlist(v_rp.src_numberlist_id, v_ret.src_prefix_out);

          select into v_numberlist * from class4.numberlists where id=v_rp.src_numberlist_id;

          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> RP SRC Numberlist. key found: %',EXTRACT(MILLISECOND from v_end-v_start), row_to_json(v_numberlist_item);
          /*}dbg*/
          IF v_numberlist_item.action_id is not null and v_numberlist_item.action_id=1 then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> RP SRC Numberlist. Drop by key action. Key: %',EXTRACT(MILLISECOND from v_end-v_start), v_numberlist_item.key;
            /*}dbg*/
            v_ret.disconnect_code_id=8017; --source blacklisted by routing plan
            RETURN NEXT v_ret;
            RETURN;
          elsif v_numberlist_item.action_id is not null and v_numberlist_item.action_id=2 then
            IF v_numberlist_item.defer_src_rewrite THEN
                v_defered_src_rewrites = array_append(
                    v_defered_src_rewrites,
                    (v_numberlist_item.src_rewrite_rule, v_numberlist_item.src_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.src_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.src_prefix_out,
                    v_numberlist_item.src_rewrite_rule,
                    v_numberlist_item.src_rewrite_result
                );
            END IF;
            IF v_numberlist_item.defer_dst_rewrite THEN
                v_defered_dst_rewrites = array_append(
                    v_defered_dst_rewrites,
                    (v_numberlist_item.dst_rewrite_rule, v_numberlist_item.dst_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.dst_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.dst_prefix_out,
                    v_numberlist_item.dst_rewrite_rule,
                    v_numberlist_item.dst_rewrite_result
                );
            END IF;
            v_call_tags=yeti_ext.tag_action(v_numberlist_item.tag_action_id, v_call_tags, v_numberlist_item.tag_action_value);
            -- pass call NOP.
          elsif v_numberlist_item.action_id is null and v_numberlist.default_action_id=1 then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> RP SRC Numberlist. Drop by default action',EXTRACT(MILLISECOND from v_end-v_start);
            /*}dbg*/
            v_ret.disconnect_code_id=8017; --source blacklisted by routing plan
            RETURN NEXT v_ret;
            RETURN;
          elsif v_numberlist_item.action_id is null and v_numberlist.default_action_id=2 then
            IF v_numberlist.defer_src_rewrite THEN
                v_defered_src_rewrites = array_append(
                    v_defered_src_rewrites,
                    (v_numberlist.default_src_rewrite_rule, v_numberlist.default_src_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.src_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.src_prefix_out,
                    v_numberlist.default_src_rewrite_rule,
                    v_numberlist.default_src_rewrite_result
                );
            END IF;
            IF v_numberlist.defer_dst_rewrite THEN
                v_defered_dst_rewrites = array_append(
                    v_defered_dst_rewrites,
                    (v_numberlist.default_dst_rewrite_rule, v_numberlist.default_dst_rewrite_result)::switch21.defered_rewrite
                );
            ELSE
                v_ret.dst_prefix_out=yeti_ext.regexp_replace_rand(
                    v_ret.dst_prefix_out,
                    v_numberlist.default_dst_rewrite_rule,
                    v_numberlist.default_dst_rewrite_result
                );
            END IF;
            v_call_tags=yeti_ext.tag_action(v_numberlist.tag_action_id, v_call_tags, v_numberlist.tag_action_value);
            -- pass by default
          end if;
        end if;
        ---- END of routing plan Numberlist processing

        --  setting numbers used for routing & billing
        v_ret.src_prefix_routing=v_ret.src_prefix_out;
        v_ret.dst_prefix_routing=v_ret.dst_prefix_out;
        v_routing_key=v_ret.dst_prefix_out;

        -- Areas and Tag detection-------------------------------------------
        v_ret.src_area_id:=(
          select area_id from class4.area_prefixes where prefix_range(prefix)@>prefix_range(v_ret.src_prefix_routing)
          order by length(prefix_range(prefix)) desc limit 1
        );

        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> SRC Area found: %',EXTRACT(MILLISECOND from v_end-v_start), v_ret.src_area_id;
        /*}dbg*/

        v_ret.dst_area_id:=(
          select area_id from class4.area_prefixes where prefix_range(prefix)@>prefix_range(v_ret.dst_prefix_routing)
          order by length(prefix_range(prefix)) desc limit 1
        );

        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> DST Area found: %',EXTRACT(MILLISECOND from v_end-v_start), v_ret.dst_area_id;
        /*}dbg*/


        select into v_area_direction * from class4.routing_tag_detection_rules
        where
          (src_area_id is null OR src_area_id = v_ret.src_area_id) AND
          (dst_area_id is null OR dst_area_id = v_ret.dst_area_id) AND
          prefix_range(src_prefix) @> prefix_range(v_ret.src_prefix_routing) AND
          prefix_range(dst_prefix) @> prefix_range(v_ret.dst_prefix_routing) AND
          yeti_ext.tag_compare(routing_tag_ids, v_call_tags, routing_tag_mode_id ) > 0
        order by
          yeti_ext.tag_compare(routing_tag_ids, v_call_tags, routing_tag_mode_id) desc,
          length(prefix_range(src_prefix)) desc,
          length(prefix_range(dst_prefix)) desc,
          src_area_id is null,
          dst_area_id is null
        limit 1;
        if found then
            /*dbg{*/
            RAISE NOTICE '% ms -> Routing tag detection rule found: %',EXTRACT(MILLISECOND from clock_timestamp() - v_start), row_to_json(v_area_direction);
            /*}dbg*/
            v_call_tags=yeti_ext.tag_action(v_area_direction.tag_action_id, v_call_tags, v_area_direction.tag_action_value);
        end if;

        v_ret.routing_tag_ids:=v_call_tags;

        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> Routing tags: %',EXTRACT(MILLISECOND from v_end-v_start), v_ret.routing_tag_ids;
        /*}dbg*/
        ----------------------------------------------------------------------

        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> Routing plan processing',EXTRACT(MILLISECOND from v_end-v_start);
        /*}dbg*/

        v_routing_key=v_ret.dst_prefix_routing;

        if v_rp.sorting_id=5 then -- route testing
          v_test_vendor_id=regexp_replace(v_routing_key,'(.*)\*(.*)','\1')::integer;
          v_routing_key=regexp_replace(v_routing_key,'(.*)\*(.*)','\2');
          v_ret.dst_prefix_out=v_routing_key;
          v_ret.dst_prefix_routing=v_routing_key;
        end if;

        if v_rp.use_lnp then
          select into v_lnp_rule rules.*
          from class4.routing_plan_lnp_rules rules
          WHERE prefix_range(rules.dst_prefix)@>prefix_range(v_ret.dst_prefix_routing) and rules.routing_plan_id=v_rp.id
          order by length(prefix_range(rules.dst_prefix)) desc limit 1;
          if found then
            v_ret.lnp_database_id=v_lnp_rule.database_id;
            v_lnp_key=v_ret.dst_prefix_routing;
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> LNP. Need LNP lookup, LNP key: %',EXTRACT(MILLISECOND from v_end-v_start),v_lnp_key;
            /*}dbg*/
            v_lnp_key=yeti_ext.regexp_replace_rand(v_lnp_key,v_lnp_rule.req_dst_rewrite_rule,v_lnp_rule.req_dst_rewrite_result);
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> LNP key translation. LNP key: %',EXTRACT(MILLISECOND from v_end-v_start),v_lnp_key;
            /*}dbg*/
            -- try cache
            select into v_ret.lrn lrn from class4.lnp_cache where dst=v_lnp_key AND database_id=v_lnp_rule.database_id and expires_at>v_now;
            if found then
              /*dbg{*/
              v_end:=clock_timestamp();
              RAISE NOTICE '% ms -> LNP. Data found in cache, lrn: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.lrn;
              /*}dbg*/
              -- TRANSLATING response from cache
              v_ret.lrn=yeti_ext.regexp_replace_rand(v_ret.lrn,v_lnp_rule.lrn_rewrite_rule,v_lnp_rule.lrn_rewrite_result);
              /*dbg{*/
              v_end:=clock_timestamp();
              RAISE NOTICE '% ms -> LNP. Translation. lrn: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.lrn;
              /*}dbg*/
              v_routing_key=v_ret.lrn;
              if v_lnp_rule.rewrite_call_destination then
                v_ret.dst_prefix_out=v_ret.lrn;
                v_ret.dst_prefix_routing=v_ret.lrn;
                -- TODO shouldn't we perform tag detection again there? Call destination changed.
              end if;
            else
              v_ret.lrn=switch21.lnp_resolve(v_ret.lnp_database_id,v_lnp_key);
              if v_ret.lrn is null then -- fail
                /*dbg{*/
                v_end:=clock_timestamp();
                RAISE NOTICE '% ms -> LNP. Query failed',EXTRACT(MILLISECOND from v_end-v_start);
                /*}dbg*/
                if v_lnp_rule.drop_call_on_error then
                  /*dbg{*/
                  v_end:=clock_timestamp();
                  RAISE NOTICE '% ms -> LNP. Dropping call',EXTRACT(MILLISECOND from v_end-v_start);
                  /*}dbg*/
                  v_ret.disconnect_code_id=8003; --No response from LNP DB
                  RETURN NEXT v_ret;
                  RETURN;
                end if;
              else
                /*dbg{*/
                v_end:=clock_timestamp();
                RAISE NOTICE '% ms -> LNP. Success, lrn: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.lrn;
                /*}dbg*/
                -- TRANSLATING response from LNP DB
                v_ret.lrn=yeti_ext.regexp_replace_rand(v_ret.lrn,v_lnp_rule.lrn_rewrite_rule,v_lnp_rule.lrn_rewrite_result);
                /*dbg{*/
                v_end:=clock_timestamp();
                RAISE NOTICE '% ms -> LNP. Translation. lrn: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.lrn;
                /*}dbg*/
                v_routing_key=v_ret.lrn;
                if v_lnp_rule.rewrite_call_destination then
                  v_ret.dst_prefix_out=v_ret.lrn;
                  v_ret.dst_prefix_routing=v_ret.lrn;
                  -- TODO shouldn't we perform tag detection again there? Call destination changed.
                end if;
              end if;
            end if;
          end if;
        end if;



        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> DST. search start. Routing key: %. Routing tags: %, Rate limit: %',EXTRACT(MILLISECOND from v_end-v_start), v_routing_key, v_ret.routing_tag_ids, v_destination_rate_limit;
        /*}dbg*/
        v_src_network:=switch21.detect_network(v_ret.src_prefix_routing);
        v_ret.src_network_id=v_src_network.network_id;
        v_ret.src_country_id=v_src_network.country_id;

        v_network:=switch21.detect_network(v_ret.dst_prefix_routing);
        v_ret.dst_network_id=v_network.network_id;
        v_ret.dst_country_id=v_network.country_id;

        IF v_rp.validate_dst_number_network AND v_ret.dst_network_id is null THEN
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> Network detection. DST network validation enabled and DST network was not found. Rejecting call',EXTRACT(MILLISECOND from v_end-v_start);
          /*}dbg*/

          v_ret.disconnect_code_id=8007; --No network detected for DST number
          RETURN NEXT v_ret;
          RETURN;
        END IF;

        IF v_rp.validate_dst_number_format AND NOT (v_routing_key ~ '^[0-9]+$') THEN
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> Dst number format is not valid. DST number: %s',EXTRACT(MILLISECOND from v_end-v_start), v_routing_key;
          /*}dbg*/

          v_ret.disconnect_code_id=8008; --Invalid DST number format
          RETURN NEXT v_ret;
          RETURN;
        END IF;

        IF v_rp.validate_src_number_network AND v_ret.src_network_id is null AND lower(v_ret.src_prefix_routing)!='anonymous' THEN
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> Network detection. SRC network validation enabled and SRC network was not found. Rejecting call',EXTRACT(MILLISECOND from v_end-v_start);
          /*}dbg*/

          v_ret.disconnect_code_id=8010; --No network detected for SRC number
          RETURN NEXT v_ret;
          RETURN;
        END IF;

        IF v_rp.validate_src_number_format AND lower(v_ret.src_prefix_routing)!='anonymous' AND NOT (v_ret.src_prefix_routing ~ '^[0-9]+$') THEN
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> SRC number format is not valid. SRC number: %s',EXTRACT(MILLISECOND from v_end-v_start), v_ret.src_prefix_routing;
          /*}dbg*/

          v_ret.disconnect_code_id=8011; --Invalid SRC number format
          RETURN NEXT v_ret;
          RETURN;
        END IF;

        --- rateplan lookup
        SELECT INTO v_rate_groups array_agg(rate_group_id) from class4.rate_plan_groups where rateplan_id = v_customer_auth_normalized.rateplan_id;

        SELECT into v_destination d.*/*,switch.tracelog(d.*)*/
        FROM class4.destinations d
        WHERE
          prefix_range(prefix)@>prefix_range(v_routing_key)
          AND length(v_routing_key) between d.dst_number_min_length and d.dst_number_max_length
          AND d.rate_group_id = ANY(v_rate_groups)
          AND enabled
          AND valid_from <= v_now
          AND valid_till >= v_now
          AND yeti_ext.tag_compare(d.routing_tag_ids, v_call_tags, d.routing_tag_mode_id)>0
        ORDER BY length(prefix_range(prefix)) DESC, yeti_ext.tag_compare(d.routing_tag_ids, v_call_tags) desc
        limit 1;
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
        RAISE NOTICE '% ms -> DST. found: %',EXTRACT(MILLISECOND from v_end-v_start),row_to_json(v_destination, true);
        /*}dbg*/

        v_ret.destination_id = v_destination.id;
        v_ret.destination_prefix = v_destination.prefix;
        v_ret.destination_initial_interval = v_destination.initial_interval;
        v_ret.destination_next_interval = v_destination.next_interval;

        IF v_destination.allow_package_billing THEN
          SELECT INTO v_package * FROM billing.package_counters pc
          WHERE pc.account_id = v_customer_auth_normalized.account_id AND
              prefix_range(pc.prefix)@>prefix_range(v_routing_key)
          ORDER BY length(prefix_range(pc.prefix)) DESC LIMIT 1;
        END IF;
        IF v_package.id is not null AND v_package.duration > 0 AND NOT v_package.exclude THEN
            v_ret.package_counter_id = v_package.id;
            v_ret.time_limit = v_package.duration;
        ELSE
          v_ret.destination_fee = v_destination.connect_fee::varchar;
          v_ret.destination_rate_policy_id = v_destination.rate_policy_id;
          v_ret.destination_reverse_billing = v_destination.reverse_billing;
          if v_destination.next_rate::float > v_destination_rate_limit then
            v_ret.disconnect_code_id=8006; -- No destination with appropriate rate found
            RETURN NEXT v_ret;
            RETURN;
          end if;
        END IF;

        IF v_destination.reject_calls THEN
          v_ret.disconnect_code_id=112; --Rejected by destination
          RETURN NEXT v_ret;
          RETURN;
        END IF;

        select into v_rateplan * from class4.rateplans where id=v_customer_auth_normalized.rateplan_id;
        if COALESCE(v_destination.profit_control_mode_id,v_rateplan.profit_control_mode_id)=2 then -- per call
          v_rate_limit=v_destination.next_rate::float;
        end if;


        /*
                    FIND dialpeers logic. Queries must use prefix index for best performance
        */
        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> DP. search start. Routing key: %. Rate limit: %. Routing tag: %',EXTRACT(MILLISECOND from v_end-v_start), v_routing_key, v_rate_limit, v_ret.routing_tag_ids;
        /*}dbg*/


        /* apply defered rewrites there, not really after routing, but without affecting v_routing_key */

        FOREACH v_rewrite IN ARRAY v_defered_src_rewrites LOOP
            v_ret.src_prefix_out = yeti_ext.regexp_replace_rand(
                v_ret.src_prefix_out,
                v_rewrite.rule,
                v_rewrite.result
            );
        END LOOP;

        FOREACH v_rewrite IN ARRAY v_defered_dst_rewrites LOOP
            v_ret.dst_prefix_out = yeti_ext.regexp_replace_rand(
                v_ret.dst_prefix_out,
                v_rewrite.rule,
                v_rewrite.result
            );
        END LOOP;

        SELECT INTO v_routing_groups array_agg(routing_group_id) from class4.routing_plan_groups where routing_plan_id = v_customer_auth_normalized.routing_plan_id;

        CASE v_rp.sorting_id
          WHEN '1' THEN -- LCR,Prio, ACD&ASR control
          FOR routedata IN (
            WITH step1 AS(
                SELECT
                  (t_dp.*)::class4.dialpeers as s1_dialpeer,
                  t_dp.vendor_id as s1_vendor_id,
                  t_dp.account_id as s1_vendor_account_id,
                  t_dp.next_rate as dp_next_rate,
                  t_dp.lcr_rate_multiplier AS dp_lcr_rate_multiplier,
                  t_dp.priority AS dp_priority,
                  t_dp.locked as dp_locked,
                  t_dp.enabled as dp_enabled,
                  rank() OVER (
                    PARTITION BY t_dp.vendor_id, t_dp.routeset_discriminator_id
                    ORDER BY
                      length(prefix_range(t_dp.prefix)) desc,
                      yeti_ext.tag_compare(t_dp.routing_tag_ids, v_call_tags, t_dp.routing_tag_mode_id) desc,
                      t_dp.exclusive_route desc -- in case when we have two identical prefixes with different exclusive flag value, we should lift up exclusive route, otherwise it will be filtered at WHERE r=1  and exclusive_rank=1
                    ) as r,
                  rank() OVER (
                    ORDER BY t_dp.exclusive_route desc -- force top rank for exclusive route
                    ) as exclusive_rank
                FROM class4.dialpeers t_dp
                WHERE
                  prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
                  AND length(v_routing_key) between t_dp.dst_number_min_length and t_dp.dst_number_max_length
                  AND t_dp.routing_group_id = ANY(v_routing_groups)
                  and t_dp.valid_from<=v_now
                  and t_dp.valid_till>=v_now
                  AND yeti_ext.tag_compare(t_dp.routing_tag_ids, v_call_tags, t_dp.routing_tag_mode_id) > 0
            )
            SELECT
                s1_dialpeer as s2_dialpeer,
                (t_vendor_account.*)::billing.accounts as s2_vendor_account
            FROM step1
            JOIN public.contractors t_vendor ON step1.s1_vendor_id = t_vendor.id
            JOIN billing.accounts t_vendor_account ON step1.s1_vendor_account_id = t_vendor_account.id
            WHERE
              r=1
              and exclusive_rank=1
              AND dp_next_rate<=v_rate_limit
              AND dp_enabled
              and not dp_locked --ACD&ASR control for DP
              AND t_vendor_account.balance < t_vendor_account.max_balance
              AND t_vendor.enabled AND t_vendor.vendor
            ORDER BY dp_next_rate*dp_lcr_rate_multiplier, dp_priority DESC
            LIMIT v_rp.max_rerouting_attempts
          ) LOOP
            RETURN QUERY
            /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}rel*/
            /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}dbg*/
          end LOOP;
          WHEN '2' THEN --LCR, no prio, No ACD&ASR control
          FOR routedata IN (
            WITH step1 AS( -- filtering
                SELECT
                  (t_dp.*)::class4.dialpeers as s1_dialpeer,
                  t_dp.vendor_id as s1_vendor_id,
                  t_dp.account_id as s1_vendor_account_id,
                  rank() OVER (
                    PARTITION BY t_dp.vendor_id, t_dp.routeset_discriminator_id
                    ORDER BY
                      length(prefix_range(t_dp.prefix)) desc,
                      yeti_ext.tag_compare(t_dp.routing_tag_ids, v_call_tags, t_dp.routing_tag_mode_id) desc,
                      t_dp.exclusive_route desc -- in case when we have two identical prefixes with different exclusive flag value, we should lift up exclusive route, otherwise it will be filtered at WHERE r=1  and exclusive_rank=1
                    ) as r,
                  rank() OVER (
                    ORDER BY t_dp.exclusive_route desc -- force top rank for exclusive route
                    ) as exclusive_rank,
                  t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric,
                  t_dp.next_rate as dp_next_rate,
                  t_dp.enabled as dp_enabled
                FROM class4.dialpeers t_dp
                WHERE
                  prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
                  AND length(v_routing_key) between t_dp.dst_number_min_length and t_dp.dst_number_max_length
                  AND t_dp.routing_group_id = ANY(v_routing_groups)
                  and t_dp.valid_from<=v_now
                  and t_dp.valid_till>=v_now
                  AND yeti_ext.tag_compare(t_dp.routing_tag_ids,v_call_tags, t_dp.routing_tag_mode_id)>0
            )
            SELECT
                s1_dialpeer as s2_dialpeer,
                (t_vendor_account.*)::billing.accounts as s2_vendor_account
            FROM step1
            JOIN public.contractors t_vendor ON step1.s1_vendor_id = t_vendor.id
            JOIN billing.accounts t_vendor_account ON step1.s1_vendor_account_id = t_vendor_account.id
            WHERE
              r=1
              and exclusive_rank=1
              AND dp_enabled
              and dp_next_rate<=v_rate_limit
              AND t_vendor_account.balance < t_vendor_account.max_balance
              AND t_vendor.enabled AND t_vendor.vendor
            ORDER BY dp_metric
            LIMIT v_rp.max_rerouting_attempts
          ) LOOP
            RETURN QUERY
            /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}rel*/
            /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}dbg*/
          END LOOP;
          WHEN '3' THEN --Prio, LCR, ACD&ASR control
          FOR routedata in(
            WITH step1 AS( -- filtering
                SELECT
                  (t_dp.*)::class4.dialpeers as s1_dialpeer,
                  t_dp.vendor_id as s1_vendor_id,
                  t_dp.account_id as s1_vendor_account_id,
                  rank() OVER (
                    PARTITION BY t_dp.vendor_id, t_dp.routeset_discriminator_id
                    ORDER BY
                      length(prefix_range(t_dp.prefix)) desc,
                      yeti_ext.tag_compare(t_dp.routing_tag_ids, v_call_tags, t_dp.routing_tag_mode_id) desc,
                      t_dp.exclusive_route desc -- in case when we have two identical prefixes with different exclusive flag value, we should lift up exclusive route, otherwise it will be filtered at WHERE r=1  and exclusive_rank=1
                    ) as r,
                  rank() OVER (
                    ORDER BY t_dp.exclusive_route desc -- force top rank for exclusive route
                    ) as exclusive_rank,
                  t_dp.priority as dp_metric_priority,
                  t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric,
                  t_dp.next_rate as dp_next_rate,
                  t_dp.locked as dp_locked,
                  t_dp.enabled as dp_enabled
                FROM class4.dialpeers t_dp
                WHERE
                  prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
                  AND length(v_routing_key) between t_dp.dst_number_min_length and t_dp.dst_number_max_length
                  AND t_dp.routing_group_id = ANY(v_routing_groups)
                  and t_dp.valid_from<=v_now
                  and t_dp.valid_till>=v_now
                  AND yeti_ext.tag_compare(t_dp.routing_tag_ids, v_call_tags, t_dp.routing_tag_mode_id) > 0
            )
            SELECT
                    s1_dialpeer as s2_dialpeer,
                    (t_vendor_account.*)::billing.accounts as s2_vendor_account
            FROM step1
            JOIN public.contractors t_vendor ON step1.s1_vendor_id = t_vendor.id
            JOIN billing.accounts t_vendor_account ON step1.s1_vendor_account_id = t_vendor_account.id
            WHERE
              r=1
              AND exclusive_rank=1
              AND dp_next_rate<=v_rate_limit
              AND dp_enabled
              AND NOT dp_locked
              AND t_vendor_account.balance < t_vendor_account.max_balance
              AND t_vendor.enabled AND t_vendor.vendor
            ORDER BY dp_metric_priority DESC, dp_metric
            LIMIT v_rp.max_rerouting_attempts
          )LOOP
            RETURN QUERY
            /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}rel*/
            /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}dbg*/
          END LOOP;
          WHEN'4' THEN -- LCRD, Prio, ACD&ACR control
          FOR routedata IN (
            WITH step1 AS(
                SELECT
                  (t_dp.*)::class4.dialpeers as s1_dialpeer,
                  t_dp.vendor_id as s1_vendor_id,
                  t_dp.account_id as s1_vendor_account_id,
                  rank() OVER (
                    PARTITION BY t_dp.vendor_id, t_dp.routeset_discriminator_id
                    ORDER BY
                      length(prefix_range(t_dp.prefix)) desc,
                      yeti_ext.tag_compare(t_dp.routing_tag_ids, v_call_tags, t_dp.routing_tag_mode_id) desc,
                      t_dp.exclusive_route desc -- in case when we have two identical prefixes with different exclusive flag value, we should lift up exclusive route, otherwise it will be filtered at WHERE r=1  and exclusive_rank=1
                  ) as r,
                  rank() OVER (
                    ORDER BY t_dp.exclusive_route desc -- force top rank for exclusive route
                  ) as exclusive_rank,
                  ((t_dp.next_rate - first_value(t_dp.next_rate) OVER(ORDER BY t_dp.next_rate ASC)) > v_rp.rate_delta_max)::INTEGER *(t_dp.next_rate + t_dp.priority) - t_dp.priority AS r2,
                  t_dp.next_rate as dp_next_rate,
                  t_dp.locked as dp_locked,
                  t_dp.enabled as dp_enabled
                FROM class4.dialpeers t_dp
                WHERE
                  prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
                  AND length(v_routing_key) between t_dp.dst_number_min_length and t_dp.dst_number_max_length
                  AND t_dp.routing_group_id = ANY(v_routing_groups)
                  and t_dp.valid_from<=v_now
                  and t_dp.valid_till>=v_now
                  AND yeti_ext.tag_compare(t_dp.routing_tag_ids,v_call_tags, t_dp.routing_tag_mode_id)>0
            )
            SELECT
                    s1_dialpeer as s2_dialpeer,
                    (t_vendor_account.*)::billing.accounts as s2_vendor_account
            FROM step1
            JOIN public.contractors t_vendor ON step1.s1_vendor_id = t_vendor.id
            JOIN billing.accounts t_vendor_account ON step1.s1_vendor_account_id = t_vendor_account.id
            WHERE
              r=1
              and exclusive_rank=1
              and dp_next_rate <= v_rate_limit
              and dp_enabled
              and not dp_locked --ACD&ASR control for DP
              AND t_vendor_account.balance < t_vendor_account.max_balance
              AND t_vendor.enabled AND t_vendor.vendor
            ORDER BY r2 ASC
            LIMIT v_rp.max_rerouting_attempts
          ) LOOP
            RETURN QUERY
            /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}rel*/
            /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}dbg*/
          end LOOP;
          WHEN'5' THEN -- Route test
          FOR routedata IN (
            WITH step1 AS( -- filtering
                SELECT
                  (t_dp.*)::class4.dialpeers as s1_dialpeer,
                  t_dp.vendor_id as s1_vendor_id,
                  t_dp.account_id as s1_vendor_account_id,
                  rank() OVER (
                    PARTITION BY t_dp.vendor_id, t_dp.routeset_discriminator_id
                    ORDER BY
                      length(prefix_range(t_dp.prefix)) desc,
                      yeti_ext.tag_compare(t_dp.routing_tag_ids, v_call_tags, t_dp.routing_tag_mode_id) desc,
                      t_dp.exclusive_route desc -- in case when we have two identical prefixes with different exclusive flag value, we should lift up exclusive route, otherwise it will be filtered at WHERE r=1  and exclusive_rank=1
                  ) as r,
                  rank() OVER (
                    ORDER BY t_dp.exclusive_route desc -- force top rank for exclusive route
                  ) as exclusive_rank,
                  t_dp.priority as dp_metric_priority,
                  t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric,
                  t_dp.next_rate as dp_next_rate,
                  t_dp.enabled as dp_enabled
                FROM class4.dialpeers t_dp
                WHERE
                  prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
                  AND length(v_routing_key) between t_dp.dst_number_min_length and t_dp.dst_number_max_length
                  AND t_dp.routing_group_id = ANY(v_routing_groups)
                  and t_dp.valid_from<=v_now
                  and t_dp.valid_till>=v_now
                  and t_dp.vendor_id = v_test_vendor_id
                  AND yeti_ext.tag_compare(t_dp.routing_tag_ids,v_call_tags, t_dp.routing_tag_mode_id) > 0
            )
            SELECT
                s1_dialpeer as s2_dialpeer,
                (t_vendor_account.*)::billing.accounts as s2_vendor_account
            FROM step1
            JOIN public.contractors t_vendor ON step1.s1_vendor_id = t_vendor.id
            JOIN billing.accounts t_vendor_account ON step1.s1_vendor_account_id = t_vendor_account.id
            WHERE
              r=1
              and exclusive_rank=1
              and dp_enabled
              and dp_next_rate<=v_rate_limit
              AND t_vendor_account.balance < t_vendor_account.max_balance
              AND t_vendor.enabled AND t_vendor.vendor
            ORDER BY dp_metric_priority DESC, dp_metric
            LIMIT v_rp.max_rerouting_attempts
          )LOOP
            RETURN QUERY
            /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}rel*/
            /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}dbg*/
          END LOOP;
          WHEN'6' THEN -- QD.Static,LCR,ACD&ACR control
          v_random:=random();
          FOR routedata in(
            WITH step1 AS( -- filtering
                SELECT
                  (t_dp.*)::class4.dialpeers as s1_dialpeer,
                  (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                  rank() OVER (
                    PARTITION BY t_dp.vendor_id, t_dp.routeset_discriminator_id
                    ORDER BY
                      length(prefix_range(t_dp.prefix)) desc,
                      yeti_ext.tag_compare(t_dp.routing_tag_ids, v_call_tags, t_dp.routing_tag_mode_id) desc,
                      t_dp.exclusive_route desc -- in case when we have two identical prefixes with different exclusive flag value, we should lift up exclusive route, otherwise it will be filtered at WHERE r=1  and exclusive_rank=1
                  ) as r,
                  rank() OVER (
                    ORDER BY t_dp.exclusive_route desc -- force top rank for exclusive route
                  ) as exclusive_rank,
                  rank() OVER (
                    PARTITION BY t_dp.vendor_id, t_dp.routeset_discriminator_id
                    ORDER BY length(prefix_range(coalesce(rpsr.prefix,''))) desc
                  ) as r2,
                  t_dp.priority as dp_metric_priority,
                  t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric,
                  t_dp.next_rate as dp_next_rate,
                  t_dp.locked as dp_locked,
                  t_dp.enabled as dp_enabled,
                  t_dp.force_hit_rate as dp_force_hit_rate,
                  COALESCE(rpsr.priority, t_dp.priority) as rpsr_priority,
                  COALESCE(rpsr.weight, 100) as rpsr_weight
                FROM class4.dialpeers t_dp
                  JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
                  join public.contractors t_vendor on t_dp.vendor_id=t_vendor.id
                  left join class4.routing_plan_static_routes rpsr
                    ON rpsr.routing_plan_id=v_customer_auth_normalized.routing_plan_id
                      and rpsr.vendor_id=t_dp.vendor_id
                      AND prefix_range(rpsr.prefix)@>prefix_range(v_routing_key)
                WHERE
                  prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
                  AND length(v_routing_key) between t_dp.dst_number_min_length and t_dp.dst_number_max_length
                  AND t_dp.routing_group_id = ANY(v_routing_groups)
                  and t_dp.valid_from<=v_now
                  and t_dp.valid_till>=v_now
                  AND t_vendor_account.balance<t_vendor_account.max_balance
                  and t_vendor.enabled and t_vendor.vendor
                  AND yeti_ext.tag_compare(t_dp.routing_tag_ids,v_call_tags, t_dp.routing_tag_mode_id) > 0
            )
            SELECT s1_dialpeer as s2_dialpeer,
                  s1_vendor_account as s2_vendor_account
            FROM step1
            WHERE
              r=1
              and exclusive_rank=1
              and r2=1
              and dp_next_rate<=v_rate_limit
              and dp_enabled
              and not dp_locked
            ORDER BY
              coalesce(v_random<=dp_force_hit_rate,false) desc,
              rpsr_priority,
              yeti_ext.rank_dns_srv(rpsr_weight) over ( partition by rpsr_priority order by rpsr_weight),
              dp_metric
            LIMIT v_rp.max_rerouting_attempts
          )LOOP
            RETURN QUERY
            /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}rel*/
            /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}dbg*/
          END LOOP;
          WHEN'7' THEN -- QD.Static, No ACD&ACR control
          v_random:=random();
          FOR routedata in(
            WITH step1 AS( -- filtering
                SELECT
                  (t_dp.*)::class4.dialpeers as s1_dialpeer,
                  (t_vendor_account.*)::billing.accounts as s1_vendor_account,
                  rank() OVER (
                    PARTITION BY t_dp.vendor_id, t_dp.routeset_discriminator_id
                    ORDER BY
                      length(prefix_range(t_dp.prefix)) desc,
                      yeti_ext.tag_compare(t_dp.routing_tag_ids, v_call_tags, t_dp.routing_tag_mode_id) desc,
                      t_dp.exclusive_route desc -- in case when we have two identical prefixes with different exclusive flag value, we should lift up exclusive route, otherwise it will be filtered at WHERE r=1  and exclusive_rank=1
                  ) as r,
                  rank() OVER (
                    ORDER BY t_dp.exclusive_route desc -- force top rank for exclusive route
                  ) as exclusive_rank,
                  rank() OVER (
                    PARTITION BY t_dp.vendor_id, t_dp.routeset_discriminator_id
                    ORDER BY length(prefix_range(coalesce(rpsr.prefix,''))) desc
                  ) as r2,
                  t_dp.priority as dp_metric_priority,
                  t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric,
                  t_dp.next_rate as dp_next_rate,
                  t_dp.enabled as dp_enabled,
                  t_dp.force_hit_rate as dp_force_hit_rate,
                  rpsr.priority as rpsr_priority,
                  rpsr.weight as rpsr_weight
                FROM class4.dialpeers t_dp
                  JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
                  join public.contractors t_vendor on t_dp.vendor_id=t_vendor.id
                  join class4.routing_plan_static_routes rpsr
                    ON rpsr.routing_plan_id=v_customer_auth_normalized.routing_plan_id
                      and rpsr.vendor_id=t_dp.vendor_id
                      AND prefix_range(rpsr.prefix)@>prefix_range(v_routing_key)
                WHERE
                  prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
                  AND length(v_routing_key) between t_dp.dst_number_min_length and t_dp.dst_number_max_length
                  AND t_dp.routing_group_id = ANY(v_routing_groups)
                  and t_dp.valid_from<=v_now
                  and t_dp.valid_till>=v_now
                  AND t_vendor_account.balance<t_vendor_account.max_balance
                  and t_vendor.enabled and t_vendor.vendor
                  AND yeti_ext.tag_compare(t_dp.routing_tag_ids,v_call_tags, t_dp.routing_tag_mode_id) > 0
            )
            SELECT s1_dialpeer as s2_dialpeer,
                  s1_vendor_account as s2_vendor_account
            FROM step1
            WHERE
              r=1
              and exclusive_rank=1
              and r2=1
              and dp_next_rate<=v_rate_limit
              and dp_enabled
            ORDER BY
              coalesce(v_random<=dp_force_hit_rate,false) desc,
              rpsr_priority,
              yeti_ext.rank_dns_srv(rpsr_weight) over ( partition by rpsr_priority order by rpsr_weight),
              dp_metric
            LIMIT v_rp.max_rerouting_attempts
          )LOOP
            RETURN QUERY
            /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}rel*/
            /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth_normalized.send_billing_information,v_max_call_length,v_diversion,v_privacy,v_pai,v_ppi);/*}dbg*/
          END LOOP;

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
      $_$;

      set search_path TO switch21;
      SELECT * from switch21.preprocess_all();
      set search_path TO gui, public, switch, billing, class4, runtime_stats, sys, logs, data_import;

    }
  end

end
