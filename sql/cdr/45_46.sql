begin;
insert into sys.version(number,comment) values(46,'Transport protocols');

alter table cdr.cdr
  add auth_orig_transport_protocol_id smallint,
  add sign_orig_transport_protocol_id smallint,
  add sign_term_transport_protocol_id smallint;

alter table cdr.cdr_archive
  add auth_orig_transport_protocol_id smallint,
  add sign_orig_transport_protocol_id smallint,
  add sign_term_transport_protocol_id smallint;

commit;