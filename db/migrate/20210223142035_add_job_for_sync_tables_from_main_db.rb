class AddJobForSyncTablesFromMainDb < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      INSERT INTO sys.jobs (id, type, description, updated_at, running) VALUES (13, 'SyncDatabaseTables', NULL, '2021-02-23 14:23:18', false);
    SQL
  end

  def down
    execute <<-SQL
      DELETE from sys.jobs WHERE type = 'SyncDatabaseTables';
    SQL
  end
end
