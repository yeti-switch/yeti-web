begin;
insert into sys.version(number,comment) values(90,'add blacklist modes');

CREATE TABLE class4.blacklist_modes(id smallint primary key, name varchar not null unique);
INSERT INTO class4.blacklist_modes VALUES (1,'Strict number match');
INSERT INTO class4.blacklist_modes VALUES (2,'Prefix match');

ALTER TABLE class4.blacklists add mode_id smallint not null default 1 references class4.blacklist_modes(id);

commit;