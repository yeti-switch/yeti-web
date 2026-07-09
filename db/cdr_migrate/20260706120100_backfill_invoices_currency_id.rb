# frozen_string_literal: true

# Backfill billing.invoices.currency_id from each invoice's account, then enforce
# NOT NULL. Accounts live in the primary DB; invoices in the CDR DB. They are two
# separate physical databases, so there is no cross-database JOIN to do this in a
# single UPDATE - we read the account -> currency mapping first, then update
# invoices grouped by account.
#
# The catch: for the duration of a CDR migration ActiveRecord routes *every* model
# onto the CDR connection - even primary-DB models like Account (reading Account
# here raises "relation billing.accounts does not exist" against the CDR DB). So
# the accounts are read through AR's own pool under a dedicated :backfill_primary
# role that points at the primary database.
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

  # [[account_id, currency_id], ...] read from the primary DB.
  def account_currencies(account_ids)
    ids = account_ids.map(&:to_i).join(',')
    on_primary do |conn|
      conn.select_rows("SELECT id, currency_id FROM billing.accounts WHERE id IN (#{ids})")
          .map { |id, currency_id| [id.to_i, currency_id.to_i] }
    end
  end

  # Runs the block against the primary DB regardless of the CDR-migration
  # connection swap, using an AR pool under a dedicated role.
  def on_primary
    primary = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: 'primary')
    ActiveRecord::Base.connection_handler.establish_connection(primary, role: :backfill_primary)
    ActiveRecord::Base.connected_to(role: :backfill_primary) do
      yield ActiveRecord::Base.lease_connection
    end
  end
end
