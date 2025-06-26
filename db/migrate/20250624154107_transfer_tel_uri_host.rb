class TransferTelUriHost < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      alter table class4.gateways
        add transfer_append_headers_req varchar[] not null default '{}'::character varying[],
        add transfer_tel_uri_host varchar;

      DROP FUNCTION switch22.load_gateway_attributes_cache();

CREATE OR REPLACE FUNCTION switch22.load_gateway_attributes_cache()
 RETURNS TABLE(
 id bigint,
 throttling_codes varchar[],
 throttling_threshold_start real,
 throttling_threshold_end real,
 throttling_window smallint,
 throttling_minimum_calls smallint,
 transfer_append_headers_req varchar[],
 transfer_tel_uri_host varchar
 )
 LANGUAGE plpgsql
 COST 10
AS $function$
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
      gw.transfer_tel_uri_host
    FROM class4.gateways gw
    LEFT JOIN class4.gateway_throttling_profiles gtp ON gtp.id = gw.throttling_profile_id
    ORDER BY gw.id;
END;
$function$;

    }
  end

  def down
    execute %q{


DROP FUNCTION switch22.load_gateway_attributes_cache();
CREATE OR REPLACE FUNCTION switch22.load_gateway_attributes_cache()
 RETURNS TABLE(
 id bigint,
 throttling_codes varchar[],
 throttling_threshold_start real,
 throttling_threshold_end real,
 throttling_window smallint,
 throttling_minimum_calls smallint
 )
 LANGUAGE plpgsql
 COST 10
AS $function$
BEGIN
  RETURN QUERY
    SELECT
      gw.id::bigint,
      gtp.codes as throttling_codes,
      gtp.threshold_start as throttling_threshold_start,
      gtp.threshold_end as throttling_threshold_end,
      gtp."window" as throttling_window,
      gtp.minimum_calls as throttling_minimum_calls
    FROM class4.gateways gw
    LEFT JOIN class4.gateway_throttling_profiles gtp ON gtp.id = gw.throttling_profile_id
    ORDER BY gw.id;
END;
$function$;

      alter table class4.gateways
        drop column transfer_append_headers_req,
        drop column transfer_tel_uri_host;
    }
  end
end
