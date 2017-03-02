begin;
insert into sys.version(number,comment) values(24,'Migration to timestamp with timezone');

alter table class4.destinations ALTER COLUMN valid_from TYPE TIMESTAMPTZ,
ALTER COLUMN valid_till TYPE TIMESTAMPTZ;

alter table class4.dialpeers ALTER COLUMN valid_from drop DEFAULT ,
ALTER COLUMN valid_till drop DEFAULT ;

alter table data_import.import_destinations ALTER COLUMN valid_from TYPE TIMESTAMPTZ,
ALTER COLUMN valid_till TYPE TIMESTAMPTZ;

alter table data_import.import_dialpeers ALTER COLUMN valid_from drop DEFAULT ,
ALTER COLUMN valid_till drop DEFAULT ;

alter table class4.dialpeers ALTER COLUMN valid_from TYPE TIMESTAMPTZ,
ALTER COLUMN valid_till TYPE TIMESTAMPTZ;

alter table billing.cdr_batches ALTER COLUMN created_at type TIMESTAMPTZ;
alter table billing.invoice_templates ALTER COLUMN created_at type TIMESTAMPTZ;

/*
alter table billing.invoices ALTER COLUMN start_date type TIMESTAMPTZ,
ALTER COLUMN end_date type TIMESTAMPTZ,
ALTER COLUMN first_cdr_date type TIMESTAMPTZ,
ALTER COLUMN last_cdr_date type TIMESTAMPTZ;
*/

alter table billing.payments ALTER COLUMN created_at type TIMESTAMPTZ;
alter table class4.blacklist_items ALTER COLUMN created_at TYPE TIMESTAMPTZ,
    ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

alter table class4.blacklists ALTER COLUMN created_at TYPE TIMESTAMPTZ,
    ALTER COLUMN updated_at TYPE TIMESTAMPTZ;


alter TABLE gui.active_admin_comments ALTER COLUMN created_at TYPE TIMESTAMPTZ,
    ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

alter TABLE gui.admin_users ALTER COLUMN created_at TYPE TIMESTAMPTZ,
    ALTER COLUMN updated_at TYPE TIMESTAMPTZ,
alter column reset_password_sent_at TYPE TIMESTAMPTZ,
alter column remember_created_at TYPE TIMESTAMPTZ,
alter column current_sign_in_at TYPE TIMESTAMPTZ,
alter column last_sign_in_at TYPE TIMESTAMPTZ;

alter TABLE gui.background_threads ALTER COLUMN created_at TYPE TIMESTAMPTZ,
    ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

alter TABLE gui.versions ALTER COLUMN created_at TYPE TIMESTAMPTZ;
alter table logs.logic_log ALTER COLUMN timestamp type TIMESTAMPTZ;

alter table runtime_stats.dialpeers_stats ALTER COLUMN created_at TYPE TIMESTAMPTZ,
    alter COLUMN updated_at TYPE TIMESTAMPTZ,
    ALTER COLUMN locked_at type TIMESTAMPTZ,
    ALTER COLUMN unlocked_at TYPE TIMESTAMPTZ;


alter table runtime_stats.gateways_stats ALTER COLUMN created_at TYPE TIMESTAMPTZ,
    alter COLUMN updated_at TYPE TIMESTAMPTZ,
    ALTER COLUMN locked_at type TIMESTAMPTZ,
    ALTER COLUMN unlocked_at TYPE TIMESTAMPTZ;


alter table sys.delayed_jobs ALTER COLUMN locked_at TYPE TIMESTAMPTZ,
    ALTER COLUMN failed_at type TIMESTAMPTZ,
    ALTER COLUMN created_at TYPE TIMESTAMPTZ,
    ALTER COLUMN updated_at type TIMESTAMPTZ,
    ALTER COLUMN run_at TYPE TIMESTAMPTZ;

alter table sys.events ALTER COLUMN created_at TYPE TIMESTAMPTZ,
    alter COLUMN updated_at TYPE TIMESTAMPTZ;

alter table sys.jobs ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

alter TABLE sys.version ALTER COLUMN apply_date TYPE TIMESTAMPTZ;

commit;
