class AddCdrIndexes < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      create index cdr_customer_id_time_start_idx on cdr.cdr using btree (customer_id,time_start);
      create index cdr_vendor_id_time_start_idx on cdr.cdr using btree (vendor_id,time_start);
    }
  end

  def down
    execute %q{
      drop index cdr.cdr_customer_id_time_start_idx;
      drop index cdr.cdr_vendor_id_time_start_idx;
    }
  end

end
