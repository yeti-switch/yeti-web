# frozen_string_literal: true

# `stateful_filters` was never read by the saved-filters feature
# (ActiveAdmin::FilterSaver persists per-controller via saved_filters['enabled']).
# The orphaned form input has been removed; drop the now-unused column.
class DropStatefulFiltersFromAdminUsers < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      ALTER TABLE gui.admin_users DROP COLUMN stateful_filters;
    }
  end

  def down
    execute %q{
      ALTER TABLE gui.admin_users ADD COLUMN stateful_filters boolean DEFAULT false NOT NULL;
    }
  end
end
