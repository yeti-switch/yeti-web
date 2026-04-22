# frozen_string_literal: true

class AddMetadataToPayments < ActiveRecord::Migration[7.2]
  def up
    execute %q{alter table billing.payments add column metadata jsonb;}
  end

  def down
    execute %q{alter table billing.payments drop column metadata;}
  end
end
