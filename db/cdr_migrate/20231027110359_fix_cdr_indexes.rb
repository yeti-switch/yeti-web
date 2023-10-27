class FixCdrIndexes < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      drop index if exists cdr.cdr_customer_invoice_id_idx;
      drop index if exists cdr.cdr_vendor_invoice_id_idx;
      drop index if exists cdr.cdr_customer_acc_id_time_start_idx;

      ALTER TABLE external_data.countries ADD PRIMARY KEY (id);
      ALTER TABLE external_data.networks ADD PRIMARY KEY (id);
      ALTER TABLE external_data.network_prefixes ADD PRIMARY KEY (id);

    }
  end

  def down
    execute %q{
      create index cdr_customer_invoice_id_idx on cdr.cdr using btree(customer_invoice_id);
      create index cdr_vendor_invoice_id_idx on cdr.cdr using btree(vendor_invoice_id);
      create index cdr_customer_acc_id_time_start_idx on cdr.cdr using btree (customer_acc_id, time_start) WHERE is_last_cdr;

      ALTER TABLE external_data.countries drop CONSTRAINT countries_pkey;
      ALTER TABLE external_data.networks  drop CONSTRAINT networks_pkey;
      ALTER TABLE external_data.network_prefixes drop CONSTRAINT network_prefixes_pkey;

    }
  end

end
