begin;
insert into sys.version(number,comment) values(66,'Ringing timeout disconnect code');

alter table sys.guiconfig add lnp_e2e_timeout smallint not null DEFAULT 1000;


CREATE OR REPLACE FUNCTION switch8.init(
    i_node_id integer,
    i_pop_id integer)
  RETURNS void AS
$BODY$
declare
    v_lnp_sockets text[];
    v_timeout integer:=1000;
BEGIN
    select into v_timeout lnp_e2e_timeout from sys.guiconfig limit 1;
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


commit;