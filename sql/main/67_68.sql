begin;
insert into sys.version(number,comment) values(68,'indexes');

create index ON class4.lnp_cache using btree (expires_at);
create index ON logs.api_requests using btree (created_at );

ALTER TABLE class4.lnp_databases add csv_file varchar;
ALTER TABLE class4.lnp_cache add tag varchar;

DROP FUNCTION switch8.load_lnp_databases();

CREATE OR REPLACE FUNCTION switch8.load_lnp_databases()
  RETURNS TABLE(
    o_id smallint,
    o_name character varying,
    o_driver_id smallint,
    o_host character varying,
    o_port integer,
    o_thinq_username character varying,
    o_thinq_token character varying,
    o_timeout smallint,
    o_csv_file varchar
    ) AS
$BODY$
BEGIN
    RETURN
    QUERY SELECT id, name, driver_id, host, port, thinq_username, thinq_token, timeout, csv_file from class4.lnp_databases;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 10
  ROWS 1000;

INSERT INTO sys.lnp_database_drivers(id,name) VALUES (3,'In-memory hash');


commit;