class PrivacyUserPhone < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      alter table class4.gateways
        add privacy_mode_id smallint not null default 0;

      alter table class4.gateways drop constraint gateways_sip_schema_id_fkey;
      alter table class4.registrations drop constraint registrations_sip_schema_id_fkey;
      alter table class4.sip_options_probers drop constraint sip_options_probers_sip_schema_id_fkey;

      drop table sys.sip_schemas;


    }
  end

  def down
    execute %q{
      alter table class4.gateways drop column privacy_mode_id;
      create table sys.sip_schemas(
        id smallint primary key,
        name varchar not null unique
      );

      insert into sys.sip_schemas(id,name) values(1,'sip');
      insert into sys.sip_schemas(id,name) values(2,'sips');

      alter table class4.gateways add constraint gateways_sip_schema_id_fkey foreign key (sip_schema_id) references sys.sip_schemas(id);
      alter table class4.registrations add constraint registrations_sip_schema_id_fkey foreign key (sip_schema_id) references sys.sip_schemas(id);
      alter table class4.sip_options_probers add constraint sip_options_probers_sip_schema_id_fkey foreign key (sip_schema_id) references sys.sip_schemas(id);

    }
  end
end
