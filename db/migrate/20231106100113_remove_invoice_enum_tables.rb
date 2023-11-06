class RemoveInvoiceEnumTables < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      ALTER TABLE ONLY billing.accounts DROP CONSTRAINT accounts_invoice_period_id_fkey
    }
    execute %q{
      DROP TABLE billing.invoice_periods
    }
  end

  def down
    execute %q{
      ALTER TABLE ONLY billing.accounts
        ADD CONSTRAINT accounts_invoice_period_id_fkey FOREIGN KEY (customer_invoice_period_id) REFERENCES billing.invoice_periods(id)

    }
    execute %q{
      CREATE TABLE billing.invoice_periods (
        id smallint PRIMARY KEY,
        name character varying NOT NULL
      )
    }
    execute %q{
      INSERT INTO billing.invoice_periods (id, name) VALUES
        (1, 'Daily'),
        (2, 'Weekly'),
        (3, 'BiWeekly'),
        (4, 'Monthly'),
        (5, 'BiWeekly. Split by new month'),
        (6, 'Weekly. Split by new month')
    }
    execute %q{
      ALTER SEQUENCE billing.invoice_periods_id_seq RESTART WITH 7
    }
  end
end
