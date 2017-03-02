begin;
insert into sys.version(number,comment) values(99,'Importing');

ALTER TABLE class4.gateways ALTER COLUMN host DROP NOT NULL ;

alter table data_import.import_customers_auth
  add radius_auth_profile_id SMALLINT,
  add radius_auth_profile_name varchar,
  add radius_accounting_profile_id SMALLINT,
  add radius_accounting_profile_name varchar,
  add src_number_radius_rewrite_rule varchar,
  add src_number_radius_rewrite_result varchar,
  add dst_number_radius_rewrite_rule VARCHAR,
  add dst_number_radius_rewrite_result varchar,
  add enable_audio_recording boolean,
  add from_domain varchar,
  add to_domain varchar;

commit;