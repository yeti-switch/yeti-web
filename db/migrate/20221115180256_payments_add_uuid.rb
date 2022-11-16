class PaymentsAddUuid < ActiveRecord::Migration[6.1]
  def up
    execute %q{
      ALTER TABLE billing.payments
        ADD uuid uuid NOT NULL UNIQUE DEFAULT public.uuid_generate_v1();
    }
  end

  def down
    execute 'ALTER TABLE billing.payments DROP uuid;'
  end
end
