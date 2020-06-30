# frozen_string_literal: true

class RenameItemsFromGuiVersionsTable < ActiveRecord::Migration[5.2]
  def change
    reversible do |direction|
      direction.up do
        execute <<-SQL
          UPDATE gui.versions SET item_type = 'Routing::Destination' WHERE item_type = 'Destination';
        SQL
      end
    end
  end
end
