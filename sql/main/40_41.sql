begin;
insert into sys.version(number,comment) values(41,'LNP config loading');

CREATE TABLE sys.lnp_resolvers(
  id serial primary key,
  name varchar unique not null,
  address varchar not null,
  port integer not null
);

DROP EXTENSION yeti ;
CREATE EXTENSION yeti WITH SCHEMA yeti_ext ;

CREATE OR REPLACE FUNCTION switch8.init(
    i_node_id integer,
    i_pop_id integer)
  RETURNS void AS
$BODY$
declare
    v_lnp_sockets text[];
    v_timeout integer:=1000;
BEGIN
    select into v_lnp_sockets array_agg('tcp://'||address||':'||port::varchar) from sys.lnp_resolvers;-- where 0=1;
    RAISE WARNING 'Adding LNP resolvers sockets: %. Resolver timeout: %ms', v_lnp_sockets, v_timeout;
    perform yeti_ext.lnp_endpoints_set(ARRAY[]::text[]);
    perform yeti_ext.lnp_endpoints_set(v_lnp_sockets);
    perform yeti_ext.lnp_set_timeout(v_timeout);
    RETURN;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 10;


CREATE OR REPLACE FUNCTION switch8.lnp_resolve(
  i_database_id smallint,
  i_timeout integer,
  i_dst character varying)
  RETURNS character varying AS
  $BODY$
BEGIN
    return yeti_ext.lnp_resolve(i_database_id::int, i_dst);
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 10;

commit;
