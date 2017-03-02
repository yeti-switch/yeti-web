begin;
insert into sys.version(number,comment) values(33,'Call debug');

ALTER TABLE sys.guiconfig DROP COLUMN rowsperpage ;
ALTER TABLE sys.guiconfig ALTER COLUMN rows_per_page set DEFAULT '50,100';
ALTER TABLE sys.guiconfig ALTER COLUMN rows_per_page set NOT NULL ;

ALTER TABLE public.contractors DROP COLUMN tech_contact ;
ALTER TABLE public.contractors DROP COLUMN fin_contact ;
ALTER TABLE public.contractors add smtp_connection_id integer references  sys.smtp_connections(id);

set search_path TO notifications;
ALTER TABLE email_log DROP COLUMN attachments;
ALTER TABLE email_log RENAME TO email_logs;
ALTER TABLE email_logs add attachment_id integer;

CREATE TABLE attachments (
  id       SERIAL PRIMARY KEY,
  filename VARCHAR NOT NULL,
  data     BYTEA
);

alter table sys.smtp_connections add global boolean not null default true;


-- Function: runtime_stats.update_gw(integer, integer, boolean, integer)

-- DROP FUNCTION runtime_stats.update_gw(integer, integer, boolean, integer);

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
                        VALUES(i_cdr.term_gw_id,1,v_success,1-v_success,v_duration,v_duration::real/1,v_success::real/1);
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

-- Function: runtime_stats.update_dp(bigint, bigint, boolean, integer)

-- DROP FUNCTION runtime_stats.update_dp(bigint, bigint, boolean, integer);

CREATE OR REPLACE FUNCTION runtime_stats.update_dp(
  i_destination_id bigint,
  i_dialpeer_id bigint,
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
        if i_destination_id is null or i_dialpeer_id is null or i_destination_id=0 or i_dialpeer_id =0 then
            return;
        end if;

        v_success=i_success::integer;
        IF i_success THEN
                v_duration=i_duration;
        ELSE
                v_duration=0;
        END IF;
        UPDATE runtime_stats.dialpeers_stats SET
                calls=calls+1,calls_success=calls_success+v_success,calls_fail=calls_fail+(1-v_success),
                total_duration=total_duration+v_duration,
                acd=(total_duration+v_duration)::real/(calls+1)::real,
                asr=(calls_success+v_success)::real/(calls+1)::real
        WHERE dialpeer_id=i_dialpeer_id;
        IF NOT FOUND THEN
                -- we can get lost update in this case if row deleted in concurrent transaction. but this is minor issue;
                BEGIN
                        INSERT into runtime_stats.dialpeers_stats(dialpeer_id,calls,calls_success,calls_fail,total_duration,acd,asr)
                        VALUES(i_dialpeer_id,1,v_success,1-v_success,v_duration,v_duration::real/1,v_success::real/1);
                EXCEPTION
                        WHEN unique_violation THEN
                                UPDATE runtime_stats.dialpeers_stats SET
                                calls=calls+1,calls_success=calls_success+v_success,calls_fail=calls_fail+(1-v_success),
                                total_duration=total_duration+v_duration,
                                acd=(total_duration+v_duration)::real/(calls+1)::real,
                                asr=(calls_success+v_success)::real/(calls+1)::real
                                WHERE dialpeer_id=i_dialpeer_id;
                END;
        END IF;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 10;

commit;