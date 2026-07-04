# frozen_string_literal: true

class AddRateProviderToCurrencies < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      ALTER TABLE billing.currencies ADD rate_provider_id smallint;
    }
  end

  def down
    execute %q{
      ALTER TABLE billing.currencies DROP COLUMN rate_provider_id;
    }
  end
end
