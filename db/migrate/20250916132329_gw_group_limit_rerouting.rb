class GwGroupLimitRerouting < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      alter table class4.gateway_groups add max_rerouting_attempts smallint not null default 10;
      alter table data_import.import_gateway_groups add max_rerouting_attempts smallint;

CREATE OR REPLACE FUNCTION switch22.process_dp(i_profile switch22.callprofile_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_call_ctx switch22.call_ctx_ty, i_diversion switch22.uri_ty[], i_privacy character varying[], i_pai switch22.uri_ty[], i_ppi switch22.uri_ty) RETURNS SETOF switch22.callprofile_ty
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
          cg.pop_id=i_call_ctx.pop_id desc,
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
        LIMIT v_gateway_group.max_rerouting_attempts
        LOOP
        return query select * from process_gw_release(i_profile, i_destination, i_dp, i_customer_acc,
                                                      i_customer_gw, i_vendor_acc , v_gw, i_call_ctx,
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
          cg.pop_id=i_call_ctx.pop_id desc,
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
        LIMIT v_gateway_group.max_rerouting_attempts
      LOOP
        IF v_gw.contractor_id!=i_dp.vendor_id THEN
          RAISE WARNING 'process_dp: Gateway owner !=dialpeer owner. Skip gateway';
          continue;
        end if;
        return query select * from process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc,
                                                    i_customer_gw, i_vendor_acc , v_gw, i_call_ctx,
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
        LIMIT v_gateway_group.max_rerouting_attempts
      LOOP
        return query select * from process_gw_release(i_profile, i_destination, i_dp, i_customer_acc,
                                                      i_customer_gw, i_vendor_acc , v_gw, i_call_ctx,
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
        LIMIT v_gateway_group.max_rerouting_attempts
      LOOP
        IF v_gw.contractor_id!=i_dp.vendor_id AND NOT v_gw.is_shared THEN
          RAISE WARNING 'process_dp: Gateway owner !=dialpeer owner. Skip gateway';
          continue;
        end if;
        return query select * from process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc,
                                                    i_customer_gw, i_vendor_acc , v_gw, i_call_ctx,
                                                    i_diversion, i_privacy, i_pai, i_ppi);
      end loop;
      /*}dbg*/

    elsif v_gateway_group.balancing_mode_id=3 THEN
      /*rel{*/
      FOR v_gw in
        select * from class4.gateways cg
        where
	  (cg.pop_id is null OR cg.pop_id=i_call_ctx.pop_id) and
          cg.gateway_group_id=i_dp.gateway_group_id and
          cg.contractor_id=i_dp.vendor_id and
          cg.enabled
        ORDER BY
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
        LIMIT v_gateway_group.max_rerouting_attempts
        LOOP
        return query select * from process_gw_release(i_profile, i_destination, i_dp, i_customer_acc,
                                                      i_customer_gw, i_vendor_acc , v_gw, i_call_ctx,
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
          cg.pop_id=i_call_ctx.pop_id desc,
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
        LIMIT v_gateway_group.max_rerouting_attempts
      LOOP
	IF v_gw.pop_id is not null and v_gw.pop_id!=i_pop_id THEN
          RAISE WARNING 'process_dp: Gateway POP is %, call pop %, skipping.',v_gw.pop_id, i_call_ctx.pop_id;
          continue;
        end if;
        IF v_gw.contractor_id!=i_dp.vendor_id THEN
          RAISE WARNING 'process_dp: Gateway owner !=dialpeer owner. Skip gateway';
          continue;
        end if;
        return query select * from process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc,
                                                    i_customer_gw, i_vendor_acc , v_gw, i_call_ctx,
                                                    i_diversion, i_privacy, i_pai, i_ppi);
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
          process_gw_release(i_profile, i_destination, i_dp, i_customer_acc,i_customer_gw, i_vendor_acc, v_gw, i_call_ctx, i_diversion, i_privacy, i_pai, i_ppi);
      /*}rel*/
      /*dbg{*/
      return query select * from
          process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc,i_customer_gw, i_vendor_acc, v_gw, i_call_ctx, i_diversion, i_privacy, i_pai, i_ppi);
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

    CREATE OR REPLACE FUNCTION switch22.process_dp(i_profile switch22.callprofile_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_call_ctx switch22.call_ctx_ty, i_diversion switch22.uri_ty[], i_privacy character varying[], i_pai switch22.uri_ty[], i_ppi switch22.uri_ty) RETURNS SETOF switch22.callprofile_ty
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
          cg.pop_id=i_call_ctx.pop_id desc,
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
        LOOP
        return query select * from process_gw_release(i_profile, i_destination, i_dp, i_customer_acc,
                                                      i_customer_gw, i_vendor_acc , v_gw, i_call_ctx,
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
          cg.pop_id=i_call_ctx.pop_id desc,
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
      LOOP
        IF v_gw.contractor_id!=i_dp.vendor_id THEN
          RAISE WARNING 'process_dp: Gateway owner !=dialpeer owner. Skip gateway';
          continue;
        end if;
        return query select * from process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc,
                                                    i_customer_gw, i_vendor_acc , v_gw, i_call_ctx,
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
                                                      i_customer_gw, i_vendor_acc , v_gw, i_call_ctx,
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
                                                    i_customer_gw, i_vendor_acc , v_gw, i_call_ctx,
                                                    i_diversion, i_privacy, i_pai, i_ppi);
      end loop;
      /*}dbg*/

    elsif v_gateway_group.balancing_mode_id=3 THEN
      /*rel{*/
      FOR v_gw in
        select * from class4.gateways cg
        where
	  (cg.pop_id is null OR cg.pop_id=i_call_ctx.pop_id) and
          cg.gateway_group_id=i_dp.gateway_group_id and
          cg.contractor_id=i_dp.vendor_id and
          cg.enabled
        ORDER BY
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
        LOOP
        return query select * from process_gw_release(i_profile, i_destination, i_dp, i_customer_acc,
                                                      i_customer_gw, i_vendor_acc , v_gw, i_call_ctx,
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
          cg.pop_id=i_call_ctx.pop_id desc,
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
      LOOP
	IF v_gw.pop_id is not null and v_gw.pop_id!=i_pop_id THEN
          RAISE WARNING 'process_dp: Gateway POP is %, call pop %, skipping.',v_gw.pop_id, i_call_ctx.pop_id;
          continue;
        end if;
        IF v_gw.contractor_id!=i_dp.vendor_id THEN
          RAISE WARNING 'process_dp: Gateway owner !=dialpeer owner. Skip gateway';
          continue;
        end if;
        return query select * from process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc,
                                                    i_customer_gw, i_vendor_acc , v_gw, i_call_ctx,
                                                    i_diversion, i_privacy, i_pai, i_ppi);
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
          process_gw_release(i_profile, i_destination, i_dp, i_customer_acc,i_customer_gw, i_vendor_acc, v_gw, i_call_ctx, i_diversion, i_privacy, i_pai, i_ppi);
      /*}rel*/
      /*dbg{*/
      return query select * from
          process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc,i_customer_gw, i_vendor_acc, v_gw, i_call_ctx, i_diversion, i_privacy, i_pai, i_ppi);
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

      alter table class4.gateway_groups drop column max_rerouting_attempts;
      alter table data_import.import_gateway_groups drop column max_rerouting_attempts;
    }
  end
end
