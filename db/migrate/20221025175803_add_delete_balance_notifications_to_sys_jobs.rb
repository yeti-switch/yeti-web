class AddDeleteBalanceNotificationsToSysJobs < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      INSERT INTO sys.jobs (name) VALUES
      ('DeleteBalanceNotifications');
    SQL
  end

  def down
    execute <<-SQL
      DELETE from sys.jobs WHERE name = 'DeleteBalanceNotifications';
    SQL
  end
end
