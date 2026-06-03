# frozen_string_literal: true

class DropSysActiveCurrencies < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      DROP TABLE sys.active_currencies;
      DROP TABLE sys.currencies;
    SQL
  end

  def down
    execute <<-SQL
      CREATE TABLE sys.currencies (
          id smallint NOT NULL,
          name character varying NOT NULL,
          country_id integer,
          code character varying(3) NOT NULL,
          num_code character varying(3) NOT NULL
      );

      CREATE SEQUENCE sys.currencies_id_seq
          START WITH 1
          INCREMENT BY 1
          NO MINVALUE
          NO MAXVALUE
          CACHE 1;

      ALTER SEQUENCE sys.currencies_id_seq OWNED BY sys.currencies.id;

      ALTER TABLE ONLY sys.currencies ALTER COLUMN id SET DEFAULT nextval('sys.currencies_id_seq'::regclass);

      ALTER TABLE ONLY sys.currencies
          ADD CONSTRAINT currencies_pkey PRIMARY KEY (id);

      ALTER TABLE ONLY sys.currencies
          ADD CONSTRAINT currencies_name_key UNIQUE (name);

      ALTER TABLE ONLY sys.currencies
          ADD CONSTRAINT currencies_country_id_fkey FOREIGN KEY (country_id) REFERENCES sys.countries(id);

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
