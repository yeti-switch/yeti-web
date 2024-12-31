class DstSubscriberCapacityLimit < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      insert into class4.disconnect_code (id, namespace_id, code, reason) values (1513, 1, 480,  'Subscriber capacity limit');
      INSERT INTO switch22.resource_type (id, name, internal_code_id, action_id) VALUES (8, 'Subscriber capacity limit', 1513, 2);

      alter table class4.gateways add termination_subscriber_capacity smallint;

CREATE OR REPLACE FUNCTION switch22.process_gw(i_profile switch22.callprofile_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_vendor_gw class4.gateways, i_send_billing_information boolean, i_max_call_length integer, i_diversion switch22.uri_ty[], i_privacy character varying[], i_pai switch22.uri_ty[], i_ppi switch22.uri_ty) RETURNS switch22.callprofile_ty
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

  -- apply capacity limit by destination number
  if i_vendor_gw.termination_subscriber_capacity is not null then
    i_profile.legb_res = i_profile.legb_res||'8:'||i_vendor_gw.id||'_'||translate(i_profile.dst_prefix_out,': #@', '____')||':'||i_vendor_gw.termination_subscriber_capacity||':1;';
  end if;

  IF cardinality(i_diversion) > 0 AND i_vendor_gw.diversion_send_mode_id > 1 THEN
    IF i_vendor_gw.diversion_send_mode_id = 2 AND i_vendor_gw.diversion_domain is not null AND i_vendor_gw.diversion_domain!='' THEN
      /* Diversion as SIP URI */
      FOREACH v_diversion_header IN ARRAY i_diversion LOOP
        v_diversion_header.u = yeti_ext.regexp_replace_rand(v_diversion_header.u, i_vendor_gw.diversion_rewrite_rule, i_vendor_gw.diversion_rewrite_result);
        v_diversion_header.s = 'sip';
        v_diversion_header.h = i_vendor_gw.diversion_domain;
        v_bleg_append_headers_req = array_append(
          v_bleg_append_headers_req,
          'Diversion: '||switch22.build_uri(false, v_diversion_header)
        );
      END LOOP;
    ELSIF i_vendor_gw.diversion_send_mode_id = 3 THEN
      /* Diversion as TEL URI */
      FOREACH v_diversion_header IN ARRAY i_diversion LOOP
        v_diversion_header.u = yeti_ext.regexp_replace_rand(v_diversion_header.u, i_vendor_gw.diversion_rewrite_rule, i_vendor_gw.diversion_rewrite_result);
        v_diversion_header.s = 'tel';
        v_bleg_append_headers_req=array_append(
          v_bleg_append_headers_req,
          'Diversion: '||switch22.build_uri(false, v_diversion_header)
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
        i_ppi.h = COALESCE(i_ppi.h, i_vendor_gw.pai_domain);
        v_bleg_append_headers_req = array_append(v_bleg_append_headers_req, format('P-Preferred-Identity: %s', switch22.build_uri(false, i_ppi))::varchar);
      END IF;
    ELSIF i_vendor_gw.pai_send_mode_id = 7 THEN
      -- relay with conversion to SIP URI. Force replace domain
      FOREACH v_pai IN ARRAY i_pai LOOP
        v_pai.s = 'sip';
        v_pai.h = i_vendor_gw.pai_domain;
        v_bleg_append_headers_req = array_append(v_bleg_append_headers_req, format('P-Asserted-Identity: %s', switch22.build_uri(false, v_pai))::varchar);
      END LOOP;
      IF i_ppi.u is not null THEN
        i_ppi.s = 'sip';
        i_ppi.h = i_vendor_gw.pai_domain;
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

      set search_path TO switch22;
      SELECT * from switch22.preprocess_all();
      set search_path TO gui, public, switch, billing, class4, runtime_stats, sys, logs, data_import;


    }
  end

  def down
    execute %q{

CREATE OR REPLACE FUNCTION switch22.process_gw(i_profile switch22.callprofile_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_vendor_gw class4.gateways, i_send_billing_information boolean, i_max_call_length integer, i_diversion switch22.uri_ty[], i_privacy character varying[], i_pai switch22.uri_ty[], i_ppi switch22.uri_ty) RETURNS switch22.callprofile_ty
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
        v_diversion_header.s = 'sip';
        v_diversion_header.h = i_vendor_gw.diversion_domain;
        v_bleg_append_headers_req = array_append(
          v_bleg_append_headers_req,
          'Diversion: '||switch22.build_uri(false, v_diversion_header)
        );
      END LOOP;
    ELSIF i_vendor_gw.diversion_send_mode_id = 3 THEN
      /* Diversion as TEL URI */
      FOREACH v_diversion_header IN ARRAY i_diversion LOOP
        v_diversion_header.u = yeti_ext.regexp_replace_rand(v_diversion_header.u, i_vendor_gw.diversion_rewrite_rule, i_vendor_gw.diversion_rewrite_result);
        v_diversion_header.s = 'tel';
        v_bleg_append_headers_req=array_append(
          v_bleg_append_headers_req,
          'Diversion: '||switch22.build_uri(false, v_diversion_header)
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
        i_ppi.h = COALESCE(i_ppi.h, i_vendor_gw.pai_domain);
        v_bleg_append_headers_req = array_append(v_bleg_append_headers_req, format('P-Preferred-Identity: %s', switch22.build_uri(false, i_ppi))::varchar);
      END IF;
    ELSIF i_vendor_gw.pai_send_mode_id = 7 THEN
      -- relay with conversion to SIP URI. Force replace domain
      FOREACH v_pai IN ARRAY i_pai LOOP
        v_pai.s = 'sip';
        v_pai.h = i_vendor_gw.pai_domain;
        v_bleg_append_headers_req = array_append(v_bleg_append_headers_req, format('P-Asserted-Identity: %s', switch22.build_uri(false, v_pai))::varchar);
      END LOOP;
      IF i_ppi.u is not null THEN
        i_ppi.s = 'sip';
        i_ppi.h = i_vendor_gw.pai_domain;
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

      set search_path TO switch22;
      SELECT * from switch22.preprocess_all();
      set search_path TO gui, public, switch, billing, class4, runtime_stats, sys, logs, data_import;


      delete from class4.disconnect_code where id = 1513;
      delete from switch22.resource_type where id = 8;

      alter table class4.gateways drop column termination_subscriber_capacity;



    }
  end
end
