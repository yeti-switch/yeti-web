class SchedulerTimezone < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      alter table sys.schedulers add timezone varchar not null default 'UTC';
    }
  end

  def down
    execute %q{
      alter table sys.schedulers drop column timezone;
    }
  end
end
