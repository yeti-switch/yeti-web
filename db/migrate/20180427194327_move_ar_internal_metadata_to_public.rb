class MoveArInternalMetadataToPublic < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
    ALTER TABLE gui.ar_internal_metadata SET SCHEMA public;
    SQL
  end

  def down
    execute <<-SQL
    ALTER TABLE public.ar_internal_metadata SET SCHEMA gui;
    SQL
  end
end
