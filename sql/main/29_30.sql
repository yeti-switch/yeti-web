begin;
insert into sys.version(number,comment) values(30,'Networks');

ALTER TABLE class4.destinations add network_prefix_id integer;
ALTER TABLE class4.dialpeers add network_prefix_id integer;

commit;
