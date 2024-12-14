class Switch22Functions < ActiveRecord::Migration[7.0]
  def up
    execute %q{

    alter table class4.customers_auth drop CONSTRAINT "customers_auth_diversion_policy_id_fkey";

    drop table class4.diversion_policy;

    alter table class4.customers_auth add pai_policy_id smallint not null default 1; -- accept by default
    alter table class4.customers_auth_normalized add pai_policy_id smallint not null default 1; -- accept by default

    alter table class4.customers_auth alter column diversion_policy_id type smallint;
    alter table class4.customers_auth_normalized alter column diversion_policy_id type smallint;

    create type switch22.uri_ty as (
      s varchar,
      n varchar,
      u varchar,
      h varchar,
      p integer,
      up_arr varchar[],
      uh_arr varchar[],
      np_arr varchar[]
    );

    -- Diversion: test2 <sip:user2@domain2:5061;uparam1=uval21;uparam2=uval22?uhdr1=uhval1>;nparam1=nval1


CREATE OR REPLACE FUNCTION switch22.build_uri(
  i_canonical boolean,
  i_schema character varying,
  i_display_name character varying,
  i_username character varying,
  i_username_params character varying[],
  i_domain character varying,
  i_port integer,
  i_uri_params character varying[]
) RETURNS character varying
    LANGUAGE plpgsql STABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_domainport varchar;
  v_username varchar;
  v_uri varchar;
BEGIN

  if coalesce(cardinality(i_username_params),0) >0 then
    v_username = i_username||';'||array_to_string(i_username_params,';');
  else
    v_username = i_username;
  end if;

  -- adding username, domain and port. Username and port are optional
  v_uri = COALESCE(v_username||'@','')||i_domain||COALESCE(':'||i_port::varchar,'');

  -- adding params after domainport if exists
  if coalesce(cardinality(i_uri_params),0)>0 then
    v_uri = v_uri||';'||array_to_string(i_uri_params,';');
  end if;

  if i_canonical then
    v_uri = i_schema||':'||v_uri;
  else
    v_uri = '<'||i_schema||':'||v_uri||'>';
    IF i_display_name is not null and i_display_name!='' THEN
      v_uri = '"'||i_display_name||'" '||v_uri;
    END IF;
  end if;

  return v_uri;
END;
$$;


CREATE FUNCTION switch22.build_uri(i_canonical boolean, i_data switch22.uri_ty) RETURNS varchar
    LANGUAGE plpgsql STABLE SECURITY DEFINER COST 10
    AS $$
DECLARE
  v_domainport varchar;
  v_username varchar;
  v_uri varchar;
BEGIN
  return switch22.build_uri(i_canonical, i_data.s, i_data.n, i_data.u, '{}'::varchar[], i_data.h, i_data.p, '{}'::varchar[]);
END;
$$;


DROP FUNCTION switch22.route_release(i_node_id integer, i_pop_id integer, i_protocol_id smallint, i_remote_ip inet, i_remote_port integer, i_local_ip inet, i_local_port integer, i_from_dsp character varying, i_from_name character varying, i_from_domain character varying, i_from_port integer, i_to_name character varying, i_to_domain character varying, i_to_port integer, i_contact_name character varying, i_contact_domain character varying, i_contact_port integer, i_uri_name character varying, i_uri_domain character varying, i_auth_id integer, i_identity_data json, i_interface character varying, i_x_yeti_auth character varying, i_diversion character varying, i_x_orig_ip inet, i_x_orig_port integer, i_x_orig_protocol_id smallint, i_pai character varying, i_ppi character varying, i_privacy character varying, i_rpid character varying, i_rpid_privacy character varying);
DROP FUNCTION switch22.route_debug(i_node_id integer, i_pop_id integer, i_protocol_id smallint, i_remote_ip inet, i_remote_port integer, i_local_ip inet, i_local_port integer, i_from_dsp character varying, i_from_name character varying, i_from_domain character varying, i_from_port integer, i_to_name character varying, i_to_domain character varying, i_to_port integer, i_contact_name character varying, i_contact_domain character varying, i_contact_port integer, i_uri_name character varying, i_uri_domain character varying, i_auth_id integer, i_identity_data json, i_interface character varying, i_x_yeti_auth character varying, i_diversion character varying, i_x_orig_ip inet, i_x_orig_port integer, i_x_orig_protocol_id smallint, i_pai character varying, i_ppi character varying, i_privacy character varying, i_rpid character varying, i_rpid_privacy character varying);
DROP FUNCTION switch22.route(i_node_id integer, i_pop_id integer, i_protocol_id smallint, i_remote_ip inet, i_remote_port integer, i_local_ip inet, i_local_port integer, i_from_dsp character varying, i_from_name character varying, i_from_domain character varying, i_from_port integer, i_to_name character varying, i_to_domain character varying, i_to_port integer, i_contact_name character varying, i_contact_domain character varying, i_contact_port integer, i_uri_name character varying, i_uri_domain character varying, i_auth_id integer, i_identity_data json, i_interface character varying, i_x_yeti_auth character varying, i_diversion character varying, i_x_orig_ip inet, i_x_orig_port integer, i_x_orig_protocol_id smallint, i_pai character varying, i_ppi character varying, i_privacy character varying, i_rpid character varying, i_rpid_privacy character varying);

CREATE FUNCTION switch22.route(
i_node_id integer,
i_pop_id integer,
i_protocol_id smallint,
i_remote_ip inet,
i_remote_port integer,
i_local_ip inet,
i_local_port integer,
i_from_dsp character varying,
i_from_name character varying,
i_from_domain character varying,
i_from_port integer,
i_to_name character varying,
i_to_domain character varying,
i_to_port integer,
i_contact_name character varying,
i_contact_domain character varying,
i_contact_port integer,
i_uri_name character varying,
i_uri_domain character varying,
i_auth_id integer,
i_identity_data json,
i_interface character varying,
i_x_yeti_auth character varying,
i_diversion json,
i_x_orig_ip inet,
i_x_orig_port integer,
i_x_orig_protocol_id smallint,
i_pai json,
i_ppi json,
i_privacy character varying,
i_rpid json,
i_rpid_privacy character varying
) RETURNS SETOF switch22.callprofile_ty
    LANGUAGE plpgsql SECURITY DEFINER ROWS 10
    AS $_$
      DECLARE
        v_ret switch22.callprofile_ty;
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
        v_lua_context switch22.lua_call_context;
        v_identity_data switch22.identity_data_ty[];
        v_identity_record switch22.identity_data_ty;
        v_pai switch22.uri_ty[];
        v_ppi switch22.uri_ty;
        v_privacy varchar[];
        v_diversion switch22.uri_ty[] not null default ARRAY[]::switch22.uri_ty[];
        v_diversion_tmp switch22.uri_ty[];
        v_diversion_header switch22.uri_ty;
        v_cnam_req_json json;
        v_cnam_resp_json json;
        v_cnam_lua_resp switch22.cnam_lua_resp;
        v_cnam_database class4.cnam_databases%rowtype;
        v_rewrite switch22.defered_rewrite;
        v_defered_src_rewrites switch22.defered_rewrite[] not null default ARRAY[]::switch22.defered_rewrite[];
        v_defered_dst_rewrites switch22.defered_rewrite[] not null default ARRAY[]::switch22.defered_rewrite[];
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
        v_ret:=switch22.new_profile();

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

        select into v_pai array_agg(d) from json_populate_recordset(null::switch22.uri_ty, i_pai) d WHERE d.u is not null and d.u!='';
        v_pai = COALESCE(v_pai, ARRAY[]::switch22.uri_ty[]);

        v_ppi = json_populate_record(null::switch22.uri_ty, i_ppi);
        if v_ppi.u is null then
          v_ppi = null;
        end if;

        v_privacy = string_to_array(COALESCE(i_privacy,''),';');

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

        select into v_diversion_tmp array_agg(d) from json_populate_recordset(null::switch22.uri_ty, i_diversion) d WHERE d.u is not null and d.u!='';
        v_diversion_tmp = COALESCE(v_diversion_tmp, ARRAY[]::switch22.uri_ty[]);

        IF v_customer_auth_normalized.dst_number_field_id=1 THEN /* default  - RURI userpart*/
          v_ret.dst_prefix_in:=i_uri_name;
        ELSIF v_customer_auth_normalized.dst_number_field_id=2 THEN /* TO URI userpart */
          v_ret.dst_prefix_in:=i_to_name;
        ELSIF v_customer_auth_normalized.dst_number_field_id=3 THEN /* Top-Most Diversion header userpart */
          v_ret.dst_prefix_in:=COALESCE(v_diversion_tmp[1].u,'');
        END IF;
        v_ret.dst_prefix_out:=v_ret.dst_prefix_in;

        IF v_customer_auth_normalized.diversion_policy_id = 2 THEN /* accept diversion */
          FOREACH v_diversion_header IN ARRAY v_diversion_tmp LOOP
            v_diversion_header.u = yeti_ext.regexp_replace_rand(
              v_diversion_header.u,
              v_customer_auth_normalized.diversion_rewrite_rule,
              v_customer_auth_normalized.diversion_rewrite_result
            );
            v_diversion = array_append(v_diversion, v_diversion_header);
          END LOOP;
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
              IF lower(v_ret.src_prefix_in)='anonymous' AND COALESCE(cardinality(v_pai),0) = 0 AND ( v_ppi is null ) THEN
                v_ret.disconnect_code_id = 8015;
                RETURN NEXT v_ret;
                RETURN;
              END IF;
        END CASE;

        ---- Identity validation ----
        select into v_identity_data array_agg(d) from  json_populate_recordset(null::switch22.identity_data_ty, i_identity_data) d;
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
          FOREACH v_identity_record IN ARRAY COALESCE(v_identity_data,'{}'::switch22.identity_data_ty[]) LOOP
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
          select into v_lua_context switch22.lua_exec(v_customer_auth_normalized.lua_script_id, v_lua_context);
          v_ret.src_name_out =  v_lua_context.src_name_out;
          v_ret.src_prefix_out = v_lua_context.src_number_out;
          v_ret.dst_prefix_out = v_lua_context.dst_number_out;
        end if;
**/
        if v_customer_auth_normalized.cnam_database_id is not null then
          select into v_cnam_database * from class4.cnam_databases where id=v_customer_auth_normalized.cnam_database_id;

          select into v_cnam_req_json * from switch22.cnam_lua_build_request(v_cnam_database.request_lua, row_to_json(v_ret)::text);
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
            select into v_cnam_lua_resp * from switch22.cnam_lua_response_exec(v_cnam_database.response_lua, json_extract_path_text(v_cnam_resp_json,'response'));

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

          v_numberlist_item=switch22.match_numberlist(v_customer_auth_normalized.dst_numberlist_id, v_ret.dst_prefix_out);
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
                    (v_numberlist_item.src_rewrite_rule, v_numberlist_item.src_rewrite_result)::switch22.defered_rewrite
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
                    (v_numberlist_item.dst_rewrite_rule, v_numberlist_item.dst_rewrite_result)::switch22.defered_rewrite
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
                    (v_numberlist.default_src_rewrite_rule, v_numberlist.default_src_rewrite_result)::switch22.defered_rewrite
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
                    (v_numberlist.default_dst_rewrite_rule, v_numberlist.default_dst_rewrite_result)::switch22.defered_rewrite
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

          if v_customer_auth_normalized.src_numberlist_use_diversion AND v_diversion[1].u is not null then
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> SRC Numberlist processing. Lookup by key %, fallback to %', EXTRACT(MILLISECOND from v_end-v_start), v_ret.src_prefix_out, v_diversion[1];
            /*}dbg*/
            v_numberlist_item=switch22.match_numberlist(v_customer_auth_normalized.src_numberlist_id, v_ret.src_prefix_out, v_diversion[1].u);
          else
            /*dbg{*/
            v_end:=clock_timestamp();
            RAISE NOTICE '% ms -> SRC Numberlist processing. Lookup by key %, no fallback', EXTRACT(MILLISECOND from v_end-v_start), v_ret.src_prefix_out;
            /*}dbg*/
            v_numberlist_item=switch22.match_numberlist(v_customer_auth_normalized.src_numberlist_id, v_ret.src_prefix_out);
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
                    (v_numberlist_item.src_rewrite_rule, v_numberlist_item.src_rewrite_result)::switch22.defered_rewrite
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
                    (v_numberlist_item.dst_rewrite_rule, v_numberlist_item.dst_rewrite_result)::switch22.defered_rewrite
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
                    (v_numberlist.default_src_rewrite_rule, v_numberlist.default_src_rewrite_result)::switch22.defered_rewrite
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
                    (v_numberlist.default_dst_rewrite_rule, v_numberlist.default_dst_rewrite_result)::switch22.defered_rewrite
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

          v_numberlist_item=switch22.match_numberlist(v_rp.dst_numberlist_id, v_ret.dst_prefix_out);
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
                    (v_numberlist_item.src_rewrite_rule, v_numberlist_item.src_rewrite_result)::switch22.defered_rewrite
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
                    (v_numberlist_item.dst_rewrite_rule, v_numberlist_item.dst_rewrite_result)::switch22.defered_rewrite
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
                    (v_numberlist.default_src_rewrite_rule, v_numberlist.default_src_rewrite_result)::switch22.defered_rewrite
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
                    (v_numberlist.default_dst_rewrite_rule, v_numberlist.default_dst_rewrite_result)::switch22.defered_rewrite
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
          v_numberlist_item=switch22.match_numberlist(v_rp.src_numberlist_id, v_ret.src_prefix_out);

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
                    (v_numberlist_item.src_rewrite_rule, v_numberlist_item.src_rewrite_result)::switch22.defered_rewrite
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
                    (v_numberlist_item.dst_rewrite_rule, v_numberlist_item.dst_rewrite_result)::switch22.defered_rewrite
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
                    (v_numberlist.default_src_rewrite_rule, v_numberlist.default_src_rewrite_result)::switch22.defered_rewrite
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
                    (v_numberlist.default_dst_rewrite_rule, v_numberlist.default_dst_rewrite_result)::switch22.defered_rewrite
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
              v_ret.lrn=switch22.lnp_resolve(v_ret.lnp_database_id,v_lnp_key);
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
        v_src_network:=switch22.detect_network(v_ret.src_prefix_routing);
        v_ret.src_network_id=v_src_network.network_id;
        v_ret.src_country_id=v_src_network.country_id;

        v_network:=switch22.detect_network(v_ret.dst_prefix_routing);
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

DROP FUNCTION switch22.process_gw_debug(i_profile switch22.callprofile_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_vendor_gw class4.gateways, i_send_billing_information boolean, i_max_call_length integer, i_diversion character varying[], i_privacy character varying[], i_pai character varying[], i_ppi character varying);
DROP FUNCTION switch22.process_gw_release(i_profile switch22.callprofile_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_vendor_gw class4.gateways, i_send_billing_information boolean, i_max_call_length integer, i_diversion character varying[], i_privacy character varying[], i_pai character varying[], i_ppi character varying);
DROP FUNCTION switch22.process_gw(i_profile switch22.callprofile_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_vendor_gw class4.gateways, i_send_billing_information boolean, i_max_call_length integer, i_diversion character varying[], i_privacy character varying[], i_pai character varying[], i_ppi character varying);

CREATE FUNCTION switch22.process_gw(i_profile switch22.callprofile_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_vendor_gw class4.gateways, i_send_billing_information boolean, i_max_call_length integer, i_diversion switch22.uri_ty[], i_privacy character varying[], i_pai switch22.uri_ty[], i_ppi switch22.uri_ty) RETURNS switch22.callprofile_ty
    LANGUAGE plpgsql STABLE SECURITY DEFINER COST 100000
    AS $_$
DECLARE
  i integer;
  v_vendor_allowtime real;
  v_route_found boolean:=false;
  v_from_user varchar;
  v_from_domain varchar;
  v_schema varchar;
  v_termination_numberlist class4.numberlists%rowtype;
  v_termination_numberlist_item class4.numberlist_items%rowtype;
  v_termination_numberlist_size integer;
  v_aleg_append_headers_reply varchar[] not null default ARRAY[]::varchar[];
  v_bleg_append_headers_req varchar[] not null default ARRAY[]::varchar[];
  v_diversion switch22.uri_ty[] not null default ARRAY[]::switch22.uri_ty[];
  v_diversion_header switch22.uri_ty;
  v_pai switch22.uri_ty;
  v_allow_pai boolean:=true;
  v_to_uri_params varchar[] not null default ARRAY[]::varchar[];
  v_from_uri_params varchar[] not null default ARRAY[]::varchar[];
  v_ruri_host varchar;
  v_ruri_params varchar[] not null default ARRAY[]::varchar[];
  v_ruri_user_params varchar[] not null default ARRAY[]::varchar[];
  v_to_username varchar;
  v_customer_transit_headers_from_origination varchar[] default ARRAY[]::varchar[];
  v_vendor_transit_headers_from_origination varchar[] default ARRAY[]::varchar[];
  /*dbg{*/
  v_start timestamp;
  v_end timestamp;
  /*}dbg*/
BEGIN
  /*dbg{*/
  v_start:=now();
  --RAISE NOTICE 'process_dp in: %',i_profile;
  v_end:=clock_timestamp();
  RAISE NOTICE '% ms -> DP. Found dialpeer: %',EXTRACT(MILLISECOND from v_end-v_start),row_to_json(i_dp,true);
  /*}dbg*/

  --RAISE NOTICE 'process_dp dst: %',i_destination;

  i_profile.destination_id:=i_destination.id;
  i_profile.destination_fee:=i_destination.connect_fee::varchar;
  i_profile.destination_rate_policy_id:=i_destination.rate_policy_id;

  --vendor account capacity limit;
  i_profile.legb_res= '';
  if i_vendor_acc.termination_capacity is not null then
    i_profile.legb_res = '2:'||i_dp.account_id::varchar||':'||i_vendor_acc.termination_capacity::varchar||':1;';
  end if;

  if i_vendor_acc.total_capacity is not null then
    i_profile.legb_res = i_profile.legb_res||'7:'||i_dp.account_id::varchar||':'||i_vendor_acc.total_capacity::varchar||':1;';
  end if;

  -- dialpeer account capacity limit;
  if i_dp.capacity is not null then
    i_profile.legb_res = i_profile.legb_res||'6:'||i_dp.id::varchar||':'||i_dp.capacity::varchar||':1;';
  end if;

  /* */
  i_profile.dialpeer_id=i_dp.id;
  i_profile.dialpeer_prefix=i_dp.prefix;
  i_profile.dialpeer_next_rate=i_dp.next_rate::varchar;
  i_profile.dialpeer_initial_rate=i_dp.initial_rate::varchar;
  i_profile.dialpeer_initial_interval=i_dp.initial_interval;
  i_profile.dialpeer_next_interval=i_dp.next_interval;
  i_profile.dialpeer_fee=i_dp.connect_fee::varchar;
  i_profile.dialpeer_reverse_billing=i_dp.reverse_billing;
  i_profile.vendor_id=i_dp.vendor_id;
  i_profile.vendor_acc_id=i_dp.account_id;
  i_profile.term_gw_id=i_vendor_gw.id;

  i_profile.orig_gw_name=i_customer_gw."name";
  i_profile.orig_gw_external_id=i_customer_gw.external_id;

  i_profile.term_gw_name=i_vendor_gw."name";
  i_profile.term_gw_external_id=i_vendor_gw.external_id;

  i_profile.customer_account_name=i_customer_acc."name";

  i_profile.routing_group_id:=i_dp.routing_group_id;

  -- TODO. store arrays in GW and not convert it there
  v_customer_transit_headers_from_origination = string_to_array(COALESCE(i_customer_gw.transit_headers_from_origination,''),',');
  v_vendor_transit_headers_from_origination = string_to_array(COALESCE(i_vendor_gw.transit_headers_from_origination,''),',');

  if i_send_billing_information then
    v_aleg_append_headers_reply=array_append(v_aleg_append_headers_reply, (E'X-VND-INIT-INT:'||i_profile.dialpeer_initial_interval)::varchar);
    v_aleg_append_headers_reply=array_append(v_aleg_append_headers_reply, (E'X-VND-NEXT-INT:'||i_profile.dialpeer_next_interval)::varchar);
    v_aleg_append_headers_reply=array_append(v_aleg_append_headers_reply, (E'X-VND-INIT-RATE:'||i_profile.dialpeer_initial_rate)::varchar);
    v_aleg_append_headers_reply=array_append(v_aleg_append_headers_reply, (E'X-VND-NEXT-RATE:'||i_profile.dialpeer_next_rate)::varchar);
    v_aleg_append_headers_reply=array_append(v_aleg_append_headers_reply, (E'X-VND-CF:'||i_profile.dialpeer_fee)::varchar);
  end if;
    v_aleg_append_headers_reply = array_cat(v_aleg_append_headers_reply,i_customer_gw.orig_append_headers_reply);
    i_profile.aleg_append_headers_reply=ARRAY_TO_STRING(v_aleg_append_headers_reply,'\r\n');

  if i_destination.use_dp_intervals THEN
    i_profile.destination_initial_interval:=i_dp.initial_interval;
    i_profile.destination_next_interval:=i_dp.next_interval;
  ELSE
    i_profile.destination_initial_interval:=i_destination.initial_interval;
    i_profile.destination_next_interval:=i_destination.next_interval;
  end if;

  IF i_profile.package_counter_id IS NULL THEN
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
  END IF;


  /* time limiting START */
  --SELECT INTO STRICT v_c_acc * FROM billing.accounts  WHERE id=v_customer_auth.account_id;
  --SELECT INTO STRICT v_v_acc * FROM billing.accounts  WHERE id=v_dialpeer.account_id;


  if i_profile.time_limit is null then
    /*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> process_gw: customer time limit is not set, calculating',EXTRACT(MILLISECOND from v_end-v_start);
    /*}dbg*/
    IF (i_customer_acc.balance-i_customer_acc.min_balance)-i_destination.connect_fee-i_destination.initial_rate/60*i_destination.initial_interval<0 THEN
      /*dbg{*/
      v_end:=clock_timestamp();
      RAISE NOTICE '% ms -> process_gw: No enough customer balance even for first billing interval. rejecting',EXTRACT(MILLISECOND from v_end-v_start);
      /*}dbg*/
      i_profile.disconnect_code_id=8000; --Not enough customer balance
      RETURN i_profile;
    ELSIF i_destination.next_rate!=0 AND i_destination.next_interval!=0 THEN
      i_profile.time_limit = (i_destination.initial_interval+
                          LEAST(FLOOR(((i_customer_acc.balance-i_customer_acc.min_balance)-i_destination.connect_fee-i_destination.initial_rate/60*i_destination.initial_interval)/
                                      (i_destination.next_rate/60*i_destination.next_interval)),24e6)::integer*i_destination.next_interval)::integer;
      /*dbg{*/
      v_end:=clock_timestamp();
      RAISE NOTICE '% ms -> process_gw: customer time limit: %',EXTRACT(MILLISECOND from v_end-v_start), i_profile.time_limit;
      /*}dbg*/
    ELSE /* DST rates is 0, allowing maximum call length */
      i_profile.time_limit = COALESCE(i_customer_acc.max_call_duration, i_max_call_length)::integer;
      /*dbg{*/
      v_end:=clock_timestamp();
      RAISE NOTICE '% ms -> process_gw: DST rate is 0. customer time limit set to max value: %',EXTRACT(MILLISECOND from v_end-v_start), i_profile.time_limit;
      /*}dbg*/
    end IF;
  end if;

  IF (i_vendor_acc.max_balance-i_vendor_acc.balance)-i_dp.connect_fee <0 THEN /* No enough balance, skipping this profile */
    v_vendor_allowtime:=0;
    return null;
  ELSIF (i_vendor_acc.max_balance-i_vendor_acc.balance)-i_dp.connect_fee-i_dp.initial_rate/60*i_dp.initial_interval<0 THEN /* No enough balance even for first billing interval - skipping this profile */
    return null;
  ELSIF i_dp.next_rate!=0 AND i_dp.next_interval!=0 THEN /* DP rates is not zero, calculating limit */
    v_vendor_allowtime:=i_dp.initial_interval+
                        LEAST(FLOOR(((i_vendor_acc.max_balance-i_vendor_acc.balance)-i_dp.connect_fee-i_dp.initial_rate/60*i_dp.initial_interval)/
                                    (i_dp.next_rate/60*i_dp.next_interval)),24e6)::integer*i_dp.next_interval;
  ELSE /* DP rates is 0, allowing maximum call length */
    v_vendor_allowtime:=COALESCE(i_vendor_acc.max_call_duration, i_max_call_length);
  end IF;

  i_profile.time_limit=LEAST(
    COALESCE(i_customer_acc.max_call_duration, i_max_call_length)::integer,
    COALESCE(i_vendor_acc.max_call_duration, i_max_call_length)::integer,
    v_vendor_allowtime,
    i_profile.time_limit
  )::integer;


  /* number rewriting _After_ routing */
  /*dbg{*/
  v_end:=clock_timestamp();
  RAISE NOTICE '% ms -> DP. Before rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),i_profile.src_prefix_out,i_profile.dst_prefix_out;
  /*}dbg*/
  i_profile.dst_prefix_out=yeti_ext.regexp_replace_rand(i_profile.dst_prefix_out,i_dp.dst_rewrite_rule,i_dp.dst_rewrite_result);
  i_profile.src_prefix_out=yeti_ext.regexp_replace_rand(i_profile.src_prefix_out,i_dp.src_rewrite_rule,i_dp.src_rewrite_result);
  i_profile.src_name_out=yeti_ext.regexp_replace_rand(i_profile.src_name_out,i_dp.src_name_rewrite_rule,i_dp.src_name_rewrite_result, true);

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
  if i_vendor_gw.termination_capacity is not null then
    i_profile.legb_res:=i_profile.legb_res||'5:'||i_vendor_gw.id::varchar||':'||i_vendor_gw.termination_capacity::varchar||':1;';
  end if;


  /*
      numberlist processing _After_ routing _IN_ termination GW
  */
  /*dbg{*/
  v_end:=clock_timestamp();
  RAISE NOTICE '% ms -> GW. Before numberlist processing src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),i_profile.src_prefix_out,i_profile.dst_prefix_out;
  /*}dbg*/


  ----- DST Numberlist processing-------------------------------------------------------------------------------------------------------
  IF i_vendor_gw.termination_dst_numberlist_id is not null then
    /*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> GW DST Numberlist processing. Lookup by key: %',EXTRACT(MILLISECOND from v_end-v_start), i_profile.dst_prefix_out;
    /*}dbg*/

    select into v_termination_numberlist * from class4.numberlists where id=i_vendor_gw.termination_dst_numberlist_id;
    CASE v_termination_numberlist.mode_id
      when 1 then -- strict match
        select into v_termination_numberlist_item * from class4.numberlist_items ni
        where
          ni.numberlist_id=i_vendor_gw.termination_dst_numberlist_id and
          ni.key=i_profile.dst_prefix_out
        limit 1;
      when 2 then -- prefix match
        select into v_termination_numberlist_item * from class4.numberlist_items ni
        where
          ni.numberlist_id=i_vendor_gw.termination_dst_numberlist_id and
          prefix_range(ni.key)@>prefix_range(i_profile.dst_prefix_out) and
          length(i_profile.dst_prefix_out) between ni.number_min_length and ni.number_max_length
        order by length(prefix_range(ni.key)) desc
        limit 1;
      when 3 then -- random
        select into v_termination_numberlist_size count(*) from class4.numberlist_items where numberlist_id=i_vendor_gw.termination_dst_numberlist_id;
        select into v_termination_numberlist_item * from class4.numberlist_items ni
         where ni.numberlist_id=i_vendor_gw.termination_dst_numberlist_id order by ni.id OFFSET floor(random()*v_termination_numberlist_size) limit 1;
    END CASE;

    /*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> GW DST Numberlist. key found: %',EXTRACT(MILLISECOND from v_end-v_start), row_to_json(v_termination_numberlist_item);
    /*}dbg*/

    IF v_termination_numberlist_item.action_id is not null and v_termination_numberlist_item.action_id=1 then
      /*dbg{*/
      v_end:=clock_timestamp();
      RAISE NOTICE '% ms -> GW DST Numberlist. Drop by key action. Skipping route. Key: %',EXTRACT(MILLISECOND from v_end-v_start), v_termination_numberlist_item.key;
      /*}dbg*/
      RETURN null;
    ELSIF v_termination_numberlist_item.action_id is not null and v_termination_numberlist_item.action_id=2 then
        i_profile.src_prefix_out=yeti_ext.regexp_replace_rand(
          i_profile.src_prefix_out,
          v_termination_numberlist_item.src_rewrite_rule,
          v_termination_numberlist_item.src_rewrite_result
        );

        i_profile.dst_prefix_out=yeti_ext.regexp_replace_rand(
          i_profile.dst_prefix_out,
          v_termination_numberlist_item.dst_rewrite_rule,
          v_termination_numberlist_item.dst_rewrite_result
        );
    ELSIF v_termination_numberlist_item.action_id is null and v_termination_numberlist.default_action_id=1 then
      /*dbg{*/
      v_end:=clock_timestamp();
      RAISE NOTICE '% ms -> GW DST Numberlist. Drop by default action. Skipping route',EXTRACT(MILLISECOND from v_end-v_start);
      /*}dbg*/
      RETURN null;
    ELSIF v_termination_numberlist_item.action_id is null and v_termination_numberlist.default_action_id=2 then
      i_profile.src_prefix_out=yeti_ext.regexp_replace_rand(
        i_profile.src_prefix_out,
        v_termination_numberlist.default_src_rewrite_rule,
        v_termination_numberlist.default_src_rewrite_result
      );

      i_profile.dst_prefix_out=yeti_ext.regexp_replace_rand(
        i_profile.dst_prefix_out,
        v_termination_numberlist.default_dst_rewrite_rule,
        v_termination_numberlist.default_dst_rewrite_result
      );
    END IF;
  END IF;



  ----- SRC Numberlist processing-------------------------------------------------------------------------------------------------------
  IF i_vendor_gw.termination_src_numberlist_id is not null then
    /*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> GW SRC Numberlist processing. Lookup by key: %',EXTRACT(MILLISECOND from v_end-v_start), i_profile.src_prefix_out;
    /*}dbg*/

    select into v_termination_numberlist * from class4.numberlists where id=i_vendor_gw.termination_src_numberlist_id;
    CASE v_termination_numberlist.mode_id
      when 1 then -- strict match
        select into v_termination_numberlist_item * from class4.numberlist_items ni
        where
          ni.numberlist_id=i_vendor_gw.termination_src_numberlist_id and
          ni.key=i_profile.src_prefix_out
        limit 1;
      when 2 then -- prefix match
        select into v_termination_numberlist_item * from class4.numberlist_items ni
        where
          ni.numberlist_id=i_vendor_gw.termination_src_numberlist_id and
          prefix_range(ni.key)@>prefix_range(i_profile.src_prefix_out) and
          length(i_profile.src_prefix_out) between ni.number_min_length and ni.number_max_length
        order by length(prefix_range(ni.key)) desc
        limit 1;
      when 3 then -- random
        select into v_termination_numberlist_size count(*) from class4.numberlist_items where numberlist_id=i_vendor_gw.termination_src_numberlist_id;
        select into v_termination_numberlist_item * from class4.numberlist_items ni
         where ni.numberlist_id=i_vendor_gw.termination_src_numberlist_id order by ni.id OFFSET floor(random()*v_termination_numberlist_size) limit 1;
    END CASE;

    /*dbg{*/
    v_end:=clock_timestamp();
    RAISE NOTICE '% ms -> GW SRC Numberlist. key found: %',EXTRACT(MILLISECOND from v_end-v_start), row_to_json(v_termination_numberlist_item);
    /*}dbg*/

    IF v_termination_numberlist_item.action_id is not null and v_termination_numberlist_item.action_id=1 then
      /*dbg{*/
      v_end:=clock_timestamp();
      RAISE NOTICE '% ms -> GW SRC Numberlist. Drop by key action. Skipping route. Key: %',EXTRACT(MILLISECOND from v_end-v_start), v_termination_numberlist_item.key;
      /*}dbg*/
      RETURN null;
    ELSIF v_termination_numberlist_item.action_id is not null and v_termination_numberlist_item.action_id=2 then
        i_profile.src_prefix_out=yeti_ext.regexp_replace_rand(
          i_profile.src_prefix_out,
          v_termination_numberlist_item.src_rewrite_rule,
          v_termination_numberlist_item.src_rewrite_result
        );

        i_profile.dst_prefix_out=yeti_ext.regexp_replace_rand(
          i_profile.dst_prefix_out,
          v_termination_numberlist_item.dst_rewrite_rule,
          v_termination_numberlist_item.dst_rewrite_result
        );
    ELSIF v_termination_numberlist_item.action_id is null and v_termination_numberlist.default_action_id=1 then
      /*dbg{*/
      v_end:=clock_timestamp();
      RAISE NOTICE '% ms -> GW DST Numberlist. Drop by default action. Skipping route.',EXTRACT(MILLISECOND from v_end-v_start);
      /*}dbg*/
      -- drop by default
      RETURN null;
    ELSIF v_termination_numberlist_item.action_id is null and v_termination_numberlist.default_action_id=2 then
      i_profile.src_prefix_out=yeti_ext.regexp_replace_rand(
        i_profile.src_prefix_out,
        v_termination_numberlist.default_src_rewrite_rule,
        v_termination_numberlist.default_src_rewrite_result
      );

      i_profile.dst_prefix_out=yeti_ext.regexp_replace_rand(
        i_profile.dst_prefix_out,
        v_termination_numberlist.default_dst_rewrite_rule,
        v_termination_numberlist.default_dst_rewrite_result
      );
    END IF;
  END IF;



  /*
      number rewriting _After_ routing _IN_ termination GW
  */
  /*dbg{*/
  v_end:=clock_timestamp();
  RAISE NOTICE '% ms -> GW. Before rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),i_profile.src_prefix_out,i_profile.dst_prefix_out;
  /*}dbg*/
  i_profile.dst_prefix_out=yeti_ext.regexp_replace_rand(i_profile.dst_prefix_out,i_vendor_gw.dst_rewrite_rule,i_vendor_gw.dst_rewrite_result);
  i_profile.src_prefix_out=yeti_ext.regexp_replace_rand(i_profile.src_prefix_out,i_vendor_gw.src_rewrite_rule,i_vendor_gw.src_rewrite_result);
  i_profile.src_name_out=yeti_ext.regexp_replace_rand(i_profile.src_name_out,i_vendor_gw.src_name_rewrite_rule,i_vendor_gw.src_name_rewrite_result, true);

  /*dbg{*/
  v_end:=clock_timestamp();
  RAISE NOTICE '% ms -> GW. After rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),i_profile.src_prefix_out,i_profile.dst_prefix_out;
  /*}dbg*/


  IF cardinality(i_diversion) > 0 AND i_vendor_gw.diversion_send_mode_id > 1 THEN
    IF i_vendor_gw.diversion_send_mode_id = 2 AND i_vendor_gw.diversion_domain is not null AND i_vendor_gw.diversion_domain!='' THEN
      /* Diversion as SIP URI */
      FOREACH v_diversion_header IN ARRAY i_diversion LOOP
        v_diversion_header.u = yeti_ext.regexp_replace_rand(v_diversion_header.u, i_vendor_gw.diversion_rewrite_rule, i_vendor_gw.diversion_rewrite_result);
        v_bleg_append_headers_req = array_append(
          v_bleg_append_headers_req,
          format('Diversion: <sip:%s@%s>', v_diversion_header.u, i_vendor_gw.diversion_domain)::varchar
        );
      END LOOP;
    ELSIF i_vendor_gw.diversion_send_mode_id = 3 THEN
      /* Diversion as TEL URI */
      FOREACH v_diversion_header IN ARRAY i_diversion LOOP
        v_diversion_header.u = yeti_ext.regexp_replace_rand(v_diversion_header.u, i_vendor_gw.diversion_rewrite_rule, i_vendor_gw.diversion_rewrite_result);
        v_bleg_append_headers_req=array_append(
          v_bleg_append_headers_req,
          format('Diversion: <tel:%s>', v_diversion_header.u)::varchar
        );
      END LOOP;
    END IF;

  END IF;

  CASE i_vendor_gw.privacy_mode_id
    WHEN 0 THEN
      -- do nothing
    WHEN 1 THEN
      IF cardinality(array_remove(i_privacy,'none')) > 0 THEN
        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> GW Privacy % requested but privacy_mode_is %. Skipping gw.',EXTRACT(MILLISECOND from v_end-v_start), i_privacy, i_vendor_gw.privacy_mode_id;
        /*}dbg*/
        return null;
      END IF;
    WHEN 2 THEN
      IF 'critical' = ANY(i_privacy) THEN
        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> GW Privacy % requested but privacy_mode_is %. Skipping gw.',EXTRACT(MILLISECOND from v_end-v_start), i_privacy, i_vendor_gw.privacy_mode_id;
        /*}dbg*/
        return null;
      END IF;
    WHEN 3 THEN
      /*dbg{*/
      v_end:=clock_timestamp();
      RAISE NOTICE '% ms -> GW Privacy % requested, privacy_mode_is %. Applying privacy.',EXTRACT(MILLISECOND from v_end-v_start), i_privacy, i_vendor_gw.privacy_mode_id;
      /*}dbg*/
      IF 'id' = ANY(i_privacy) OR 'user' = ANY(i_privacy) THEN
        i_profile.src_prefix_out='anonymous';
        i_profile.src_name_out='Anonymous';
        v_from_domain = 'anonymous.invalid';
      END IF;
      IF 'id' = ANY(i_privacy) OR 'header' = ANY(i_privacy) THEN
        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> GW Privacy % requested, privacy_mode_is %. removing PAI/PPI headers.',EXTRACT(MILLISECOND from v_end-v_start), i_privacy, i_vendor_gw.privacy_mode_id;
        /*}dbg*/
        v_allow_pai = false;
      END IF;
      v_bleg_append_headers_req = array_append(v_bleg_append_headers_req, format('Privacy: %s', array_to_string(i_privacy,';')::varchar));
    WHEN 4 THEN
      /*dbg{*/
      v_end:=clock_timestamp();
      RAISE NOTICE '% ms -> GW Privacy % requested, privacy_mode_is %. forwarding.',EXTRACT(MILLISECOND from v_end-v_start), i_privacy, i_vendor_gw.privacy_mode_id;
      /*}dbg*/
      IF cardinality(i_privacy)>0 THEN
        v_bleg_append_headers_req = array_append(v_bleg_append_headers_req, format('Privacy: %s', array_to_string(i_privacy,';')::varchar));
      END IF;
    WHEN 5 THEN
      /*dbg{*/
      v_end:=clock_timestamp();
      RAISE NOTICE '% ms -> GW Privacy % requested, privacy_mode_is %. forwarding with anonymous From.',EXTRACT(MILLISECOND from v_end-v_start), i_privacy, i_vendor_gw.privacy_mode_id;
      /*}dbg*/
      IF 'id' = ANY(i_privacy) or 'user' = ANY(i_privacy) THEN
        i_profile.src_prefix_out='anonymous';
        i_profile.src_name_out='Anonymous';
        v_from_domain = 'anonymous.invalid';
        v_bleg_append_headers_req = array_append(v_bleg_append_headers_req, format('Privacy: %s', array_to_string(i_privacy,';')::varchar));
      END IF;
  END CASE;

  IF v_allow_pai THEN
    -- only if privacy mode allows to send PAI
    IF i_vendor_gw.pai_send_mode_id = 1 THEN
      -- TEL URI
      v_bleg_append_headers_req = array_append(v_bleg_append_headers_req, format('P-Asserted-Identity: <tel:%s>', i_profile.src_prefix_out)::varchar);
    ELSIF i_vendor_gw.pai_send_mode_id = 2 and i_vendor_gw.pai_domain is not null and i_vendor_gw.pai_domain!='' THEN
      -- SIP URL
      v_bleg_append_headers_req = array_append(v_bleg_append_headers_req, format('P-Asserted-Identity: <sip:%s@%s>', i_profile.src_prefix_out, i_vendor_gw.pai_domain)::varchar);
    ELSIF i_vendor_gw.pai_send_mode_id = 3 and i_vendor_gw.pai_domain is not null and i_vendor_gw.pai_domain!='' THEN
      v_bleg_append_headers_req = array_append(v_bleg_append_headers_req, format('P-Asserted-Identity: <sip:%s@%s;user=phone>', i_profile.src_prefix_out, i_vendor_gw.pai_domain)::varchar);
    ELSIF i_vendor_gw.pai_send_mode_id = 4 THEN
      -- relay
      FOREACH v_pai IN ARRAY i_pai LOOP
        v_bleg_append_headers_req = array_append(v_bleg_append_headers_req, format('P-Asserted-Identity: %s', switch22.build_uri(false, v_pai))::varchar);
      END LOOP;
      IF i_ppi.u is not null THEN
        v_bleg_append_headers_req = array_append(v_bleg_append_headers_req, format('P-Preferred-Identity: %s', switch22.build_uri(false, i_ppi))::varchar);
      END IF;
    ELSIF i_vendor_gw.pai_send_mode_id = 5 THEN
      -- relay with conversion to tel URI
      FOREACH v_pai IN ARRAY i_pai LOOP
        v_pai.s = 'tel';
        v_bleg_append_headers_req = array_append(v_bleg_append_headers_req, format('P-Asserted-Identity: %s', switch22.build_uri(false, v_pai))::varchar);
      END LOOP;
      IF i_ppi.u is not null THEN
        i_ppi.s = 'tel';
        v_bleg_append_headers_req = array_append(v_bleg_append_headers_req, format('P-Preferred-Identity: %s', switch22.build_uri(false, i_ppi))::varchar);
      END IF;
    ELSIF i_vendor_gw.pai_send_mode_id = 6 THEN
      -- relay with conversion to SIP URI
      FOREACH v_pai IN ARRAY i_pai LOOP
        v_pai.s = 'sip';
        v_pai.h = COALESCE(v_pai.h, i_vendor_gw.pai_domain);
        v_bleg_append_headers_req = array_append(v_bleg_append_headers_req, format('P-Asserted-Identity: %s', switch22.build_uri(false, v_pai))::varchar);
      END LOOP;
      IF i_ppi.u is not null THEN
        i_ppi.s = 'sip';
        i_ppi.s = COALESCE(i_ppi.h, i_vendor_gw.pai_domain);
        v_bleg_append_headers_req = array_append(v_bleg_append_headers_req, format('P-Preferred-Identity: %s', switch22.build_uri(false, i_ppi))::varchar);
      END IF;
    END IF;

  END IF;

  IF i_vendor_gw.stir_shaken_mode_id IN (1,2) THEN
    IF i_profile.lega_ss_status_id >0 THEN
      -- relaying valid header from customer
      i_profile.legb_ss_status_id = i_profile.lega_ss_status_id;
      v_customer_transit_headers_from_origination = array_append(v_customer_transit_headers_from_origination,'Identity');
      v_vendor_transit_headers_from_origination = array_append(v_vendor_transit_headers_from_origination,'Identity');
    ELSIF COALESCE(i_profile.ss_attest_id,0) > 0 AND i_vendor_gw.stir_shaken_crt_id IS NOT NULL THEN
      -- insert our signature
      i_profile.ss_crt_id = i_vendor_gw.stir_shaken_crt_id;
      i_profile.legb_ss_status_id = i_profile.ss_attest_id;

      IF i_vendor_gw.stir_shaken_mode_id = 1 THEN
        i_profile.ss_otn = i_profile.src_prefix_routing;
        i_profile.ss_dtn = i_profile.dst_prefix_routing;
      ELSIF i_vendor_gw.stir_shaken_mode_id = 2 THEN
        i_profile.ss_otn = i_profile.src_prefix_out;
        i_profile.ss_dtn = i_profile.dst_prefix_out;
      END IF;
    END IF;
  END IF ;

  v_bleg_append_headers_req = array_cat(v_bleg_append_headers_req, i_vendor_gw.term_append_headers_req);
  i_profile.append_headers_req = array_to_string(v_bleg_append_headers_req,'\r\n');

  i_profile.aleg_append_headers_req = array_to_string(i_customer_gw.orig_append_headers_req,'\r\n');

  i_profile.next_hop_1st_req=i_vendor_gw.auth_enabled; -- use low delay dns srv if auth enabled
  i_profile.next_hop:=i_vendor_gw.term_next_hop;
  i_profile.aleg_next_hop:=i_customer_gw.orig_next_hop;
  --    i_profile.next_hop_for_replies:=v_dst_gw.term_next_hop_for_replies;

  i_profile.dlg_nat_handling=i_customer_gw.dialog_nat_handling;

  i_profile.call_id:=''; -- Generation by sems

  i_profile.enable_auth:=i_vendor_gw.auth_enabled;
  i_profile.auth_pwd:=i_vendor_gw.auth_password;
  i_profile.auth_user:=i_vendor_gw.auth_user;
  i_profile.enable_aleg_auth:=false;
  i_profile.auth_aleg_pwd:='';
  i_profile.auth_aleg_user:='';

  if i_profile.enable_auth then
    v_from_user=COALESCE(i_vendor_gw.auth_from_user,i_profile.src_prefix_out,'');
    -- may be it already defined by privacy logic
    v_from_domain=COALESCE(v_from_domain, i_vendor_gw.auth_from_domain, '$Oi');
  else
    v_from_user=COALESCE(i_profile.src_prefix_out,'');
    if i_vendor_gw.preserve_anonymous_from_domain and i_profile.from_domain='anonymous.invalid' then
      v_from_domain='anonymous.invalid';
    else
      v_from_domain=COALESCE(v_from_domain, '$Oi');
    end if;
  end if;

  v_to_username = yeti_ext.regexp_replace_rand(i_profile.dst_prefix_out, i_vendor_gw.to_rewrite_rule, i_vendor_gw.to_rewrite_result);

  if i_vendor_gw.sip_schema_id = 1 then
    v_schema='sip';
  elsif i_vendor_gw.sip_schema_id = 2 then
    v_schema='sips';
  elsif i_vendor_gw.sip_schema_id = 3 then
    v_schema='sip';
    -- user=phone param require e.164 with + in username, but we are not forcing it
    v_from_uri_params = array_append(v_from_uri_params,'user=phone');
    v_to_uri_params = array_append(v_to_uri_params,'user=phone');
    v_ruri_params = array_append(v_ruri_params,'user=phone');
  else
    RAISE exception 'Unknown termination gateway % SIP schema %', i_vendor_gw.id, i_vendor_gw.sip_schema_id;
  end if;

  if i_vendor_gw.send_lnp_information and i_profile.lrn is not null then
    if i_profile.lrn=i_profile.dst_prefix_routing then -- number not ported, but request was successf we musr add ;npdi=yes;
      v_ruri_user_params = array_append(v_ruri_user_params, 'npdi=yes');
      i_profile.lrn=nullif(i_profile.dst_prefix_routing,i_profile.lrn); -- clear lnr field if number not ported;
    else -- if number ported
      v_ruri_user_params = array_append(v_ruri_user_params, 'rn='||i_profile.lrn);
      v_ruri_user_params = array_append(v_ruri_user_params, 'npdi=yes');
    end if;
  end if;

  i_profile.registered_aor_mode_id = i_vendor_gw.registered_aor_mode_id;
  if i_vendor_gw.registered_aor_mode_id > 0  then
    i_profile.registered_aor_id=i_vendor_gw.id;
    v_ruri_host = 'unknown.invalid';
  else
    v_ruri_host = i_vendor_gw.host;
  end if;

  i_profile."from" = switch22.build_uri(false, v_schema, i_profile.src_name_out, v_from_user, null, v_from_domain, null, v_from_uri_params);

  i_profile."to" = switch22.build_uri(false, v_schema, null, v_to_username, null, v_ruri_host, i_vendor_gw.port, v_to_uri_params);
  i_profile.ruri = switch22.build_uri(true, v_schema, null, i_profile.dst_prefix_out, v_ruri_user_params, v_ruri_host, i_vendor_gw.port, v_ruri_params);

  i_profile.bleg_transport_protocol_id:=i_vendor_gw.transport_protocol_id;
  i_profile.bleg_protocol_priority_id:=i_vendor_gw.network_protocol_priority_id;

  i_profile.aleg_media_encryption_mode_id:=i_customer_gw.media_encryption_mode_id;
  i_profile.bleg_media_encryption_mode_id:=i_vendor_gw.media_encryption_mode_id;

  IF (i_vendor_gw.term_use_outbound_proxy ) THEN
    i_profile.outbound_proxy:=v_schema||':'||i_vendor_gw.term_outbound_proxy;
    i_profile.force_outbound_proxy:=i_vendor_gw.term_force_outbound_proxy;
    i_profile.bleg_outbound_proxy_transport_protocol_id:=i_vendor_gw.term_proxy_transport_protocol_id;
  ELSE
    i_profile.outbound_proxy:=NULL;
    i_profile.force_outbound_proxy:=false;
  END IF;

  IF (i_customer_gw.orig_use_outbound_proxy ) THEN
    i_profile.aleg_force_outbound_proxy:=i_customer_gw.orig_force_outbound_proxy;
    i_profile.aleg_outbound_proxy=v_schema||':'||i_customer_gw.orig_outbound_proxy;
    i_profile.aleg_outbound_proxy_transport_protocol_id:=i_customer_gw.orig_proxy_transport_protocol_id;
  else
    i_profile.aleg_force_outbound_proxy:=FALSE;
    i_profile.aleg_outbound_proxy=NULL;
  end if;

  i_profile.aleg_policy_id=i_customer_gw.orig_disconnect_policy_id;
  i_profile.bleg_policy_id=i_vendor_gw.term_disconnect_policy_id;

  i_profile.transit_headers_a2b:=array_to_string(v_customer_transit_headers_from_origination,',')||';'||array_to_string(v_vendor_transit_headers_from_origination,',');
  i_profile.transit_headers_b2a:=i_vendor_gw.transit_headers_from_termination||';'||i_customer_gw.transit_headers_from_termination;

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

  i_profile.rtprelay_interface:=i_vendor_gw.rtp_interface_name;
  i_profile.aleg_rtprelay_interface:=i_customer_gw.rtp_interface_name;

  i_profile.outbound_interface:=i_vendor_gw.sip_interface_name;
  i_profile.aleg_outbound_interface:=i_customer_gw.sip_interface_name;

  i_profile.bleg_force_symmetric_rtp:=i_vendor_gw.force_symmetric_rtp;
  i_profile.bleg_symmetric_rtp_nonstop=i_vendor_gw.symmetric_rtp_nonstop;

  i_profile.aleg_force_symmetric_rtp:=i_customer_gw.force_symmetric_rtp;
  i_profile.aleg_symmetric_rtp_nonstop=i_customer_gw.symmetric_rtp_nonstop;

  i_profile.bleg_rtp_ping=i_vendor_gw.rtp_ping;
  i_profile.aleg_rtp_ping=i_customer_gw.rtp_ping;

  i_profile.bleg_relay_options = i_vendor_gw.relay_options;
  i_profile.aleg_relay_options = i_customer_gw.relay_options;


  i_profile.filter_noaudio_streams = i_vendor_gw.filter_noaudio_streams OR i_customer_gw.filter_noaudio_streams;
  i_profile.force_one_way_early_media = i_vendor_gw.force_one_way_early_media OR i_customer_gw.force_one_way_early_media;
  i_profile.aleg_relay_reinvite = i_vendor_gw.relay_reinvite;
  i_profile.bleg_relay_reinvite = i_customer_gw.relay_reinvite;

  i_profile.aleg_relay_hold = i_vendor_gw.relay_hold;
  i_profile.bleg_relay_hold = i_customer_gw.relay_hold;

  i_profile.aleg_relay_prack = i_vendor_gw.relay_prack;
  i_profile.bleg_relay_prack = i_customer_gw.relay_prack;
  i_profile.aleg_rel100_mode_id = i_customer_gw.rel100_mode_id;
  i_profile.bleg_rel100_mode_id = i_vendor_gw.rel100_mode_id;

  i_profile.rtp_relay_timestamp_aligning=i_vendor_gw.rtp_relay_timestamp_aligning OR i_customer_gw.rtp_relay_timestamp_aligning;
  i_profile.allow_1xx_wo2tag=i_vendor_gw.allow_1xx_without_to_tag OR i_customer_gw.allow_1xx_without_to_tag;

  i_profile.aleg_sdp_c_location_id=i_customer_gw.sdp_c_location_id;
  i_profile.bleg_sdp_c_location_id=i_vendor_gw.sdp_c_location_id;
  i_profile.trusted_hdrs_gw=false;



  i_profile.aleg_codecs_group_id:=i_customer_gw.codec_group_id;
  i_profile.bleg_codecs_group_id:=i_vendor_gw.codec_group_id;
  i_profile.aleg_single_codec_in_200ok:=i_customer_gw.single_codec_in_200ok;
  i_profile.bleg_single_codec_in_200ok:=i_vendor_gw.single_codec_in_200ok;
  i_profile.try_avoid_transcoding = i_customer_gw.try_avoid_transcoding;
  i_profile.ringing_timeout=i_vendor_gw.ringing_timeout;
  i_profile.dead_rtp_time=GREATEST(i_vendor_gw.rtp_timeout,i_customer_gw.rtp_timeout);
  i_profile.invite_timeout=i_vendor_gw.sip_timer_b;
  i_profile.srv_failover_timeout=i_vendor_gw.dns_srv_failover_timer;
  i_profile.fake_180_timer=i_vendor_gw.fake_180_timer;
  i_profile.rtp_force_relay_cn=i_vendor_gw.rtp_force_relay_cn OR i_customer_gw.rtp_force_relay_cn;
  i_profile.patch_ruri_next_hop=i_vendor_gw.resolve_ruri;

  i_profile.aleg_sensor_id=i_customer_gw.sensor_id;
  i_profile.aleg_sensor_level_id=i_customer_gw.sensor_level_id;
  i_profile.bleg_sensor_id=i_vendor_gw.sensor_id;
  i_profile.bleg_sensor_level_id=i_vendor_gw.sensor_level_id;

  i_profile.aleg_dtmf_send_mode_id=i_customer_gw.dtmf_send_mode_id;
  i_profile.aleg_dtmf_recv_modes=i_customer_gw.dtmf_receive_mode_id;
  i_profile.bleg_dtmf_send_mode_id=i_vendor_gw.dtmf_send_mode_id;
  i_profile.bleg_dtmf_recv_modes=i_vendor_gw.dtmf_receive_mode_id;


  i_profile.aleg_rtp_filter_inband_dtmf=false;
  i_profile.bleg_rtp_filter_inband_dtmf=false;

  if i_customer_gw.rx_inband_dtmf_filtering_mode_id=3 then -- enable filtering
    i_profile.aleg_rtp_filter_inband_dtmf=true;
  elsif i_customer_gw.rx_inband_dtmf_filtering_mode_id=1 then -- inherit
    if i_vendor_gw.tx_inband_dtmf_filtering_mode_id in (1,2) then  -- inherit or disable filtering
      i_profile.aleg_rtp_filter_inband_dtmf=false;
    elsif i_vendor_gw.tx_inband_dtmf_filtering_mode_id = 3 then -- enable filtering
      i_profile.aleg_rtp_filter_inband_dtmf=true;
    end if;
  end if;


  if i_vendor_gw.rx_inband_dtmf_filtering_mode_id=3 then -- enable filtering
    i_profile.bleg_rtp_filter_inband_dtmf=true;
  elsif i_vendor_gw.rx_inband_dtmf_filtering_mode_id=1 then -- inherit
    if i_customer_gw.tx_inband_dtmf_filtering_mode_id in (1,2) then  -- inherit or disable filtering
      i_profile.bleg_rtp_filter_inband_dtmf=false;
    elsif i_customer_gw.tx_inband_dtmf_filtering_mode_id = 3 then -- enable filtering
      i_profile.bleg_rtp_filter_inband_dtmf=true;
    end if;
  end if;

  i_profile.aleg_rtp_acl = i_customer_gw.rtp_acl;
  i_profile.bleg_rtp_acl = i_vendor_gw.rtp_acl;

  i_profile.rtprelay_force_dtmf_relay=i_vendor_gw.force_dtmf_relay;
  i_profile.rtprelay_dtmf_detection=NOT i_vendor_gw.force_dtmf_relay;
  i_profile.rtprelay_dtmf_filtering=NOT i_vendor_gw.force_dtmf_relay;
  i_profile.bleg_max_30x_redirects = i_vendor_gw.max_30x_redirects;
  i_profile.bleg_max_transfers = i_vendor_gw.max_transfers;


  i_profile.aleg_relay_update=i_customer_gw.relay_update;
  i_profile.bleg_relay_update=i_vendor_gw.relay_update;
  i_profile.suppress_early_media=i_customer_gw.suppress_early_media OR i_vendor_gw.suppress_early_media;

  i_profile.bleg_radius_acc_profile_id=i_vendor_gw.radius_accounting_profile_id;
  i_profile.bleg_force_cancel_routeset=i_vendor_gw.force_cancel_routeset;

  /*dbg{*/
  v_end:=clock_timestamp();
  RAISE NOTICE '% ms -> DP. Finished: % ',EXTRACT(MILLISECOND from v_end-v_start),row_to_json(i_profile,true);
  /*}dbg*/
  RETURN i_profile;
END;
$_$;


DROP FUNCTION switch22.process_dp_debug(i_profile switch22.callprofile_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_pop_id integer, i_send_billing_information boolean, i_max_call_length integer, i_diversion character varying[], i_privacy character varying[], i_pai character varying[], i_ppi character varying);
DROP FUNCTION switch22.process_dp_release(i_profile switch22.callprofile_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_pop_id integer, i_send_billing_information boolean, i_max_call_length integer, i_diversion character varying[], i_privacy character varying[], i_pai character varying[], i_ppi character varying);
DROP FUNCTION switch22.process_dp(i_profile switch22.callprofile_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_pop_id integer, i_send_billing_information boolean, i_max_call_length integer, i_diversion character varying[], i_privacy character varying[], i_pai character varying[], i_ppi character varying);

CREATE FUNCTION switch22.process_dp(i_profile switch22.callprofile_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_pop_id integer, i_send_billing_information boolean, i_max_call_length integer, i_diversion switch22.uri_ty[], i_privacy character varying[], i_pai switch22.uri_ty[], i_ppi switch22.uri_ty) RETURNS SETOF switch22.callprofile_ty
    LANGUAGE plpgsql STABLE SECURITY DEFINER COST 10000
    AS $$
DECLARE
  /*dbg{*/
  v_start timestamp;
  v_end timestamp;
  /*}dbg*/
  v_gw class4.gateways%rowtype;
  v_gateway_group class4.gateway_groups%rowtype;
BEGIN
  /*dbg{*/
  v_start:=now();
  --RAISE NOTICE 'process_dp in: %',i_profile;5
  v_end:=clock_timestamp();
  RAISE NOTICE '% ms -> process-DP. Found dialpeer: %',EXTRACT(MILLISECOND from v_end-v_start),row_to_json(i_dp,true);
  /*}dbg*/

  --RAISE NOTICE 'process_dp dst: %',i_destination;
  if i_dp.gateway_id is null then /* termination to gw group */
    select into v_gateway_group * from  class4.gateway_groups where id=i_dp.gateway_group_id;
    IF v_gateway_group.balancing_mode_id=2 THEN
      /*rel{*/
      FOR v_gw in
        select * from class4.gateways cg
        where
          cg.gateway_group_id=i_dp.gateway_group_id and
          cg.contractor_id=i_dp.vendor_id and
          cg.enabled
        ORDER BY
          cg.pop_id=i_pop_id desc,
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
        LOOP
        return query select * from process_gw_release(i_profile, i_destination, i_dp, i_customer_acc,
                                                      i_customer_gw, i_vendor_acc , v_gw, i_send_billing_information, i_max_call_length,
                                                      i_diversion, i_privacy, i_pai, i_ppi);
      end loop;
      /*}rel*/
      /*dbg{*/
      FOR v_gw in
        select * from class4.gateways cg
        where
          cg.gateway_group_id=i_dp.gateway_group_id AND
          cg.enabled
        ORDER BY
          cg.pop_id=i_pop_id desc,
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
      LOOP
        IF v_gw.contractor_id!=i_dp.vendor_id THEN
          RAISE WARNING 'process_dp: Gateway owner !=dialpeer owner. Skip gateway';
          continue;
        end if;
        return query select * from process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc,
                                                    i_customer_gw, i_vendor_acc , v_gw, i_send_billing_information, i_max_call_length,
                                                    i_diversion, i_privacy, i_pai, i_ppi);
      end loop;
      /*}dbg*/
    elsif v_gateway_group.balancing_mode_id=1 then
      /*rel{*/
      FOR v_gw in
        select * from class4.gateways cg
        where
          cg.gateway_group_id=i_dp.gateway_group_id AND
          cg.contractor_id=i_dp.vendor_id AND
          cg.enabled
        ORDER BY
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
      LOOP
        return query select * from process_gw_release(i_profile, i_destination, i_dp, i_customer_acc,
                                                      i_customer_gw, i_vendor_acc , v_gw, i_send_billing_information, i_max_call_length,
                                                      i_diversion, i_privacy, i_pai, i_ppi);
      end loop;
      /*}rel*/
      /*dbg{*/
      FOR v_gw in
        select * from class4.gateways cg
        where
          cg.gateway_group_id=i_dp.gateway_group_id and
          cg.enabled
        ORDER BY
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
      LOOP
        IF v_gw.contractor_id!=i_dp.vendor_id AND NOT v_gw.is_shared THEN
          RAISE WARNING 'process_dp: Gateway owner !=dialpeer owner. Skip gateway';
          continue;
        end if;
        return query select * from process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc,
                                                    i_customer_gw, i_vendor_acc , v_gw, i_send_billing_information, i_max_call_length,
                                                    i_diversion, i_privacy, i_pai, i_ppi);
      end loop;
      /*}dbg*/

    elsif v_gateway_group.balancing_mode_id=3 THEN
      /*rel{*/
      FOR v_gw in
        select * from class4.gateways cg
        where
	  (cg.pop_id is null OR cg.pop_id=i_pop_id) and
          cg.gateway_group_id=i_dp.gateway_group_id and
          cg.contractor_id=i_dp.vendor_id and
          cg.enabled
        ORDER BY
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
        LOOP
        return query select * from process_gw_release(i_profile, i_destination, i_dp, i_customer_acc,
                                                      i_customer_gw, i_vendor_acc , v_gw, i_send_billing_information, i_max_call_length, i_diversion, i_privacy, i_pai, i_ppi);
      end loop;
      /*}rel*/
      /*dbg{*/
      FOR v_gw in
        select * from class4.gateways cg
        where
          cg.gateway_group_id=i_dp.gateway_group_id AND
          cg.enabled
        ORDER BY
          cg.pop_id=i_pop_id desc,
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
      LOOP
	IF v_gw.pop_id is not null and v_gw.pop_id!=i_pop_id THEN
          RAISE WARNING 'process_dp: Gateway POP is %, call pop %, skipping.',v_gw.pop_id, i_pop_id;
          continue;
        end if;
        IF v_gw.contractor_id!=i_dp.vendor_id THEN
          RAISE WARNING 'process_dp: Gateway owner !=dialpeer owner. Skip gateway';
          continue;
        end if;
        return query select * from process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc,
                                                    i_customer_gw, i_vendor_acc , v_gw, i_send_billing_information, i_max_call_length, i_diversion, i_privacy, i_pai, i_ppi);
      end loop;
      /*}dbg*/
    end if;
  else
    select into v_gw * from class4.gateways cg where cg.id=i_dp.gateway_id and cg.enabled;
    if FOUND THEN
      IF v_gw.contractor_id!=i_dp.vendor_id AND NOT v_gw.is_shared THEN
        RAISE WARNING 'process_dp: Gateway owner !=dialpeer owner. Stop processing';
        return;
      end if;

      /*rel{*/
      return query select * from
          process_gw_release(i_profile, i_destination, i_dp, i_customer_acc,i_customer_gw, i_vendor_acc, v_gw, i_send_billing_information, i_max_call_length, i_diversion, i_privacy, i_pai, i_ppi);
      /*}rel*/
      /*dbg{*/
      return query select * from
          process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc,i_customer_gw, i_vendor_acc, v_gw, i_send_billing_information, i_max_call_length, i_diversion, i_privacy, i_pai, i_ppi);
      /*}dbg*/
    else
      return;
    end if;
  end if;
END;
$$;

      set search_path TO switch22;
      SELECT * from switch22.preprocess_all();
      set search_path TO gui, public, switch, billing, class4, runtime_stats, sys, logs, data_import;

    }
  end

  def down
    execute %q{

      alter table class4.customers_auth drop column pai_policy_id;
      alter table class4.customers_auth_normalized drop column pai_policy_id;

      create table class4.diversion_policy (
        id integer primary key,
        name varchar not null unique
      );

      insert into class4.diversion_policy(id,name) values (1,'Do not accept');
      insert into class4.diversion_policy(id,name) values (2,'Accept');

      alter table class4.customers_auth alter column diversion_policy_id type integer;
      alter table class4.customers_auth_normalized alter column diversion_policy_id type integer;

      alter table class4.customers_auth add CONSTRAINT "customers_auth_diversion_policy_id_fkey" FOREIGN KEY (diversion_policy_id) REFERENCES class4.diversion_policy(id);

    }
  end

end
