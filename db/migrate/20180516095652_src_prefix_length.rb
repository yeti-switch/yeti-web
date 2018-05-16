class SrcPrefixLength < ActiveRecord::Migration[5.1]
  def up
    execute %q{

      alter table class4.customers_auth
        add src_number_max_length smallint not null default 100,
        add src_number_min_length smallint not null default 0;

      alter table class4.customers_auth_normalized
        add src_number_max_length smallint not null default 100,
        add src_number_min_length smallint not null default 0;

      alter table class4.customers_auth_normalized add constraint customers_auth_max_src_number_length CHECK(src_number_max_length>=0);
      alter table class4.customers_auth_normalized add constraint customers_auth_min_src_number_length CHECK(src_number_min_length>=0);

      alter table data_import.import_customers_auth
        add src_number_max_length smallint,
        add src_number_min_length smallint;

      alter table class4.numberlist_items add number_min_length smallint not null default 0;
      alter table class4.numberlist_items add number_max_length smallint not null default 100;
      alter table class4.numberlist_items add constraint numberlist_items_min_number_length CHECK(number_min_length>=0);
      alter table class4.numberlist_items add constraint numberlist_items_max_number_length CHECK(number_max_length>=0);

      alter table data_import.import_numberlist_items add number_min_length smallint;
      alter table data_import.import_numberlist_items add number_max_length smallint;



    }
  end
  def down
    execute %q{
      alter table class4.customers_auth drop column src_number_max_length;
      alter table class4.customers_auth drop column src_number_min_length;

      alter table class4.customers_auth_normalized drop column src_number_max_length;
      alter table class4.customers_auth_normalized drop column src_number_min_length;

      alter table data_import.import_customers_auth drop column src_number_max_length;
      alter table data_import.import_customers_auth drop column src_number_min_length;

      alter table class4.numberlist_items drop column number_min_length;
      alter table class4.numberlist_items drop column number_max_length;

      alter table data_import.import_numberlist_items drop column number_min_length;
      alter table data_import.import_numberlist_items drop column number_max_length;

    }
  end
end
