class AddCnameDatabases < ActiveRecord::Migration[6.1]
  def up
    execute %q{
      create table class4.cnam_databases (
        id smallint primary key default nextval('class4.lnp_databases_id_seq'::regclass),
        name varchar not null unique,
        created_at timestamptz,
        database_type varchar not null,
        database_id smallint not null
      );

      create table class4.cnam_databases_http (
        id smallserial primary key,
        url varchar not null,
        timeout smallint not null default 5
      );

CREATE OR REPLACE FUNCTION lnp.load_lnp_databases()
 RETURNS TABLE(id smallint, name character varying, database_type character varying, parameters json)
 LANGUAGE plpgsql
 COST 10
AS $function$
      BEGIN
        RETURN QUERY
          SELECT
            db.id,
            db.name,
            db.database_type,
            params.data
          from class4.lnp_databases db
          join (
            SELECT t.id, 'Lnp::DatabaseThinq' as type, row_to_json(t.*) as data from class4.lnp_databases_thinq t
            UNION ALL
            SELECT t.id, 'Lnp::DatabaseSipRedirect' as type, row_to_json(t.*) as data from class4.lnp_databases_30x_redirect t
            UNION ALL
            SELECT t.id, 'Lnp::DatabaseCsv' as type, row_to_json(t.*) as data from class4.lnp_databases_csv t
            UNION ALL
            SELECT t.id, 'Lnp::DatabaseAlcazar' as type, row_to_json(t.*) as data from class4.lnp_databases_alcazar t
            UNION ALL
            SELECT t.id, 'Lnp::DatabaseCoureAnq' as type, row_to_json(t.*) as data from class4.lnp_databases_coure_anq t
            ) params ON db.database_id=params.id AND db.database_type=params.type
          UNION ALL
          SELECT
            db.id,
            db.name,
            db.database_type,
            params.data
          from class4.cnam_databases db
          join (
            SELECT t.id, 'Cnam::DatabaseHttp' as type, row_to_json(t.*) as data from class4.cnam_databases_http t
            ) params ON db.database_id=params.id AND db.database_type=params.type;
      END;
      $function$;


    }
  end

  def down
    execute %q{

CREATE OR REPLACE FUNCTION lnp.load_lnp_databases()
 RETURNS TABLE(id smallint, name character varying, database_type character varying, parameters json)
 LANGUAGE plpgsql
 COST 10
AS $function$
      BEGIN
        RETURN QUERY
          SELECT
            db.id,
            db.name,
            db.database_type,
            params.data
          from class4.lnp_databases db
          join (
            SELECT t.id, 'Lnp::DatabaseThinq' as type, row_to_json(t.*) as data from class4.lnp_databases_thinq t
            UNION ALL
            SELECT t.id, 'Lnp::DatabaseSipRedirect' as type, row_to_json(t.*) as data from class4.lnp_databases_30x_redirect t
            UNION ALL
            SELECT t.id, 'Lnp::DatabaseCsv' as type, row_to_json(t.*) as data from class4.lnp_databases_csv t
            UNION ALL
            SELECT t.id, 'Lnp::DatabaseAlcazar' as type, row_to_json(t.*) as data from class4.lnp_databases_alcazar t
            UNION ALL
            SELECT t.id, 'Lnp::DatabaseCoureAnq' as type, row_to_json(t.*) as data from class4.lnp_databases_coure_anq t
            ) params ON db.database_id=params.id AND db.database_type=params.type;
      END;
      $function$;

      drop table class4.cnam_databases_http;
      drop table class4.cnam_databases;
    }
  end

end
