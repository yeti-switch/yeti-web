begin;
insert into sys.version(number,comment) values(45,'Auth by username instead of email');


ALTER TABLE notifications.email_logs rename column  attachment_id to attachment_id_;
ALTER TABLE notifications.email_logs add attachment_id integer[];
update  notifications.email_logs set attachment_id[1]=attachment_id_;
ALTER TABLE notifications.email_logs drop column  attachment_id_;

ALTER TABLE billing.accounts add send_invoices_to integer[];

commit;
