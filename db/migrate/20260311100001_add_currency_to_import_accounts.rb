# frozen_string_literal: true

class AddCurrencyToImportAccounts < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      ALTER TABLE data_import.import_accounts
        ADD COLUMN currency_id smallint,
        ADD COLUMN currency_name varchar;
    }
  end

  def down
    execute %q{
      ALTER TABLE data_import.import_accounts
        DROP COLUMN currency_name,
        DROP COLUMN currency_id;
    }
  end
end
