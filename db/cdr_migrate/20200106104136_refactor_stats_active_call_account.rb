class RefactorStatsActiveCallAccount < ActiveRecord::Migration[5.2]
  def up
    create_table 'stats.active_call_accounts' do |t|
      t.integer :account_id, null: false
      t.integer :originated_count, null: false
      t.integer :terminated_count, null: false
      t.column :created_at, 'timestamp with time zone'
    end

    drop_table 'stats.active_call_customer_accounts'
    drop_table 'stats.active_call_vendor_accounts'

    create_table 'stats.active_call_accounts_hourly' do |t|
      t.integer :account_id, null: false
      t.integer :max_originated_count, null: false
      t.integer :avg_originated_count, null: false
      t.integer :min_originated_count, null: false
      t.integer :max_terminated_count, null: false
      t.integer :avg_terminated_count, null: false
      t.integer :min_terminated_count, null: false
      t.column :created_at, 'timestamp with time zone', null: false
      t.column :calls_time, 'timestamp with time zone', null: false
    end

    drop_table 'stats.active_call_customer_accounts_hourly'
    drop_table 'stats.active_call_vendor_accounts_hourly'
  end

  def down
    create_table 'stats.active_call_customer_accounts' do |t|
      t.integer :account_id, null: false
      t.integer :count, null: false
      t.timestamp :created_at
    end

    create_table 'stats.active_call_vendor_accounts' do |t|
      t.integer :account_id, null: false
      t.integer :count, null: false
      t.timestamp :created_at
    end

    drop_table 'stats.active_call_accounts'

    create_table 'stats.active_call_customer_accounts_hourly' do |t|
      t.integer :account_id, null: false
      t.integer :max_count, null: false
      t.integer :avg_count, null: false
      t.integer :min_count, null: false
      t.timestamp :created_at, null: false
      t.timestamp :calls_time, null: false
    end

    create_table 'stats.active_call_vendor_accounts_hourly' do |t|
      t.integer :account_id, null: false
      t.integer :max_count, null: false
      t.integer :avg_count, null: false
      t.integer :min_count, null: false
      t.timestamp :created_at, null: false
      t.timestamp :calls_time, null: false
    end

    drop_table 'stats.active_call_accounts_hourly'
  end
end
