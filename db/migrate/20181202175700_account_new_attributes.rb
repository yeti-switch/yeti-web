class AccountNewAttributes < ActiveRecord::Migration[5.1]
  def up
    execute %q{
      alter table billing.accounts
        add total_capacity smallint,
        add destination_rate_limit numeric;

      alter table data_import.import_accounts
        add total_capacity smallint,
        add destination_rate_limit numeric,
        add vat numeric;
    }
  end

  def down
    execute %q{
      alter table billing.accounts
        drop column total_capacity,
        drop column destination_rate_limit;

      alter table data_import.import_accounts
        drop column total_capacity,
        drop column destination_rate_limit,
        drop column vat;
    }
  end

end
