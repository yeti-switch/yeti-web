class SharedGatewayGroup < ActiveRecord::Migration[6.1]
  def up
    execute %q{
      alter table class4.gateway_groups add is_shared boolean not null default false;

CREATE or replace FUNCTION switch20.process_dp(i_profile switch20.callprofile_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_pop_id integer, i_send_billing_information boolean, i_max_call_length integer) RETURNS SETOF switch20.callprofile_ty
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
  if i_dp.gateway_id IS NULL AND i_dp.gateway_group_id IS NOT NULL then /* termination to gw group */
    select into v_gateway_group * from class4.gateway_groups where id=i_dp.gateway_group_id and (vendor_id=i_dp.vendor_id or is_shared);
    IF v_gateway_group.vendor_id!=i_dp.vendor_id and not v_gateway_group.is_shared THEN
      /*dbg{*/
      v_end:=clock_timestamp();
      RAISE NOTICE '% ms -> process-DP. Gateway Group id=%, name=% is not shared and owned by other vendor then dialpeer id=%',EXTRACT(MILLISECOND from v_end-v_start),v_gateway_group.id,v_gateway_group.name,i_dp.id;
      /*}dbg*/
      return;
    END IF;
    IF v_gateway_group.balancing_mode_id=2 THEN
      /*rel{*/
      FOR v_gw in
        select * from class4.gateways cg
        where
          cg.gateway_group_id=v_gateway_group.id and
          cg.contractor_id=v_gateway_group.vendor_id and
          cg.enabled
        ORDER BY
          cg.pop_id=i_pop_id desc,
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
        LOOP
        return query select * from process_gw_release(i_profile, i_destination, i_dp, i_customer_acc,
                                                      i_customer_gw, i_vendor_acc , v_gw, i_send_billing_information,i_max_call_length);
      end loop;
      /*}rel*/
      /*dbg{*/
      FOR v_gw in
        select * from class4.gateways cg
        where
          cg.gateway_group_id=v_gateway_group.id AND
          cg.enabled
        ORDER BY
          cg.pop_id=i_pop_id desc,
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
      LOOP
        IF v_gw.contractor_id!=v_gateway_group.vendor_id THEN
          RAISE WARNING 'process_dp: Gateway owner != Gateway Group owner. Skip gateway';
          continue;
        end if;
        return query select * from process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc,
                                                    i_customer_gw, i_vendor_acc , v_gw, i_send_billing_information,i_max_call_length);
      end loop;
      /*}dbg*/

    elsif v_gateway_group.balancing_mode_id=1 then
      /*rel{*/
      FOR v_gw in
        select * from class4.gateways cg
        where
          cg.gateway_group_id=v_gateway_group.id AND
          cg.contractor_id=v_gateway_group.vendor_id AND
          cg.enabled
        ORDER BY
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
      LOOP
        return query select * from process_gw_release(i_profile, i_destination, i_dp, i_customer_acc,
                                                      i_customer_gw, i_vendor_acc , v_gw, i_send_billing_information,i_max_call_length);
      end loop;
      /*}rel*/
      /*dbg{*/
      FOR v_gw in
        select * from class4.gateways cg
        where
          cg.gateway_group_id=v_gateway_group.id and
          cg.enabled
        ORDER BY
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
      LOOP
        IF v_gw.contractor_id!=v_gateway_group.vendor_id AND NOT v_gw.is_shared THEN
          RAISE WARNING 'process_dp: Gateway owner != Gateway Group owner. Skip gateway';
          continue;
        end if;
        return query select * from process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc,
                                                    i_customer_gw, i_vendor_acc , v_gw, i_send_billing_information,i_max_call_length);
      end loop;
      /*}dbg*/

    elsif v_gateway_group.balancing_mode_id=3 THEN
      /*rel{*/
      FOR v_gw in
        select * from class4.gateways cg
        where
	        (cg.pop_id is null OR cg.pop_id=i_pop_id) and
          cg.gateway_group_id=v_gateway_group.id and
          cg.contractor_id=v_gateway_group.vendor_id and
          cg.enabled
        ORDER BY
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
      LOOP
        return query select * from process_gw_release(i_profile, i_destination, i_dp, i_customer_acc,
                                                      i_customer_gw, i_vendor_acc , v_gw, i_send_billing_information,i_max_call_length);
      end loop;
      /*}rel*/
      /*dbg{*/
      FOR v_gw in
        select * from class4.gateways cg
        where
          cg.gateway_group_id=v_gateway_group.id AND
          cg.enabled
        ORDER BY
          cg.pop_id=i_pop_id desc,
          yeti_ext.rank_dns_srv(cg.weight) over ( partition by cg.priority order by cg.weight)
      LOOP
	      IF v_gw.pop_id is not null and v_gw.pop_id!=i_pop_id THEN
          RAISE WARNING 'process_dp: Gateway POP is %, call pop %, skipping.',v_gw.pop_id, i_pop_id;
          continue;
        end if;
        IF v_gw.contractor_id!=v_gateway_group.vendor_id THEN
          RAISE WARNING 'process_dp: Gateway owner != Gateway Group owner. Skip gateway';
          continue;
        end if;
        return query select * from process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc,
                                                    i_customer_gw, i_vendor_acc , v_gw, i_send_billing_information,i_max_call_length);
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
          process_gw_release(i_profile, i_destination, i_dp, i_customer_acc,i_customer_gw, i_vendor_acc, v_gw, i_send_billing_information,i_max_call_length);
      /*}rel*/
      /*dbg{*/
      return query select * from
          process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc,i_customer_gw, i_vendor_acc, v_gw, i_send_billing_information,i_max_call_length);
      /*}dbg*/
    else
      return;
    end if;
  end if;
END;
$$;


    set search_path TO switch20;
    SELECT * from switch20.preprocess_all();
    set search_path TO gui, public, switch, billing, class4, runtime_stats, sys, logs, data_import;

            }
  end

  def down
    execute %q{

CREATE or replace FUNCTION switch20.process_dp(i_profile switch20.callprofile_ty, i_destination class4.destinations, i_dp class4.dialpeers, i_customer_acc billing.accounts, i_customer_gw class4.gateways, i_vendor_acc billing.accounts, i_pop_id integer, i_send_billing_information boolean, i_max_call_length integer) RETURNS SETOF switch20.callprofile_ty
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
                                                      i_customer_gw, i_vendor_acc , v_gw, i_send_billing_information,i_max_call_length);
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
                                                    i_customer_gw, i_vendor_acc , v_gw, i_send_billing_information,i_max_call_length);
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
                                                      i_customer_gw, i_vendor_acc , v_gw, i_send_billing_information,i_max_call_length);
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
                                                    i_customer_gw, i_vendor_acc , v_gw, i_send_billing_information,i_max_call_length);
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
                                                      i_customer_gw, i_vendor_acc , v_gw, i_send_billing_information,i_max_call_length);
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
                                                    i_customer_gw, i_vendor_acc , v_gw, i_send_billing_information,i_max_call_length);
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
          process_gw_release(i_profile, i_destination, i_dp, i_customer_acc,i_customer_gw, i_vendor_acc, v_gw, i_send_billing_information,i_max_call_length);
      /*}rel*/
      /*dbg{*/
      return query select * from
          process_gw_debug(i_profile, i_destination, i_dp, i_customer_acc,i_customer_gw, i_vendor_acc, v_gw, i_send_billing_information,i_max_call_length);
      /*}dbg*/
    else
      return;
    end if;
  end if;
END;
$$;


      alter table class4.gateway_groups drop column is_shared;



    set search_path TO switch20;
    SELECT * from switch20.preprocess_all();
    set search_path TO gui, public, switch, billing, class4, runtime_stats, sys, logs, data_import;



            }
  end
end
