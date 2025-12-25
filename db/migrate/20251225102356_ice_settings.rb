class IceSettings < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      alter table class4.gateways
        add ice_mode_id smallint not null default 1,
        add rtcp_mux_mode_id smallint not null default 1,
        add rtcp_feedback_mode_id smallint not null default 1;

    drop FUNCTION switch22.load_gateway_attributes_cache();
    CREATE or replace FUNCTION switch22.load_gateway_attributes_cache() RETURNS TABLE(
    id bigint,
    throttling_codes character varying[],
    throttling_threshold_start real,
    throttling_threshold_end real,
    throttling_window smallint,
    throttling_minimum_calls smallint,
    transfer_append_headers_req character varying[],
    transfer_tel_uri_host character varying,
    ice_mode_id smallint,
    rtcp_mux_mode_id smallint,
    rtcp_feedback_mode_id smallint
    )
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
      gw.rtcp_feedback_mode_id
    FROM class4.gateways gw
    LEFT JOIN class4.gateway_throttling_profiles gtp ON gtp.id = gw.throttling_profile_id
    ORDER BY gw.id;
END;
$$;
    }
  end

  def down
    execute %q{
      alter table class4.gateways
        drop column ice_mode_id,
        drop column rtcp_mux_mode_id,
        drop column rtcp_feedback_mode_id;

        drop FUNCTION switch22.load_gateway_attributes_cache();

    CREATE or replace FUNCTION switch22.load_gateway_attributes_cache() RETURNS TABLE(id bigint, throttling_codes character varying[], throttling_threshold_start real, throttling_threshold_end real, throttling_window smallint, throttling_minimum_calls smallint, transfer_append_headers_req character varying[], transfer_tel_uri_host character varying)
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
      gw.transfer_tel_uri_host
    FROM class4.gateways gw
    LEFT JOIN class4.gateway_throttling_profiles gtp ON gtp.id = gw.throttling_profile_id
    ORDER BY gw.id;
END;
$$;

    }
  end
end
