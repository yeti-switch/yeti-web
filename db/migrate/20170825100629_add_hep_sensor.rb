class AddHepSensor < ActiveRecord::Migration
  def up
    execute %q{
      insert into sys.sensor_modes(id,name) values(3,'HEPv3');
      alter table sys.sensors
        add target_port integer,
        add hep_capture_id integer;

DROP FUNCTION switch12.load_sensor();
CREATE OR REPLACE FUNCTION switch12.load_sensor()
  RETURNS TABLE(o_id smallint, o_name character varying, o_mode_id integer, o_source_interface character varying, o_target_mac macaddr, o_use_routing boolean, o_target_ip inet, o_target_port integer, o_hep_capture_id integer, o_source_ip inet) AS
$BODY$
BEGIN
  RETURN
  QUERY SELECT
          id,
          name,
          mode_id,
          source_interface,
          target_mac macaddr,
          use_routing,
          target_ip,
          target_port,
          hep_capture_id,
          source_ip from sys.sensors;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 10
  ROWS 1000;


    }
  end

  def down
    execute %q{

DROP FUNCTION switch12.load_sensor();
CREATE OR REPLACE FUNCTION switch12.load_sensor()
  RETURNS TABLE(o_id smallint, o_name character varying, o_mode_id integer, o_source_interface character varying, o_target_mac macaddr, o_use_routing boolean, o_target_ip inet, o_source_ip inet) AS
$BODY$
BEGIN
  RETURN
  QUERY SELECT
          id,
          name,
          mode_id,
          source_interface,
          target_mac macaddr,
          use_routing,
          target_ip,
          source_ip from sys.sensors;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 10
  ROWS 1000;

      delete from sys.sensor_modes where id=3;
      alter table sys.sensors
        drop column target_port,
        drop column hep_capture_id;
    }

  end
end
