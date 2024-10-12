class GwJwtAuth < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      alter table class4.gateways add incoming_auth_allow_jwt boolean not null default false;
      alter table data_import.import_gateways add incoming_auth_allow_jwt boolean not null default false;

      alter table sys.api_access add provision_gateway_id integer references class4.gateways(id);
      create index api_access_provision_gateway_id_idx on sys.api_access using btree(provision_gateway_id);

DROP FUNCTION switch21.load_incoming_auth();
CREATE FUNCTION switch21.load_incoming_auth() RETURNS TABLE(id integer, username character varying, password character varying, allow_jwt_auth boolean, jwt_gid varchar)
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

  def down
    execute %q{

DROP FUNCTION switch21.load_incoming_auth();
CREATE FUNCTION switch21.load_incoming_auth() RETURNS TABLE(id integer, username character varying, password character varying)
    LANGUAGE plpgsql COST 10 ROWS 10
    AS $$
BEGIN
  RETURN QUERY
    SELECT
      gw.id,
      gw.incoming_auth_username,
      gw.incoming_auth_password
    from class4.gateways gw
    where
      gw.enabled and
      gw.incoming_auth_username is not null and gw.incoming_auth_password is not null and
      gw.incoming_auth_username !='' and gw.incoming_auth_password !='';
END;
$$;
      alter table sys.api_access drop column provision_gateway_id;
      alter table class4.gateways drop column incoming_auth_allow_jwt;
      alter table data_import.import_gateways drop column incoming_auth_allow_jwt;

    }
  end
end
