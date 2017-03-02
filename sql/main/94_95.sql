begin;
insert into sys.version(number,comment) values(95,'Registrations');

DROP FUNCTION switch11.load_registrations_out(integer, integer);

CREATE OR REPLACE FUNCTION switch11.load_registrations_out(
    IN i_pop_id integer,
    IN i_node_id integer,
    IN i_registration_id integer default null
    )
  RETURNS TABLE(o_id integer, o_domain character varying, o_user character varying, o_display_name character varying, o_auth_user character varying, o_auth_password character varying, o_proxy character varying, o_contact character varying, o_expire integer, o_force_expire boolean) AS
$BODY$
BEGIN
  RETURN QUERY
  SELECT
    id,"domain","username","display_username",auth_user,auth_password,proxy,contact,expire,force_expire
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