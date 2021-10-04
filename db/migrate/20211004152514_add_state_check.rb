class AddStateCheck < ActiveRecord::Migration[6.1]
  def up
    execute %q{
    select nextval('class4.customers_auth_state_seq'::regclass);

    CREATE or replace FUNCTION switch20.check_states() RETURNS TABLE(
      trusted_lb bigint,
      ip_auth bigint
    )
    LANGUAGE plpgsql COST 10 ROWS 100
    AS $$
    BEGIN
    RETURN QUERY
      SELECT
        currval('class4.customers_auth_state_seq'),
        currval('class4.customers_auth_state_seq');
    END;
    $$;
    }
  end

  def down
    execute %q{

    drop FUNCTION switch20.check_states();

    }

  end
end
