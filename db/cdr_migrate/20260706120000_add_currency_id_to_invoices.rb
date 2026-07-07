# frozen_string_literal: true

class AddCurrencyIdToInvoices < ActiveRecord::Migration[7.2]
  def change
    add_column 'billing.invoices', :currency_id, :smallint
  end
end
