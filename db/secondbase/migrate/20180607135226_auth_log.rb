class AuthLog < ActiveRecord::Migration[5.1]
  def up

    execute %q{
      create schema auth_log;
      create table auth_log.auth_log (
        id bigserial primary key,
        node_id smallint,
        pop_id smallint,
        request_time timestamptz not null,
        transport_proto_id smallint,
        transport_remote_ip varchar,
        transport_remote_port integer,
        transport_local_ip varchar,
        transport_local_port integer,
        origination_ip varchar,
        origination_port integer,
        origination_proto_id smallint,
        username varchar,
        method varchar,
        ruri varchar,
        from_uri varchar,
        to_uri varchar,
        call_id varchar,
        success boolean,
        code smallint,
        reason varchar,
        internal_reason varchar,
        nonce varchar,
        response varchar,
        gateway_id integer,
        x_yeti_auth varchar,
        diversion varchar,
        pai varchar,
        ppi varchar,
        privacy varchar,
        rpid varchar,
        rpid_privacy varchar
      );




  CREATE OR REPLACE FUNCTION switch.write_auth_log(
    i_is_master boolean,
    i_node_id integer,
    i_pop_id integer,
    i_request_time double precision,
    i_transport_proto_id smallint,
    i_transport_remote_ip varchar,
    i_transport_remote_port integer,
    i_transport_local_ip varchar,
    i_transport_local_port integer,
    i_username varchar,
    i_method varchar,
    i_ruri varchar,
    i_from_uri varchar,
    i_to_uri varchar,
    i_call_id varchar,
    i_success boolean,
    i_code smallint,
    i_reason varchar,
    i_internal_reason varchar,
    i_nonce varchar,
    i_response varchar,
    i_gateway_id integer,
    i_x_yeti_auth varchar,
    i_diversion varchar,
    i_origination_ip varchar,
    i_origination_port integer,
    i_origination_proto_id smallint,
    i_pai varchar,
    i_ppi varchar,
    i_privacy varchar,
    i_rpid varchar,
    i_rpid_privacy varchar
    )
  RETURNS integer AS
$BODY$
DECLARE

    v_log auth_log.auth_log%rowtype;
BEGIN

  v_log.node_id = i_node_id;
  v_log.pop_id = i_pop_id;
  v_log.request_time = to_timestamp(i_request_time);
  v_log.transport_proto_id = i_transport_proto_id;
  v_log.transport_remote_ip = i_transport_remote_ip;
  v_log.transport_remote_port = i_transport_remote_port;
  v_log.transport_local_ip = i_transport_local_ip;
  v_log.transport_local_port = i_transport_local_port;
  v_log.origination_ip = i_origination_ip;
  v_log.origination_port = i_origination_port;
  v_log.origination_proto_id = i_origination_proto_id;
  v_log.username = i_username;
  v_log.method = i_method;
  v_log.ruri = i_ruri;
  v_log.from_uri = i_from_uri;
  v_log.to_uri = i_to_uri;
  v_log.call_id = i_call_id;
  v_log.success = i_success;
  v_log.code = i_code;
  v_log.reason = i_reason;
  v_log.internal_reason = i_internal_reason;
  v_log.nonce = i_nonce;
  v_log.response = i_response;
  v_log.gateway_id = i_gateway_id;
  v_log.x_yeti_auth = i_x_yeti_auth;
  v_log.diversion = i_diversion;
  v_log.pai = i_pai;
  v_log.ppi = i_ppi;
  v_log.privacy = i_privacy;
  v_log.rpid = i_rpid;
  v_log.rpid_privacy = i_rpid_privacy;

  v_log.id = nextval('auth_log.auth_log_id_seq');

  insert into auth_log.auth_log values(v_log.*);

  RETURN 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 10;


    }

  end

  def down
    execute %q{
      drop schema auth_log cascade;
      drop FUNCTION switch.write_auth_log(
    i_is_master boolean,
    i_node_id integer,
    i_pop_id integer,
    i_request_time double precision,
    i_transport_proto_id smallint,
    i_transport_remote_ip varchar,
    i_transport_remote_port integer,
    i_transport_local_ip varchar,
    i_transport_local_port integer,
    i_username varchar,
    i_method varchar,
    i_ruri varchar,
    i_from_uri varchar,
    i_to_uri varchar,
    i_call_id varchar,
    i_success boolean,
    i_code smallint,
    i_reason varchar,
    i_internal_reason varchar,
    i_nonce varchar,
    i_response varchar,
    i_gateway_id integer,
    i_x_yeti_auth varchar,
    i_diversion varchar,
    i_origination_ip varchar,
    i_origination_port integer,
    i_origination_proto_id smallint,
    i_pai varchar,
    i_ppi varchar,
    i_privacy varchar,
    i_rpid varchar,
    i_rpid_privacy varchar
    );

    }
  end
end
