# frozen_string_literal: true

class CreateNewEntityForCustomerPermissions < ActiveRecord::Migration[7.2]
  def up
    ApplicationRecord.transaction do
      create_table 'sys.customer_portal_access_profiles', id: :smallserial do |t|
        t.string :name, null: false
        t.boolean :account, null: false, default: true
        t.boolean :outgoing_rateplans, null: false, default: true
        t.boolean :outgoing_cdrs, null: false, default: true
        t.boolean :outgoing_cdr_exports, null: false, default: true
        t.boolean :outgoing_statistics, null: false, default: true
        t.boolean :outgoing_statistics_active_calls, null: false, default: true
        t.boolean :outgoing_statistics_acd, null: false, default: true
        t.boolean :outgoing_statistics_asr, null: false, default: true
        t.boolean :outgoing_statistics_failed_calls, null: false, default: true
        t.boolean :outgoing_statistics_successful_calls, null: false, default: true
        t.boolean :outgoing_statistics_total_calls, null: false, default: true
        t.boolean :outgoing_statistics_total_duration, null: false, default: true
        t.boolean :outgoing_statistics_total_price, null: false, default: true
        t.boolean :incoming_cdrs, null: false, default: true
        t.boolean :incoming_statistics, null: false, default: true
        t.boolean :invoices, null: false, default: true
        t.boolean :payments, null: false, default: true
        t.boolean :services, null: false, default: true
        t.boolean :transactions, null: false, default: true

        t.timestamps
      end

      execute <<~SQL.squish
        CREATE UNIQUE INDEX idx_customer_portal_access_profiles_name_index
            ON sys.customer_portal_access_profiles
            USING btree (name);
      SQL

      add_column 'sys.api_access', 'customer_portal_access_profile_id', :smallint, default: 1, null: false
      add_index 'sys.api_access', :customer_portal_access_profile_id

      execute <<~SQL.squish
        INSERT INTO sys.customer_portal_access_profiles (id, name, created_at, updated_at)
            VALUES(1, 'Default', NOW(), NOW())
      SQL

      add_foreign_key 'sys.api_access', 'sys.customer_portal_access_profiles', column: :customer_portal_access_profile_id
    end
  end

  def down
    ApplicationRecord.transaction do
      remove_foreign_key 'sys.api_access', column: :customer_portal_access_profile_id
      execute <<~SQL.squish
        DELETE FROM sys.customer_portal_access_profiles WHERE name like 'Default' AND id = 1;
      SQL
      remove_index 'sys.api_access', :customer_portal_access_profile_id
      remove_column 'sys.api_access', 'customer_portal_access_profile_id'
      remove_index 'sys.customer_portal_access_profiles', name: :idx_customer_portal_access_profiles_name_index
      drop_table 'sys.customer_portal_access_profiles'
    end
  end
end
