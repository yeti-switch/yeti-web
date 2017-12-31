class FixRouteSimulation < ActiveRecord::Migration
  def up
    execute %q{

CREATE OR REPLACE FUNCTION switch14.debug(
    i_transport_protocol_id smallint,
    i_remote_ip inet,
    i_remote_port integer,
    i_src_prefix character varying,
    i_dst_prefix character varying,
    i_pop_id integer,
    i_uri_domain character varying,
    i_from_domain character varying,
    i_to_domain character varying,
    i_x_yeti_auth character varying,
    i_release_mode boolean DEFAULT false,
    i_pai character varying DEFAULT NULL::character varying,
    i_ppi character varying DEFAULT NULL::character varying,
    i_privacy character varying DEFAULT NULL::character varying,
    i_rpid character varying DEFAULT NULL::character varying,
    i_rpid_privacy character varying DEFAULT NULL::character varying)
  RETURNS SETOF switch14.callprofile57_ty AS
$BODY$
DECLARE
  v_r record;
  v_start  timestamp;
  v_end timestamp;
BEGIN
  set local search_path to switch14,sys,public;
  v_start:=now();
  v_end:=clock_timestamp(); /*DBG*/
  RAISE NOTICE '% ms -> DBG. Start',EXTRACT(MILLISECOND from v_end-v_start); /*DBG*/
  if i_release_mode then
    return query SELECT * from route_release(
        1,              --i_node_id
        i_pop_id,              --i_pop_id
        i_transport_protocol_id,
        i_remote_ip::inet,
        i_remote_port::int,
        '127.0.0.1'::inet,    --i_local_ip
        '5060'::int,         --i_local_port
        'from_name'::varchar,
        i_src_prefix::varchar,   --i_from_name
        i_from_domain,
        '5060'::int,         --i_from_port
        i_dst_prefix::varchar,   --i_to_name
        i_to_domain,
        '5060'::int,         --i_to_port
        i_src_prefix::varchar,   --i_contact_name
        i_remote_ip::varchar,    --i_contact_domain
        i_remote_port::int,  --i_contact_port
        i_dst_prefix::varchar,   --i_user,
        i_uri_domain::varchar,   -- URI domain,
        null, -- i_auth_id
        i_x_yeti_auth::varchar,            --i_headers,
        NULL, --diversion
        NULL, --X-ORIG-IP
        NULL, --X-ORIG-PORT
        NULL, -- X-ORIG-PROTO
        i_pai,
        i_ppi,
        i_privacy,
        i_rpid,
        i_rpid_privacy
    );
  else
    return query SELECT * from route_debug(
        1,              --i_node_id
        i_pop_id,              --i_pop_id
        i_transport_protocol_id,
        i_remote_ip::inet,
        i_remote_port::int,
        '127.0.0.1'::inet,    --i_local_ip
        '5060'::int,         --i_local_port
        'from_name'::varchar,
        i_src_prefix::varchar,   --i_from_name
        i_from_domain,
        '5060'::int,         --i_from_port
        i_dst_prefix::varchar,   --i_to_name
        i_to_domain,
        '5060'::int,         --i_to_port
        i_src_prefix::varchar,   --i_contact_name
        i_remote_ip::varchar,    --i_contact_domain
        i_remote_port::int,  --i_contact_port
        i_dst_prefix::varchar,   --i_user,
        i_uri_domain::varchar,   -- URI domain
        null, -- i_auth_id
        i_x_yeti_auth::varchar,            --i_headers,
        NULL, --diversion
        NULL, --X-ORIG-IP
        NULL, --X-ORIG-PORT
        NULL, -- X-ORIG-PROTO
        i_pai,
        i_ppi,
        i_privacy,
        i_rpid,
        i_rpid_privacy
    );
  end if;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 100
  ROWS 10;

    }
  end

  def down
    execute %q{
CREATE OR REPLACE FUNCTION switch14.debug(
    i_transport_protocol_id smallint,
    i_remote_ip inet,
    i_remote_port integer,
    i_src_prefix character varying,
    i_dst_prefix character varying,
    i_pop_id integer,
    i_uri_domain character varying,
    i_from_domain character varying,
    i_to_domain character varying,
    i_x_yeti_auth character varying,
    i_release_mode boolean DEFAULT false,
    i_pai character varying DEFAULT NULL::character varying,
    i_ppi character varying DEFAULT NULL::character varying,
    i_privacy character varying DEFAULT NULL::character varying,
    i_rpid character varying DEFAULT NULL::character varying,
    i_rpid_privacy character varying DEFAULT NULL::character varying)
  RETURNS SETOF switch14.callprofile57_ty AS
$BODY$
DECLARE
  v_r record;
  v_start  timestamp;
  v_end timestamp;
BEGIN
  set local search_path to switch14,sys,public;
  v_start:=now();
  v_end:=clock_timestamp(); /*DBG*/
  RAISE NOTICE '% ms -> DBG. Start',EXTRACT(MILLISECOND from v_end-v_start); /*DBG*/
  if i_release_mode then
    return query SELECT * from route_release(
        1,              --i_node_id
        i_pop_id,              --i_pop_id
        i_transport_protocol_id,
        i_remote_ip::inet,
        i_remote_port::int,
        '127.0.0.1'::inet,    --i_local_ip
        '5060'::int,         --i_local_port
        'from_name'::varchar,
        i_src_prefix::varchar,   --i_from_name
        i_from_domain,
        '5060'::int,         --i_from_port
        i_dst_prefix::varchar,   --i_to_name
        i_to_domain,
        '5060'::int,         --i_to_port
        i_src_prefix::varchar,   --i_contact_name
        i_remote_ip::varchar,    --i_contact_domain
        i_remote_port::int,  --i_contact_port
        i_dst_prefix::varchar,   --i_user,
        i_uri_domain::varchar,   -- URI domain,
        null, -- i_auth_id
        i_x_yeti_auth::varchar,            --i_headers,
        NULL, --diversion
        NULL, --X-ORIG-IP
        NULL, --X-ORIG-PORT
        NULL, -- X-ORIG-PROTO
        i_pai,
        i_ppi,
        i_privacy,
        i_rpid,
        i_rpid_privacy
    );
  else
    return query SELECT * from route_debug(
        1,              --i_node_id
        i_pop_id,              --i_pop_id
        i_transport_protocol_id,
        i_remote_ip::inet,
        i_remote_port::int,
        '127.0.0.1'::inet,    --i_local_ip
        '5060'::int,         --i_local_port
        'from_name'::varchar,
        i_src_prefix::varchar,   --i_from_name
        i_from_domain,
        '5060'::int,         --i_from_port
        i_dst_prefix::varchar,   --i_to_name
        i_to_domain,
        '5060'::int,         --i_to_port
        i_src_prefix::varchar,   --i_contact_name
        i_remote_ip::varchar,    --i_contact_domain
        i_remote_port::int,  --i_contact_port
        i_dst_prefix::varchar,   --i_user,
        i_uri_domain::varchar,   -- URI domain
        i_x_yeti_auth::varchar,            --i_headers,
        NULL, --diversion
        NULL, --X-ORIG-IP
        NULL, --X-ORIG-PORT
        NULL, -- X-ORIG-PROTO
        i_pai,
        i_ppi,
        i_privacy,
        i_rpid,
        i_rpid_privacy
    );
  end if;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 100
  ROWS 10;
}
  end
end

