class AllowNullNetworkId < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      alter table sys.network_prefixes alter column network_id drop not null;
    }
  end

  def down
    execute %q{
      alter table sys.network_prefixes alter column network_id set not null;
    }
  end

end
