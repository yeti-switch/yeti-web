class Switch19LoadRegistrationsOutAddSipInterfaceName < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      DROP FUNCTION switch19.load_registrations_out(i_pop_id integer, i_node_id integer, i_registration_id integer)
    SQL

    execute <<-SQL
      CREATE FUNCTION switch19.load_registrations_out(i_pop_id integer, i_node_id integer, i_registration_id integer DEFAULT NULL::integer) 
      RETURNS TABLE(o_id integer, o_transport_protocol_id smallint, o_domain character varying, o_user character varying, o_display_name character varying, o_auth_user character varying, o_auth_password character varying, o_proxy character varying, o_proxy_transport_protocol_id smallint, o_contact character varying, o_expire integer, o_force_expire boolean, o_retry_delay smallint, o_max_attempts smallint, o_scheme_id smallint, o_sip_interface_name character varying)
      LANGUAGE plpgsql COST 10 ROWS 100
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    id,
    transport_protocol_id,
    "domain",
    "username",
    "display_username",
    auth_user,
    auth_password,
    proxy,
    proxy_transport_protocol_id,
    contact,
    expire,
    force_expire,
    retry_delay,
    max_attempts,
    sip_schema_id,
    sip_interface_name
  FROM class4.registrations r
  WHERE
    r.enabled and
    (r.pop_id=i_pop_id OR r.pop_id is null) AND
    (r.node_id=i_node_id OR r.node_id IS NULL) AND
    (i_registration_id is null OR id=i_registration_id);

end;
$$;
    SQL
  end

  def down
    execute <<-SQL
      DROP FUNCTION switch19.load_registrations_out(i_pop_id integer, i_node_id integer, i_registration_id integer)
    SQL

    execute <<-SQL
      CREATE FUNCTION switch19.load_registrations_out(i_pop_id integer, i_node_id integer, i_registration_id integer DEFAULT NULL::integer)
      RETURNS TABLE(o_id integer, o_transport_protocol_id smallint, o_domain character varying, o_user character varying, o_display_name character varying, o_auth_user character varying, o_auth_password character varying, o_proxy character varying, o_proxy_transport_protocol_id smallint, o_contact character varying, o_expire integer, o_force_expire boolean, o_retry_delay smallint, o_max_attempts smallint, o_scheme_id smallint)
      LANGUAGE plpgsql COST 10 ROWS 100
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    id,
    transport_protocol_id,
    "domain",
    "username",
    "display_username",
    auth_user,
    auth_password,
    proxy,
    proxy_transport_protocol_id,
    contact,
    expire,
    force_expire,
    retry_delay,
    max_attempts,
    sip_schema_id
  FROM class4.registrations r
  WHERE
    r.enabled and
    (r.pop_id=i_pop_id OR r.pop_id is null) AND
    (r.node_id=i_node_id OR r.node_id IS NULL) AND
    (i_registration_id is null OR id=i_registration_id);

end;
$$;
    SQL
  end
end
