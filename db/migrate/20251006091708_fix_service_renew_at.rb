class FixServiceRenewAt < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      update billing.services set renew_period_id = null where renew_at is null;
      update billing.services set renew_at = null where renew_period_id is null;
    }
  end

  def down

  end
end
