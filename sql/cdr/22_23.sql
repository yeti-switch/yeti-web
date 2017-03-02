begin;
insert into sys.version(number,comment) values(23,'PDD distribution time');

CREATE INDEX ON stats.termination_quality_stats USING btree (gateway_id);
CREATE INDEX ON stats.termination_quality_stats USING btree (dialpeer_id);


commit;