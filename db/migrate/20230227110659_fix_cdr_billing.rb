class FixCdrBilling < ActiveRecord::Migration[6.1]
  def up
    execute %q{

CREATE or replace FUNCTION runtime_stats.update_dp(
  i_dialpeer_id bigint,
  i_calls integer,
  i_successful_calls integer,
  i_failed_calls integer,
  i_duration integer
) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
BEGIN
        if i_dialpeer_id is null OR i_calls is null OR i_successful_calls is null OR i_failed_calls is null OR i_duration IS NULL then
            return;
        end if;

        UPDATE runtime_stats.dialpeers_stats SET
          calls = calls + i_calls,
          calls_success = calls_success + i_successful_calls,
          calls_fail = calls_fail + i_failed_calls,
          total_duration = total_duration + i_duration,
          acd = coalesce((total_duration + i_duration )::real/nullif((calls_success + i_successful_calls),0)::real,0),
          asr = (calls_success + i_successful_calls)::real/(calls + i_calls)::real
        WHERE dialpeer_id = i_dialpeer_id;
        IF NOT FOUND THEN
          /* Unique violation possible there in if multiple CDR billed in parallel. This case is not valid, let it fail */
          INSERT into runtime_stats.dialpeers_stats(
            dialpeer_id,
            calls,
            calls_success,
            calls_fail,
            total_duration,
            acd,
            asr
          ) VALUES(
            i_dialpeer_id,
            i_calls,
            i_successful_calls,
            i_failed_calls,
            i_duration,
            coalesce(i_duration::real/nullif(i_successful_calls,0)::real,0),
            i_successful_calls::real/i_calls::real
          );
        END IF;
END;
$$;

CREATE or replace FUNCTION runtime_stats.update_gw(
  i_gw_id bigint,
  i_calls integer,
  i_successful_calls integer,
  i_failed_calls integer,
  i_duration integer
)
 RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$

DECLARE

BEGIN

    if i_gw_id is null OR i_calls is null OR i_successful_calls is null OR i_failed_calls is null OR i_duration IS NULL then
      return;
    end if;

    UPDATE runtime_stats.gateways_stats SET
      calls = calls + i_calls,
      calls_success = calls_success + i_successful_calls,
      calls_fail = calls_fail + i_failed_calls,
      total_duration = total_duration + i_duration,
      acd = coalesce((total_duration + i_duration )::real/nullif(calls_success + i_successful_calls,0)::real,0),
      asr = (calls_success + i_successful_calls)::real/(calls + i_calls)::real
    WHERE gateway_id = i_gw_id;
    IF NOT FOUND THEN
      /* Unique violation possible there in if multiple CDR billed in parallel. This case is not valid, let it fail */
      INSERT into runtime_stats.gateways_stats(
        gateway_id,
        calls,
        calls_success,
        calls_fail,
        total_duration,
        acd,
        asr
      ) VALUES(
        i_gw_id,
        i_calls,
        i_successful_calls,
        i_failed_calls,
        i_duration,
        coalesce(i_duration::real/nullif(i_successful_calls,0)::real,0),
        i_successful_calls::real/i_calls::real
      );
    END IF;
END;
$$;}
  end


  def down
    execute %q{

CREATE or replace FUNCTION runtime_stats.update_dp(
  i_dialpeer_id bigint,
  i_calls integer,
  i_successful_calls integer,
  i_failed_calls integer,
  i_duration integer
) RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
BEGIN
        if i_dialpeer_id is null OR i_calls is null OR i_successful_calls is null OR i_failed_calls is null OR i_duration IS NULL then
            return;
        end if;

        UPDATE runtime_stats.dialpeers_stats SET
          calls = calls + i_calls,
          calls_success = calls_success + i_successful_calls,
          calls_fail = calls_fail + i_failed_calls,
          total_duration = total_duration + i_duration,
          acd = (total_duration + i_duration )::real/(calls_success + i_successful_calls)::real,
          asr = (calls_success + i_successful_calls)::real/(calls + i_calls)::real
        WHERE dialpeer_id = i_dialpeer_id;
        IF NOT FOUND THEN
          /* Unique violation possible there in if multiple CDR billed in parallel. This case is not valid, let it fail */
          INSERT into runtime_stats.dialpeers_stats(
            dialpeer_id,
            calls,
            calls_success,
            calls_fail,
            total_duration,
            acd,
            asr
          ) VALUES(
            i_dialpeer_id,
            i_calls,
            i_successful_calls,
            i_failed_calls,
            i_duration,
            i_duration::real/i_successful_calls::real,
            i_successful_calls::real/i_calls::real
          );
        END IF;
END;
$$;

CREATE or replace FUNCTION runtime_stats.update_gw(
  i_gw_id bigint,
  i_calls integer,
  i_successful_calls integer,
  i_failed_calls integer,
  i_duration integer
)
 RETURNS void
    LANGUAGE plpgsql COST 10
    AS $$

DECLARE

BEGIN

    if i_gw_id is null OR i_calls is null OR i_successful_calls is null OR i_failed_calls is null OR i_duration IS NULL then
      return;
    end if;

    UPDATE runtime_stats.gateways_stats SET
      calls = calls + i_calls,
      calls_success = calls_success + i_successful_calls,
      calls_fail = calls_fail + i_failed_calls,
      total_duration = total_duration + i_duration,
      acd = (total_duration + i_duration )::real/(calls_success + i_successful_calls)::real,
      asr = (calls_success + i_successful_calls)::real/(calls + i_calls)::real
    WHERE gateway_id = i_gw_id;
    IF NOT FOUND THEN
      /* Unique violation possible there in if multiple CDR billed in parallel. This case is not valid, let it fail */
      INSERT into runtime_stats.gateways_stats(
        gateway_id,
        calls,
        calls_success,
        calls_fail,
        total_duration,
        acd,
        asr
      ) VALUES(
        i_gw_id,
        i_calls,
        i_successful_calls,
        i_failed_calls,
        i_duration,
        i_duration::real/i_successful_calls::real,
        i_successful_calls::real/i_calls::real
      );
    END IF;
END;
$$;}
  end
end
