class CreateBillingInvoiceServiceData < ActiveRecord::Migration[7.0]
  def change
    create_table 'billing.invoice_service_data' do |t|
      t.references :invoice,
                   null: false,
                   foreign_key: { to_table: 'billing.invoices', name: 'invoice_service_data_invoice_id_fkey' },
                   index: { name: 'invoice_service_data_invoice_id_idx' },
                   type: :integer
      t.integer :service_id, limit: 8
      t.decimal :amount, null: false
      t.boolean :spent, null: false, default: true
      t.integer :transactions_count, null: false
    end

    change_table 'billing.invoices', bulk: true do |t|
      t.decimal :services_amount_spent, null: false, default: 0.0
      t.decimal :services_amount_earned, null: false, default: 0.0
      t.integer :service_transactions_count, null: false, default: 0
    end
  end
end
