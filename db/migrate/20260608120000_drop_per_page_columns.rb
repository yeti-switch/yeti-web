# frozen_string_literal: true

# Per-page is now AA-native (config.default_per_page from yeti_web.yml), so the
# custom per-user store (gui.admin_users.per_page) and the per-page options
# column (sys.guiconfig.rows_per_page) are no longer used.
class DropPerPageColumns < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      ALTER TABLE gui.admin_users DROP COLUMN per_page;
      ALTER TABLE sys.guiconfig DROP COLUMN rows_per_page;
    }
  end

  def down
    execute %q{
      ALTER TABLE gui.admin_users ADD COLUMN per_page json DEFAULT '{}'::json NOT NULL;
      ALTER TABLE sys.guiconfig ADD COLUMN rows_per_page character varying DEFAULT '50,100'::character varying NOT NULL;
    }
  end
end
