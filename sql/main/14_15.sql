begin;
insert into sys.version(number,comment) values(15,'Stabilised version');


-- second step to upgrade
drop schema switch2 CASCADE;
drop schema switch3 CASCADE;
alter table class4.customers_auth drop column routing_group_id;
ALTER TABLE class4.routing_groups
DROP COLUMN sorting_id,
DROP COLUMN more_specific_per_vendor,
drop column rate_delta_max;
commit;