# frozen_string_literal: true

class DropSysActiveCurrencies < ActiveRecord::Migration[7.2]
  # sys.active_currencies was scaffolded for an old currency auto-update design
  # but was never wired into any model, admin page, or stored procedure. It is
  # also tied to sys.currencies rather than the currently-used billing.currencies.
  # Drop the orphan table; auto-update will be built on billing.currencies.
  def up
    execute <<-SQL
      DROP TABLE sys.active_currencies;
    SQL
  end

  def down
    execute <<-SQL
      CREATE TABLE sys.active_currencies (
          id integer NOT NULL,
          currency_id smallint NOT NULL,
          is_base boolean DEFAULT false NOT NULL,
          enable_autoupdate boolean DEFAULT true NOT NULL,
          description character varying,
          created_at timestamp with time zone,
          updated_at timestamp with time zone,
          rate numeric
      );

      CREATE SEQUENCE sys.active_currencies_id_seq
          START WITH 1
          INCREMENT BY 1
          NO MINVALUE
          NO MAXVALUE
          CACHE 1;

      ALTER SEQUENCE sys.active_currencies_id_seq OWNED BY sys.active_currencies.id;

      ALTER TABLE ONLY sys.active_currencies ALTER COLUMN id SET DEFAULT nextval('sys.active_currencies_id_seq'::regclass);

      ALTER TABLE ONLY sys.active_currencies
          ADD CONSTRAINT active_currencies_pkey PRIMARY KEY (id);

      ALTER TABLE ONLY sys.active_currencies
          ADD CONSTRAINT active_currencies_currency_id_key UNIQUE (currency_id);

      ALTER TABLE ONLY sys.active_currencies
          ADD CONSTRAINT active_currencies_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES sys.currencies(id);
    SQL
  end
end
