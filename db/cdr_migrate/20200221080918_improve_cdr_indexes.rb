class ImproveCdrIndexes < ActiveRecord::Migration[5.2]
  def up
    execute %Q{
      DROP INDEX IF EXISTS cdr.cdr_customer_acc_external_id_eq_time_start_idx;
    }
    execute %Q{
      DROP INDEX IF EXISTS cdr.cdr_customer_acc_id_time_start_idx;
    }

    execute %Q{
      CREATE INDEX IF NOT EXISTS cdr_customer_acc_external_id_time_start_idx
      ON cdr.cdr
      USING btree (customer_acc_external_id, time_start)
      WHERE is_last_cdr;
    }
    execute %Q{
      CREATE INDEX IF NOT EXISTS cdr_customer_acc_id_time_start_idx
      ON cdr.cdr
      USING btree (customer_acc_id, time_start)
      WHERE is_last_cdr;
    }
  end
end
