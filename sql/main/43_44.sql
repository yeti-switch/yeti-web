begin;
insert into sys.version(number,comment) values(44,'Auth by username instead of email');

UPDATE gui.admin_users set username =regexp_replace(email,'(.*)@.*','\1');
ALTER TABLE gui.admin_users ALTER COLUMN username set NOT NULL ;
CREATE UNIQUE INDEX ON gui.admin_users(username );
ALTER TABLE gui.admin_users DROP COLUMN email ;

commit;
