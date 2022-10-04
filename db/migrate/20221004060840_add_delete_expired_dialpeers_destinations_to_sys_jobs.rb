class AddDeleteExpiredDialpeersDestinationsToSysJobs < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      INSERT INTO sys.jobs (name) VALUES
      ('DeleteExpiredDestinations'),
      ('DeleteExpiredDialpeers');
    SQL
  end

  def down
    execute <<-SQL
      DELETE from sys.jobs WHERE name IN ('DeleteExpiredDialpeers', 'DeleteExpiredDestinations');
    SQL
  end
end
