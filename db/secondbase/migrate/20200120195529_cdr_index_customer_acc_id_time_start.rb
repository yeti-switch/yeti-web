class CdrIndexCustomerAccIdTimeStart < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE INDEX ON cdr.cdr USING btree (customer_acc_id, time_start) WHERE routing_attempt=1;
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX cdr.cdr_customer_acc_id_time_start_idx;
    SQL
  end
end
