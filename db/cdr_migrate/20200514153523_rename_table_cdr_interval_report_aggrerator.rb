class RenameTableCdrIntervalReportAggrerator < ActiveRecord::Migration[5.2]
  def change
    reversible do |direction|
      direction.up do
        #rename step 1
        rename_table 'reports.cdr_interval_report_aggrerator', 'cdr_interval_report_aggregator'
        #rename step 2
        execute <<-SQL
          ALTER TABLE ONLY reports.cdr_interval_report_aggregator
          RENAME CONSTRAINT cdr_interval_report_aggrerator_name_key
          TO cdr_interval_report_aggregator_name_key;
        SQL
        #rename step 3
        execute <<-SQL
          ALTER TABLE ONLY reports.cdr_interval_report_aggregator
          RENAME CONSTRAINT cdr_interval_report_aggrerator_pkey
          TO cdr_interval_report_aggregator_pkey;
        SQL
        #replace step 4
        execute <<-SQL
CREATE OR REPLACE FUNCTION reports.cdr_interval_report(i_id integer) RETURNS integer
    LANGUAGE plpgsql COST 3000
    AS $$
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
    select into v_agg "name"||'('||i_agg_by||')' from reports.cdr_interval_report_aggregator where id=i_agg_id;
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
$$;
        SQL
      end

      direction.down do
        #rename step 1
        rename_table 'reports.cdr_interval_report_aggregator', 'cdr_interval_report_aggrerator'
        #rename step 2
        execute <<-SQL
          ALTER TABLE ONLY reports.cdr_interval_report_aggrerator
          RENAME CONSTRAINT cdr_interval_report_aggregator_name_key
          TO cdr_interval_report_aggrerator_name_key;
        SQL
        #rename step 3
        execute <<-SQL
          ALTER TABLE ONLY reports.cdr_interval_report_aggrerator
          RENAME CONSTRAINT cdr_interval_report_aggregator_pkey
          TO cdr_interval_report_aggrerator_pkey;
        SQL
        #replace step 4
        execute <<-SQL
CREATE OR REPLACE FUNCTION reports.cdr_interval_report(i_id integer) RETURNS integer
    LANGUAGE plpgsql COST 3000
    AS $$
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
$$;
        SQL
      end
    end
  end
end
