class AddBillingDecrement < ActiveRecord::Migration
  def up
    execute %q{
        alter type billing.cdr_v2
          add attribute destination_reverse_billing boolean,
          add attribute dialpeer_reverse_billing boolean;

CREATE OR REPLACE FUNCTION billing.bill_cdr(i_cdr billing.cdr_v2)
  RETURNS void AS
$BODY$
DECLARE
BEGIN
    if i_cdr.dialpeer_reverse_billing is not null and i_cdr.dialpeer_reverse_billing=true then
      UPDATE billing.accounts SET balance=balance-i_cdr.vendor_price WHERE id=i_cdr.vendor_acc_id;
    else
      UPDATE billing.accounts SET balance=balance+i_cdr.vendor_price WHERE id=i_cdr.vendor_acc_id;
    end if;

    if i_cdr.destination_reverse_billing is not null and i_cdr.destination_reverse_billing=true then
      UPDATE billing.accounts SET balance=balance+i_cdr.customer_price WHERE id=i_cdr.customer_acc_id;
    else
      UPDATE billing.accounts SET balance=balance-i_cdr.customer_price WHERE id=i_cdr.customer_acc_id;
    end if;

    return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 10;

    }

  end

  def down
    execute %q{
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

        alter type billing.cdr_v2
          drop attribute destination_reverse_billing,
          drop attribute dialpeer_reverse_billing;

    }

  end
end
