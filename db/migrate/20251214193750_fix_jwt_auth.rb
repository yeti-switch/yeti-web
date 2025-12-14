class FixJwtAuth < ActiveRecord::Migration[7.2]
  def up
    execute %q{

    CREATE OR REPLACE FUNCTION switch22.load_incoming_auth()
 RETURNS TABLE(id integer, username character varying, password character varying, allow_jwt_auth boolean, jwt_gid character varying)
 LANGUAGE plpgsql
 COST 10 ROWS 10
AS $function$
BEGIN
  RETURN QUERY
    SELECT
      gw.id,
      gw.incoming_auth_username,
      gw.incoming_auth_password,
      gw.incoming_auth_allow_jwt,
      gw.uuid::varchar
    from class4.gateways gw
    where
      gw.enabled and
      (
        ( gw.incoming_auth_username is not null and gw.incoming_auth_password is not null and
          gw.incoming_auth_username !='' and gw.incoming_auth_password !=''
        )  OR
        incoming_auth_allow_jwt
      );
END;
$function$;

  INSERT INTO class4.transport_protocols(id,name) values(5,'WS');


    }
  end

  def down
    execute %q{

CREATE or replace FUNCTION switch22.load_incoming_auth() RETURNS TABLE(id integer, username character varying, password character varying, allow_jwt_auth boolean, jwt_gid character varying)
    LANGUAGE plpgsql COST 10 ROWS 10
    AS $$
BEGIN
  RETURN QUERY
    SELECT
      gw.id,
      gw.incoming_auth_username,
      gw.incoming_auth_password,
      gw.incoming_auth_allow_jwt,
      gw.id::varchar
    from class4.gateways gw
    where
      gw.enabled and
      (
        ( gw.incoming_auth_username is not null and gw.incoming_auth_password is not null and
          gw.incoming_auth_username !='' and gw.incoming_auth_password !=''
        )  OR
        incoming_auth_allow_jwt
      );
END;
$$;

  delete from class4.transport_protocols where id=5;

    }
  end
end
