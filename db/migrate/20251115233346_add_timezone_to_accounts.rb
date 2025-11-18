# frozen_string_literal: true

class AddTimezoneToAccounts < ActiveRecord::Migration[7.2]
  def change
    add_column 'billing.accounts', :timezone, :string
  end
end
