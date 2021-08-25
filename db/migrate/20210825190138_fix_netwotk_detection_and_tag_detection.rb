class FixNetwotkDetectionAndTagDetection < ActiveRecord::Migration[6.1]
  def up
    execute %q{

CREATE or replace FUNCTION switch20.detect_network(i_dst character varying) RETURNS sys.network_prefixes
    LANGUAGE plpgsql COST 10
    AS $$
declare
  v_ret sys.network_prefixes%rowtype;
BEGIN

  select into v_ret *
  from sys.network_prefixes np
  where
    prefix_range(np.prefix)@>prefix_range(i_dst) AND
    np.number_min_length <= length(i_dst) AND
    np.number_max_length >= length(i_dst)
  order by length(prefix_range(np.prefix)) desc
  limit 1;

  return v_ret;
END;
$$;

            }

  end

  def down
    execute %q{

CREATE or replace FUNCTION switch20.detect_network(i_dst character varying) RETURNS sys.network_prefixes
    LANGUAGE plpgsql COST 10
    AS $$
declare
  v_ret sys.network_prefixes%rowtype;
BEGIN

  select into v_ret *
  from sys.network_prefixes
  where prefix_range(prefix)@>prefix_range(i_dst)
  order by length(prefix_range(prefix)) desc
  limit 1;

  return v_ret;
END;
$$;

            }

  end

end
