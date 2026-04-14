# frozen_string_literal: true

class AddCurrencyNameToImportTables < ActiveRecord::Migration[7.1]
  def up
    execute %q{
      ALTER TABLE data_import.import_dialpeers ADD COLUMN currency_name character varying;
      ALTER TABLE data_import.import_destinations ADD COLUMN currency_name character varying;
    }
  end

  def down
    execute %q{
      ALTER TABLE data_import.import_dialpeers DROP COLUMN IF EXISTS currency_name;
      ALTER TABLE data_import.import_destinations DROP COLUMN IF EXISTS currency_name;
    }
  end
end
