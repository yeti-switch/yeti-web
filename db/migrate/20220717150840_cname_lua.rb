class CnameLua < ActiveRecord::Migration[6.1]
  def up
    execute %q{

      alter extension yeti update TO "1.3.4";
      alter table class4.customers_auth add cnam_database_id smallint references class4.cnam_databases(id);
      alter table class4.customers_auth_normalized add cnam_database_id smallint;
      alter table class4.cnam_databases
        add response_lua varchar,
        add request_lua varchar,
        add drop_call_on_error boolean not null default false;
            }
  end

  def down
    execute %q{
    --  alter extension yeti update TO "1.3.4";
      alter table class4.customers_auth drop column cnam_database_id;
      alter table class4.customers_auth_normalized drop column cnam_database_id;
      alter table class4.cnam_databases
        drop column response_lua,
        drop column request_lua,
        drop column drop_call_on_error;

            }
  end
end
