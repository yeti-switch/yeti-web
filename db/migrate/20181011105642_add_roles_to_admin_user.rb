class AddRolesToAdminUser < ActiveRecord::Migration[5.1]
  def up
    add_column :admin_users, :roles, :string, array: true, null: false
    remove_column :admin_users, :group
  end

  def down
    remove_column :admin_users, :roles
    add_column :admin_users, :group, :integer, default: 0
  end
end
