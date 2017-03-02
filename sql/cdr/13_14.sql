begin;
insert into sys.version(number,comment) values(14,'Vendor reports');

CREATE TABLE reports.vendor_traffic_report
(
  id bigserial PRIMARY KEY,
  created_at timestamp with time zone,
  date_start timestamp with time zone,
  date_end timestamp with time zone,
  vendor_id integer NOT NULL
)
WITH (
OIDS=FALSE
);

CREATE TABLE reports.vendor_traffic_report_data
(
  id bigserial PRIMARY KEY,
  report_id integer NOT NULL,
  customer_id integer,
  calls_count bigint,
  calls_duration bigint,
  acd real,
  asr real,
  origination_cost numeric,
  termination_cost numeric,
  profit numeric,
  success_calls_count bigint,
  first_call_at timestamp with time zone,
  last_call_at timestamp with time zone,
  short_calls_count bigint,
  CONSTRAINT vendor_traffic_report_data_report_id_fkey FOREIGN KEY (report_id)
  REFERENCES reports.vendor_traffic_report (id) MATCH SIMPLE
  ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
OIDS=FALSE
);

create index on reports.vendor_traffic_report_data using BTREE (report_id);


CREATE OR REPLACE FUNCTION reports.vendor_traffic_remove(i_report_id integer)
  RETURNS void AS
  $BODY$
DECLARE

BEGIN
    delete from reports.vendor_traffic_report_data where report_id=i_report_id;
    delete from reports.vendor_traffic_report where id=i_report_id;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 3000;

CREATE OR REPLACE FUNCTION reports.vendor_traffic_report(
  i_date_start timestamp without time zone,
  i_date_end timestamp without time zone,
  i_vendor_id integer)
  RETURNS integer AS
  $BODY$
DECLARE
    v_rid integer;
    v_sql varchar;
    v_keys varchar:='';
    v_i integer:=0;
    v_field varchar;
    v_filter varchar;
BEGIN
    INSERT INTO reports.vendor_traffic_report(created_at,date_start,date_end,vendor_id)
        values(now(),i_date_start,i_date_end,i_vendor_id) RETURNING id INTO v_rid;

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


CREATE OR REPLACE FUNCTION reports.customer_traffic_report(
  i_date_start timestamp without time zone,
  i_date_end timestamp without time zone,
  i_customer_id integer)
  RETURNS integer AS
  $BODY$
DECLARE
    v_rid integer;
    v_sql varchar;
    v_keys varchar:='';
    v_i integer:=0;
    v_field varchar;
    v_filter varchar;
BEGIN
    INSERT INTO reports.customer_traffic_report(created_at,date_start,date_end,customer_id)
        values(now(),i_date_start,i_date_end,i_customer_id) RETURNING id INTO v_rid;

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

commit;