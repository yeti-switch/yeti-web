class AddDeleteAppliedRateManagementPricelistsJob < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      INSERT INTO sys.jobs (name) VALUES ('DeleteAppliedRateManagementPricelists');
    SQL
  end

  def down
    execute <<-SQL
      DELETE FROM sys.jobs WHERE name = 'DeleteAppliedRateManagementPricelists';
    SQL
  end
end
