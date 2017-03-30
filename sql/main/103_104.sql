begin;
insert into sys.version(number,comment) values(104,'Routing simulation fixes');


DROP FUNCTION switch12.debug(smallint, inet, integer, character varying, character varying, integer, character varying, character varying);

CREATE OR REPLACE FUNCTION switch12.debug(
  i_transport_protocol_id smallint,
  i_remote_ip inet,
  i_remote_port integer,
  i_src_prefix character varying,
  i_dst_prefix character varying,
  i_pop_id integer,
  i_uri_domain character varying,
  i_from_domain varchar,
  i_to_domain varchar,
  i_x_yeti_auth character varying)
  RETURNS SETOF switch12.callprofile53_ty AS
$BODY$
DECLARE
  v_r record;
  v_start  timestamp;
  v_end timestamp;
BEGIN
  set local search_path to switch12,sys,public;
  v_start:=now();
  v_end:=clock_timestamp(); /*DBG*/
  RAISE NOTICE '% ms -> DBG. Start',EXTRACT(MILLISECOND from v_end-v_start); /*DBG*/

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
      NULL -- X-ORIG-PROTO
  );
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER
COST 100
ROWS 10;

commit;