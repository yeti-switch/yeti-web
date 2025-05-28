class GwThrottlingMinCalls < ActiveRecord::Migration[7.2]

  def up
    execute %q{
      alter table class4.gateway_throttling_profiles add minimum_calls smallint not null default 20;

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

    }
  end


  def down
    execute %q{

DROP FUNCTION switch22.load_gateway_attributes_cache();
CREATE OR REPLACE FUNCTION switch22.load_gateway_attributes_cache()
 RETURNS TABLE(id bigint, throttling_codes varchar[], throttling_threshold_start real, throttling_threshold_end real, throttling_window smallint)
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
      gtp."window" as throttling_window
    FROM class4.gateways gw
    LEFT JOIN class4.gateway_throttling_profiles gtp ON gtp.id = gw.throttling_profile_id
    ORDER BY gw.id;
END;
$function$;

alter table class4.gateway_throttling_profiles drop column minimum_calls;

    }
  end

end
