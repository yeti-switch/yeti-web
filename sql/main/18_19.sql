begin;
insert into sys.version(number,comment) values(19,'Active calls configuration');

alter table sys.guiconfig add active_calls_require_filter boolean not null default true;
alter table sys.guiconfig add registrations_require_filter boolean not null default true;
alter table sys.guiconfig add active_calls_show_chart boolean not null default false;

insert into class4.disconnect_code(id,namespace_id,stop_hunting,pass_reason_to_originator,code,reason,rewrited_code,rewrited_reason,success,successnozerolen,store_cdr,silently_drop)
values(1500,1,true,false,500,'SDP processing exception',null,null,false,true,true,false);

insert into class4.disconnect_code(id,namespace_id,stop_hunting,pass_reason_to_originator,code,reason,rewrited_code,rewrited_reason,success,successnozerolen,store_cdr,silently_drop)
values(1501,1,true,false,500,'SDP parsing failed',null,null,false,true,true,false);

insert into class4.disconnect_code(id,namespace_id,stop_hunting,pass_reason_to_originator,code,reason,rewrited_code,rewrited_reason,success,successnozerolen,store_cdr,silently_drop)
values(1502,1,true,false,500,'SDP empty answer',null,null,false,true,true,false);

insert into class4.disconnect_code(id,namespace_id,stop_hunting,pass_reason_to_originator,code,reason,rewrited_code,rewrited_reason,success,successnozerolen,store_cdr,silently_drop)
values(1503,1,true,false,500,'SDP invalid streams count',null,null,false,true,true,false);

insert into class4.disconnect_code(id,namespace_id,stop_hunting,pass_reason_to_originator,code,reason,rewrited_code,rewrited_reason,success,successnozerolen,store_cdr,silently_drop)
values(1504,1,true,false,500,'SDP inv streams types',null,null,false,true,true,false);

commit;
