class AddPrometheusCustomerAuthStatsJob < ActiveRecord::Migration[7.0]
  def up
    # conflicts with seeds that loaded into test database
    return if Rails.env.test?

    execute <<-SQL
      INSERT INTO sys.jobs (name) VALUES ('PrometheusCustomerAuthStats');
    SQL
  end

  def down
    execute <<-SQL
      DELETE FROM sys.jobs WHERE name = 'PrometheusCustomerAuthStats';
    SQL
  end
end
