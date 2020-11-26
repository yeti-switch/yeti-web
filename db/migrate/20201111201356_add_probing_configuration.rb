class AddProbingConfiguration < ActiveRecord::Migration[5.2]
  def up
    execute %q{
      create table class4.sip_options_probers(
        id serial primary key,
        name varchar not null unique,
        enabled boolean not null default true,
        pop_id smallint references sys.pops(id),
        node_id smallint references sys.nodes(id),
        ruri_domain varchar not null,
        ruri_username varchar not null,
        transport_protocol_id smallint not null references class4.transport_protocols(id) default 1,
        sip_schema_id smallint not null REFERENCES sys.sip_schemas(id) default 1,
        from_uri varchar,
        to_uri varchar,
        contact_uri varchar,
        proxy varchar,
        proxy_transport_protocol_id smallint not null references class4.transport_protocols(id) default 1,
        interval smallint not null default 60,
        append_headers varchar,
        sip_interface_name varchar,
        auth_username varchar,
        auth_password varchar,
        created_at timestamptz not null,
        updated_at timestamptz not null
      );

CREATE OR REPLACE FUNCTION switch18.load_sip_options_probers(i_node_id integer, i_registration_id integer DEFAULT NULL::integer)
RETURNS TABLE(
  id integer,
  name varchar,
  ruri_domain varchar,
  ruri_username varchar,
  transport_protocol_id smallint,
  sip_schema_id smallint,
  from_uri varchar,
  to_uri varchar,
  contact_uri varchar,
  proxy varchar,
  proxy_transport_protocol_id smallint,
  "interval" smallint,
  append_headers varchar,
  sip_interface_name varchar,
  auth_username varchar,
  auth_password varchar,
  created_at timestamptz,
  updated_at timestamptz
)
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

  def down
    execute %q{
      DROP FUNCTION switch18.load_sip_options_probers(i_node_id integer, i_registration_id integer);
      drop table class4.sip_options_probers;
    }
  end
end
