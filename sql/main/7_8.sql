begin;
ALTER TABLE gui.admin_users add ssh_key text;
insert into sys.version(number,comment) values(8,'SSH key management for yeticmd');
commit;
