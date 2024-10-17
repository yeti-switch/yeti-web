class FixNetworkDeletionPerformance < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      CREATE INDEX network_prefixes_network_id_idx ON sys.network_prefixes USING btree (network_id);
    }
  end
  def down
    execute %q{
      DROP INDEX sys."network_prefixes_network_id_idx";
    }
  end
end
