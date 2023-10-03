class FixApiAccessForIpv6 < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      alter table sys.api_access alter column allowed_ips set default '{0.0.0.0/0,::/0}'::inet[]
    }
  end

  def down
    execute %q{
      alter table sys.api_access alter column allowed_ips set default '{0.0.0.0/0}'::inet[]
    }
  end
end
