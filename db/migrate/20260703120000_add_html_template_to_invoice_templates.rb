# frozen_string_literal: true

class AddHtmlTemplateToInvoiceTemplates < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      ALTER TABLE billing.invoice_templates ADD COLUMN html_template text;
      ALTER TABLE billing.invoice_templates ALTER COLUMN filename DROP NOT NULL;
    }
  end

  def down
    execute %q{
      ALTER TABLE billing.invoice_templates ALTER COLUMN filename SET NOT NULL;
      ALTER TABLE billing.invoice_templates DROP COLUMN html_template;
    }
  end
end
