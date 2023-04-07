class CreateImportRoutingTagDetectionRules < ActiveRecord::Migration[6.1]
  def up
    create_table 'data_import.import_routing_tag_detection_rules' do |t|
      t.integer :routing_tag_ids, type: :integer, limit: 2, array: true, null: false, default: []
      t.references :src_area, type: :integer, limit: 4, foreign_key: { to_table: 'class4.areas' }, index: { name: 'index_import_routing_tag_detection_rules_on_src_area_id' }
      t.references :dst_area, type: :integer, limit: 4, foreign_key: { to_table: 'class4.areas' }, index: { name: 'index_import_routing_tag_detection_rules_on_dst_area_id' }
      t.references :tag_action, type: :integer, limit: 2, foreign_key: { to_table: 'class4.tag_actions' }, index: { name: 'index_import_routing_tag_detection_rules_on_tag_action_id' }
      t.string :routing_tag_names
      t.string :src_area_name
      t.string :dst_area_name
      t.string :src_prefix
      t.string :dst_prefix
      t.string :tag_action_name
      t.integer :tag_action_value, limit: 2, array: true, null: false, default: []
      t.string :tag_action_value_names
      t.string :error_string
      t.bigint :o_id
      t.boolean :is_changed
    end
  end

  def down
    drop_table 'data_import.import_routing_tag_detection_rules'
  end
end
