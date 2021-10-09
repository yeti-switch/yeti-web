class AddStateCheck < ActiveRecord::Migration[6.1]
  def up
    execute %q{
    CREATE SEQUENCE sys.load_balancers_state_seq;
    CREATE SEQUENCE class4.stir_shaken_trusted_certificates_state_seq;
    CREATE SEQUENCE class4.stir_shaken_trusted_repositories_state_seq;

    SELECT nextval('class4.stir_shaken_trusted_certificates_state_seq');
    SELECT nextval('class4.stir_shaken_trusted_repositories_state_seq');
    SELECT nextval('sys.load_balancers_state_seq');


    CREATE or replace FUNCTION switch20.check_states() RETURNS TABLE(
      trusted_lb bigint,
      ip_auth bigint,
      stir_shaken_trusted_certificates bigint,
      stir_shaken_trusted_repositories bigint
    )
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
    }
  end

  def down
    execute %q{

    drop FUNCTION switch20.check_states();
    drop sequence if exists sys.load_balancers_state_seq;
    drop sequence if exists class4.stir_shaken_trusted_certificates_state_seq;
    drop sequence if exists class4.stir_shaken_trusted_repositories_state_seq;
    }

  end
end
