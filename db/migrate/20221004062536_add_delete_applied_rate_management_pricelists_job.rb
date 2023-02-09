class AddDeleteAppliedRateManagementPricelistsJob < ActiveRecord::Migration[6.1]
  def up
    # conflicts with seeds that loaded into test database
    return if Rails.env.test?

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
