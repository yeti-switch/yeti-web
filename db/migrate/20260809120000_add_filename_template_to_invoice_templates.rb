# frozen_string_literal: true

class AddFilenameTemplateToInvoiceTemplates < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      ALTER TABLE billing.invoice_templates
        ADD COLUMN filename_template character varying NOT NULL
        DEFAULT 'invoice-{{invoice.reference}}';
    }
  end

  def down
    execute %q{
      ALTER TABLE billing.invoice_templates DROP COLUMN filename_template;
    }
  end
end
