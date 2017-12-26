class IncomingSipAuth < ActiveRecord::Migration
  def up
    execute %q{
      alter table class4.customers_auth add require_sip_auth boolean not null default false;
      alter table data_import.import_customers_auth add require_sip_auth boolean;

      alter table class4.gateways
        add incoming_auth_username varchar,
        add incoming_auth_password varchar;

      alter table data_import.import_gateways
        add incoming_auth_username varchar,
        add incoming_auth_password varchar;


CREATE OR REPLACE FUNCTION switch14.load_incoming_auth()
  RETURNS TABLE(id integer, username character varying, password character varying) AS
$BODY$
BEGIN
  RETURN QUERY SELECT gw.id, gw.incoming_auth_username, gw.incoming_auth_password from class4.gateways gw where gw.enabled;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 10
  ROWS 10;

    }
  end

  def down
    execute %q{

    drop FUNCTION switch14.load_incoming_auth();

      alter table class4.customers_auth drop column require_sip_auth;
      alter table data_import.import_customers_auth drop column require_sip_auth;

      alter table class4.gateways
        drop column incoming_auth_username,
        drop column incoming_auth_password;

      alter table data_import.import_gateways
        drop column incoming_auth_username,
        drop column incoming_auth_password;

    }
  end

end
