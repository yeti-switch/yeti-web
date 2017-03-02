begin;
insert into sys.version(number,comment) values(69,'new LNP caching');

ALTER EXTENSION yeti UPDATE;

CREATE OR REPLACE FUNCTION switch8.cache_lnp_data(
    i_database_id smallint,
    i_dst character varying,
    i_lrn character varying,
    i_tag character varying,
    i_data character varying)
  RETURNS void AS
$BODY$
declare
v_ttl integer;
v_expire timestamptz;
BEGIN
    select into v_ttl lnp_cache_ttl from sys.guiconfig;
    v_expire=now()+v_ttl*'1 minute'::interval;
    begin
        insert into class4.lnp_cache(dst,lrn,created_at,updated_at,expires_at,database_id,data, tag) values( i_dst, i_lrn, now(),now(),v_expire,i_database_id,i_data, i_tag);
    Exception
        when unique_violation then
            update class4.lnp_cache set lrn=i_lrn, updated_at=now(), expires_at=v_expire, data=i_data, tag=i_tag WHERE dst=i_dst and database_id=i_database_id;
    end;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 10;


CREATE OR REPLACE FUNCTION switch8.lnp_resolve(
    i_database_id smallint,
    i_dst character varying)
  RETURNS character varying AS
$BODY$
BEGIN
    return lrn from yeti_ext.lnp_resolve_tagged(i_database_id::int, i_dst);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 10;

create type switch8.lnp_resolve as(
    lrn text,
    tag text
);

CREATE OR REPLACE FUNCTION switch8.lnp_resolve_tagged(
    i_database_id smallint,
    i_dst character varying)
  RETURNS switch8.lnp_resolve AS
$BODY$
BEGIN
    return yeti_ext.lnp_resolve_tagged(i_database_id::int, i_dst);
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 10;

ALTER TABLE sys.guiconfig add web_url varchar not null default 'http://127.0.0.1';

commit;