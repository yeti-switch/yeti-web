begin;
ALTER TABLE switch1.switch_interface_in add param varchar;
DROP FUNCTION switch1.load_interface_in();

CREATE OR REPLACE FUNCTION switch1.load_interface_in()
  RETURNS TABLE(varname character varying, vartype character varying, varformat character varying, varhashkey boolean, varparam varchar) AS
$BODY$
BEGIN
    RETURN QUERY SELECT "name","type","format","hashkey","param" from switch_interface_in order by rank asc;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 10
  ROWS 1000;

insert into sys.version(number,comment) values(5,'Fix switch1.load_interface_in()');
commit;
