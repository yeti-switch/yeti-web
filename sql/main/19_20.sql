begin;
insert into sys.version(number,comment) values(20,'Profit control');

create table class4.rate_profit_control_modes(
  id SMALLINT PRIMARY KEY ,
  name varchar not null UNIQUE
);

-- работает только для rate policy = FIXED
insert into class4.rate_profit_control_modes VALUES (1,'no control'); -- не проверять цену роута
insert into class4.rate_profit_control_modes VALUES (2,'per call'); -- Искать роуты только с меньшей ценой чем рейт.


alter table class4.destinations
add valid_from timestamp without time zone,
add valid_till timestamp without time zone,
add profit_control_mode_id SMALLINT not null REFERENCES class4.rate_profit_control_modes(id) DEFAULT 1;

update class4.destinations set valid_from=now(), valid_till=now()+'5 years'::interval;
ALTER TABLE class4.destinations ALTER COLUMN valid_from SET NOT NULL ;
ALTER TABLE class4.destinations ALTER COLUMN valid_till SET NOT NULL ;

drop index class4.destinations_prefix_rateplan_id_idx;

alter table data_import.import_destinations
add valid_from timestamp without time zone,
add valid_till timestamp without time zone,
add profit_control_mode_id SMALLINT,
add profit_control_mode_name varchar;

commit;