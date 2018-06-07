class AuthLog < ActiveRecord::Migration[5.1]
  def up

    execute %q{
      create schema auth_log;
      create table auth_log.auth_log (
        id bigserial primary key,
        node_id smallint,
        pop_id smallint,
        request_time timestamptz not null default now(),
        sign_orig_ip varchar,
        sign_orig_port integer,
        sign_orig_local_ip varchar,
        sign_orig_local_port integer,
        auth_orig_ip varchar,
        auth_orig_port integer,
        ruri varchar,
        from_uri varchar,
        to_uri varchar,
        orig_call_id varchar,
        success boolean not null default false,
        code smallint,
        reason varchar,
        internal_reason varchar,
        nonce varchar,
        response varchar,
        gateway_id integer
      );


  CREATE OR REPLACE FUNCTION switch.write_auth_log(
    i_is_master boolean,
    i_node_id integer,
    i_pop_id integer,
    i_request_time double precision,
    i_sign_orig_ip varchar,
    i_sign_orig_port integer,
    i_sign_orig_local_ip varchar,
    i_sign_orig_local_port integer,
    i_ruri varchar,
    i_from_uri varchar,
    i_to_uri varchar,
    i_orig_call_id varchar,
    i_success boolean,
    i_code smallint,
    i_reason varchar,
    i_internal_reason varchar,
    i_nonce varchar,
    i_response varchar,
    i_gateway_id integer
    )
  RETURNS integer AS
$BODY$
DECLARE
BEGIN
  INSERT INTO auth_log.auth_log (
        node_id,
        pop_id,
        request_time,
        sign_orig_ip,
        sign_orig_port,
        sign_orig_local_ip,
        sign_orig_local_port,
        auth_orig_ip,
        auth_orig_port,
        ruri,
        from_uri,
        to_uri,
        orig_call_id,
        success,
        code,
        reason,
        internal_reason,
        nonce,
        response,
        gateway_id
      ) VALUES(
        i_node_id,
        i_pop_id,
        to_timestamp(i_request_time),
        i_sign_orig_ip,
        i_sign_orig_port,
        i_sign_orig_local_ip,
        i_sign_orig_local_port,
        null,
        null,
        i_ruri,
        i_from_uri,
        i_to_uri,
        i_orig_call_id,
        i_success,
        i_code,
        i_reason,
        i_internal_reason,
        i_nonce,
        i_response,
        i_gateway_id
    );
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
    i_sign_orig_ip varchar,
    i_sign_orig_port integer,
    i_sign_orig_local_ip varchar,
    i_sign_orig_local_port integer,
    i_ruri varchar,
    i_from_uri varchar,
    i_to_uri varchar,
    i_orig_call_id varchar,
    i_success boolean,
    i_code smallint,
    i_reason varchar,
    i_internal_reason varchar,
    i_nonce varchar,
    i_response varchar,
    i_gateway_id integer
    );

    }
  end
end
