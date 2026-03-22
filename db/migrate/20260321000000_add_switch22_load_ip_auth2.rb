# frozen_string_literal: true

class AddSwitch22LoadIpAuth2 < ActiveRecord::Migration[7.0]
  def up
    execute %q{
CREATE FUNCTION switch22.load_ip_auth2(i_pop_id integer, i_node_id integer) RETURNS TABLE(ip inet, x_yeti_auth character varying, require_incoming_auth boolean, require_identity_parsing boolean)
    LANGUAGE plpgsql COST 10 ROWS 100
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    ca.ip,
    ca.x_yeti_auth,
    ca.require_incoming_auth,
    true as require_identity_parsing
  FROM class4.customers_auth_normalized ca
  WHERE
    ca.enabled
  ORDER BY
    ca.ip;
END;
$$;
    }
  end

  def down
    execute %q{
      DROP FUNCTION IF EXISTS switch22.load_ip_auth2(integer, integer);
    }
  end
end
