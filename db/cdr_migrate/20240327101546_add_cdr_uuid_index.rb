class AddCdrUuidIndex < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      create index if not exists cdr_uuid_idx on cdr.cdr using btree(uuid);
    }
  end

  def down
    execute %q{
      drop index cdr.cdr_uuid_idx;
    }
  end

end
