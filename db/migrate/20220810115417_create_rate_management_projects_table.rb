class CreateRateManagementProjectsTable < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE SCHEMA ratemanagement;
    SQL

    create_table :'ratemanagement.projects', id: :integer, limit: 4 do |t|
      t.string :name, null: false, index: { unique: true }

      t.boolean :enabled, null: false, default: false
      t.string :src_rewrite_rule
      t.string :dst_rewrite_rule
      t.string :src_rewrite_result
      t.string :dst_rewrite_result
      t.string :src_name_rewrite_rule
      t.string :src_name_rewrite_result
      t.column :acd_limit, :real, default: 0
      t.column :asr_limit, :real, default: 0.0
      t.integer :keep_applied_pricelists_days, limit: 2, null: false, default: 30
      t.integer :priority, null: false, default: 100
      t.integer :capacity, limit: 2
      t.column :lcr_rate_multiplier, :numeric, default: 1
      t.integer :initial_interval, default: 1
      t.integer :next_interval, default: 1
      t.column :force_hit_rate, 'double precision'
      t.column :short_calls_limit, :real, null: false, default: 1
      t.boolean :exclusive_route, null: false, default: false
      t.integer :dst_number_min_length, limit: 2, null: false, default: 0
      t.integer :dst_number_max_length, limit: 2, null: false, default: 100
      t.boolean :reverse_billing, default: false
      t.integer :routing_tag_ids, limit: 2, array: true, null: false, default: []

      t.references :account, type: :integer, limit: 4, null: false, foreign_key: { to_table: 'accounts' }
      t.references :vendor, type: :integer, limit: 4, null: false, foreign_key: { to_table: 'contractors' }
      t.references :routing_group, type: :integer, limit: 4, null: false, foreign_key: { to_table: 'routing_groups' }
      t.references :routeset_discriminator, type: :integer, limit: 2, null: false, foreign_key: { to_table: 'routeset_discriminators' }

      t.references :gateway, type: :integer, limit: 4, null: true, foreign_key: { to_table: 'gateways' }
      t.references :gateway_group, type: :integer, limit: 4, null: true, foreign_key: { to_table: 'gateway_groups' }

      t.references :routing_tag_mode, type: :integer, limit: 2, default: 0, foreign_key: { to_table: 'routing_tag_modes' }

      t.timestamps
    end
  end

  def down
    execute <<-SQL
      DROP SCHEMA ratemanagement CASCADE;
    SQL
  end
end


