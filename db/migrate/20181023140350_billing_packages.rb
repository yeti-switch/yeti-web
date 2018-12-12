class BillingPackages < ActiveRecord::Migration[5.1]
  def up
    execute %q{
      create table billing.packages(
        id serial primary key,
        name varchar not null unique,
        price numeric not null,
        billing_interval integer,
        allow_minutes_aggregation boolean not null default false -- разрешает накапливать минуты оставшиеся от прошлого пакета
      );

      create table billing.package_configs(
        id serial primary key,
        package_id integer not null references billing.packages(id),
        prefix varchar not null default '',
        amount integer not null default 0
      );

      alter table billing.accounts add package_id integer references billing.packages(id);

      create table billing.account_package_counters(
        id bigserial primary key,
        account_id integer not null references billing.accounts(id),
        prefix varchar not null default '',
        duration integer not null default 0,
        expired_at timestamptz
      );

      alter table class4.destinations add allow_package_billing boolean not null default false;

    }
  end

  def down
    execute %q{
      drop table billing.account_package_counters;
      alter table billing.accounts drop column package_id;
      drop table billing.package_configs;
      drop table billing.packages;
      alter table class4.destinations drop column allow_package_billing;
    }
  end

end
