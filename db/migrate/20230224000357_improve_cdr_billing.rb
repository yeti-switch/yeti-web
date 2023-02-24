class ImproveCdrBilling < ActiveRecord::Migration[6.1]

  def up
        execute %q{

    CREATE or replace FUNCTION billing.bill_cdr_batch(i_batch_id bigint, i_data text, i_data_version integer DEFAULT 2) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    v_batch_data billing.cdr_v2;
    v_acc_data record;
    _j_data json;
BEGIN
    begin
        _j_data:=i_data::json;
    exception
        when others then
            RAISE exception 'billing.bill_cdr_batch: Invalid json payload';
    end;

    BEGIN
        insert into billing.cdr_batches(id) values(i_batch_id);
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

    for v_acc_data in
      select
        customer_acc_id,
        sum(customer_price) FILTER ( WHERE customer_price>0) as customer_price,
        destination_reverse_billing,
        vendor_acc_id,
        sum(vendor_price) FILTER ( WHERE vendor_price>0) as vendor_price,
        dialpeer_reverse_billing
      from json_populate_recordset(null::billing.cdr_v2,_j_data)
      where customer_price>0 or vendor_price>0
      group by customer_acc_id, destination_reverse_billing, vendor_acc_id, dialpeer_reverse_billing
    LOOP
      IF v_acc_data.destination_reverse_billing IS NULL OR v_acc_data.destination_reverse_billing = false THEN
        UPDATE billing.accounts SET balance = balance - COALESCE(v_acc_data.customer_price,0) WHERE id = v_acc_data.customer_acc_id;
      ELSE
        UPDATE billing.accounts SET balance = balance + COALESCE(v_acc_data.customer_price,0) WHERE id = v_acc_data.customer_acc_id;
      END IF;

      IF v_acc_data.dialpeer_reverse_billing IS NULL OR v_acc_data.dialpeer_reverse_billing = false THEN
        UPDATE billing.accounts SET balance = balance + COALESCE(v_acc_data.vendor_price,0) WHERE id = v_acc_data.vendor_acc_id;
      ELSE
        UPDATE billing.accounts SET balance = balance - COALESCE(v_acc_data.vendor_price,0) WHERE id = v_acc_data.vendor_acc_id;
      END IF;
    END LOOP;

    for v_batch_data IN select * from json_populate_recordset(null::billing.cdr_v2,_j_data) LOOP
        perform runtime_stats.update_dp(v_batch_data.destination_id,v_batch_data.dialpeer_id,
            v_batch_data.success,v_batch_data.duration
            );

        perform runtime_stats.update_gw(v_batch_data.orig_gw_id,v_batch_data.term_gw_id,
            v_batch_data.success,v_batch_data.duration
            );
    end loop;
END;
$$;

drop FUNCTION billing.bill_cdr(i_cdr billing.cdr_v2);

drop FUNCTION billing.unbill_cdr(i_cdr_id bigint);
            }
  end


  def down
    execute %q{

CREATE or replace FUNCTION billing.unbill_cdr(i_cdr_id bigint) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    v_cdr record;
BEGIN
        SELECT into v_cdr * from class4.cdrs WHERE id=i_cdr_id;
        PERFORM billing.bill_account(v_cdr.vendor_acc_id, +v_cdr.vendor_price::numeric);
        PERFORM billing.bill_account(v_cdr.customer_acc_id, -v_cdr.customer_price::numeric);
        delete from class4.cdrs where id=i_cdr_id;
END;
$$;


CREATE or replace FUNCTION billing.bill_cdr(i_cdr billing.cdr_v2) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
BEGIN
    if i_cdr.dialpeer_reverse_billing is not null and i_cdr.dialpeer_reverse_billing=true then
      UPDATE billing.accounts SET balance=balance-i_cdr.vendor_price WHERE id=i_cdr.vendor_acc_id;
    else
      UPDATE billing.accounts SET balance=balance+i_cdr.vendor_price WHERE id=i_cdr.vendor_acc_id;
    end if;

    if i_cdr.destination_reverse_billing is not null and i_cdr.destination_reverse_billing=true then
      UPDATE billing.accounts SET balance=balance+i_cdr.customer_price WHERE id=i_cdr.customer_acc_id;
    else
      UPDATE billing.accounts SET balance=balance-i_cdr.customer_price WHERE id=i_cdr.customer_acc_id;
    end if;

    return;
END;
$$;

    CREATE or replace FUNCTION billing.bill_cdr_batch(i_batch_id bigint, i_data text, i_data_version integer DEFAULT 2) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    v_batch_data billing.cdr_v2;
    _j_data json;
BEGIN
    begin
        _j_data:=i_data::json;
    exception
        when others then
            RAISE exception 'billing.bill_cdr_batch: Invalid json payload';
    end;

    BEGIN
        insert into billing.cdr_batches(id) values(i_batch_id);
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


    end loop;
END;
$$;

            }
  end

end
