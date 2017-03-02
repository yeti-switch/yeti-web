begin;
insert into sys.version(number,comment) values(22,'Email infrastructure');

alter table class4.rateplans add profit_control_mode_id SMALLINT not null
  REFERENCES class4.rate_profit_control_modes(id) DEFAULT 1;

alter table class4.destinations alter column profit_control_mode_id drop not null;
alter table class4.destinations alter column profit_control_mode_id drop default;

create table sys.smtp_connections(
  id SERIAL PRIMARY KEY ,
  name varchar UNIQUE  not null,
  host varchar not null,
  port integer not null DEFAULT 25,
  from_address varchar not null,
  auth_user varchar,
  auth_password VARCHAR
);

commit;