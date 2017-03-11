begin;
insert into sys.version(number,comment) values(102,'Registration delay was added');

alter table class4.registrations
    ADD retry_delay smallint not null default 5,
    ADD max_attempts smallint;

alter table data_import.import_registrations
  ADD retry_delay integer,
  ADD max_attempts integer;

DROP FUNCTION switch11.load_registrations_out(integer, integer, integer);
CREATE OR REPLACE FUNCTION switch11.load_registrations_out(
    IN i_pop_id integer,
    IN i_node_id integer,
    IN i_registration_id integer DEFAULT NULL::integer)
  RETURNS TABLE(
    o_id integer,
    o_domain character varying,
    o_user character varying,
    o_display_name character varying,
    o_auth_user character varying,
    o_auth_password character varying,
    o_proxy character varying,
    o_contact character varying,
    o_expire integer,
    o_force_expire boolean,
    o_retry_delay smallint,
    o_max_attempts smallint
  ) AS
$BODY$
BEGIN
  RETURN QUERY
  SELECT
    id,
    "domain",
    "username",
    "display_username",
    auth_user,
    auth_password,
    proxy,
    contact,
    expire,
    force_expire,
    retry_delay,
    max_attempts
  FROM class4.registrations r
  WHERE
    r.enabled and
    (r.pop_id=i_pop_id OR r.pop_id is null) AND
    (r.node_id=i_node_id OR r.node_id IS NULL) AND
    (i_registration_id is null OR id=i_registration_id);

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 10
  ROWS 100;

commit;