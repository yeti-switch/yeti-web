class AddExternalIdToCustomerAuth < ActiveRecord::Migration
  def change
    add_column 'class4.customers_auth', :external_id, :bigint
    add_index  'class4.customers_auth', :external_id, unique: true, name: 'customers_auth_external_id_idx'
  end
end
