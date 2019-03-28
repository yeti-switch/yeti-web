class NewLnpLoadSp < ActiveRecord::Migration[5.2]
  def up
    execute %q{
      CREATE TABLE class4.lnp_databases_alcazar (
        id smallserial primary key,
        host varchar not null,
        port integer,
        timeout smallint not null default 300,
        key varchar not null,
        database_id integer
      );

      CREATE TABLE class4.lnp_databases_coure_anq (
        id smallserial primary key,
        database_id integer,
        base_url varchar not null,
        timeout smallint not null default 300,
        username varchar not null,
        password varchar not null,
        country_code varchar not null,
        operators_map varchar
      );
      drop function lnp.load_lnp_databases;

      CREATE FUNCTION lnp.load_lnp_databases()
        RETURNS TABLE(id smallint, name varchar, database_type varchar, parameters json)
        LANGUAGE plpgsql COST 10
      AS $$
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
      $$;
    }
  end

  def down
    execute %q{
      delete from class4.lnp_databases where database_type ='Lnp::DatabaseAlcazar';
      delete from class4.lnp_databases where database_type ='Lnp::DatabaseCoureAnq';
      drop table class4.lnp_databases_alcazar;

      drop table class4.lnp_databases_coure_anq;

      drop function lnp.load_lnp_databases;

      CREATE FUNCTION lnp.load_lnp_databases() RETURNS TABLE(o_id smallint, o_name character varying, o_driver_id smallint, o_host character varying, o_port integer, o_thinq_username character varying, o_thinq_token character varying, o_timeout smallint, o_csv_file character varying)
        LANGUAGE plpgsql COST 10
      AS $$
      BEGIN
        RETURN QUERY SELECT id, name, driver_id, host, port, thinq_username, thinq_token, timeout, csv_file from class4.lnp_databases;
      END;
      $$;
    }
  end
end