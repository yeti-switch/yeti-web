class AddCpsLimitAndLegaResources < ActiveRecord::Migration[6.1]
  def up
    execute %q{
      alter table class4.customers_auth add cps_limit float;
      alter table class4.customers_auth_normalized add cps_limit float;
      alter table data_import.import_customers_auth add cps_limit float;
    }
  end
  def down
    execute %q{
      alter table class4.customers_auth drop column cps_limit;
      alter table class4.customers_auth_normalized drop column cps_limit;
      alter table data_import.import_customers_auth drop column cps_limit;
    }
  end
end
