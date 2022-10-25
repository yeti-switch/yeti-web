class RemoveThresholdsFromAccountImport < ActiveRecord::Migration[6.1]
  def up
    remove_column 'data_import.import_accounts', :balance_low_threshold
    remove_column 'data_import.import_accounts', :balance_high_threshold
  end

  def down
    add_column 'data_import.import_accounts', :balance_low_threshold, :decimal
    add_column 'data_import.import_accounts', :balance_high_threshold, :decimal
  end
end
