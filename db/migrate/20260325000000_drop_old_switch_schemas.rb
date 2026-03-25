class DropOldSwitchSchemas < ActiveRecord::Migration[7.2]

  def up
    execute %q{
      DROP SCHEMA switch18 CASCADE;
      DROP SCHEMA switch19 CASCADE;
      DROP SCHEMA switch20 CASCADE;
      DROP SCHEMA switch21 CASCADE;
    }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
