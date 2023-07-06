class AddLoadStirShakenKeys < ActiveRecord::Migration[7.0]
  def up
    execute %q{
create table class4.stir_shaken_signing_certificates (
    id smallserial primary key,
    name varchar not null,
    certificate varchar not null,
    key varchar not null,
    url varchar not null,
    updated_at timestamptz
);

CREATE FUNCTION switch20.load_stir_shaken_signing_certificates() RETURNS SETOF class4.stir_shaken_signing_certificates
    LANGUAGE plpgsql COST 10
    AS $$

BEGIN
  RETURN QUERY SELECT * from class4.stir_shaken_signing_certificates order by id;
END;
$$;

INSERT INTO sys.states(key,value) VALUES('stir_shaken_signing_certificates',1);

DROP FUNCTION switch20.check_states();
CREATE FUNCTION switch20.check_states() RETURNS TABLE(
    trusted_lb bigint,
    ip_auth bigint,
    stir_shaken_trusted_certificates bigint, stir_shaken_trusted_repositories bigint, stir_shaken_signing_certificates bigint,
    sensors bigint,
    translations bigint,
    codec_groups bigint,
    registrations bigint,
    radius_authorization_profiles bigint, radius_accounting_profiles bigint,
    auth_credentials bigint, options_probers bigint
    )
    LANGUAGE plpgsql COST 10 ROWS 100
    AS $$
    BEGIN
    RETURN QUERY
      SELECT
        (select value from sys.states where key = 'load_balancers'),
        (select value from sys.states where key = 'customers_auth'),
        (select value from sys.states where key = 'stir_shaken_trusted_certificates'),
        (select value from sys.states where key = 'stir_shaken_trusted_repositories'),
        (select value from sys.states where key = 'stir_shaken_signing_certificates'),
        (select value from sys.states where key = 'sensors'),
        (select value from sys.states where key = 'translations'),
        (select value from sys.states where key = 'codec_groups'),
        (select value from sys.states where key = 'registrations'),
        (select value from sys.states where key = 'radius_authorization_profiles'),
        (select value from sys.states where key = 'radius_accounting_profiles'),
        (select value from sys.states where key = 'auth_credentials'),
        (select value from sys.states where key = 'options_probers');
    END;
    $$;


}
  end

  def down
    execute %q{
DROP FUNCTION switch20.load_stir_shaken_signing_certificates();
drop table class4.stir_shaken_signing_certificates;

delete from sys.states where key = 'stir_shaken_signing_certificates';

DROP FUNCTION switch20.check_states();
CREATE FUNCTION switch20.check_states() RETURNS TABLE(trusted_lb bigint, ip_auth bigint, stir_shaken_trusted_certificates bigint, stir_shaken_trusted_repositories bigint, sensors bigint, translations bigint, codec_groups bigint, registrations bigint, radius_authorization_profiles bigint, radius_accounting_profiles bigint, auth_credentials bigint, options_probers bigint)
    LANGUAGE plpgsql COST 10 ROWS 100
    AS $$
    BEGIN
    RETURN QUERY
      SELECT
        (select value from sys.states where key = 'load_balancers'),
        (select value from sys.states where key = 'customers_auth'),
        (select value from sys.states where key = 'stir_shaken_trusted_certificates'),
        (select value from sys.states where key = 'stir_shaken_trusted_repositories'),
        (select value from sys.states where key = 'sensors'),
        (select value from sys.states where key = 'translations'),
        (select value from sys.states where key = 'codec_groups'),
        (select value from sys.states where key = 'registrations'),
        (select value from sys.states where key = 'radius_authorization_profiles'),
        (select value from sys.states where key = 'radius_accounting_profiles'),
        (select value from sys.states where key = 'auth_credentials'),
        (select value from sys.states where key = 'options_probers');
    END;
    $$;

}
  end


end
