class AddExternalIdToRoutingNumberlist < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      ALTER TABLE class4.numberlists ADD COLUMN external_id bigint UNIQUE;
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE class4.numberlists DROP COLUMN external_id;
    SQL
  end
end
