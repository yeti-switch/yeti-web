class CreateRateManagementPricelists < ActiveRecord::Migration[6.1]
  def up
    create_table :'ratemanagement.pricelists', id: :integer, limit: 4 do |t|
      t.string :name, null: false
      t.string :filename, null: false
      t.timestamp :valid_till, null: false
      t.integer :items_count, default: 0, null: false
      t.timestamp :applied_at
      t.boolean :apply_changes_in_progress, null: false, default: false
      t.boolean :detect_dialpeers_in_progress, null: false, default: false
      t.boolean :retain_enabled, null: false, default: false
      t.boolean :retain_priority, null: false, default: false
      t.timestamp :valid_from, null: true, default: nil
      t.integer :state_id, limit: 2, null: false

      t.references :project, type: :integer, limit: 4, null: false, foreign_key: { to_table: 'ratemanagement.projects' }

      t.timestamps
    end

    create_table :'ratemanagement.pricelist_items' do |t|
      t.references :pricelist, type: :integer, limit: 4, null: false, foreign_key: { to_table: 'ratemanagement.pricelists' }
      t.timestamp :valid_from
      t.timestamp :valid_till, null: false

      t.string :prefix, null: false, default: ''
      t.column :connect_fee, :numeric, null: false
      t.column :initial_rate, :numeric, null: false
      t.column :next_rate, :numeric, null: false
      t.column :initial_interval, :smallint, null: false
      t.column :next_interval, :smallint, null: false

      # constant fields
      t.boolean :enabled, null: true
      t.string :src_rewrite_rule
      t.string :dst_rewrite_rule
      t.string :src_rewrite_result
      t.string :dst_rewrite_result
      t.string :src_name_rewrite_rule
      t.string :src_name_rewrite_result
      t.column :acd_limit, :real
      t.column :asr_limit, :real
      t.integer :priority, null: true
      t.integer :capacity, limit: 2
      t.column :lcr_rate_multiplier, :numeric
      t.column :force_hit_rate, 'double precision'
      t.column :short_calls_limit, :real, null: false
      t.boolean :exclusive_route, null: false
      t.integer :dst_number_min_length, limit: 2, null: false
      t.integer :dst_number_max_length, limit: 2, null: false
      t.boolean :reverse_billing, default: false
      t.integer :routing_tag_ids, limit: 2, array: true, null: false, default: []

      t.references :gateway, type: :integer, limit: 4, null: true, foreign_key: { to_table: 'gateways' }
      t.references :gateway_group, type: :integer, limit: 4, null: true, foreign_key: { to_table: 'gateway_groups' }
      t.references :routing_tag_mode, type: :integer, limit: 2, default: 0, foreign_key: { to_table: 'routing_tag_modes' }
      # constant fields

      # scope fields
      t.references :account, type: :integer, limit: 4, null: true, foreign_key: { to_table: 'accounts' }
      t.references :vendor, type: :integer, limit: 4, null: false, foreign_key: { to_table: 'contractors' }
      t.references :routing_group, type: :integer, limit: 4, null: true, foreign_key: { to_table: 'routing_groups' }
      t.references :routeset_discriminator, type: :integer, limit: 2, null: true, foreign_key: { to_table: 'routeset_discriminators' }, index: { name: 'index_ratemanagement.pricelistitems_on_routesetdiscriminator_id' }
      # scope fields

      t.references :dialpeer, type: :bigint, null: true, foreign_key: { to_table: 'class4.dialpeers' }
      t.column :detected_dialpeer_ids, :bigint, array: true, default: []

      t.boolean :to_delete, null: false, default: false
    end
  end

  def down
    drop_table :'ratemanagement.pricelist_items'
    drop_table :'ratemanagement.pricelists'
  end
end
