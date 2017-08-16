class MoveSchemaMigrationsTable < ActiveRecord::Migration
  def up
    execute %q{ DROP TABLE IF EXISTS gui.schema_migrations; }
  end

  def down
    execute %q{ CREATE TABLE gui.schema_migrations(version character varying(255) NOT NULL) }
  end
end
