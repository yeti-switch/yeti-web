class GwThrottlingProfile < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      create table class4.gateway_throttling_profiles(
        id smallserial primary key not null,
        name varchar unique not null,
        codes varchar[] not null,
        threshold_start real not null,
        threshold_end real not null,
        "window" smallint not null
      );

      alter table class4.gateways
        add throttling_profile_id smallint references class4.gateway_throttling_profiles(id);

      create index "gateways_throttling_profile_id_idx" on class4.gateways using btree(throttling_profile_id);

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

insert into sys.states(key,value) values('gateways_cache', 1);

    }
  end

  def down
    execute %q{
      DROP FUNCTION switch22.load_gateway_attributes_cache();

      alter table class4.gateways
        drop column throttling_profile_id;

      drop table class4.gateway_throttling_profiles;

      delete from sys.states where key = 'gateways_cache';

    }
  end

end
