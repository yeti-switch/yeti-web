class CustomersAuhNormalizedAddExternalType < ActiveRecord::Migration[7.0]
  def change
    add_column 'class4.customers_auth_normalized', :external_type, :string
  end
end
