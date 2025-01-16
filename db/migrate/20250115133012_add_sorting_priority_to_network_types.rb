class AddSortingPriorityToNetworkTypes < ActiveRecord::Migration[7.0]
  def up
    add_column :network_types, :sorting_priority, :smallint, default: 999, null: false
  end

  def down
    remove_column :network_types, :sorting_priority
  end
end
