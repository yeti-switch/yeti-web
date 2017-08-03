begin;
insert into sys.version(number,comment) values(113,'balance notifications');


ALTER TABLE billing.accounts
  add balance_high_threshold numeric,
  add balance_low_threshold numeric,
  add send_balance_notifications_to integer[];

ALTER TABLE data_import.import_accounts
  add balance_high_threshold numeric,
  add balance_low_threshold numeric;


create table logs.balance_notifications(
    id bigserial primary key,
    created_at timestamptz not null default now(),
    is_processed boolean not null default false,
    processed_at timestamptz,
    direction varchar,
    action varchar,
    data json
);

-- create index on logs.balance_notifications using btree(is_processed);

CREATE OR REPLACE FUNCTION billing.balance_notify(i_type varchar, i_action varchar, i_account billing.accounts)
returns void as
$BODY$
begin
    insert into logs.balance_notifications(direction,action,data) values(i_type,i_action,row_to_json(i_account));
    return;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

CREATE OR REPLACE FUNCTION billing.account_change_iu_tgf()
  RETURNS trigger AS
$BODY$
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE TRIGGER account_notification_tgf AFTER UPDATE OR INSERT ON billing.accounts FOR EACH ROW EXECUTE PROCEDURE billing.account_change_iu_tgf();

INSERT INTO sys.jobs (type) VALUES ('AccountBalanceNotify');
INSERT INTO notifications.alerts(event,send_to) VALUES ('AccountLowThesholdReached','{}');
INSERT INTO notifications.alerts(event,send_to) VALUES ('AccountHighThesholdReached','{}');
INSERT INTO notifications.alerts(event,send_to) VALUES ('AccountLowThesholdCleared','{}');
INSERT INTO notifications.alerts(event,send_to) VALUES ('AccountHighThesholdCleared','{}');


commit;