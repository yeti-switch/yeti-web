class FixLoadIncomingAuth < ActiveRecord::Migration[7.0]

  def up
    execute %q{
CREATE or replace FUNCTION switch21.load_incoming_auth() RETURNS TABLE(id integer, username character varying, password character varying, allow_jwt_auth boolean, jwt_gid varchar)
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


    }
  end

  def down
    execute %q{
CREATE or replace FUNCTION switch21.load_incoming_auth() RETURNS TABLE(id integer, username character varying, password character varying, allow_jwt_auth boolean, jwt_gid varchar)
    LANGUAGE plpgsql COST 10 ROWS 10
    AS $$
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
$$;


    }
  end
end
