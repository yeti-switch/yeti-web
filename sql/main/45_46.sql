begin;
insert into sys.version(number,comment) values(46,'New LNP driver');


INSERT INTO sys.lnp_database_drivers(id,name) VALUES (2,'thinQ REST LRN Driver');
ALTER TABLE class4.lnp_databases add thinq_token varchar;

DROP FUNCTION switch8.load_lnp_databases();

CREATE OR REPLACE FUNCTION switch8.load_lnp_databases()
  RETURNS TABLE(
    o_id smallint,
    o_name character varying,
    o_driver_id smallint,
    o_host character varying,
    o_port integer,
    o_thinq_token varchar
  ) AS
  $BODY$
BEGIN
    RETURN
    QUERY SELECT id, name, driver_id, host, port, thinq_token from class4.lnp_databases;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 10
ROWS 1000;


INSERT INTO notifications.alerts (event) VALUES ('DialpeerUnlocked');
INSERT INTO notifications.alerts (event) VALUES ('GatewayUnlocked');


commit;