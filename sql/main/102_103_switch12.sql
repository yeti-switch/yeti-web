begin;
insert into sys.version(number,comment) values(103,'New schema with TCP transport and IPv6 support');

create table class4.transport_protocols(
  id smallint primary key,
  name varchar not null unique
);

insert into class4.transport_protocols(id,name) values(1, 'UDP');
insert into class4.transport_protocols(id,name) values(2, 'TCP');

alter table class4.gateways add transport_protocol_id smallint not null REFERENCES class4.transport_protocols(id) default 1;
alter table class4.gateways add term_proxy_transport_protocol_id smallint not null REFERENCES class4.transport_protocols(id) default 1;
alter table class4.gateways add orig_proxy_transport_protocol_id smallint not null REFERENCES class4.transport_protocols(id) default 1;

alter table data_import.import_gateways add transport_protocol_id smallint;
alter table data_import.import_gateways add term_proxy_transport_protocol_id smallint;
alter table data_import.import_gateways add orig_proxy_transport_protocol_id smallint;
alter table data_import.import_gateways add transport_protocol_name varchar;
alter table data_import.import_gateways add term_proxy_transport_protocol_name varchar;
alter table data_import.import_gateways add orig_proxy_transport_protocol_name varchar;

alter table class4.customers_auth add transport_protocol_id smallint REFERENCES class4.transport_protocols(id);
alter table data_import.import_customers_auth add transport_protocol_id smallint;
alter table data_import.import_customers_auth add transport_protocol_name varchar;
delete from data_import.import_customers_auth;
ALTER TABLE data_import.import_customers_auth ALTER COLUMN ip TYPE varchar;

commit;