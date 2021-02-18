class AddAccountInvoiceReference < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :customer_invoice_ref_template, :string, default: '$id', null: false
    add_column :accounts, :vendor_invoice_ref_template, :string, default: '$id', null: false
  end
end
