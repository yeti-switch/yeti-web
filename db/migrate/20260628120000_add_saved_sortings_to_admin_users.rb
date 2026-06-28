# frozen_string_literal: true

# Per-resource persistent sorting (opt-in), stored per admin user keyed by
# controller name — mirrors saved_filters / per_page. See
# lib/active_admin/sorting_saver/controller.rb.
class AddSavedSortingsToAdminUsers < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      ALTER TABLE gui.admin_users ADD COLUMN saved_sortings jsonb DEFAULT '{}'::jsonb NOT NULL;
    }
  end

  def down
    execute %q{
      ALTER TABLE gui.admin_users DROP COLUMN saved_sortings;
    }
  end
end
