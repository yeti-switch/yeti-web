begin;
insert into sys.version(number,comment) values(25,'ActiveCalls autorefresh,Invoices,Static routes');

ALTER TABLE sys.guiconfig add active_calls_autorefresh_enable boolean not null default false;

create table sys.currencies(
  id smallserial primary key,
  name varchar not null unique,
  country_id integer references sys.countries(id),
  code varchar(3) not null,
  num_code varchar(3) not null
);

create table sys.active_currencies(
  id serial primary key,
  currency_id smallint not null unique references sys.currencies(id),
  is_base boolean not null default false,
  enable_autoupdate boolean not null default true,
  description varchar,
  created_at timestamptz,
  updated_at timestamptz,
  rate numeric
);


INSERT INTO class4.sortings(id,name) VALUES (5,'Route testing');
INSERT INTO class4.sortings(id,name) VALUES (6,'QD-Static, LCR, ACD&ASR control');

ALTER TABLE class4.sortings add use_static_routes boolean not null default false;
UPDATE class4.sortings set use_static_routes =true where id=6;

CREATE TABLE class4.routing_plan_static_routes(
  id serial primary key,
  routing_plan_id INTEGER not null REFERENCES class4.routing_plans(id),
  prefix varchar not null default '',
  vendor_id integer not null references public.contractors(id)
);

create unique index on class4.routing_plan_static_routes using btree( routing_plan_id, prefix, vendor_id);

commit;