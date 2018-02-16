class AddVatToAccounts < ActiveRecord::Migration
  #numeric DEFAULT 0 NOT NULL
  def change
    add_column :accounts, :vat, :numeric, default: 0, null: false
  end
end
