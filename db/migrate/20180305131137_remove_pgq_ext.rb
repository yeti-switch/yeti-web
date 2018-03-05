class RemovePgqExt < ActiveRecord::Migration
  def up
    execute %q{
      drop extension pgq_ext;
    }
  end

  def down
    execute %q{
       create extension pgq_ext;
    }
  end
end
