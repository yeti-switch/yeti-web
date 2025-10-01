class AddCdrCompactionJob < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      INSERT INTO sys.jobs (name) VALUES ('CdrCompaction')
    SQL
  end

  def down
    execute <<-SQL
      DELETE from sys.jobs WHERE name = 'CdrCompaction';
    SQL
  end
end
