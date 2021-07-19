class RemoveUnusedExtensions < ActiveRecord::Migration[4.2]
  def up
    execute %q{
      drop extension pgq_coop;
      drop extension pgq_node;
    }
  end

  def down
    execute %q{
      create extension pgq_coop;
      create extension pgq_node;
    }
  end
end
