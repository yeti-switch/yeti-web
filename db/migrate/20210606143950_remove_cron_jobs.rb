class RemoveCronJobs < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      DROP TABLE sys.jobs;
    SQL
  end

  def down
    execute <<-SQL
      CREATE TABLE sys.jobs (
          id integer NOT NULL,
          type character varying NOT NULL,
          description character varying,
          updated_at timestamp with time zone DEFAULT now() NOT NULL,
          running boolean DEFAULT false NOT NULL
      );
    SQL
    execute <<-SQL
      INSERT INTO sys.jobs (id, type, description, updated_at, running) VALUES (1, 'CdrPartitioning', NULL, '2014-08-30 18:42:51.904755+00', false);
      INSERT INTO sys.jobs (id, type, description, updated_at, running) VALUES (2, 'EventProcessor', NULL, '2014-08-30 19:16:02.393718+00', false);
      INSERT INTO sys.jobs (id, type, description, updated_at, running) VALUES (3, 'CdrBatchCleaner', NULL, '2014-08-30 19:34:21.645614+00', false);
      INSERT INTO sys.jobs (id, type, description, updated_at, running) VALUES (4, 'PartitionRemoving', NULL, '2017-08-14 09:56:28.619626+00', false);
      INSERT INTO sys.jobs (id, type, description, updated_at, running) VALUES (5, 'CallsMonitoring', NULL, '2017-08-14 09:56:32.076616+00', false);
      INSERT INTO sys.jobs (id, type, description, updated_at, running) VALUES (6, 'StatsClean', NULL, '2017-08-14 09:56:32.687261+00', false);
      INSERT INTO sys.jobs (id, type, description, updated_at, running) VALUES (7, 'StatsAggregation', NULL, '2017-08-14 09:56:32.687261+00', false);
      INSERT INTO sys.jobs (id, type, description, updated_at, running) VALUES (8, 'Invoice', NULL, '2017-08-14 09:56:40.146861+00', false);
      INSERT INTO sys.jobs (id, type, description, updated_at, running) VALUES (9, 'ReportScheduler', NULL, '2017-08-14 09:56:42.568485+00', false);
      INSERT INTO sys.jobs (id, type, description, updated_at, running) VALUES (10, 'TerminationQualityCheck', NULL, '2017-08-14 09:56:42.693909+00', false);
      INSERT INTO sys.jobs (id, type, description, updated_at, running) VALUES (11, 'DialpeerRatesApply', NULL, '2017-08-14 09:56:51.574849+00', false);
      INSERT INTO sys.jobs (id, type, description, updated_at, running) VALUES (12, 'AccountBalanceNotify', NULL, '2017-08-14 09:57:13.033701+00', false);
      INSERT INTO sys.jobs (id, type, description, updated_at, running) VALUES (13, 'SyncDatabaseTables', NULL, '2021-01-01 09:57:13.033701+00', false);
    SQL
  end
end
