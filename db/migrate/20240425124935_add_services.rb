class AddServices < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      create table billing.service_types(
        id smallserial primary key,
        name varchar not null unique,
        provisioning_class varchar,
        variables jsonb,
        force_renew boolean not null default false
      );

      create table billing.services(
        id bigserial primary key,
        uuid uuid not null default uuid_generate_v4(),
        type_id smallint not null references billing.service_types(id),
        account_id integer not null references billing.accounts(id),
        name varchar,
        variables jsonb,
        state_id smallint not null default 10, -- Billing::Service::STATE_ID_ACTIVE = 10
        created_at timestamptz not null default now(),
        renew_at timestamptz,
        renew_period_id smallint,
        initial_price numeric not null,
        renew_price numeric not null
      );
      create index on billing.services using btree (uuid);
      create index on billing.services using btree (type_id);
      create index on billing.services using btree (account_id);
      create index on billing.services using btree (renew_at);

      create table billing.transactions(
        id bigserial primary key,
        uuid uuid not null default uuid_generate_v4(),
        created_at timestamptz not null default now(),
        account_id integer not null references billing.accounts(id),
        service_id bigint,
        amount numeric not null,
        description varchar
      );
      create index on billing.transactions using btree (uuid);
      create index on billing.transactions using btree (account_id);
      create index on billing.transactions using btree (service_id);


      delete from sys.jobs;
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (1, 'CdrPartitioning', NULL, NULL, NULL);
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (2, 'EventProcessor', NULL, NULL, NULL);
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (3, 'CdrBatchCleaner', NULL, NULL, NULL);
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (4, 'PartitionRemoving', NULL, NULL, NULL);
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (5, 'CallsMonitoring', NULL, NULL, NULL);
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (6, 'StatsClean', NULL, NULL, NULL);
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (7, 'StatsAggregation', NULL, NULL, NULL);
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (8, 'Invoice', NULL, NULL, NULL);
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (9, 'ReportScheduler', NULL, NULL, NULL);
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (10, 'TerminationQualityCheck', NULL, NULL, NULL);
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (11, 'DialpeerRatesApply', NULL, NULL, NULL);
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (12, 'AccountBalanceNotify', NULL, NULL, NULL);
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (13, 'SyncDatabaseTables', NULL, NULL, NULL);
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (14, 'DeleteExpiredDestinations', NULL, NULL, NULL);
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (15, 'DeleteExpiredDialpeers', NULL, NULL, NULL);
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (16, 'DeleteAppliedRateManagementPricelists', NULL, NULL, NULL);
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (17, 'DeleteBalanceNotifications', NULL, NULL, NULL);
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (18, 'PrometheusCustomerAuthStats', NULL, NULL, NULL);
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (19, 'ServiceRenew', NULL, NULL, NULL);

    }
  end

  def down
    execute %q{
      drop table billing.transactions;
      drop table billing.services;
      drop table billing.service_types;

      delete from sys.jobs where id = 19;
    }
  end
end
