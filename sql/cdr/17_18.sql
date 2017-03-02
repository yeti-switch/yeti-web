begin;
insert into sys.version(number,comment) values(18,'Reports refactoring');

DROP FUNCTION reports.cdr_custom_report(timestamp without time zone, timestamp without time zone, character varying, character varying);
DROP FUNCTION reports.cdr_custom_report_remove(integer);

DROP FUNCTION reports.cdr_interval_report(timestamp without time zone, timestamp without time zone, integer, integer, character varying, character varying, character varying);
DROP FUNCTION reports.cdr_interval_report_remove(integer);

DROP FUNCTION reports.customer_traffic_report(timestamp without time zone, timestamp without time zone, integer);
DROP FUNCTION reports.customer_traffic_remove(integer);

DROP FUNCTION reports.vendor_traffic_report(timestamp without time zone, timestamp without time zone, integer);
DROP FUNCTION reports.vendor_traffic_remove(integer);


CREATE OR REPLACE FUNCTION reports.cdr_custom_report(i_id integer)
  RETURNS integer AS
  $BODY$
DECLARE
    v_rid integer;
    v_sql varchar;
    v_keys varchar:='';
    v_i integer:=0;
    v_field varchar;
    v_filter varchar;
    i_date_start timestamptz;
    i_date_end timestamptz;
    i_filter varchar;
    i_group_by varchar;
BEGIN
    --INSERT INTO reports.cdr_custom_report(created_at,date_start,date_end,filter,group_by)
      --  values(now(),i_date_start,i_date_end,i_filter,i_group_by) RETURNING id INTO v_rid;
    select into v_rid,i_date_start,i_date_end,i_filter,i_group_by id,date_start,date_end,filter,group_by from reports.cdr_custom_report where id=i_id;

    raise warning 'REPORT: % - % - % - % - % ',v_rid,i_date_start,i_date_end,i_filter,i_group_by ;

    For v_field in select * from regexp_split_to_table(i_group_by,',') LOOP
        v_i:=v_i+1;
        --IF regexp_match(v_field','w');
        v_keys:=v_keys||'key'||v_i::varchar||',';
    end loop;

    v_filter=COALESCE('AND '||NULLIF(i_filter,''),'');

    v_sql:='
        INSERT INTO cdr_custom_report_data(
        report_id,
        '||i_group_by||',
        agg_calls_count,
        agg_calls_duration,
        agg_customer_price,
        agg_vendor_price,
        agg_profit,
        agg_asr_origination,
        agg_asr_termination,
        agg_calls_acd)
        SELECT '||v_rid::varchar||','||i_group_by::varchar||',
        count(id),
        sum(duration),
        sum(customer_price),
        sum(vendor_price),
        sum(profit),
        count(nullif(success AND is_last_cdr,false))::float/nullif(count(nullif(is_last_cdr,false)),0)::float,
        count(nullif(success,false))::float/nullif(count(id),0)::float,
        sum(duration)::float/nullif(count(nullif(success,false)),0)::float
            from cdr.cdr
            WHERE
                time_start>='''||i_date_start::varchar||'''
                AND time_start<'''||i_date_end::varchar||''' '||v_filter||'
            GROUP BY '||i_group_by;

    RAISE WARNING 'SQL: %',v_sql;
    EXECUTE v_sql;
    RETURN v_rid;

END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 10;


CREATE OR REPLACE FUNCTION reports.customer_traffic_report(i_id integer)
  RETURNS integer AS
  $BODY$
DECLARE
    v_rid integer;
    v_sql varchar;
    v_keys varchar:='';
    v_i integer:=0;
    v_field varchar;
    v_filter varchar;

    i_date_start timestamp without time zone;
    i_date_end timestamp without time zone;
    i_customer_id integer;


BEGIN
/*
    INSERT INTO reports.customer_traffic_report(created_at,c)
        values(now(),i_date_start,i_date_end,i_customer_id) RETURNING id INTO v_rid;
*/

    select into v_rid,i_date_start,i_date_end,i_customer_id
        id,date_start,date_end,customer_id
        from reports.customer_traffic_report where id=i_id;

    v_sql:='
        INSERT INTO reports.customer_traffic_report_data(report_id,vendor_id,calls_count,short_calls_count,success_calls_count,calls_duration,acd,asr,
        origination_cost,termination_cost,profit,first_call_at,last_call_at)
            SELECT '||v_rid::varchar||',vendor_id,
            count(id),
            count(nullif(duration>32,false)),
            count(nullif(success,false)),
            sum(duration),
            sum(duration)::float/nullif(count(nullif(success,false)),0)::float,
            count(nullif(success,false))::float/nullif(count(id),0)::float,
            sum(customer_price),sum(vendor_price),sum(profit),
            min(time_start),
            max(time_start)
            from cdr.cdr
            WHERE
                time_start>='''||i_date_start::varchar||'''
                AND time_start<'''||i_date_end::varchar||'''
                AND customer_id='''||i_customer_id||'''
            GROUP BY vendor_id';
    RAISE WARNING 'SQL: %',v_sql;
    EXECUTE v_sql;
    RETURN v_rid;

END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 10;


CREATE OR REPLACE FUNCTION reports.vendor_traffic_report(i_id integer)
  RETURNS integer AS
  $BODY$
DECLARE
    v_rid integer;
    v_sql varchar;
    v_keys varchar:='';
    v_i integer:=0;
    v_field varchar;
    v_filter varchar;

    i_date_start timestamp without time zone;
    i_date_end timestamp without time zone;
    i_vendor_id integer;

BEGIN
/*
    INSERT INTO reports.vendor_traffic_report(created_at,date_start,date_end,vendor_id)
        values(now(),i_date_start,i_date_end,i_vendor_id) RETURNING id INTO v_rid;
*/
    select into v_rid,i_date_start,i_date_end,i_vendor_id
        id,date_start,date_end,vendor_id
        from reports.vendor_traffic_report where id=i_id;

    v_sql:='
        INSERT INTO reports.vendor_traffic_report_data(report_id,customer_id,calls_count,short_calls_count,success_calls_count,calls_duration,acd,asr,
        origination_cost,termination_cost,profit,first_call_at,last_call_at)
            SELECT '||v_rid::varchar||',customer_id,
            count(id),
            count(nullif(duration>32,false)),
            count(nullif(success,false)),
            sum(duration),
            sum(duration)::float/nullif(count(nullif(success,false)),0)::float,
            count(nullif(success,false))::float/nullif(count(id),0)::float,
            sum(customer_price),sum(vendor_price),sum(profit),
            min(time_start),
            max(time_start)
            from cdr.cdr
            WHERE
                time_start>='''||i_date_start::varchar||'''
                AND time_start<'''||i_date_end::varchar||'''
                AND vendor_id='''||i_vendor_id||'''
            GROUP BY customer_id';
    RAISE WARNING 'SQL: %',v_sql;
    EXECUTE v_sql;
    RETURN v_rid;

END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 10;


CREATE OR REPLACE FUNCTION reports.cdr_interval_report(i_id integer)
  RETURNS integer AS
  $BODY$
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

    i_date_start timestamp;
    i_date_end timestamp;
    i_filter varchar;
    i_group_by varchar;
    i_interval_length integer;
    i_agg_id integer;
    i_agg_by varchar;
BEGIN
/*
    INSERT INTO reports.cdr_interval_report(created_at,date_start,date_end,
    filter,group_by,interval_length,aggregator_id,aggregate_by)
        values(now(),i_date_start,i_date_end,i_filter,i_group_by,i_interval_length,i_agg_id,i_agg_by) RETURNING id INTO v_rid;
*/
    select into v_rid,i_date_start, i_date_end, i_filter, i_group_by, i_interval_length, i_agg_id, i_agg_by
        id, date_start,date_end,filter,group_by,interval_length,aggregator_id,aggregate_by
        from reports.cdr_interval_report where id=i_id;

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
            from cdr.cdr
            WHERE
                time_start>='''||i_date_start::varchar||'''
                AND time_start<'''||i_date_end::varchar||''' '||v_filter||'
            GROUP BY '||v_tsp||v_group_by;

    RAISE WARNING 'SQL: %',v_sql;
    EXECUTE v_sql;
    RETURN v_rid;

END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 3000;

commit;