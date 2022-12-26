class RemoveSshKey < ActiveRecord::Migration[6.1]
  def up
    execute %q{
      alter table gui.admin_users drop column ssh_key;
    }
  end

  def down
    execute %q{
      alter table gui.admin_users add ssh_key text;
    }
  end
end
