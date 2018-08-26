class RejectCallsAtCustomerAuth < ActiveRecord::Migration[5.0]

  def up
    execute %q{
      ALTER EXTENSION yeti UPDATE TO "1.3.2";

      alter table class4.customers_auth add reject_calls boolean not null default false;
      alter table class4.customers_auth_normalized add reject_calls boolean not null default false;
      alter table data_import.import_customers_auth add reject_calls boolean;

      create table class4.routing_tag_modes(
        id smallint primary key,
        name varchar not null unique
      );

      insert into class4.routing_tag_modes(id,name) values( 0, 'OR');
      insert into class4.routing_tag_modes(id,name) values( 1, 'AND');

      alter table class4.destinations
        add routing_tag_mode_id smallint not null references class4.routing_tag_modes(id) default 0;
      alter table data_import.import_destinations
        add routing_tag_mode_id smallint,
        add routing_tag_mode_name varchar;

      alter table class4.dialpeers
        add routing_tag_mode_id smallint not null references class4.routing_tag_modes(id) default 0;
      alter table data_import.import_dialpeers
        add routing_tag_mode_id smallint,
        add routing_tag_mode_name varchar;

      alter table class4.routing_tag_detection_rules
        add routing_tag_mode_id smallint not null references class4.routing_tag_modes(id) default 0;

    }
  end

  def down
    execute %q{
      alter table class4.customers_auth drop column reject_calls;
      alter table class4.customers_auth_normalized drop column reject_calls;
      alter table data_import.import_customers_auth drop column reject_calls;


      alter table class4.destinations drop column routing_tag_mode_id;
      alter table data_import.import_destinations drop column routing_tag_mode_id;
      alter table data_import.import_destinations drop column routing_tag_mode_name;

      alter table class4.dialpeers drop column routing_tag_mode_id;

      alter table data_import.import_dialpeers drop column routing_tag_mode_id;
      alter table data_import.import_dialpeers drop column routing_tag_mode_name;

      alter table class4.routing_tag_detection_rules drop column routing_tag_mode_id;

      drop table class4.routing_tag_modes;

    }
  end

end
