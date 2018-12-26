class AddRoutesetDiscriminator < ActiveRecord::Migration[5.1]
  def up
    execute %q{
      create table class4.routeset_discriminators(
        id smallserial primary key,
        name varchar unique not null
      );
      insert into class4.routeset_discriminators(name) values('default');

      alter table class4.dialpeers add routeset_discriminator_id smallint not null default 1 references class4.routeset_discriminators(id);

      alter table data_import.import_dialpeers
        add routeset_discriminator_id smallint,
        add routeset_discriminator_name varchar;

      insert into class4.transport_protocols(id,name) values(3,'TLS');

      create table class4.gateway_network_protocol_priorities(
        id smallint primary key,
        name varchar not null unique
      );
      insert into class4.gateway_network_protocol_priorities(id, name) values(0, 'force IPv4');
      insert into class4.gateway_network_protocol_priorities(id, name) values(1, 'force IPv6');
      insert into class4.gateway_network_protocol_priorities(id, name) values(2, 'Any');
      insert into class4.gateway_network_protocol_priorities(id, name) values(3, 'prefer IPv4');
      insert into class4.gateway_network_protocol_priorities(id, name) values(4, 'prefer IPv6');


      create table class4.gateway_media_encryption_modes(
        id smallint primary key,
        name varchar not null unique
      );
      insert into class4.gateway_media_encryption_modes(id, name) values(0, 'Disable');
      insert into class4.gateway_media_encryption_modes(id, name) values(1, 'SRTP SDES');
      insert into class4.gateway_media_encryption_modes(id, name) values(2, 'SRTP DTLS');

      create table sys.sip_schemas (
        id smallint primary key,
        name varchar not null unique
      );
      insert into sys.sip_schemas(id,name) values(1,'sip');
      insert into sys.sip_schemas(id,name) values(2,'sips');

      alter table class4.gateways
        add sip_schema_id smallint not null default 1 references sys.sip_schemas(id),
        add network_protocol_priority_id smallint not null default 0 references class4.gateway_network_protocol_priorities(id),
        add media_encryption_mode_id smallint not null default 0 references class4.gateway_media_encryption_modes(id);

      alter table data_import.import_gateways
        add sip_schema_id smallint,
        add sip_schema_name varchar,
        add network_protocol_priority_id smallint,
        add network_protocol_priority_name varchar,
        add media_encryption_mode_id smallint,
        add media_encryption_mode_name varchar;

      alter table class4.routing_plans add max_rerouting_attempts smallint not null default 10;
    }
  end

  def down
    execute %q{
      alter table data_import.import_dialpeers
        drop routeset_discriminator_id,
        drop routeset_discriminator_name;

      alter table class4.dialpeers drop column routeset_discriminator_id;
      drop table class4.routeset_discriminators;

      delete from class4.transport_protocols where id=3;
      alter table class4.gateways
        drop column sip_schema_id,
        drop column network_protocol_priority_id,
        drop column media_encryption_mode_id;

      alter table data_import.import_gateways
        drop column sip_schema_id,
        drop column sip_schema_name,
        drop column network_protocol_priority_id,
        drop column network_protocol_priority_name,
        drop column media_encryption_mode_id,
        drop column media_encryption_mode_name;

      drop table class4.gateway_network_protocol_priorities;
      drop table class4.gateway_media_encryption_modes;
      drop table sys.sip_schemas;

      alter table class4.routing_plans drop column max_rerouting_attempts;

}
  end
end
