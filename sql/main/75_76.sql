begin;
insert into sys.version(number,comment) values(76,'route fix');

set search_path TO switch9;

CREATE OR REPLACE FUNCTION switch9.load_radius_accounting_profiles()
  RETURNS TABLE(id smallint, name character varying, server character varying, port integer, secret character varying, timeout smallint, attempts smallint, enable_start_accounting boolean, enable_interim_accounting boolean, enable_stop_accounting boolean, interim_accounting_interval smallint, start_avps json, interim_avps json, stop_avps json) AS
$BODY$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.name,
        p.server,
        p.port,
        p.secret,
        p.timeout,
        p.attempts,
        p.enable_start_accounting,
        p.enable_interim_accounting,
        p.enable_stop_accounting,
        p.interim_accounting_interval,
        (select json_agg(d.*) from class4.radius_accounting_profile_start_attributes d where profile_id=p.id),
        (select json_agg(d.*) from class4.radius_accounting_profile_interim_attributes d where profile_id=p.id),
        (select json_agg(d.*) from class4.radius_accounting_profile_stop_attributes d where profile_id=p.id)
    from class4.radius_accounting_profiles p
    order by p.id;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 10
  ROWS 1000;

commit;