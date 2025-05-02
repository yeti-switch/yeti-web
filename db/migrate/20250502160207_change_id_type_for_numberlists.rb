class ChangeIdTypeForNumberlists < ActiveRecord::Migration[7.2]
  def up
    change_column :numberlists, :id, :integer
    change_column :numberlist_items, :numberlist_id, :integer
    change_column :customers_auth, :dst_numberlist_id, :integer
    change_column :customers_auth, :src_numberlist_id, :integer
    change_column :customers_auth_normalized, :dst_numberlist_id, :integer
    change_column :customers_auth_normalized, :src_numberlist_id, :integer
    change_column :routing_plans, :dst_numberlist_id, :integer
    change_column :routing_plans, :src_numberlist_id, :integer

    change_column :gateways, :termination_src_numberlist_id, :integer
    change_column :gateways, :termination_dst_numberlist_id, :integer
    add_foreign_key :gateways, :numberlists, column: :termination_src_numberlist_id, name: 'gateways_termination_src_numberlist_id_fkey'
    add_foreign_key :gateways, :numberlists, column: :termination_dst_numberlist_id, name: 'gateways_termination_dst_numberlist_id_fkey'
  end

  def down
    change_column :numberlists, :id, :smallint
    change_column :numberlist_items, :numberlist_id, :smallint
    change_column :customers_auth, :dst_numberlist_id, :smallint
    change_column :customers_auth, :src_numberlist_id, :smallint
    change_column :customers_auth_normalized, :dst_numberlist_id, :smallint
    change_column :customers_auth_normalized, :src_numberlist_id, :smallint
    change_column :routing_plans, :dst_numberlist_id, :smallint
    change_column :routing_plans, :src_numberlist_id, :smallint

    change_column :gateways, :termination_src_numberlist_id, :smallint
    change_column :gateways, :termination_dst_numberlist_id, :smallint
    remove_foreign_key :gateways, name: 'gateways_termination_src_numberlist_id_fkey'
    remove_foreign_key :gateways, name: 'gateways_termination_dst_numberlist_id_fkey'
  end
end
