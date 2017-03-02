begin;
insert into sys.version(number,comment) values(67,'Ringing timeout disconnect code');


ALTER TABLE class4.lnp_databases add timeout smallint not null default 300;

DROP FUNCTION switch8.load_lnp_databases();

CREATE OR REPLACE FUNCTION switch8.load_lnp_databases()
  RETURNS TABLE(o_id smallint, o_name character varying, o_driver_id smallint, o_host character varying, o_port integer, o_thinq_username character varying, o_thinq_token character varying, o_timeout smallint) AS
  $BODY$
BEGIN
    RETURN
    QUERY SELECT id, name, driver_id, host, port, thinq_username, thinq_token, timeout from class4.lnp_databases;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 10
ROWS 1000;

commit;