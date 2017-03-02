begin;
insert into sys.version(number,comment) values(60,'fix next rates');

delete from class4.dialpeer_next_rates where id in (select c.id from class4.dialpeer_next_rates c left join class4.dialpeers d ON c.dialpeer_id=d.id where d.id is null);
ALTER TABLE class4.dialpeer_next_rates ADD  FOREIGN KEY(dialpeer_id) REFERENCES class4.dialpeers(id);


ALTER TABLE billing.accounts add next_customer_invoice_type_id smallint;
ALTER TABLE billing.accounts add next_vendor_invoice_type_id smallint;
commit;