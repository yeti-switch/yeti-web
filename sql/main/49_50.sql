begin;
insert into sys.version(number,comment) values(50,'events to pgq');

CREATE EXTENSION pgq;
CREATE EXTENSION pgq_ext;

select pgq.create_queue('gateway-sync');

commit;