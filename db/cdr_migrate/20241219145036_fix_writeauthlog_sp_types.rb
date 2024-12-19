class FixWriteauthlogSpTypes < ActiveRecord::Migration[7.0]

  def up
    execute %q{
alter table auth_log.auth_log
  alter column transport_remote_ip type inet USING transport_remote_ip::inet,
  alter column transport_local_ip type inet USING transport_local_ip::inet;

alter type switch.lega_request_headers_ty
  add attribute x_yeti_auth varchar,
  add attribute x_orig_ip varchar,
  add attribute x_orig_port varchar,
  add attribute x_orig_proto varchar;

CREATE FUNCTION switch.write_auth_log(
i_is_master boolean,
i_node_id integer,
i_pop_id integer,
i_request_time double precision,
i_transport_proto_id smallint,
i_transport_remote_ip inet,
i_transport_remote_port integer,
i_transport_local_ip inet,
i_transport_local_port integer,
i_username character varying,
i_realm character varying,
i_method character varying,
i_ruri character varying,
i_from_uri character varying,
i_to_uri character varying,
i_call_id character varying,
i_success boolean,
i_code smallint,
i_reason character varying,
i_internal_reason character varying,
i_nonce character varying,
i_response character varying,
i_gateway_id integer,
i_lega_request_headers json
) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER COST 10
    AS $$
DECLARE
    v_lega_request_headers switch.lega_request_headers_ty;
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

  v_log.username = i_username;
  v_log.realm = i_realm;
  v_log.request_method = i_method;
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

  v_lega_request_headers = json_populate_record(null::switch.lega_request_headers_ty, i_lega_request_headers);

  v_log.origination_ip = v_lega_request_headers.x_orig_ip::inet;
  v_log.origination_port = v_lega_request_headers.x_orig_port::integer;
  v_log.origination_proto_id = v_lega_request_headers.x_orig_proto::smallint;

  v_log.x_yeti_auth = v_lega_request_headers.x_yeti_auth;
  v_log.diversion = array_to_string(v_lega_request_headers.diversion, ',');
  v_log.pai = array_to_string(v_lega_request_headers.p_asserted_identity, ',');
  v_log.ppi = v_lega_request_headers.p_preferred_identity;
  v_log.privacy = array_to_string(v_lega_request_headers.privacy, ',');
  v_log.rpid = array_to_string(v_lega_request_headers.remote_party_id, ',');
  v_log.rpid_privacy = array_to_string(v_lega_request_headers.rpid_privacy, ',');

  v_log.id = nextval('auth_log.auth_log_id_seq');

  insert into auth_log.auth_log values(v_log.*);

  RETURN 0;
END;
$$;


    }
  end

  def down
    execute %q{

      alter table auth_log.auth_log
        alter column transport_remote_ip type varchar USING transport_remote_ip::varchar,
        alter column transport_local_ip type varchar USING transport_local_ip::varchar;

      alter type switch.lega_request_headers_ty
        drop attribute x_yeti_auth,
        drop attribute x_orig_ip,
        drop attribute x_orig_port,
        drop attribute x_orig_proto;


DROP FUNCTION switch.write_auth_log(
i_is_master boolean,
i_node_id integer,
i_pop_id integer,
i_request_time double precision,
i_transport_proto_id smallint,
i_transport_remote_ip inet,
i_transport_remote_port integer,
i_transport_local_ip inet,
i_transport_local_port integer,
i_username character varying,
i_realm character varying,
i_method character varying,
i_ruri character varying,
i_from_uri character varying,
i_to_uri character varying,
i_call_id character varying,
i_success boolean,
i_code smallint,
i_reason character varying,
i_internal_reason character varying,
i_nonce character varying,
i_response character varying,
i_gateway_id integer,
i_lega_request_headers json
);

    }
  end

end
