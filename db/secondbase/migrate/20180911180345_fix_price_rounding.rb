class FixPriceRounding < ActiveRecord::Migration[5.1]
  def up
    execute %q{
    CREATE or replace FUNCTION switch.vendor_price_round(i_config sys.config, i_amount numeric) RETURNS numeric
    LANGUAGE plpgsql COST 10
    AS $$
    DECLARE

    BEGIN

      case i_config.vendor_amount_round_mode_id
      when 1 then -- disable rounding
      return i_amount;
      when 2 then --always up
      return trunc(i_amount, i_config.vendor_amount_round_precision) +
        (mod(i_amount::numeric, power(10,-i_config.vendor_amount_round_precision)::numeric)>0)::int*power(10,-i_config.vendor_amount_round_precision);
      when 3 then --always down
      return trunc(i_amount, i_config.vendor_amount_round_precision);
      when 4 then -- math
      return round(i_amount, i_config.vendor_amount_round_precision);
      else -- fallback to math rules
      return round(i_amount, i_config.vendor_amount_round_precision);
      end case;
      END;
      $$;


      CREATE or replace FUNCTION switch.customer_price_round(i_config sys.config, i_amount numeric) RETURNS numeric
      LANGUAGE plpgsql COST 10
      AS $$
      DECLARE
      BEGIN

        case i_config.customer_amount_round_mode_id
        when 1 then -- disable rounding
        return i_amount;
        when 2 then --always up
        return trunc(i_amount, i_config.customer_amount_round_precision) +
          (mod(i_amount::numeric, power(10,-i_config.customer_amount_round_precision)::numeric)>0)::int*power(10,-i_config.customer_amount_round_precision);
        when 3 then --always down
        return trunc(i_amount, i_config.customer_amount_round_precision);
        when 4 then -- math
        return round(i_amount, i_config.customer_amount_round_precision);
        else -- fallback to math rules
        return round(i_amount, i_config.customer_amount_round_precision);
        end case;
        END;
        $$;
}
  end

  def down
execute %q{
    CREATE or replace FUNCTION switch.vendor_price_round(i_config sys.config, i_amount numeric) RETURNS numeric
    LANGUAGE plpgsql COST 10
    AS $$
    DECLARE

    BEGIN

      case i_config.vendor_amount_round_mode_id
      when 1 then -- disable rounding
      return i_amount;
      when 2 then --always up
      return trunc(i_amount, i_config.vendor_amount_round_precision) + power(10 , - i_config.vendor_amount_round_precision);
      when 3 then --always down
      return trunc(i_amount, i_config.vendor_amount_round_precision);
      when 4 then -- math
      return round(i_amount, i_config.vendor_amount_round_precision);
      else -- fallback to math rules
      return round(i_amount, i_config.vendor_amount_round_precision);
      end case;
      END;
      $$;


      CREATE or replace FUNCTION switch.customer_price_round(i_config sys.config, i_amount numeric) RETURNS numeric
      LANGUAGE plpgsql COST 10
      AS $$
      DECLARE
      BEGIN

        case i_config.customer_amount_round_mode_id
        when 1 then -- disable rounding
        return i_amount;
        when 2 then --always up
        return trunc(i_amount, i_config.customer_amount_round_precision) + power(10 , - i_config.customer_amount_round_precision);
        when 3 then --always down
        return trunc(i_amount, i_config.customer_amount_round_precision);
        when 4 then -- math
        return round(i_amount, i_config.customer_amount_round_precision);
        else -- fallback to math rules
        return round(i_amount, i_config.customer_amount_round_precision);
        end case;
        END;
        $$;
}
  end
end
