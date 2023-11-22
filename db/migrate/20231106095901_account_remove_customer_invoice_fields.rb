class AccountRemoveCustomerInvoiceFields < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      ALTER TABLE billing.accounts RENAME customer_invoice_period_id TO invoice_period_id
    }
    execute %q{
      ALTER TABLE billing.accounts RENAME customer_invoice_template_id TO invoice_template_id
    }
    execute %q{
      ALTER TABLE billing.accounts RENAME next_customer_invoice_at TO next_invoice_at
    }
    execute %q{
      ALTER TABLE billing.accounts RENAME next_customer_invoice_type_id TO next_invoice_type_id
    }
    execute %q{
      ALTER TABLE billing.accounts RENAME customer_invoice_ref_template TO invoice_ref_template
    }
    execute %q{
      ALTER TABLE billing.accounts
        DROP COLUMN vendor_invoice_template_id,
        DROP COLUMN vendor_invoice_period_id,
        DROP COLUMN next_vendor_invoice_at,
        DROP COLUMN next_vendor_invoice_type_id,
        DROP COLUMN vendor_invoice_ref_template
    }
  end

  def down
    execute %q{
      ALTER TABLE billing.accounts
        ADD COLUMN vendor_invoice_template_id integer,
        ADD COLUMN vendor_invoice_period_id smallint,
        ADD COLUMN next_vendor_invoice_at timestamp with time zone,
        ADD COLUMN next_vendor_invoice_type_id smallint,
        ADD COLUMN vendor_invoice_ref_template character varying DEFAULT '$id'::character varying NOT NULL
    }
    execute %q{
      ALTER TABLE billing.accounts RENAME invoice_period_id TO customer_invoice_period_id
    }
    execute %q{
      ALTER TABLE billing.accounts RENAME invoice_template_id TO customer_invoice_template_id
    }
    execute %q{
      ALTER TABLE billing.accounts RENAME next_invoice_at TO next_customer_invoice_at
    }
    execute %q{
      ALTER TABLE billing.accounts RENAME next_invoice_type_id TO next_customer_invoice_type_id
    }
    execute %q{
      ALTER TABLE billing.accounts RENAME invoice_ref_template TO customer_invoice_ref_template
    }
  end
end
