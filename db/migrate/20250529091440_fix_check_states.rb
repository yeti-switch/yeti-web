class FixCheckStates < ActiveRecord::Migration[7.2]
  def up
    execute %q{

insert into class4.disconnect_code
  (id, namespace_id, stop_hunting, pass_reason_to_originator, code, reason, rewrited_code, rewrited_reason, success, successnozerolen, store_cdr, silently_drop)
values
  (133, 1, true, false, 480, 'Term. gw throttled', 480, 'Temporarily Unavailable', false, true,  true, false);

drop function switch22.check_states();
CREATE OR REPLACE FUNCTION switch22.check_states()
 RETURNS TABLE(
  trusted_lb bigint,
  ip_auth bigint,
  stir_shaken_trusted_certificates bigint,
  stir_shaken_trusted_repositories bigint,
  stir_shaken_signing_certificates bigint,
  sensors bigint,
  translations bigint,
  codec_groups bigint,
  registrations bigint,
  radius_authorization_profiles bigint,
  radius_accounting_profiles bigint,
  auth_credentials bigint,
  options_probers bigint,
  gateways_cache bigint
)
 LANGUAGE plpgsql
 COST 10 ROWS 100
AS $function$
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
        (select value from sys.states where key = 'options_probers'),
        (select value from sys.states where key = 'gateways_cache');
    END;
    $function$
    ;
    }
  end

    def down
    execute %q{

drop function switch22.check_states();
CREATE OR REPLACE FUNCTION switch22.check_states()
 RETURNS TABLE(trusted_lb bigint, ip_auth bigint, stir_shaken_trusted_certificates bigint, stir_shaken_trusted_repositories bigint, stir_shaken_signing_certificates bigint, sensors bigint, translations bigint, codec_groups bigint, registrations bigint, radius_authorization_profiles bigint, radius_accounting_profiles bigint, auth_credentials bigint, options_probers bigint)
 LANGUAGE plpgsql
 COST 10 ROWS 100
AS $function$
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
    $function$
    ;

    delete from class4.disconnect_code where id=133;

    }
  end
end
