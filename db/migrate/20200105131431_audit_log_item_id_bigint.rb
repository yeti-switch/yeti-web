class AuditLogItemIdBigint < ActiveRecord::Migration[5.2]
  def up
    execute  %q{
      ALTER TABLE gui.versions ALTER COLUMN item_id type bigint;
    }
  end

  def down
    execute  %q{
      ALTER TABLE gui.versions ALTER COLUMN item_id type integer;
    }
  end
  
end
