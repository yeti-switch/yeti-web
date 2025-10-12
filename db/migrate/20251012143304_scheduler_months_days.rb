class SchedulerMonthsDays < ActiveRecord::Migration[7.2]


  def up
    execute %q{
      alter table sys.scheduler_ranges
        add months smallint[],
        add days smallint[];
    }
  end

  def down
    execute %q{
      alter table sys.scheduler_ranges
        drop column months,
        drop column days;
    }
  end

end
