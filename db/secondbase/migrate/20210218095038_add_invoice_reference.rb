class AddInvoiceReference < ActiveRecord::Migration[5.2]
  def up
    add_column 'billing.invoices', :reference, :string

    execute <<-SQL
      UPDATE billing.invoices SET reference = id::varchar
    SQL

    add_index 'billing.invoices', :reference
  end

  def down
    remove_column 'billing.invoices', :reference
  end
end
