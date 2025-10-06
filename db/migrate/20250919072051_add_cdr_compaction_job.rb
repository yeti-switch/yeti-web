class AddCdrCompactionJob < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (20, 'CdrCompaction', NULL, NULL, NULL);
    SQL
  end

  def down
    execute <<-SQL
      DELETE from sys.jobs WHERE name = 'CdrCompaction';
    SQL
  end
end
