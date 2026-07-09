# frozen_string_literal: true

class AddCurrencyIdToInvoices < ActiveRecord::Migration[7.2]
  def up
    execute %q{alter table billing.invoices add column currency_id smallint;}
  end

  def down
    execute %q{alter table billing.invoices drop column currency_id;}
  end
end
