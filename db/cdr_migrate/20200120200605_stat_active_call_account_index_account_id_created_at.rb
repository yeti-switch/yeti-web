class StatActiveCallAccountIndexAccountIdCreatedAt < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE INDEX ON stats.active_call_accounts USING btree (account_id, created_at);
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX stats.active_call_accounts_account_id_created_at_idx;
    SQL
  end
end
