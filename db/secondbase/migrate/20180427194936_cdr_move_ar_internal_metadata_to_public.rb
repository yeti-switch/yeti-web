class CdrMoveArInternalMetadataToPublic < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
    ALTER TABLE cdr.ar_internal_metadata SET SCHEMA public;
    SQL
  end

  def down
    execute <<-SQL
    ALTER TABLE public.ar_internal_metadata SET SCHEMA cdr;
    SQL
  end
end
