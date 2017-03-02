begin;
insert into sys.version(number,comment) values(34,'New type of scheduler');


INSERT INTO sys.jobs (type) VALUES ('ReportScheduler');


CREATE OR REPLACE FUNCTION runtime_stats.update_gw(
  i_orig_gw_id integer,
  i_term_gw_id integer,
  i_success boolean,
  i_duration integer)
  RETURNS void AS
  $BODY$

DECLARE
i integer;
v_id bigint;
v_success integer;
v_duration integer;
BEGIN
    if i_term_gw_id is null or i_term_gw_id is null then
        return;
    end if;
        v_success=i_success::integer;
        IF i_success THEN
                v_duration=i_duration;
        ELSE
                v_duration=0;
        END IF;
        UPDATE runtime_stats.gateways_stats SET
                calls=calls+1,calls_success=calls_success+v_success,calls_fail=calls_fail+(1-v_success),
                total_duration=total_duration+v_duration,
                acd=(total_duration+v_duration)::real/(calls+1)::real,
                asr=(calls_success+v_success)::real/(calls+1)::real
        WHERE gateway_id=i_term_gw_id;
        IF NOT FOUND THEN
                -- we can get lost update in this case if row deleted in concurrent transaction. but this is minor issue;
                BEGIN
                        INSERT into runtime_stats.gateways_stats(gateway_id,calls,calls_success,calls_fail,total_duration,acd,asr)
                        VALUES(i_term_gw_id,1,v_success,1-v_success,v_duration,v_duration::real/1,v_success::real/1);
                EXCEPTION
                        WHEN unique_violation THEN
                                UPDATE runtime_stats.gateways_stats SET
                                calls=calls+1,calls_success=calls_success+v_success,calls_fail=calls_fail+(1-v_success),
                                total_duration=total_duration+v_duration,
                                acd=(total_duration+v_duration)::real/(calls+1)::real,
                                asr=(calls_success+v_success)::real/(calls+1)::real
                                WHERE gateway_id=i_term_gw_id;
                END;
        END IF;

END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 10;

commit;