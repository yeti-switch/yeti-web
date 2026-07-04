# frozen_string_literal: true

class AddCurrencyRatesUpdateJob < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      INSERT INTO sys.jobs (id, name, last_duration, last_exception, last_run_at) VALUES (22, 'CurrencyRatesUpdate', NULL, NULL, NULL);
    }
  end

  def down
    execute %q{
      DELETE FROM sys.jobs WHERE name = 'CurrencyRatesUpdate';
    }
  end
end
