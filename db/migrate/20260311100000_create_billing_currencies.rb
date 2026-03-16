# frozen_string_literal: true

class CreateBillingCurrencies < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      CREATE TABLE billing.currencies (
        id smallserial PRIMARY KEY,
        name varchar NOT NULL UNIQUE,
        rate double precision NOT NULL
      );
      INSERT INTO billing.currencies (id, name, rate) VALUES (0, 'USD', 1);
      SELECT pg_catalog.setval('billing.currencies_id_seq', 1, true);

      ALTER TABLE billing.accounts
        ADD COLUMN currency_id smallint REFERENCES billing.currencies(id),
        ADD COLUMN currency_name varchar;

      UPDATE billing.accounts SET currency_id = 0, currency_name = 'USD';

      ALTER TABLE billing.accounts
        ALTER COLUMN currency_id SET NOT NULL,
        ALTER COLUMN currency_name SET NOT NULL;

      CREATE INDEX accounts_currency_id_idx ON billing.accounts USING btree(currency_id);
    }
  end

  def down
    execute %q{
      ALTER TABLE billing.accounts DROP COLUMN currency_name;
      ALTER TABLE billing.accounts DROP COLUMN currency_id;
      DROP TABLE billing.currencies;
    }
  end
end
