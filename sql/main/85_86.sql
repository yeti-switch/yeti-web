begin;
insert into sys.version(number,comment) values(86,'Stop hunting flag');

ALTER TABLE class4.dialpeers add stop_hunting boolean not null default false;
ALTER TABLE data_import.import_dialpeers add stop_hunting boolean;

commit;
