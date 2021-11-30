class AddPrimaryKeyToSysStateTable < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
ALTER TABLE sys.states ADD PRIMARY KEY (key);
    SQL
  end

  def down
    execute <<-SQL
ALTER TABLE IF EXISTS sys.states DROP CONSTRAINT states_pkey;
    SQL
  end
end
