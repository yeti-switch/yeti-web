class SchedulerRanges < ActiveRecord::Migration[7.2]
  def up
    execute %q{

      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (21, 'Scheduler', NULL, NULL, NULL);

      create table sys.scheduler_ranges(
        id smallserial primary key,
        scheduler_id smallint not null references sys.schedulers(id),
        weekdays smallint[] not null default '{}'::smallint[],
        from_time time,
        till_time time
      );

      create index "scheduler_ranges_scheduler_id_idx" on sys.scheduler_ranges using btree (scheduler_id);
    }
  end

  def down
    execute %q{
      DELETE from sys.jobs WHERE name = 'Scheduler';

      drop table sys.scheduler_ranges;
    }
  end

end
