begin;
insert into sys.version(number,comment) values(36,'API log');

CREATE TABLE logs.api_requests(
  id bigserial primary key,
  created_at timestamptz not null default now(),
  path varchar,
  method varchar,
  status integer,
  controller varchar,
  action varchar,
  page_duration real,
  db_duration real,
  params text,
  request_body text,
  response_body text,
  request_headers text,
  response_headers text
);

commit;