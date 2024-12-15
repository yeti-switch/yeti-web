class RemoveCustomerAuthNumberFields < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      alter table class4.customers_auth drop constraint "customers_auth_dst_number_field_id_fkey";
      alter table class4.customers_auth drop constraint "customers_auth_src_number_field_id_fkey";
      alter table class4.customers_auth drop constraint "customers_auth_src_name_field_id_fkey";
      drop table class4.customers_auth_src_name_fields;
      drop table class4.customers_auth_src_number_fields;
      drop table class4.customers_auth_dst_number_fields;
    }
  end

  def down
    execute %q{
      create table class4.customers_auth_src_name_fields (
        id smallint PRIMARY KEY,
        name varchar not null unique
      );
      insert into class4.customers_auth_src_name_fields(id,name) values(1,'From header display name');
      insert into class4.customers_auth_src_name_fields(id,name) values(2,'From header userpart');

      create table class4.customers_auth_src_number_fields (
        id smallint PRIMARY KEY,
        name varchar not null unique
      );
      insert into class4.customers_auth_src_number_fields(id,name) values(1,'From header userpart');
      insert into class4.customers_auth_src_number_fields(id,name) values(2,'From header display name');

      create table class4.customers_auth_dst_number_fields (
        id smallint PRIMARY KEY,
        name varchar not null unique
      );
      insert into class4.customers_auth_dst_number_fields(id,name) values(1,'R-URI userpart');
      insert into class4.customers_auth_dst_number_fields(id,name) values(2,'To URI userpart');
      insert into class4.customers_auth_dst_number_fields(id,name) values(3,'Top Diversion header userpart');

      alter table class4.customers_auth add constraint "customers_auth_dst_number_field_id_fkey" FOREIGN KEY (dst_number_field_id) REFERENCES class4.customers_auth_dst_number_fields(id);
      alter table class4.customers_auth add constraint  "customers_auth_src_name_field_id_fkey" FOREIGN KEY (src_name_field_id) REFERENCES class4.customers_auth_src_name_fields(id);
      alter table class4.customers_auth add constraint"customers_auth_src_number_field_id_fkey" FOREIGN KEY (src_number_field_id) REFERENCES class4.customers_auth_src_number_fields(id);
    }
  end
end
