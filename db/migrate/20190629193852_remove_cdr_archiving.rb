class RemoveCdrArchiving < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      UPDATE sys.jobs SET type = 'PartitionRemoving' WHERE type = 'CdrArchiving';

      ALTER TABLE sys.guiconfig DROP COLUMN cdr_archive_delay;
      ALTER TABLE sys.guiconfig DROP COLUMN cdr_remove_delay;
    SQL
  end

  def down
    execute <<-SQL
      UPDATE sys.jobs SET type = 'CdrArchiving' WHERE type = 'PartitionRemoving';

      ALTER TABLE sys.guiconfig ADD COLUMN cdr_archive_delay integer DEFAULT 4 NOT NULL;
      ALTER TABLE sys.guiconfig ADD COLUMN cdr_remove_delay integer DEFAULT 120 NOT NULL;
    SQL
  end
end
