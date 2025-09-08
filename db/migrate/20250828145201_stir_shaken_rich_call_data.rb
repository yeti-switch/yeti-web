class StirShakenRichCallData < ActiveRecord::Migration[7.2]
  def up
    execute %q{

      create table class4.stir_shaken_rcd_profiles(
        id serial primary key,
        external_id bigint,
        mode_id smallint not null default 1, -- inject by default
        created_at timestamp with time zone,
        updated_at timestamp with time zone,
        nam varchar not null,
        apn varchar, -- The "apn" key value is an optional alternate presentation number
        icn varchar, -- The "icn" key value is an optional HTTPS URL reference to an image resource that can be used
        jcd jsonb, -- The "jcd" key value is defined to contain a jCard JSON object [RFC7095]
        jcl varchar
      );

CREATE FUNCTION switch22.load_stir_shaken_rcd_profiles() RETURNS SETOF class4.stir_shaken_rcd_profiles
    LANGUAGE plpgsql COST 10
    AS $$

BEGIN
  RETURN QUERY SELECT * from class4.stir_shaken_rcd_profiles order by id;
END;
$$;

      INSERT INTO sys.states(key,value) values('stir_shaken_rcd_profiles', 1);

      DROP FUNCTION switch22.check_states();
      CREATE FUNCTION switch22.check_states() RETURNS TABLE(
        trusted_lb bigint,
        ip_auth bigint,
        stir_shaken_trusted_certificates bigint,
        stir_shaken_trusted_repositories bigint,
        stir_shaken_signing_certificates bigint,
        stir_shaken_rcd_profiles bigint,
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

  def down
    execute %q{

DROP FUNCTION switch22.load_stir_shaken_rcd_profiles();

drop table class4.stir_shaken_rcd_profiles;

DELETE from sys.states where key = 'stir_shaken_rcd_profiles';

DROP FUNCTION switch22.check_states();
CREATE FUNCTION switch22.check_states() RETURNS TABLE(trusted_lb bigint, ip_auth bigint, stir_shaken_trusted_certificates bigint, stir_shaken_trusted_repositories bigint, stir_shaken_signing_certificates bigint, sensors bigint, translations bigint, codec_groups bigint, registrations bigint, radius_authorization_profiles bigint, radius_accounting_profiles bigint, auth_credentials bigint, options_probers bigint, gateways_cache bigint)
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
        (select value from sys.states where key = 'options_probers'),
        (select value from sys.states where key = 'gateways_cache');
    END;
    $$;

    }
  end
end
