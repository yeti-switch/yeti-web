class CreateAuthLogTables < ActiveRecord::Migration[5.1]
  def up
    create_table 'sys.auth_log_tables' do |t|
      t.column :name,       :string,  null: false
      t.column :date_start, :string,  null: false
      t.column :date_stop,  :string,  null: false
      t.column :readable,   :boolean, null: false, default: true
      t.column :writable,   :boolean, null: false, default: false
      t.column :active,     :boolean, null: false, default: true
    end

    execute %q{
      CREATE OR REPLACE FUNCTION auth_log.auth_log_i_tgf() RETURNS trigger AS $trg$
      BEGIN
        RAISE EXCEPTION 'auth_log.auth_log_i_tg: request_time out of range.';
        RETURN NULL;
      END; $trg$
      LANGUAGE plpgsql VOLATILE COST 100;
    }

    execute %q{
      CREATE TRIGGER auth_log_i BEFORE INSERT
        ON auth_log.auth_log
        FOR EACH ROW
        EXECUTE PROCEDURE auth_log.auth_log_i_tgf();
    }
  end

  def down
    execute %q{
      DROP TRIGGER auth_log_i ON auth_log.auth_log RESTRICT;
      DROP FUNCTION auth_log.auth_log_i_tgf();
      DROP TABLE sys.auth_log_tables;
    }
  end
end
