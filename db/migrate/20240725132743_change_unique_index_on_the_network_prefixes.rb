class ChangeUniqueIndexOnTheNetworkPrefixes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    execute <<~SQL.squish
      ALTER TABLE ONLY sys.network_prefixes
      DROP CONSTRAINT network_prefixes_prefix_key;

      CREATE UNIQUE INDEX network_prefixes_prefix_key ON sys.network_prefixes USING btree (prefix, number_min_length, number_max_length);
    SQL
  end

  def down
    execute <<~SQL.squish
      DROP INDEX IF EXISTS network_prefixes_prefix_key;

      ALTER TABLE ONLY sys.network_prefixes
      ADD CONSTRAINT network_prefixes_prefix_key UNIQUE (prefix);
    SQL
  end
end
