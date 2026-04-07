# frozen_string_literal: true

class PerLegGwCache < ActiveRecord::Migration[7.0]
  def up
    execute %q{
CREATE FUNCTION switch22.load_aleg_gateway_attributes_cache() RETURNS TABLE(id bigint, ice_mode_id smallint, rtcp_mux_mode_id smallint, rtcp_feedback_mode_id smallint, allowed_methods character varying[], supported_tags character varying[])
    LANGUAGE plpgsql COST 10
    AS $$
BEGIN
  RETURN QUERY
    SELECT
      gw.id::bigint,
      gw.ice_mode_id,
      gw.rtcp_mux_mode_id,
      gw.rtcp_feedback_mode_id,
      gw.allowed_methods,
      gw.supported_tags
    FROM class4.gateways gw
    ORDER BY gw.id;
END;
$$;

CREATE FUNCTION switch22.load_bleg_gateway_attributes_cache() RETURNS TABLE(id bigint, throttling_codes character varying[], throttling_threshold_start real, throttling_threshold_end real, throttling_window smallint, throttling_minimum_calls smallint, transfer_append_headers_req character varying[], transfer_tel_uri_host character varying, ice_mode_id smallint, rtcp_mux_mode_id smallint, rtcp_feedback_mode_id smallint, allowed_methods character varying[], supported_tags character varying[])
    LANGUAGE plpgsql COST 10
    AS $$
BEGIN
  RETURN QUERY
    SELECT
      gw.id::bigint,
      gtp.codes as throttling_codes,
      gtp.threshold_start as throttling_threshold_start,
      gtp.threshold_end as throttling_threshold_end,
      gtp."window" as throttling_window,
      gtp.minimum_calls as throttling_minimum_calls,
      gw.transfer_append_headers_req,
      gw.transfer_tel_uri_host,
      gw.ice_mode_id,
      gw.rtcp_mux_mode_id,
      gw.rtcp_feedback_mode_id,
      gw.allowed_methods,
      gw.supported_tags
    FROM class4.gateways gw
    LEFT JOIN class4.gateway_throttling_profiles gtp ON gtp.id = gw.throttling_profile_id
    ORDER BY gw.id;
END;
$$;

INSERT INTO sys.states(key, value) VALUES('aleg_gateways_cache', 1);
INSERT INTO sys.states(key, value) VALUES('bleg_gateways_cache', 1);

DROP FUNCTION switch22.check_states();
CREATE FUNCTION switch22.check_states() RETURNS TABLE(trusted_lb bigint, ip_auth bigint, stir_shaken_trusted_certificates bigint, stir_shaken_trusted_repositories bigint, stir_shaken_signing_certificates bigint, stir_shaken_rcd_profiles bigint, sensors bigint, translations bigint, codec_groups bigint, registrations bigint, radius_authorization_profiles bigint, radius_accounting_profiles bigint, auth_credentials bigint, options_probers bigint, gateways_cache bigint, aleg_gateways_cache bigint, bleg_gateways_cache bigint)
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
        (select value from sys.states where key = 'stir_shaken_rcd_profiles'),
        (select value from sys.states where key = 'sensors'),
        (select value from sys.states where key = 'translations'),
        (select value from sys.states where key = 'codec_groups'),
        (select value from sys.states where key = 'registrations'),
        (select value from sys.states where key = 'radius_authorization_profiles'),
        (select value from sys.states where key = 'radius_accounting_profiles'),
        (select value from sys.states where key = 'auth_credentials'),
        (select value from sys.states where key = 'options_probers'),
        (select value from sys.states where key = 'gateways_cache'),
        (select value from sys.states where key = 'aleg_gateways_cache'),
        (select value from sys.states where key = 'bleg_gateways_cache');
    END;
    $$;
    }
  end

  def down
    execute %q{
DROP FUNCTION switch22.load_aleg_gateway_attributes_cache();
DROP FUNCTION switch22.load_bleg_gateway_attributes_cache();

DELETE FROM sys.states WHERE key IN ('aleg_gateways_cache', 'bleg_gateways_cache');

DROP FUNCTION switch22.check_states();
CREATE FUNCTION switch22.check_states() RETURNS TABLE(trusted_lb bigint, ip_auth bigint, stir_shaken_trusted_certificates bigint, stir_shaken_trusted_repositories bigint, stir_shaken_signing_certificates bigint, stir_shaken_rcd_profiles bigint, sensors bigint, translations bigint, codec_groups bigint, registrations bigint, radius_authorization_profiles bigint, radius_accounting_profiles bigint, auth_credentials bigint, options_probers bigint, gateways_cache bigint)
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
        (select value from sys.states where key = 'stir_shaken_rcd_profiles'),
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
    $$;
    }
  end
end
