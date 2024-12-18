class SchemaIndependentLoadInterfaceIn < ActiveRecord::Migration[7.0]

  def up
    execute %q{

    CREATE or replace FUNCTION switch21.load_interface_in() RETURNS TABLE(varname character varying, vartype character varying, varformat character varying, varhashkey boolean, varparam character varying)
    LANGUAGE plpgsql COST 10
    AS $$
BEGIN
  RETURN QUERY SELECT "name","type","format","hashkey","param" from switch21.switch_interface_in order by rank asc;
END;
$$;

}
  end

  def down
    execute %q{

    CREATE or replace FUNCTION switch21.load_interface_in() RETURNS TABLE(varname character varying, vartype character varying, varformat character varying, varhashkey boolean, varparam character varying)
    LANGUAGE plpgsql COST 10
    AS $$
BEGIN
  RETURN QUERY SELECT "name","type","format","hashkey","param" from switch_interface_in order by rank asc;
END;
$$;

}
  end
end
