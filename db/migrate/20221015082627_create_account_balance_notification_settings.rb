class CreateAccountBalanceNotificationSettings < ActiveRecord::Migration[6.1]
  def up
    execute %q{
      DROP TRIGGER account_notification_tgf ON billing.accounts;
      DROP FUNCTION billing.account_change_iu_tgf;
      DROP FUNCTION billing.balance_notify;
    }

    create_table 'billing.account_balance_notification_settings' do |t|
      t.references :account,
                   foreign_key: { to_table: 'billing.accounts' },
                   null: false,
                   index: { unique: true, name: 'account_balance_notification_settings_account_id_uniq_idx' }
      t.decimal :low_threshold
      t.decimal :high_threshold
      t.integer :state_id, null: false, limit: 2, default: 0
      t.integer :send_to, array: true
    end

    execute %q{
      INSERT INTO billing.account_balance_notification_settings
      (account_id, low_threshold, high_threshold, state_id, send_to)
      SELECT id, balance_low_threshold, balance_high_threshold, 0, send_balance_notifications_to
      FROM billing.accounts
    }

    remove_column 'billing.accounts', :balance_low_threshold
    remove_column 'billing.accounts', :balance_high_threshold
    remove_column 'billing.accounts', :send_balance_notifications_to
  end

  def down
    add_column 'billing.accounts', :balance_low_threshold, :decimal
    add_column 'billing.accounts', :balance_high_threshold, :decimal
    add_column 'billing.accounts', :send_balance_notifications_to, :integer, array: true

    execute %q{
      UPDATE billing.accounts SET
        balance_low_threshold = account_balance_notification_settings.low_threshold,
        balance_high_threshold = account_balance_notification_settings.high_threshold,
        send_balance_notifications_to = account_balance_notification_settings.send_to
      FROM billing.account_balance_notification_settings
      WHERE account_balance_notification_settings.account_id = accounts.id
    }

    drop_table 'billing.account_balance_notification_settings'

    execute %q{
      CREATE FUNCTION billing.balance_notify(i_type character varying, i_action character varying, i_account billing.accounts) RETURNS void
      LANGUAGE plpgsql
      AS $$
begin
    insert into logs.balance_notifications(direction,action,data) values(i_type,i_action,row_to_json(i_account));
    return;
END;
$$;

      CREATE FUNCTION billing.account_change_iu_tgf() RETURNS trigger
      LANGUAGE plpgsql
      AS $$
BEGIN
if TG_OP='UPDATE' then
    if (new.balance_high_threshold is not null and (new.balance > new.balance_high_threshold)) and NOT
        (old.balance_high_threshold is not null AND (old.balance > old.balance_high_threshold)) then
        -- fire high balance
        perform billing.balance_notify('high', 'fire', new);
    end if;

    if (new.balance_low_threshold is not null and (new.balance < new.balance_low_threshold)) and NOT
        (old.balance_low_threshold is not null AND (old.balance < old.balance_low_threshold)) then
        -- fire low balance
        perform billing.balance_notify('low', 'fire', new);
    end if;

    if (new.balance_high_threshold is null OR (new.balance <= new.balance_high_threshold)) and NOT
        (old.balance_high_threshold is null OR (old.balance <= old.balance_high_threshold)) then
        -- clear high balance
        perform billing.balance_notify('high', 'clear', new);
    end if;

    if (new.balance_low_threshold is null OR (new.balance >= new.balance_low_threshold)) and NOT
        (old.balance_low_threshold is null OR (old.balance >= old.balance_low_threshold)) then
        -- clear low balance
        perform billing.balance_notify('low', 'clear', new);
    end if;

elsif TG_OP='INSERT' THEN
    if new.balance_high_threshold is not null and (new.balance > new.balance_high_threshold) then
        -- fire high balance
        perform billing.balance_notify('high', 'fire', new);
    end if;

    if new.balance_low_threshold is not null and (new.balance < new.balance_low_threshold) then
        -- fire low balance
        perform billing.balance_notify('low', 'fire', new);
    end if;
END IF;

return new;
END;
$$;

      CREATE TRIGGER account_notification_tgf
      AFTER INSERT OR UPDATE ON billing.accounts
      FOR EACH ROW EXECUTE FUNCTION billing.account_change_iu_tgf();
    }
  end
end
