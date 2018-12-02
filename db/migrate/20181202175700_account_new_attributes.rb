class AccountNewAttributes < ActiveRecord::Migration[5.1]
  def up
    execute %q{
      alter table billing.accounts
        add total_capacity smallint,
        add destination_rate_limit numeric,
        add max_call_duration integer;

      alter table data_import.import_accounts
        add total_capacity smallint,
        add destination_rate_limit numeric,
        add vat numeric,
        add max_call_duration integer;
    }
  end

  def down
    execute %q{
      alter table billing.accounts
        drop column total_capacity,
        drop column destination_rate_limit,
        drop column max_call_duration;

      alter table data_import.import_accounts
        drop column total_capacity,
        drop column destination_rate_limit,
        drop column vat,
        drop column max_call_duration;
    }
  end

end
