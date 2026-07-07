# frozen_string_literal: true

# Backfill billing.invoices.currency_id from each invoice's account, then enforce
# NOT NULL. Accounts live in the primary DB and this migration runs on the CDR
# connection; ActiveRecord forces model reads onto the CDR connection for the
# duration of a CDR migration, so the account -> currency mapping is read through
# a direct connection to the primary DB. Invoices (CDR) are updated with raw SQL
# on the migration's own connection.
class BackfillInvoicesCurrencyId < ActiveRecord::Migration[7.2]
  def up
    account_ids = select_values('SELECT DISTINCT account_id FROM billing.invoices')
    unless account_ids.empty?
      account_currencies(account_ids).each do |account_id, currency_id|
        execute("UPDATE billing.invoices SET currency_id = #{currency_id} WHERE account_id = #{account_id}")
      end
    end
    change_column_null 'billing.invoices', :currency_id, false
  end

  def down
    change_column_null 'billing.invoices', :currency_id, true
  end

  private

  # [[account_id, currency_id], ...] read straight from the primary DB.
  def account_currencies(account_ids)
    cfg = ActiveRecord::Base.configurations
                            .configs_for(env_name: Rails.env, name: 'primary')
                            .configuration_hash
    conn = PG.connect(host: cfg[:host], port: cfg[:port], dbname: cfg[:database],
                      user: cfg[:username], password: cfg[:password])
    ids = account_ids.map(&:to_i).join(',')
    conn.exec("SELECT id, currency_id FROM billing.accounts WHERE id IN (#{ids})")
        .map { |r| [r['id'].to_i, r['currency_id'].to_i] }
  ensure
    conn&.close
  end
end
