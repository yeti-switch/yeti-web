class ReportIntervalCdrAddCompletedSendTo < ActiveRecord::Migration[6.1]
  def up
    execute %Q{
      ALTER TABLE reports.cdr_interval_report
      ADD COLUMN completed boolean NOT NULL DEFAULT false
    }

    execute %Q{
      ALTER TABLE reports.cdr_interval_report
      ADD COLUMN send_to integer[]
    }

    execute %Q{
      ALTER TABLE reports.cdr_interval_report
      ALTER COLUMN group_by TYPE varchar[] USING regexp_split_to_array(group_by, ',')
    }

    execute %Q{
      UPDATE reports.cdr_interval_report
      SET completed = true
    }

    execute %Q{
      DROP FUNCTION IF EXISTS reports.cdr_interval_report(integer)
    }
  end

  def down
    execute %Q{
      ALTER TABLE reports.cdr_interval_report
      ALTER COLUMN group_by TYPE varchar USING array_to_string(group_by, ',')
    }

    execute %Q{
      ALTER TABLE reports.cdr_interval_report
      DROP COLUMN completed
    }

    execute %Q{
      ALTER TABLE reports.cdr_interval_report
      DROP COLUMN send_to
    }
  end
end
