class AddIndexToCdr < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE INDEX IF NOT EXISTS cdr_customer_acc_external_id_eq_time_start_idx
      ON cdr.cdr
      USING btree (customer_acc_external_id, time_start)
      WHERE routing_attempt = 1;
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX IF EXISTS cdr.cdr_customer_acc_external_id_eq_time_start_idx;
    SQL
  end
end
