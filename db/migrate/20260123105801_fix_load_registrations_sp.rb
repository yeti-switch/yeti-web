class FixLoadRegistrationsSp < ActiveRecord::Migration[7.2]

  def up
    execute %q{
   DROP FUNCTION switch22.load_registrations_out(i_pop_id integer, i_node_id integer, i_registration_id integer);
   CREATE FUNCTION switch22.load_registrations_out(i_pop_id integer, i_node_id integer, i_registration_id integer DEFAULT NULL::integer)
   RETURNS TABLE(
   o_id integer, o_transport_protocol_id smallint, o_domain character varying, o_user character varying, o_display_name character varying, o_auth_user character varying, o_auth_password character varying, o_route_set character varying, o_contact character varying, o_expire integer, o_force_expire boolean, o_retry_delay smallint, o_max_attempts smallint, o_scheme_id smallint, o_sip_interface_name character varying)
    LANGUAGE plpgsql COST 10 ROWS 100
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.id,
    r.transport_protocol_id,
    r."domain",
    r."username",
    r."display_username",
    r.auth_user,
    r.auth_password,
    array_to_string(r.route_set, ',')::varchar as o_route_set,
    r.contact,
    r.expire,
    r.force_expire,
    r.retry_delay,
    r.max_attempts,
    r.sip_schema_id,
    r.sip_interface_name
  FROM class4.registrations r
  WHERE
    r.enabled and
    (r.pop_id=i_pop_id OR r.pop_id is null) AND
    (r.node_id=i_node_id OR r.node_id IS NULL) AND
    (i_registration_id is null OR id=i_registration_id);

end;
$$;
    }
  end

  def down
    execute %q{
   DROP FUNCTION switch22.load_registrations_out(i_pop_id integer, i_node_id integer, i_registration_id integer);
   CREATE FUNCTION switch22.load_registrations_out(i_pop_id integer, i_node_id integer, i_registration_id integer DEFAULT NULL::integer)
   RETURNS TABLE(
   o_id integer, o_transport_protocol_id smallint, o_domain character varying, o_user character varying, o_display_name character varying, o_auth_user character varying, o_auth_password character varying, route_set character varying, o_contact character varying, o_expire integer, o_force_expire boolean, o_retry_delay smallint, o_max_attempts smallint, o_scheme_id smallint, o_sip_interface_name character varying)
    LANGUAGE plpgsql COST 10 ROWS 100
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.id,
    r.transport_protocol_id,
    r."domain",
    r."username",
    r."display_username",
    r.auth_user,
    r.auth_password,
    array_to_string(r.route_set, ',')::varchar as route_set,
    r.contact,
    r.expire,
    r.force_expire,
    r.retry_delay,
    r.max_attempts,
    r.sip_schema_id,
    r.sip_interface_name
  FROM class4.registrations r
  WHERE
    r.enabled and
    (r.pop_id=i_pop_id OR r.pop_id is null) AND
    (r.node_id=i_node_id OR r.node_id IS NULL) AND
    (i_registration_id is null OR id=i_registration_id);

end;
$$;
    }
  end

end
