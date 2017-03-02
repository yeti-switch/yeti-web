begin;
insert into sys.version(number,comment) values(72,'Fix Disconnect codes loading');

set search_path TO switch9;

CREATE OR REPLACE FUNCTION switch9.load_disconnect_code_refuse()
  RETURNS TABLE(o_id integer, o_code integer, o_reason character varying, o_rewrited_code integer, o_rewrited_reason character varying, o_store_cdr boolean, o_silently_drop boolean) AS
$BODY$
BEGIN
    RETURN
    QUERY SELECT id,code,reason,rewrited_code,rewrited_reason,store_cdr,silently_drop
    from class4.disconnect_code
    where namespace_id=0 or namespace_id=1 OR namespace_id=3 /* radius */
    order by id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 10
  ROWS 1000;



CREATE OR REPLACE FUNCTION switch9.route(i_node_id integer, i_pop_id integer, i_remote_ip inet, i_remote_port integer, i_local_ip inet, i_local_port integer, i_from_dsp character varying, i_from_name character varying, i_from_domain character varying, i_from_port integer, i_to_name character varying, i_to_domain character varying, i_to_port integer, i_contact_name character varying, i_contact_domain character varying, i_contact_port integer, i_uri_name character varying, i_uri_domain character varying, i_x_yeti_auth character varying, i_diversion character varying, i_x_orig_ip inet, i_x_orig_port integer) RETURNS SETOF callprofile45_ty
LANGUAGE plpgsql SECURITY DEFINER ROWS 10
AS $$
DECLARE
  v_ret switch9.callprofile45_ty;
  i integer;
  v_ip inet;
  v_remote_ip inet;
  v_remote_port INTEGER;
  v_customer_auth class4.customers_auth%rowtype;
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
  routedata record;
  /*dbg{*/
  v_start timestamp;
  v_end timestamp;
  /*}dbg*/
  v_rate NUMERIC;
  v_now timestamp;
  v_x_yeti_auth varchar;
  v_uri_domain varchar;
  v_rate_limit float:='Infinity';
  v_test_vendor_id integer;
  v_random float;
  v_max_call_length integer;
  v_routing_key varchar;
  v_lnp_key varchar;
  v_drop_call_if_lnp_fail boolean;
  v_lnp_rule class4.routing_plan_lnp_rules%rowtype;
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
  v_ret:=switch9.new_profile();
  v_ret.cache_time = 10;

  v_ret.diversion_in:=i_diversion;
  v_ret.diversion_out:=i_diversion; -- FIXME

  v_ret.auth_orig_ip = v_remote_ip;
  v_ret.auth_orig_port = v_remote_port;

  v_ret.src_name_in:=i_from_dsp;
  v_ret.src_name_out:=v_ret.src_name_in;

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
  SELECT into v_customer_auth ca.*
  from class4.customers_auth ca
    JOIN public.contractors c ON c.id=ca.customer_id
  WHERE ca.enabled AND
        ca.ip>>=v_remote_ip AND
                prefix_range(ca.dst_prefix)@>prefix_range(v_ret.dst_prefix_in) AND
                prefix_range(ca.src_prefix)@>prefix_range(v_ret.src_prefix_in) AND
                (ca.pop_id=i_pop_id or ca.pop_id is null) and
                COALESCE(ca.x_yeti_auth,'')=v_x_yeti_auth AND
                COALESCE(nullif(ca.uri_domain,'')=v_uri_domain,true) AND
                c.enabled
                and c.customer
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

  /*dbg{*/
  v_end:=clock_timestamp();
  RAISE NOTICE '% ms -> AUTH. found: %',EXTRACT(MILLISECOND from v_end-v_start),hstore(v_customer_auth);
  /*}dbg*/

  -- feel customer data
  v_ret.dump_level_id:=v_customer_auth.dump_level_id;
  v_ret.customer_auth_id:=v_customer_auth.id;
  v_ret.customer_id:=v_customer_auth.customer_id;
  v_ret.rateplan_id:=v_customer_auth.rateplan_id;
  v_ret.routing_plan_id:=v_customer_auth.routing_plan_id;
  v_ret.customer_acc_id:=v_customer_auth.account_id;
  v_ret.orig_gw_id:=v_customer_auth.gateway_id;
  v_ret.radius_auth_profile_id=v_customer_auth.radius_auth_profile_id;

  SELECT INTO STRICT v_c_acc * FROM billing.accounts  WHERE id=v_customer_auth.account_id;
  if v_c_acc.balance<=v_c_acc.min_balance then
    v_ret.disconnect_code_id=8000; --No enought customer balance
    RETURN NEXT v_ret;
    RETURN;
  end if;

  SELECT into v_orig_gw * from class4.gateways WHERE id=v_customer_auth.gateway_id;
  v_ret.resources:='';
  if v_c_acc.origination_capacity is not null then
    v_ret.resources:=v_ret.resources||'1:'||v_c_acc.id::varchar||':'||v_c_acc.origination_capacity::varchar||':1;';
  end if;
  if v_customer_auth.capacity is not null then
    v_ret.resources:=v_ret.resources||'3:'||v_customer_auth.id::varchar||':'||v_customer_auth.capacity::varchar||':1;';
  end if;
  if v_orig_gw.origination_capacity is not null then
    v_ret.resources:=v_ret.resources||'4:'||v_orig_gw.id::varchar||':'||v_orig_gw.origination_capacity::varchar||':1;';
  end if;

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

  IF (v_customer_auth.src_name_rewrite_rule IS NOT NULL AND v_customer_auth.src_name_rewrite_rule!='') THEN
    v_ret.src_name_out=regexp_replace(v_ret.src_name_out,v_customer_auth.src_name_rewrite_rule,v_customer_auth.src_name_rewrite_result);
  END IF;

  --  setting numbers used for routing & billing
  v_ret.src_prefix_routing=v_ret.src_prefix_out;
  v_ret.dst_prefix_routing=v_ret.dst_prefix_out;
  v_routing_key=v_ret.dst_prefix_out;


  /*dbg{*/
  v_end:=clock_timestamp();
  RAISE NOTICE '% ms -> AUTH. After rewrite src_prefix: % , dst_prefix: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.src_prefix_out,v_ret.dst_prefix_out;
  /*}dbg*/


  --- Blacklist processing
  if v_customer_auth.dst_blacklist_id is not null then
    perform * from class4.blacklist_items bl
    where bl.blacklist_id=v_customer_auth.dst_blacklist_id and bl.key=v_ret.dst_prefix_out;
    IF FOUND then
      v_ret.disconnect_code_id=8001; --destination blacklisted
      RETURN NEXT v_ret;
      RETURN;
    end if;
  end if;
  if v_customer_auth.src_blacklist_id is not null then
    perform * from class4.blacklist_items bl
    where bl.blacklist_id=v_customer_auth.src_blacklist_id and bl.key=v_ret.src_prefix_out;
    IF FOUND then
      v_ret.disconnect_code_id=8002; --source blacklisted
      RETURN NEXT v_ret;
      RETURN;
    end if;
  end if;

  /*dbg{*/
  v_end:=clock_timestamp();
  RAISE NOTICE '% ms -> Routing plan search start',EXTRACT(MILLISECOND from v_end-v_start);
  /*}dbg*/

  select into v_max_call_length,v_drop_call_if_lnp_fail max_call_duration,drop_call_if_lnp_fail from sys.guiconfig limit 1;

  v_routing_key=v_ret.dst_prefix_routing;
  SELECT INTO v_rp * from class4.routing_plans WHERE id=v_customer_auth.routing_plan_id;
  if v_rp.use_lnp then
    select into v_lnp_rule rules.*
    from class4.routing_plan_lnp_rules rules
    WHERE prefix_range(rules.dst_prefix)@>prefix_range(v_ret.dst_prefix_routing) and rules.routing_plan_id=v_rp.id
    order by length(rules.dst_prefix) limit 1;
    if found then
      v_ret.lnp_database_id=v_lnp_rule.database_id;
      v_lnp_key=v_ret.dst_prefix_routing;
      /*dbg{*/
      v_end:=clock_timestamp();
      RAISE NOTICE '% ms -> LNP. Need LNP lookup, LNP key: %',EXTRACT(MILLISECOND from v_end-v_start),v_lnp_key;
      /*}dbg*/
      IF (v_lnp_rule.req_dst_rewrite_rule IS NOT NULL AND v_lnp_rule.req_dst_rewrite_rule!='') THEN
        v_lnp_key=regexp_replace(v_lnp_key,v_lnp_rule.req_dst_rewrite_rule,v_lnp_rule.req_dst_rewrite_result);
        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> LNP key translation. LNP key: %',EXTRACT(MILLISECOND from v_end-v_start),v_lnp_key;
        /*}dbg*/
      END IF;
      -- try cache
      select into v_ret.lrn lrn from class4.lnp_cache where dst=v_lnp_key AND database_id=v_lnp_rule.database_id and expires_at>v_now;
      if found then
        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> LNP. Data found in cache, lrn: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.lrn;
        /*}dbg*/
        -- TRANSLATING response from cache
        IF (v_lnp_rule.lrn_rewrite_rule IS NOT NULL AND v_lnp_rule.lrn_rewrite_rule!='') THEN
          v_ret.lrn=regexp_replace(v_ret.lrn,v_lnp_rule.lrn_rewrite_rule,v_lnp_rule.lrn_rewrite_result);
        END IF;
        /*dbg{*/
        v_end:=clock_timestamp();
        RAISE NOTICE '% ms -> LNP. Translation. lrn: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.lrn;
        /*}dbg*/
        v_routing_key=v_ret.lrn;
      else
        v_ret.lrn=switch9.lnp_resolve(v_ret.lnp_database_id,v_lnp_key);
        if v_ret.lrn is null then -- fail
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> LNP. Query failed',EXTRACT(MILLISECOND from v_end-v_start);
          /*}dbg*/
          if v_drop_call_if_lnp_fail then
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
          IF (v_lnp_rule.lrn_rewrite_rule IS NOT NULL AND v_lnp_rule.lrn_rewrite_rule!='') THEN
            v_ret.lrn=regexp_replace(v_ret.lrn,v_lnp_rule.lrn_rewrite_rule,v_lnp_rule.lrn_rewrite_result);
          END IF;
          /*dbg{*/
          v_end:=clock_timestamp();
          RAISE NOTICE '% ms -> LNP. Translation. lrn: %',EXTRACT(MILLISECOND from v_end-v_start),v_ret.lrn;
          /*}dbg*/
          v_routing_key=v_ret.lrn;
        end if;
      end if;
    end if;
  end if;


  /*dbg{*/
  v_end:=clock_timestamp();
  RAISE NOTICE '% ms -> DST. search start. Routing key: %',EXTRACT(MILLISECOND from v_end-v_start), v_routing_key;
  /*}dbg*/
  v_network:=switch9.detect_network(v_ret.dst_prefix_routing);
  v_ret.dst_network_id=v_network.network_id;
  v_ret.dst_country_id=v_network.country_id;

  SELECT into v_destination d.*/*,switch.tracelog(d.*)*/ from class4.destinations d
  WHERE
    prefix_range(prefix)@>prefix_range(v_routing_key)
    AND rateplan_id=v_customer_auth.rateplan_id
    AND enabled
    AND valid_from <= v_now
    AND valid_till >= v_now
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
  v_ret.destination_prefix=v_destination.prefix;
  v_ret.destination_initial_interval:=v_destination.initial_interval;
  v_ret.destination_fee:=v_destination.connect_fee::varchar;
  v_ret.destination_next_interval:=v_destination.next_interval;
  v_ret.destination_rate_policy_id:=v_destination.rate_policy_id;
  IF v_destination.reject_calls THEN
    v_ret.disconnect_code_id=112; --Rejected by destination
    RETURN NEXT v_ret;
    RETURN;
  END IF;
  select into v_rateplan * from class4.rateplans where id=v_customer_auth.rateplan_id;
  if COALESCE(v_destination.profit_control_mode_id,v_rateplan.profit_control_mode_id)=2 then -- per call
    v_rate_limit=v_destination.next_rate::float;
  end if;


  /*
              FIND dialpeers logic. Queries must use prefix index for best performance
  */
  /*dbg{*/
  v_end:=clock_timestamp();
  RAISE NOTICE '% ms -> DP. search start. Routing key: %. Rate limit: %',EXTRACT(MILLISECOND from v_end-v_start), v_routing_key, v_rate_limit;
  /*}dbg*/
  CASE v_rp.sorting_id
    WHEN'1' THEN -- LCR,Prio, ACD&ASR control
    FOR routedata IN (
      WITH step1 AS(
          SELECT
            (t_dp.*)::class4.dialpeers as s1_dialpeer,
            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
            t_dp.next_rate as dp_next_rate,
            t_dp.lcr_rate_multiplier AS dp_lcr_rate_multiplier,
            t_dp.priority AS dp_priority,
            t_dp.locked as dp_locked,
            t_dp.enabled as dp_enabled,
            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r
          FROM class4.dialpeers t_dp
            JOIN billing.accounts t_vendor_account ON t_dp.account_id = t_vendor_account.id
            JOIN class4.routing_plan_groups t_rpg ON t_dp.routing_group_id=t_rpg.routing_group_id
          WHERE
            prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
            AND t_rpg.routing_plan_id=v_customer_auth.routing_plan_id
            and t_dp.valid_from<=v_now
            and t_dp.valid_till>=v_now
            AND t_vendor_account.balance<t_vendor_account.max_balance
      )
      SELECT s1_dialpeer as s2_dialpeer,
             s1_vendor_account as s2_vendor_account
      from step1
      WHERE
        r=1
        AND dp_next_rate<v_rate_limit
        AND dp_enabled
        and not dp_locked --ACD&ASR control for DP
      ORDER BY dp_next_rate*dp_lcr_rate_multiplier, dp_priority DESC limit 10
    ) LOOP
      RETURN QUERY
      /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth.send_billing_information,v_max_call_length);/*}rel*/
      /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth.send_billing_information,v_max_call_length);/*}dbg*/
    end LOOP;
    WHEN '2' THEN --LCR, no prio, No ACD&ASR control
    FOR routedata IN (
      WITH step1 AS( -- filtering
          SELECT
            (t_dp.*)::class4.dialpeers as s1_dialpeer,
            --  (t_vendor_gateway.*)::class4.gateways as s1_vendor_gateway,
            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r,
            t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric,
            t_dp.next_rate as dp_next_rate,
            t_dp.enabled as dp_enabled
          FROM class4.dialpeers t_dp
            JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
            JOIN class4.routing_plan_groups t_rpg ON t_dp.routing_group_id=t_rpg.routing_group_id
          WHERE
            prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
            AND t_rpg.routing_plan_id=v_customer_auth.routing_plan_id
            and t_dp.valid_from<=v_now
            and t_dp.valid_till>=v_now
            AND t_vendor_account.balance<t_vendor_account.max_balance
      )
      SELECT s1_dialpeer as s2_dialpeer,
             s1_vendor_account as s2_vendor_account
      FROM step1
      WHERE
        r=1
        AND dp_enabled
        and dp_next_rate<v_rate_limit
      ORDER BY dp_metric limit 10
    ) LOOP
      RETURN QUERY
      /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth.send_billing_information,v_max_call_length);/*}rel*/
      /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth.send_billing_information,v_max_call_length);/*}dbg*/
    END LOOP;
    WHEN '3' THEN --Prio, LCR, ACD&ASR control
    FOR routedata in(
      WITH step1 AS( -- filtering
          SELECT
            (t_dp.*)::class4.dialpeers as s1_dialpeer,
            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r,
            t_dp.priority as dp_metric_priority,
            t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric,
            t_dp.next_rate as dp_next_rate,
            t_dp.locked as dp_locked,
            t_dp.enabled as dp_enabled
          FROM class4.dialpeers t_dp
            JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
            JOIN class4.routing_plan_groups t_rpg ON t_dp.routing_group_id=t_rpg.routing_group_id
          WHERE
            prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
            AND t_rpg.routing_plan_id=v_customer_auth.routing_plan_id
            and t_dp.valid_from<=v_now
            and t_dp.valid_till>=v_now
            AND t_vendor_account.balance<t_vendor_account.max_balance
      )
      SELECT s1_dialpeer as s2_dialpeer,
             s1_vendor_account as s2_vendor_account
      FROM step1
      WHERE
        r=1
        and dp_next_rate<v_rate_limit
        and dp_enabled
        and not dp_locked
      ORDER BY dp_metric_priority DESC, dp_metric limit 10
    )LOOP
      RETURN QUERY
      /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth.send_billing_information,v_max_call_length);/*}rel*/
      /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth.send_billing_information,v_max_call_length);/*}dbg*/
    END LOOP;
    WHEN'4' THEN -- LCRD, Prio, ACD&ACR control
    FOR routedata IN (
      WITH step1 AS(
          SELECT
            (t_dp.*)::class4.dialpeers as s1_dialpeer,
            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r,
            ((t_dp.next_rate - first_value(t_dp.next_rate) OVER(ORDER BY t_dp.next_rate ASC)) > v_rp.rate_delta_max)::INTEGER *(t_dp.next_rate + t_dp.priority) - t_dp.priority AS r2,
            t_dp.next_rate as dp_next_rate,
            t_dp.locked as dp_locked,
            t_dp.enabled as dp_enabled
          FROM class4.dialpeers t_dp
            JOIN billing.accounts t_vendor_account ON t_dp.account_id = t_vendor_account.id
            JOIN class4.routing_plan_groups t_rpg ON t_dp.routing_group_id=t_rpg.routing_group_id
          WHERE
            prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
            AND t_rpg.routing_plan_id=v_customer_auth.routing_plan_id
            and t_dp.valid_from<=v_now
            and t_dp.valid_till>=v_now
            AND t_vendor_account.balance<t_vendor_account.max_balance
      )
      SELECT s1_dialpeer as s2_dialpeer,
             s1_vendor_account as s2_vendor_account
      from step1
      WHERE
        r=1
        and dp_next_rate < v_rate_limit
        and dp_enabled
        and not dp_locked --ACD&ASR control for DP
      ORDER BY r2 ASC limit 10
    ) LOOP
      RETURN QUERY
      /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth.send_billing_information,v_max_call_length);/*}rel*/
      /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth.send_billing_information,v_max_call_length);/*}dbg*/
    end LOOP;
    WHEN'5' THEN -- Route test
    v_test_vendor_id=regexp_replace(v_routing_key,'(.*)\*(.*)','\1')::integer;
    v_routing_key=regexp_replace(v_routing_key,'(.*)\*(.*)','\2');
    v_ret.dst_prefix_out=v_routing_key;
    -- cheat( Prefix changed by regexp, we need recalculate destination)
    v_network:=switch9.detect_network(v_routing_key);
    v_ret.dst_network_id=v_network.network_id;
    v_ret.dst_country_id=v_network.country_id;
    FOR routedata IN (
      WITH step1 AS( -- filtering
          SELECT
            (t_dp.*)::class4.dialpeers as s1_dialpeer,
            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r,
            t_dp.priority as dp_metric_priority,
            t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric,
            t_dp.next_rate as dp_next_rate,
            t_dp.enabled as dp_enabled
          FROM class4.dialpeers t_dp
            JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
            JOIN class4.routing_plan_groups t_rpg ON t_dp.routing_group_id=t_rpg.routing_group_id
          WHERE
            prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
            AND t_rpg.routing_plan_id=v_customer_auth.routing_plan_id
            and t_dp.valid_from<=v_now
            and t_dp.valid_till>=v_now
            AND t_vendor_account.balance<t_vendor_account.max_balance
            and t_dp.vendor_id=v_test_vendor_id
      )
      SELECT s1_dialpeer as s2_dialpeer,
             s1_vendor_account as s2_vendor_account
      FROM step1
      WHERE
        r=1
        and dp_enabled
        and dp_next_rate<v_rate_limit
      ORDER BY dp_metric_priority DESC, dp_metric limit 10
    )LOOP
      RETURN QUERY
      /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth.send_billing_information,v_max_call_length);/*}rel*/
      /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth.send_billing_information,v_max_call_length);/*}dbg*/
    END LOOP;
    WHEN'6' THEN -- QD.Static,LCR,ACD&ACR control
    v_random:=random();
    FOR routedata in(
      WITH step1 AS( -- filtering
          SELECT
            (t_dp.*)::class4.dialpeers as s1_dialpeer,
            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r,
            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(coalesce(rpsr.prefix,'')) desc) as r2,
            t_dp.priority as dp_metric_priority,
            t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric,
            t_dp.next_rate as dp_next_rate,
            t_dp.locked as dp_locked,
            t_dp.enabled as dp_enabled,
            t_dp.force_hit_rate as dp_force_hit_rate,
            rpsr.priority as rpsr_priority
          FROM class4.dialpeers t_dp
            JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
            JOIN class4.routing_plan_groups t_rpg ON t_dp.routing_group_id=t_rpg.routing_group_id
            left join class4.routing_plan_static_routes rpsr
              ON rpsr.routing_plan_id=v_customer_auth.routing_plan_id
                 and rpsr.vendor_id=t_dp.vendor_id
                 AND prefix_range(rpsr.prefix)@>prefix_range(v_routing_key)
          WHERE
            prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
            AND t_rpg.routing_plan_id=v_customer_auth.routing_plan_id
            and t_dp.valid_from<=v_now
            and t_dp.valid_till>=v_now
            AND t_vendor_account.balance<t_vendor_account.max_balance
      )
      SELECT s1_dialpeer as s2_dialpeer,
             s1_vendor_account as s2_vendor_account
      FROM step1
      WHERE
        r=1
        and r2=1
        and dp_next_rate<v_rate_limit
        and dp_enabled
        and not dp_locked
      ORDER BY coalesce(v_random<=dp_force_hit_rate,false) desc, coalesce(rpsr_priority,0) DESC, dp_metric limit 10
    )LOOP
      RETURN QUERY
      /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth.send_billing_information,v_max_call_length);/*}rel*/
      /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth.send_billing_information,v_max_call_length);/*}dbg*/
    END LOOP;
    WHEN'7' THEN -- QD.Static, No ACD&ACR control
    v_random:=random();
    FOR routedata in(
      WITH step1 AS( -- filtering
          SELECT
            (t_dp.*)::class4.dialpeers as s1_dialpeer,
            (t_vendor_account.*)::billing.accounts as s1_vendor_account,
            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(t_dp.prefix) desc) as r,
            rank() OVER (PARTITION BY t_dp.vendor_id ORDER BY length(coalesce(rpsr.prefix,'')) desc) as r2,
            t_dp.priority as dp_metric_priority,
            t_dp.next_rate*t_dp.lcr_rate_multiplier as dp_metric,
            t_dp.next_rate as dp_next_rate,
            t_dp.enabled as dp_enabled,
            t_dp.force_hit_rate as dp_force_hit_rate,
            rpsr.priority as rpsr_priority
          FROM class4.dialpeers t_dp
            JOIN billing.accounts t_vendor_account ON t_dp.account_id=t_vendor_account.id
            JOIN class4.routing_plan_groups t_rpg ON t_dp.routing_group_id=t_rpg.routing_group_id
            join class4.routing_plan_static_routes rpsr
              ON rpsr.routing_plan_id=v_customer_auth.routing_plan_id
                 and rpsr.vendor_id=t_dp.vendor_id
                 AND prefix_range(rpsr.prefix)@>prefix_range(v_routing_key)
          WHERE
            prefix_range(t_dp.prefix)@>prefix_range(v_routing_key)
            AND t_rpg.routing_plan_id=v_customer_auth.routing_plan_id
            and t_dp.valid_from<=v_now
            and t_dp.valid_till>=v_now
            AND t_vendor_account.balance<t_vendor_account.max_balance
      )
      SELECT s1_dialpeer as s2_dialpeer,
             s1_vendor_account as s2_vendor_account
      FROM step1
      WHERE
        r=1
        and r2=1
        and dp_next_rate<v_rate_limit
        and dp_enabled
      ORDER BY coalesce(v_random<=dp_force_hit_rate,false) desc, rpsr_priority DESC, dp_metric limit 10
    )LOOP
      RETURN QUERY
      /*rel{*/SELECT * from process_dp_release(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth.send_billing_information,v_max_call_length);/*}rel*/
      /*dbg{*/SELECT * from process_dp_debug(v_ret,v_destination,routedata.s2_dialpeer,v_c_acc,v_orig_gw,routedata.s2_vendor_account,i_pop_id,v_customer_auth.send_billing_information,v_max_call_length);/*}dbg*/
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
$$;

SELECT * from switch9.preprocess_all();

commit;
