class AddAllowedIpsToAdminUsers < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      ALTER TABLE admin_users
      ADD COLUMN allowed_ips inet[]
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE admin_users
      DROP COLUMN allowed_ips
    SQL
  end
end
