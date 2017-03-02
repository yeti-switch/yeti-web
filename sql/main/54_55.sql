begin;
insert into sys.version(number,comment) values(55,'Static routes refactoring');
ALTER TABLE  class4.routing_plan_static_routes add priority smallint not null default 100;

commit;
