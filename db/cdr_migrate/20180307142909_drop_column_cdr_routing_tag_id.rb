class DropColumnCdrRoutingTagId < ActiveRecord::Migration
  def up
    execute %q{
      ALTER TABLE cdr.cdr DROP routing_tag_id;
      ALTER TABLE cdr.cdr_archive DROP routing_tag_id;
    }
  end

  def down
    execute %q{
      ALTER TABLE cdr.cdr ADD routing_tag_id smallint;
      ALTER TABLE cdr.cdr_archive ADD routing_tag_id smallint;
    }
  end
end
