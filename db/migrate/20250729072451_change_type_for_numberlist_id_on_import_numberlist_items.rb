class ChangeTypeForNumberlistIdOnImportNumberlistItems < ActiveRecord::Migration[7.2]
  def up
    change_column :import_numberlist_items, :numberlist_id, :integer
  end

  def down
    change_column :import_numberlist_items, :numberlist_id, :integer, limit: 2
  end
end
