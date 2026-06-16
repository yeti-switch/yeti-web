# frozen_string_literal: true

class ReAddPerPageToAdminUsers < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      ALTER TABLE gui.admin_users ADD COLUMN per_page jsonb DEFAULT '{}'::jsonb NOT NULL;
    }
  end

  def down
    execute %q{
      ALTER TABLE gui.admin_users DROP COLUMN per_page;
    }
  end
end
