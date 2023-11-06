class ChangeInvoiceCdrFields < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      ALTER TABLE ONLY billing.invoices DROP CONSTRAINT invoices_state_id_fkey
    }
    execute %q{
      DROP TABLE billing.invoice_states
    }
    execute %q{
      ALTER TABLE ONLY billing.invoices DROP CONSTRAINT invoices_type_id_fkey
    }
    execute %q{
      DROP TABLE billing.invoice_types
    }
    execute %q{
      ALTER TABLE billing.invoices RENAME COLUMN amount TO originated_amount
    }
    execute %q{
      ALTER TABLE billing.invoices RENAME COLUMN calls_count TO originated_calls_count
    }
    execute %q{
      ALTER TABLE billing.invoices RENAME COLUMN first_call_at TO first_originated_call_at
    }
    execute %q{
      ALTER TABLE billing.invoices RENAME COLUMN last_call_at TO last_originated_call_at
    }
    execute %q{
      ALTER TABLE billing.invoices RENAME COLUMN calls_duration TO originated_calls_duration
    }
    execute %q{
      ALTER TABLE billing.invoices RENAME COLUMN successful_calls_count TO originated_successful_calls_count
    }
    execute %q{
      ALTER TABLE billing.invoices RENAME COLUMN billing_duration TO originated_billing_duration
    }
    # Billing::InvoiceState::NEW == 3
    execute %q{
      ALTER TABLE billing.invoices
        ALTER COLUMN state_id SET DEFAULT 3,
        ALTER COLUMN originated_amount SET DEFAULT 0,
        ALTER COLUMN originated_calls_count SET DEFAULT 0,
        ALTER COLUMN originated_calls_duration SET DEFAULT 0,
        ALTER COLUMN originated_successful_calls_count SET NOT NULL,
        ALTER COLUMN originated_successful_calls_count SET DEFAULT 0,
        ALTER COLUMN originated_billing_duration SET DEFAULT 0,
        ADD COLUMN terminated_amount numeric NOT NULL DEFAULT 0,
        ADD COLUMN terminated_calls_count integer NOT NULL DEFAULT 0,
        ADD COLUMN first_terminated_call_at timestamp with time zone,
        ADD COLUMN last_terminated_call_at timestamp with time zone,
        ADD COLUMN terminated_calls_duration integer NOT NULL DEFAULT 0,
        ADD COLUMN terminated_successful_calls_count integer NOT NULL DEFAULT 0,
        ADD COLUMN terminated_billing_duration integer NOT NULL DEFAULT 0,
        DROP COLUMN vendor_invoice,
        DROP COLUMN first_successful_call_at,
        DROP COLUMN last_successful_call_at
    }
  end

  def down
    execute %q{
      ALTER TABLE billing.invoices RENAME COLUMN originated_amount TO amount
    }
    execute %q{
      ALTER TABLE billing.invoices RENAME COLUMN originated_calls_count TO calls_count
    }
    execute %q{
      ALTER TABLE billing.invoices RENAME COLUMN first_originated_call_at TO first_call_at
    }
    execute %q{
      ALTER TABLE billing.invoices RENAME COLUMN last_originated_call_at TO last_call_at
    }
    execute %q{
      ALTER TABLE billing.invoices RENAME COLUMN originated_calls_duration TO calls_duration
    }
    execute %q{
      ALTER TABLE billing.invoices RENAME COLUMN originated_successful_calls_count TO successful_calls_count
    }
    execute %q{
      ALTER TABLE billing.invoices RENAME COLUMN originated_billing_duration TO billing_duration
    }
    execute %q{
      ALTER TABLE billing.invoices
        DROP COLUMN terminated_amount,
        DROP COLUMN terminated_calls_count,
        DROP COLUMN first_terminated_call_at,
        DROP COLUMN last_terminated_call_at,
        DROP COLUMN terminated_calls_duration,
        DROP COLUMN terminated_successful_calls_count,
        DROP COLUMN terminated_billing_duration,
        ADD COLUMN vendor_invoice boolean NOT NULL DEFAULT false,
        ADD COLUMN first_successful_call_at timestamp with time zone,
        ADD COLUMN last_successful_call_at timestamp with time zone
    }

    execute %q{
      CREATE TABLE billing.invoice_states (
        id smallint PRIMARY KEY,
        name character varying NOT NULL
      )
    }
    execute %q{
      INSERT INTO billing.invoice_states (id, name) VALUES
        (1, 'Pending'),
        (2, 'Approved'),
        (3, 'New')
    }
    execute %q{
      ALTER SEQUENCE billing.invoice_states_id_seq RESTART WITH 4
    }
    execute %q{
      ALTER TABLE ONLY billing.invoices
        ADD CONSTRAINT invoices_state_id_fkey FOREIGN KEY (state_id) REFERENCES billing.invoice_states(id)
    }

    execute %q{
      CREATE TABLE billing.invoice_types (
        id smallint PRIMARY KEY,
        name character varying NOT NULL
      )
    }
    execute %q{
      INSERT INTO billing.invoice_types (id, name) VALUES
        (1, 'Manual'),
        (2, 'Auto. Full period'),
        (3, 'Auto. Partial')
    }
    execute %q{
      ALTER SEQUENCE billing.invoice_types_id_seq RESTART WITH 4
    }
    execute %q{
      ALTER TABLE ONLY billing.invoices
        ADD CONSTRAINT invoices_type_id_fkey FOREIGN KEY (type_id) REFERENCES billing.invoice_types(id)
    }
  end
end
