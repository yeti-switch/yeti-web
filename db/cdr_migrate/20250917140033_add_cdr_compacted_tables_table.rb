class AddCdrCompactedTablesTable < ActiveRecord::Migration[7.2]
  def up
    create_table :'sys.cdr_compacted_tables' do |t|
      t.string :table_name, null: false, index: { unique: true }

      t.timestamps
    end
  end

  def down
    drop_table :'sys.cdr_compacted_tables'
  end
end
