begin;
create sequence sys.events_id_seq;
alter table sys.events alter COLUMN id set default nextval('sys.events_id_seq'::regclass);

CREATE OR REPLACE FUNCTION billing.bill_cdr(i_cdr billing.cdr_v2)
  RETURNS void AS
$BODY$
DECLARE
BEGIN
    UPDATE billing.accounts SET balance=balance+i_cdr.vendor_price WHERE id=i_cdr.vendor_acc_id;
    UPDATE billing.accounts SET balance=balance-i_cdr.customer_price WHERE id=i_cdr.customer_acc_id;
    return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 10;


insert into sys.version(number,comment) values(7,'Fix switch events insertion.Fix billing.');
commit;
