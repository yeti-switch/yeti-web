begin;
insert into sys.version(number,comment) values(70,'filters saving');

ALTER TABLE gui.admin_users
  add visible_columns json DEFAULT '{}' NOT NULL,
  add per_page json DEFAULT '{}' NOT NULL,
  add saved_filters json DEFAULT '{}' NOT NULL;

commit;