# frozen_string_literal: true

class MigrateAccountTimezoneData < ActiveRecord::Migration[7.2]
  def up
    # Copy timezone names from sys.timezones to billing.accounts.timezone
    execute <<-SQL
      UPDATE billing.accounts
      SET timezone = sys.timezones.name
      FROM sys.timezones
      WHERE billing.accounts.timezone_id = sys.timezones.id
    SQL
  end

  def down
    execute <<-SQL
      UPDATE billing.accounts SET timezone = NULL;
    SQL
  end
end

