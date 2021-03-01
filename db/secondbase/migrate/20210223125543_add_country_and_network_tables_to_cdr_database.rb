class AddCountryAndNetworkTablesToCdrDatabase < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE SCHEMA IF NOT EXISTS external_data;
  
      CREATE TABLE external_data.countries (
        id integer NOT NULL,
        name character varying,
        iso2 character varying
      );

      CREATE TABLE external_data.networks (
        id integer NOT NULL,
        name character varying,
        type_id integer,
        uuid uuid
      );
      
      CREATE TABLE external_data.network_prefixes (
        id integer NOT NULL,
        number_max_length integer,
        number_min_length integer,
        prefix character varying,
        uuid uuid,
        country_id integer,
        network_id integer
      );
    SQL
  end

  def down
    execute <<-SQL
      DROP SCHEMA IF EXISTS external_data CASCADE;
    SQL
  end
end
