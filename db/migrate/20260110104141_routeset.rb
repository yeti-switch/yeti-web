class Routeset < ActiveRecord::Migration[7.2]

  def up
    execute %q{
      alter table class4.registrations
        add route_set varchar[] not null default '{}';

      update class4.registrations set route_set='{'||proxy||';transport=udp}'::varchar::varchar[] where COALESCE(proxy,'')!='' and proxy_transport_protocol_id=1;
      update class4.registrations set route_set='{'||proxy||';transport=tcp}'::varchar::varchar[] where COALESCE(proxy,'')!='' and proxy_transport_protocol_id=2;
      update class4.registrations set route_set='{'||proxy||';transport=tls}'::varchar::varchar[] where COALESCE(proxy,'')!='' and proxy_transport_protocol_id=3;
      update class4.registrations set route_set='{'||proxy||';transport=ws}'::varchar::varchar[] where COALESCE(proxy,'')!='' and proxy_transport_protocol_id=5;

      alter table class4.registrations
        drop column proxy,
        drop column proxy_transport_protocol_id;

      alter table class4.sip_options_probers
        add route_set varchar[] not null default '{}';

      update class4.sip_options_probers set route_set='{'||proxy||';transport=udp}'::varchar::varchar[] where COALESCE(proxy,'')!='' and proxy_transport_protocol_id=1;
      update class4.sip_options_probers set route_set='{'||proxy||';transport=tcp}'::varchar::varchar[] where COALESCE(proxy,'')!='' and proxy_transport_protocol_id=2;
      update class4.sip_options_probers set route_set='{'||proxy||';transport=tls}'::varchar::varchar[] where COALESCE(proxy,'')!='' and proxy_transport_protocol_id=3;
      update class4.sip_options_probers set route_set='{'||proxy||';transport=ws}'::varchar::varchar[] where COALESCE(proxy,'')!='' and proxy_transport_protocol_id=5;

      alter table class4.sip_options_probers
        drop column proxy,
        drop column proxy_transport_protocol_id;

   DROP FUNCTION switch22.load_registrations_out(i_pop_id integer, i_node_id integer, i_registration_id integer);
   CREATE FUNCTION switch22.load_registrations_out(i_pop_id integer, i_node_id integer, i_registration_id integer DEFAULT NULL::integer)
   RETURNS TABLE(
   o_id integer, o_transport_protocol_id smallint, o_domain character varying, o_user character varying, o_display_name character varying, o_auth_user character varying, o_auth_password character varying, o_route_set character varying, o_contact character varying, o_expire integer, o_force_expire boolean, o_retry_delay smallint, o_max_attempts smallint, o_scheme_id smallint, o_sip_interface_name character varying)
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
    array_to_string(route_set, ',') as route_set,
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

    DROP FUNCTION switch22.load_sip_options_probers(i_node_id integer, i_registration_id integer);
    CREATE FUNCTION switch22.load_sip_options_probers(i_node_id integer, i_registration_id integer DEFAULT NULL::integer)
    RETURNS TABLE(id integer, name character varying, ruri_domain character varying, ruri_username character varying, transport_protocol_id smallint, sip_schema_id smallint, from_uri character varying, to_uri character varying, contact_uri character varying, route_set character varying, "interval" smallint, append_headers character varying, sip_interface_name character varying, auth_username character varying, auth_password character varying, created_at timestamp with time zone, updated_at timestamp with time zone)
    LANGUAGE plpgsql COST 10 ROWS 100
    AS $$
BEGIN
  RETURN QUERY
  SELECT
        o.id,
        o.name,
        o.ruri_domain,
        o.ruri_username,
        o.transport_protocol_id,
        o.sip_schema_id,
        o.from_uri,
        o.to_uri,
        o.contact_uri,
        array_to_string(o.route_set, ',') as route_set,
        o.interval,
        o.append_headers,
        o.sip_interface_name,
        o.auth_username,
        o.auth_password,
        o.created_at,
        o.updated_at
  FROM
    class4.sip_options_probers o
  WHERE
    o.enabled AND
    (
      (o.pop_id is null and o.node_id is null) OR
      (o.pop_id is not null and o.node_id is null and o.pop_id in (select n.pop_id from sys.nodes n where n.id=i_node_id)) OR
      (o.node_id is not null and o.node_id=i_node_id )
    ) AND
    (i_registration_id is null OR o.id=i_registration_id);
end;
$$;



    }
  end

  def down
    execute %q{
      alter table class4.registrations
        drop column route_set;

      alter table class4.registrations
        add proxy varchar,
        add proxy_transport_protocol_id smallint not null default 1 references class4.transport_protocols(id);

      alter table class4.sip_options_probers
        drop column route_set;

      alter table class4.sip_options_probers
        add proxy varchar,
        add proxy_transport_protocol_id smallint not null default 1 references class4.transport_protocols(id);

    DROP FUNCTION switch22.load_registrations_out(i_pop_id integer, i_node_id integer, i_registration_id integer);
    CREATE FUNCTION switch22.load_registrations_out(i_pop_id integer, i_node_id integer, i_registration_id integer DEFAULT NULL::integer) RETURNS TABLE(o_id integer, o_transport_protocol_id smallint, o_domain character varying, o_user character varying, o_display_name character varying, o_auth_user character varying, o_auth_password character varying, o_proxy character varying, o_proxy_transport_protocol_id smallint, o_contact character varying, o_expire integer, o_force_expire boolean, o_retry_delay smallint, o_max_attempts smallint, o_scheme_id smallint, o_sip_interface_name character varying)
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

    DROP FUNCTION switch22.load_sip_options_probers(i_node_id integer, i_registration_id integer);
    CREATE FUNCTION switch22.load_sip_options_probers(i_node_id integer, i_registration_id integer DEFAULT NULL::integer) RETURNS TABLE(id integer, name character varying, ruri_domain character varying, ruri_username character varying, transport_protocol_id smallint, sip_schema_id smallint, from_uri character varying, to_uri character varying, contact_uri character varying, proxy character varying, proxy_transport_protocol_id smallint, "interval" smallint, append_headers character varying, sip_interface_name character varying, auth_username character varying, auth_password character varying, created_at timestamp with time zone, updated_at timestamp with time zone)
    LANGUAGE plpgsql COST 10 ROWS 100
    AS $$
BEGIN
  RETURN QUERY
  SELECT
        o.id,
        o.name,
        o.ruri_domain,
        o.ruri_username,
        o.transport_protocol_id,
        o.sip_schema_id,
        o.from_uri,
        o.to_uri,
        o.contact_uri,
        o.proxy,
        o.proxy_transport_protocol_id,
        o.interval,
        o.append_headers,
        o.sip_interface_name,
        o.auth_username,
        o.auth_password,
        o.created_at,
        o.updated_at
  FROM
    class4.sip_options_probers o
  WHERE
    o.enabled AND
    (
      (o.pop_id is null and o.node_id is null) OR
      (o.pop_id is not null and o.node_id is null and o.pop_id in (select n.pop_id from sys.nodes n where n.id=i_node_id)) OR
      (o.node_id is not null and o.node_id=i_node_id )
    ) AND
    (i_registration_id is null OR o.id=i_registration_id);
end;
$$;

    }
  end

end
