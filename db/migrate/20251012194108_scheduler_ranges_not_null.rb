class SchedulerRangesNotNull < ActiveRecord::Migration[7.2]

  def up
    execute %q{

      update sys.scheduler_ranges set months = '{}'::smallint[] where months is null;
      update sys.scheduler_ranges set days = '{}'::smallint[] where days is null;

      alter table sys.scheduler_ranges
        alter column months set default '{}'::smallint[],
        alter column months set not null,
        alter column days set default '{}'::smallint[],
        alter column days set not null;
    }
  end

  def down
    execute %q{
      alter table sys.scheduler_ranges
        alter column months drop not null,
        alter column months drop default,
        alter column days drop not null,
        alter column days drop default;
    }
  end
end





