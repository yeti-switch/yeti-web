class CreateCronJobInfos < ActiveRecord::Migration[5.2]
  def change
    create_table 'sys.jobs' do |t|
      t.string :name, null: false, unique: true
      t.decimal :last_duration
      t.string :last_exception
      t.timestamp :last_run_at
    end

    up_only do
      execute <<-SQL
        INSERT INTO sys.jobs (name) VALUES
        ('CdrPartitioning'),
        ('EventProcessor'),
        ('CdrBatchCleaner'),
        ('PartitionRemoving'),
        ('CallsMonitoring'),
        ('StatsClean'),
        ('StatsAggregation'),
        ('Invoice'),
        ('ReportScheduler'),
        ('TerminationQualityCheck'),
        ('DialpeerRatesApply'),
        ('AccountBalanceNotify'),
        ('SyncDatabaseTables');
      SQL
    end
  end
end
