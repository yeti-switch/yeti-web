class CustomerPriceNoVatFixNull < ActiveRecord::Migration
  def up
    execute %q{
    CREATE or replace FUNCTION billing.bill_cdr(i_cdr cdr.cdr) RETURNS cdr.cdr
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    _v billing.interval_billing_data%rowtype;
BEGIN
    if i_cdr.duration>0 and i_cdr.success then  -- run billing.
        _v=billing.interval_billing(
            i_cdr.duration,
            i_cdr.destination_fee,
            i_cdr.destination_initial_rate,
            i_cdr.destination_next_rate,
            i_cdr.destination_initial_interval,
            i_cdr.destination_next_interval,
            i_cdr.customer_acc_vat);
         i_cdr.customer_price=_v.amount;
         i_cdr.customer_price_no_vat=_v.amount_no_vat;
         i_cdr.customer_duration=_v.duration;

         _v=billing.interval_billing(
            i_cdr.duration,
            i_cdr.dialpeer_fee,
            i_cdr.dialpeer_initial_rate,
            i_cdr.dialpeer_next_rate,
            i_cdr.dialpeer_initial_interval,
            i_cdr.dialpeer_next_interval,
            0);
         i_cdr.vendor_price=_v.amount;
         i_cdr.vendor_duration=_v.duration;
         i_cdr.profit=i_cdr.customer_price-i_cdr.vendor_price;
    else
        i_cdr.customer_price=0;
        i_cdr.customer_price_no_vat=0;
        i_cdr.vendor_price=0;
        i_cdr.profit=0;
    end if;
    RETURN i_cdr;
END;
$$;

    }
  end

  def down
    execute %q{
    CREATE or replace FUNCTION billing.bill_cdr(i_cdr cdr.cdr) RETURNS cdr.cdr
    LANGUAGE plpgsql COST 10
    AS $$
DECLARE
    _v billing.interval_billing_data%rowtype;
BEGIN
    if i_cdr.duration>0 and i_cdr.success then  -- run billing.
        _v=billing.interval_billing(
            i_cdr.duration,
            i_cdr.destination_fee,
            i_cdr.destination_initial_rate,
            i_cdr.destination_next_rate,
            i_cdr.destination_initial_interval,
            i_cdr.destination_next_interval,
            i_cdr.customer_acc_vat);
         i_cdr.customer_price=_v.amount;
         i_cdr.customer_price_no_vat=_v.amount_no_vat;
         i_cdr.customer_duration=_v.duration;

         _v=billing.interval_billing(
            i_cdr.duration,
            i_cdr.dialpeer_fee,
            i_cdr.dialpeer_initial_rate,
            i_cdr.dialpeer_next_rate,
            i_cdr.dialpeer_initial_interval,
            i_cdr.dialpeer_next_interval,
            0);
         i_cdr.vendor_price=_v.amount;
         i_cdr.vendor_duration=_v.duration;
         i_cdr.profit=i_cdr.customer_price-i_cdr.vendor_price;
    else
        i_cdr.customer_price=0;
        i_cdr.vendor_price=0;
        i_cdr.profit=0;
    end if;
    RETURN i_cdr;
END;
$$;

    }
  end

end
