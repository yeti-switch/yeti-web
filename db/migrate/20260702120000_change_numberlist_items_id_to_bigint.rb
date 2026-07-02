class ChangeNumberlistItemsIdToBigint < ActiveRecord::Migration[7.2]
  # class4.numberlist_items.id was manually changed to bigint on some systems.
  # Make it official, and widen the importer's o_id to match so resolving
  # o_id = numberlist_items.id no longer overflows (integer out of range).
  def up
    execute %q{
ALTER TABLE class4.numberlist_items ALTER COLUMN id TYPE bigint;
ALTER TABLE data_import.import_numberlist_items ALTER COLUMN o_id TYPE bigint;
    }
  end

  def down
    execute %q{
ALTER TABLE data_import.import_numberlist_items ALTER COLUMN o_id TYPE integer;
ALTER TABLE class4.numberlist_items ALTER COLUMN id TYPE integer;
    }
  end
end
