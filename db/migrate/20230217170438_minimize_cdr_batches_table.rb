class MinimizeCdrBatchesTable < ActiveRecord::Migration[6.1]
  def up
    execute %q{

    DROP FUNCTION billing.clean_cdr_batch();

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


  alter table billing.cdr_batches
    drop column size,
    drop column raw_data;

            }
    end

  def down
    execute %q{

    alter table billing.cdr_batches
      add size integer not null default 0,
      add raw_data text;

    CREATE or replace FUNCTION billing.bill_cdr_batch(i_batch_id bigint, i_data text, i_data_version integer DEFAULT 2) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
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
$$;

CREATE FUNCTION billing.clean_cdr_batch() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
BEGIN
    DELETE FROM billing.cdr_batches where id not in (SELECT id from billing.cdr_batches order by id desc limit 50);
    return;
END;
$$;

            }
  end
end
