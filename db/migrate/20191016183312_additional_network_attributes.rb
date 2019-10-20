class AdditionalNetworkAttributes < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE TABLE sys.network_types(
        id smallserial PRIMARY KEY,
        name varchar UNIQUE NOT NULL,
        uuid uuid NOT NULL UNIQUE DEFAULT public.uuid_generate_v1()
      );

      INSERT INTO sys.network_types (name) VALUES ('Unknown');

      ALTER TABLE sys.networks
        ADD type_id smallint REFERENCES sys.network_types(id) NOT NULL DEFAULT 1,
        ADD uuid uuid NOT NULL UNIQUE DEFAULT public.uuid_generate_v1();

      ALTER TABLE sys.networks
        ALTER type_id DROP DEFAULT;

      ALTER TABLE sys.network_prefixes
        ADD number_min_length smallint NOT NULL DEFAULT 0,
        ADD number_max_length smallint NOT NULL DEFAULT 100,
        ADD uuid uuid NOT NULL UNIQUE DEFAULT public.uuid_generate_v1();
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE sys.networks 
        DROP type_id,
        DROP uuid;

      ALTER TABLE sys.network_prefixes
        DROP number_min_length,
        DROP number_max_length,
        DROP uuid;

      DROP TABLE sys.network_types;
    SQL
  end
end
