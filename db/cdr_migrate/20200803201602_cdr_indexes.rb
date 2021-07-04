class CdrIndexes < ActiveRecord::Migration[5.2]
  def up
    execute %q{
      create index if not exists "cdr_customer_invoice_id_idx" on cdr.cdr using btree(customer_invoice_id);
      create index if not exists "invoice_networks_invoice_id_idx" on billing.invoice_networks using btree(invoice_id);
      create index if not exists "cdr_customer_acc_id_time_start_idx1" ON cdr.cdr using btree (customer_acc_id, time_start);
    }
  end

  def down
    execute %q{
      drop index cdr.cdr_customer_invoice_id_idx;
      drop index billing.invoice_networks_invoice_id_idx;
      drop index cdr.cdr_customer_acc_id_time_start_idx1;
    }
  end

end
