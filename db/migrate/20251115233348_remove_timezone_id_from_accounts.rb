# frozen_string_literal: true

class RemoveTimezoneIdFromAccounts < ActiveRecord::Migration[7.2]
  def up
    # Remove foreign key constraint
    execute <<-SQL
      ALTER TABLE billing.accounts DROP CONSTRAINT accounts_timezone_id_fkey;
    SQL

    # Remove the timezone_id column
    remove_column 'billing.accounts', :timezone_id, :integer

    # Make timezone NOT NULL after migration
    change_column_null 'billing.accounts', :timezone, false
    change_column_default 'billing.accounts', :timezone, from: nil, to: 'UTC'
  end

  def down
    # Add timezone_id column back
    add_column 'billing.accounts', :timezone_id, :integer, default: 1, null: false

    # Add foreign key constraint back
    execute <<-SQL
      ALTER TABLE billing.accounts
      ADD CONSTRAINT accounts_timezone_id_fkey
      FOREIGN KEY (timezone_id) REFERENCES sys.timezones(id);
    SQL

    # Migrate data back (assuming UTC for all if timezone is 'UTC', otherwise find by name)
    execute <<-SQL
      UPDATE billing.accounts
      SET timezone_id = COALESCE(
        (SELECT id FROM sys.timezones WHERE name = billing.accounts.timezone LIMIT 1),
        1
      )
    SQL

    # Make timezone nullable again
    change_column_null 'billing.accounts', :timezone, true
  end
end

