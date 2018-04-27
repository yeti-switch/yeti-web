class CreateImportNumberlistItems < ActiveRecord::Migration
  def change
    create_table 'data_import.import_numberlists' do |t|
      t.integer :o_id, limit: 2
      t.string :error_string
      t.string :name
      t.integer :mode_id
      t.string :mode_name
      t.integer :default_action_id
      t.string :default_action_name
      t.string :default_src_rewrite_rule
      t.string :default_src_rewrite_result
      t.string :default_dst_rewrite_rule
      t.string :default_dst_rewrite_result
      t.integer :tag_action_id
      t.string :tag_action_name
      t.integer :tag_action_value, limit: 2, null: false, array: true, default: []
      t.string :tag_action_value_names
    end

    create_table 'data_import.import_numberlist_items' do |t|
      t.integer :o_id
      t.string :error_string
      t.integer :numberlist_id, limit: 2
      t.string :numberlist_name
      t.string :key
      t.integer :action_id
      t.string :action_name
      t.string :src_rewrite_rule
      t.string :src_rewrite_result
      t.string :dst_rewrite_rule
      t.string :dst_rewrite_result
      t.integer :tag_action_id
      t.string :tag_action_name
      t.integer :tag_action_value, limit: 2, null: false, array: true, default: []
      t.string :tag_action_value_names
    end
  end
end
