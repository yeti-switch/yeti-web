class FixCustomerAuthImport < ActiveRecord::Migration
  def up
    execute %q{
      alter table data_import.import_customers_auth rename column dst_blacklist_id to dst_numberlist_id;
      alter table data_import.import_customers_auth rename column dst_blacklist_name to dst_numberlist_name;
      alter table data_import.import_customers_auth rename column src_blacklist_id to src_numberlist_id;
      alter table data_import.import_customers_auth rename column src_blacklist_name to src_numberlist_name;
    }
  end

  def down
    execute %q{
      alter table data_import.import_customers_auth rename column dst_numberlist_id to dst_blacklist_id;
      alter table data_import.import_customers_auth rename column dst_numberlist_name to dst_blacklist_name;
      alter table data_import.import_customers_auth rename column src_numberlist_id to src_blacklist_id;
      alter table data_import.import_customers_auth rename column src_numberlist_name to src_blacklist_name;
    }
  end

end
