class AddExternalIdToCustomerAuth < ActiveRecord::Migration
  def up
    execute %q{
      alter table class4.customers_auth add external_id bigint;
      alter table class4.customers_auth_normalized add external_id bigint;
      create unique index  customers_auth_external_id_idx on class4.customers_auth using btree(external_id);
    }
  end

  def down
    execute %q{
      alter table class4.customers_auth drop column external_id;
      alter table class4.customers_auth_normalized drop column external_id;
      --drop index class4.customers_auth_external_id_idx;
  }

  end
end
