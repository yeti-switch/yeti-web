class AddUniqDatabaseIndexToLnpDatabases < ActiveRecord::Migration[5.2]
  def change
    add_index 'class4.lnp_databases', [:database_id, :database_type], unique: true
  end
end
