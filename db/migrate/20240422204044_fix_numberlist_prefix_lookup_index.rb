class FixNumberlistPrefixLookupIndex < ActiveRecord::Migration[7.0]

  def up
    execute %q{
      CREATE INDEX IF NOT EXISTS numberlist_items_numberlist_id_idx ON class4.numberlist_items USING gist(prefix_range(key));
      DROP INDEX class4.blacklist_items_blacklist_id_prefix_range_idx;
    }
  end

  def down
    execute %q{
      CREATE INDEX blacklist_items_blacklist_id_prefix_range_idx on class4.numberlist_items USING gist(numberlist_id,prefix_range(key));
      DROP INDEX class4.numberlist_items_numberlist_id_idx;
    }
  end

end
