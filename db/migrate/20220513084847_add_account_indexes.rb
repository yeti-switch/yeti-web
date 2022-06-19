class AddAccountIndexes < ActiveRecord::Migration[6.1]
  def up
    execute %q{
      CREATE INDEX IF NOT EXISTS customers_auth_account_id_idx ON class4.customers_auth USING btree (account_id);
      CREATE INDEX IF NOT EXISTS dialpeers_account_id_idx ON class4.dialpeers USING btree (account_id);
      CREATE INDEX IF NOT EXISTS payments_account_id_idx ON billing.payments USING btree (account_id);

      CREATE INDEX IF NOT EXISTS accounts_contractor_id_idx ON billing.accounts USING btree (contractor_id);
      CREATE INDEX IF NOT EXISTS api_access_customer_id_idx ON sys.api_access USING btree (customer_id);
      CREATE INDEX IF NOT EXISTS contacts_contractor_id_idx ON notifications.contacts USING btree (contractor_id);
      CREATE INDEX IF NOT EXISTS customers_auth_customer_id_idx ON class4.customers_auth USING btree (customer_id);
      CREATE INDEX IF NOT EXISTS dialpeers_vendor_id_idx ON class4.dialpeers USING btree (vendor_id);
      CREATE INDEX IF NOT EXISTS gateway_groups_vendor_id_idx ON class4.gateway_groups USING btree (vendor_id);
      CREATE INDEX IF NOT EXISTS gateways_contractor_id_idx ON class4.gateways USING btree (contractor_id);
      CREATE INDEX IF NOT EXISTS routing_plan_static_routes_vendor_id_idx ON class4.routing_plan_static_routes USING btree (vendor_id);
    }
  end

  def down
    execute %q{
      DROP INDEX class4.customers_auth_account_id_idx;
      DROP INDEX class4.dialpeers_account_id_idx;
      DROP INDEX billing.payments_account_id_idx;

      DROP INDEX billing.accounts_contractor_id_idx;
      DROP INDEX sys.api_access_customer_id_idx;
      DROP INDEX notifications.contacts_contractor_id_idx;
      DROP INDEX class4.customers_auth_customer_id_idx;
      DROP INDEX class4.dialpeers_vendor_id_idx;
      DROP INDEX class4.gateway_groups_vendor_id_idx;
      DROP INDEX class4.gateways_contractor_id_idx;
      DROP INDEX class4.routing_plan_static_routes_vendor_id_idx;

    }
  end

end


