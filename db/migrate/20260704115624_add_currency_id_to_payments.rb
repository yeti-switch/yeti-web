# frozen_string_literal: true

class AddCurrencyIdToPayments < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      ALTER TABLE billing.payments ADD currency_id smallint;
      UPDATE billing.payments p SET currency_id = a.currency_id FROM billing.accounts a WHERE a.id = p.account_id;
      ALTER TABLE billing.payments ALTER COLUMN currency_id SET NOT NULL;
      ALTER TABLE billing.payments ADD CONSTRAINT payments_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES billing.currencies(id);
    }
  end

  def down
    execute %q{
      ALTER TABLE billing.payments DROP COLUMN currency_id;
    }
  end
end
