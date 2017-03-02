begin;
insert into sys.version(number,comment) values(56,'New invoice periods');

INSERT INTO billing.invoice_periods VALUES (5,'BiWeekly. Split by new month');
INSERT INTO billing.invoice_periods VALUES (6,'Weekly. Split by new month');

commit;
