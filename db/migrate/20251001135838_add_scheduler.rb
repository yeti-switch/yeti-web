class AddScheduler < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      create table sys.schedulers (
        id smallserial primary key,
        name varchar not null unique,
        enabled boolean not null default true,
        current_state boolean,
        use_reject_calls boolean not null default true
      );

      alter table class4.customers_auth add scheduler_id smallint references sys.schedulers(id);
      create index "customers_auth_scheduler_id_idx" on class4.customers_auth using btree(scheduler_id);
      alter table data_import.import_customers_auth
        add scheduler_id smallint,
        add scheduler_name varchar;


      alter table class4.destinations add scheduler_id smallint references sys.schedulers(id);
      create index "destinations_scheduler_id_idx" on class4.destinations using btree(scheduler_id);
      alter table data_import.import_destinations
        add scheduler_id smallint,
        add scheduler_name varchar;

      alter table class4.dialpeers add scheduler_id smallint references sys.schedulers(id);
      create index "dialpeers_scheduler_id_idx" on class4.dialpeers using btree(scheduler_id);
      alter table data_import.import_dialpeers
        add scheduler_id smallint,
        add scheduler_name varchar;

      alter table class4.gateways add scheduler_id smallint references sys.schedulers(id);
      create index "gateways_scheduler_id_idx" on class4.gateways using btree(scheduler_id);
      alter table data_import.import_gateways
        add scheduler_id smallint,
        add scheduler_name varchar;

    }
  end

  def down
    execute %q{
      alter table class4.customers_auth drop column scheduler_id;
      alter table data_import.import_customers_auth
        drop column scheduler_id,
        drop column scheduler_name;

      alter table class4.destinations drop column scheduler_id;
      alter table data_import.import_destinations
        drop column scheduler_id,
        drop column scheduler_name;

      alter table class4.dialpeers drop column scheduler_id;
      alter table data_import.import_dialpeers
        drop column scheduler_id,
        drop column scheduler_name;

      alter table class4.gateways drop column scheduler_id;
      alter table data_import.import_gateways
        drop column scheduler_id,
        drop column scheduler_name;

      drop table sys.schedulers;
    }
  end

end
