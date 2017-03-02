begin;
insert into sys.version(number,comment) values(7,'CDR tables fix.');
select * from sys.cdr_createtable(-1);
select * from sys.cdr_createtable(0);
select * from sys.cdr_createtable(1);
commit;
