class InvoicesAddUuid < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      ALTER TABLE billing.invoices
      ADD COLUMN uuid uuid
      DEFAULT public.uuid_generate_v1()
      NOT NULL
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE billing.invoices
      DROP COLUMN uuid
    SQL
  end
end
