class DelayedJobsAddUniqueName < ActiveRecord::Migration[6.1]
  def up
    execute %Q{
      ALTER TABLE #{Delayed::Job.table_name}
      ADD COLUMN unique_name varchar
    }
  end

  def down
    execute %Q{
      ALTER TABLE #{Delayed::Job.table_name}
      DROP COLUMN unique_name
    }
  end
end
