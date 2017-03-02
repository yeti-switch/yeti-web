begin;
insert into sys.version(number,comment) values(31,'Reports refactoring');

set SEARCH_PATH to reports;
ALTER TABLE reports.customer_traffic_report_data RENAME TO customer_traffic_report_data_by_vendor;

CREATE TABLE reports.customer_traffic_report_data_full (
  id                  BIGSERIAL PRIMARY KEY,
  report_id           INTEGER NOT NULL,
  vendor_id           INTEGER,
  destination_prefix  VARCHAR,
  dst_country_id      INTEGER,
  dst_network_id      INTEGER,
  calls_count         BIGINT  NOT NULL,
  calls_duration      BIGINT  NOT NULL,
  acd                 REAL,
  asr                 REAL,
  origination_cost    NUMERIC,
  termination_cost    NUMERIC,
  profit              NUMERIC,
  success_calls_count NUMERIC,
  first_call_at       TIMESTAMPTZ,
  last_call_at        TIMESTAMPTZ,
  short_calls_count   BIGINT  NOT NULL
);

CREATE TABLE reports.customer_traffic_report_data_by_destination (
  id                  BIGSERIAL PRIMARY KEY,
  report_id           INTEGER NOT NULL,
  destination_prefix  VARCHAR,
  dst_country_id      INTEGER,
  dst_network_id      INTEGER,
  calls_count         BIGINT  NOT NULL,
  calls_duration      BIGINT  NOT NULL,
  acd                 REAL,
  asr                 REAL,
  origination_cost    NUMERIC,
  termination_cost    NUMERIC,
  profit              NUMERIC,
  success_calls_count NUMERIC,
  first_call_at       TIMESTAMPTZ,
  last_call_at        TIMESTAMPTZ,
  short_calls_count   BIGINT  NOT NULL
);


commit;