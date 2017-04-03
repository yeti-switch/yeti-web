begin;
insert into sys.version(number,comment) values(104,'Dialpeer next rate was changed');

ALTER TABLE class4.dialpeer_next_rates RENAME COLUMN rate TO next_rate;
ALTER TABLE class4.dialpeer_next_rates ADD COLUMN initial_rate numeric;
UPDATE class4.dialpeer_next_rates SET initial_rate = next_rate;
ALTER TABLE class4.dialpeer_next_rates ALTER COLUMN initial_rate SET NOT NULL;

commit;
