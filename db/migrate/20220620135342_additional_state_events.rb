class AdditionalStateEvents < ActiveRecord::Migration[6.1]
  def up
    execute %q{
      INSERT INTO sys.states(key,value) VALUES('sensors',1);
      INSERT INTO sys.states(key,value) VALUES('translations',1);
      INSERT INTO sys.states(key,value) VALUES('codec_groups',1);
      INSERT INTO sys.states(key,value) VALUES('registrations',1);
      INSERT INTO sys.states(key,value) VALUES('radius_authorization_profiles',1);
      INSERT INTO sys.states(key,value) VALUES('radius_accounting_profiles',1);
      INSERT INTO sys.states(key,value) VALUES('auth_credentials',1);
      INSERT INTO sys.states(key,value) VALUES('options_probers',1);

DROP FUNCTION switch20.check_states();
CREATE OR REPLACE FUNCTION switch20.check_states() RETURNS TABLE(
  trusted_lb bigint,
  ip_auth bigint,
  stir_shaken_trusted_certificates bigint,
  stir_shaken_trusted_repositories bigint,
  sensors bigint,
  translations bigint,
  codec_groups bigint,
  registrations bigint,
  radius_authorization_profiles bigint,
  radius_accounting_profiles bigint,
  auth_credentials bigint,
  options_probers bigint
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
DROP FUNCTION switch20.check_states();
CREATE OR REPLACE FUNCTION switch20.check_states() RETURNS TABLE(trusted_lb bigint, ip_auth bigint, stir_shaken_trusted_certificates bigint, stir_shaken_trusted_repositories bigint)
    LANGUAGE plpgsql COST 10 ROWS 100
    AS $$
    BEGIN
    RETURN QUERY
      SELECT
        (select value from sys.states where key = 'load_balancers'),
        (select value from sys.states where key = 'customers_auth'),
        (select value from sys.states where key = 'stir_shaken_trusted_certificates'),
        (select value from sys.states where key = 'stir_shaken_trusted_repositories');
    END;
    $$;

    delete from sys.states where key in (
      'sensors',
      'translations',
      'codec_groups',
      'registrations',
      'radius_authorization_profiles',
      'radius_accounting_profiles',
      'auth_credentials',
      'options_probers'
    );

            }

  end
end
