# frozen_string_literal: true

class CreateBillingCurrencies < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE TABLE billing.currencies (
        id smallserial PRIMARY KEY,
        name varchar NOT NULL UNIQUE,
        rate double precision NOT NULL
      );
      INSERT INTO billing.currencies (id, name, rate) VALUES (0, 'USD', 1);
      SELECT pg_catalog.setval('billing.currencies_id_seq', 1, true);

      ALTER TABLE billing.accounts
        ADD COLUMN currency_id smallint NOT NULL DEFAULT 0
        REFERENCES billing.currencies(id),
        ADD COLUMN currency_name varchar NOT NULL DEFAULT 'USD';

      CREATE INDEX accounts_currency_id_idx ON billing.accounts USING btree(currency_id);
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE billing.accounts DROP COLUMN currency_name;
      ALTER TABLE billing.accounts DROP COLUMN currency_id;
      DROP TABLE billing.currencies;
    SQL
  end
end
