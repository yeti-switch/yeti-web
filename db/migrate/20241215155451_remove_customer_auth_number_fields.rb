class RemoveCustomerAuthNumberFields < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      alter table class4.customers_auth
        drop constraint "customers_auth_dst_number_field_id_fkey",
        drop constraint "customers_auth_src_number_field_id_fkey",
        drop constraint "customers_auth_src_name_field_id_fkey",
        drop constraint "customers_auth_transport_protocol_id_fkey";

      drop table class4.customers_auth_src_name_fields;
      drop table class4.customers_auth_src_number_fields;
      drop table class4.customers_auth_dst_number_fields;

      delete from data_import.import_customers_auth;
      alter table data_import.import_customers_auth
        alter column src_name_field_name type varchar,
        alter column dst_number_field_name type varchar;
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

      alter table class4.customers_auth
        add constraint "customers_auth_dst_number_field_id_fkey" FOREIGN KEY (dst_number_field_id) REFERENCES class4.customers_auth_dst_number_fields(id),
        add constraint "customers_auth_src_name_field_id_fkey" FOREIGN KEY (src_name_field_id) REFERENCES class4.customers_auth_src_name_fields(id),
        add constraint "customers_auth_src_number_field_id_fkey" FOREIGN KEY (src_number_field_id) REFERENCES class4.customers_auth_src_number_fields(id),
        add constraint "customers_auth_transport_protocol_id_fkey" FOREIGN KEY (transport_protocol_id) REFERENCES class4.transport_protocols(id);

      delete from data_import.import_customers_auth;
      alter table data_import.import_customers_auth
        alter column src_name_field_name type smallint USING src_name_field_name::smallint,
        alter column dst_number_field_name type smallint USING dst_number_field_name::smallint;
    }
  end
end
