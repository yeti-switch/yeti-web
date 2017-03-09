begin;
insert into sys.version(number,comment) values(101,'G722 codec');

insert into class4.codecs(name) values('G722/8000');

commit;