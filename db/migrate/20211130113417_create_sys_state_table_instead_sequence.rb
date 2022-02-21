class CreateSysStateTableInsteadSequence < ActiveRecord::Migration[6.1]
  def up
    create_table :'sys.states', id: false, primary_key: :key do |t|
      t.string :key
      t.integer :value, null: false, default: 0, limit: 8
    end

    execute <<-SQL
      INSERT INTO sys.states(key,value) VALUES('customers_auth',1);
      INSERT INTO sys.states(key,value) VALUES('stir_shaken_trusted_certificates',1);
      INSERT INTO sys.states(key,value) VALUES('stir_shaken_trusted_repositories',1);
      INSERT INTO sys.states(key,value) VALUES('load_balancers',1);

      DROP SEQUENCE IF EXISTS class4.customers_auth_state_seq;
      DROP SEQUENCE IF EXISTS sys.load_balancers_state_seq;
      DROP SEQUENCE IF EXISTS class4.stir_shaken_trusted_certificates_state_seq;
      DROP SEQUENCE IF EXISTS class4.stir_shaken_trusted_repositories_state_seq;

CREATE OR REPLACE FUNCTION switch20.check_states() RETURNS TABLE(trusted_lb bigint, ip_auth bigint, stir_shaken_trusted_certificates bigint, stir_shaken_trusted_repositories bigint)
    LANGUAGE plpgsql COST 10 ROWS 100
    AS $$
    BEGIN
    RETURN QUERY
      SELECT
        (select value from sys.states where key = 'load_balancers'),
        (select value from sys.states where key = 'customers_auth'),
        (select value from sys.states where key = 'stir_shaken_trusted_certificates'),
        (select value from sys.states where key = 'stir_shaken_trusted_repositories');
    END;
    $$;
    SQL
  end

  def down
    drop_table :'sys.states'

    execute <<-SQL
      CREATE SEQUENCE class4.customers_auth_state_seq;
      CREATE SEQUENCE sys.load_balancers_state_seq;
      CREATE SEQUENCE class4.stir_shaken_trusted_certificates_state_seq;
      CREATE SEQUENCE class4.stir_shaken_trusted_repositories_state_seq;

CREATE OR REPLACE FUNCTION switch20.check_states() RETURNS TABLE(trusted_lb bigint, ip_auth bigint, stir_shaken_trusted_certificates bigint, stir_shaken_trusted_repositories bigint)
    LANGUAGE plpgsql COST 10 ROWS 100
    AS $$
    BEGIN
    RETURN QUERY
      SELECT
        (select last_value from sys.load_balancers_state_seq),
        (select last_value from class4.customers_auth_state_seq),
        (select last_value from class4.stir_shaken_trusted_certificates_state_seq),
        (select last_value from class4.stir_shaken_trusted_repositories_state_seq);
    END;
    $$;
    SQL
  end
end
