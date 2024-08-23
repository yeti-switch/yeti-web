class AddColumnToImportCustomersAuth < ActiveRecord::Migration[7.0]
  def change
    add_column 'data_import.import_customers_auth', :privacy_mode_id, :integer, limit: 2
    add_column 'data_import.import_customers_auth', :privacy_mode_name, :string
  end
end
