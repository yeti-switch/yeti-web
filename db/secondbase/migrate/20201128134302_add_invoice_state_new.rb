class AddInvoiceStateNew < ActiveRecord::Migration[5.2]
  def change
    # Billing::InvoiceState::NEW == 3
    execute <<-SQL
      INSERT INTO billing.invoice_states VALUES (3, 'New');
    SQL
  end
end
