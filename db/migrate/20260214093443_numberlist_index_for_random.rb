class NumberlistIndexForRandom < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      create unique index "numberlist_items_numberlist_id_id_idx" on class4.numberlist_items using btree(numberlist_id,id);
    }
  end

  def down
    execute %q{
      drop index class4."numberlist_items_numberlist_id_id_idx";
    }
  end

end
