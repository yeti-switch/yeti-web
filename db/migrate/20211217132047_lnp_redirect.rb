class LnpRedirect < ActiveRecord::Migration[6.1]
  def up
    execute %q{
      create table class4.lnp_databases_30x_redirect_formats(
        id smallint primary key,
        name varchar unique not null
      );
      insert into class4.lnp_databases_30x_redirect_formats(id, name) values (1,'Contact URI username rn parameter');
      insert into class4.lnp_databases_30x_redirect_formats(id, name) values (2,'Contact URI username');

      alter table class4.lnp_databases_30x_redirect
        add format_id smallint not null default 1 references class4.lnp_databases_30x_redirect_formats(id);

      alter table class4.lnp_databases
        add cache_ttl integer not null default 10800;

      alter table class4.routing_plan_lnp_rules
        add drop_call_on_error boolean not null default false,
        add rewrite_call_destination boolean not null default false;

CREATE OR REPLACE FUNCTION lnp.cache_lnp_data(i_database_id smallint, i_dst character varying, i_lrn character varying, i_tag character varying, i_data character varying)
 RETURNS void
 LANGUAGE plpgsql
 COST 10
AS $function$
      declare
        v_ttl integer;
        v_expire timestamptz;
      BEGIN
        select into v_ttl cache_ttl from class4.lnp_databases where id=i_database_id;
        if v_ttl is not null and v_ttl > 0 then
          v_expire=now()+v_ttl*'1 seconds'::interval;
          begin
            insert into class4.lnp_cache(dst,lrn,created_at,updated_at,expires_at,database_id,data,tag) values( i_dst, i_lrn, now(),now(),v_expire,i_database_id,i_data,i_tag);
          exception
            when unique_violation then
              update class4.lnp_cache set lrn=i_lrn, updated_at=now(), expires_at=v_expire, data=i_data, tag=i_tag WHERE dst=i_dst and database_id=i_database_id;
          end;
        end if;
      END;
    $function$;

    }
  end

  def down
    execute %q{
      alter table class4.routing_plan_lnp_rules
        drop column drop_call_on_error,
        drop column rewrite_call_destination;

      alter table class4.lnp_databases_30x_redirect
        drop column format_id;

      alter table class4.lnp_databases
        drop column cache_ttl;

      drop table class4.lnp_databases_30x_redirect_formats;

CREATE OR REPLACE FUNCTION lnp.cache_lnp_data(i_database_id smallint, i_dst character varying, i_lrn character varying, i_tag character varying, i_data character varying)
 RETURNS void
 LANGUAGE plpgsql
 COST 10
AS $function$
      declare
        v_ttl integer;
        v_expire timestamptz;
      BEGIN
        select into v_ttl lnp_cache_ttl from sys.guiconfig;
        v_expire=now()+v_ttl*'1 minute'::interval;
        begin
          insert into class4.lnp_cache(dst,lrn,created_at,updated_at,expires_at,database_id,data,tag) values( i_dst, i_lrn, now(),now(),v_expire,i_database_id,i_data,i_tag);
        Exception
          when unique_violation then
            update class4.lnp_cache set lrn=i_lrn, updated_at=now(), expires_at=v_expire, data=i_data, tag=i_tag WHERE dst=i_dst and database_id=i_database_id;
        end;
      END;
    $function$;
    }

  end


end
