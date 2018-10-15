class AddRolesToAdminUser < ActiveRecord::Migration[5.1]
  def up
    execute %q{
      alter table gui.admin_users add  roles varchar[] not null default array['root']::varchar[];
      alter table gui.admin_users alter column roles drop default;
      alter table gui.admin_users drop column "group";
    }
  end

  def down
    execute %q{
      alter table gui.admin_users drop column roles;
      alter table gui.admin_users add "group" integer not null default 0;
    }
  end
end
