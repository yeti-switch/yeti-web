class UpdateRoutingTagNamesToLowercase < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      UPDATE class4.routing_tags SET name = LOWER(name)
    SQL
  end

  def down; end
end
