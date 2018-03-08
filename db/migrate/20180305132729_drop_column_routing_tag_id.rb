class DropColumnRoutingTagId < ActiveRecord::Migration
  def up
    execute %q{
      ALTER TABLE class4.dialpeers DROP routing_tag_id;
      ALTER TABLE class4.destinations DROP routing_tag_id;
      ALTER TABLE class4.routing_tag_detection_rules DROP routing_tag_id;

      ALTER TABLE data_import.import_destinations DROP routing_tag_id;
      ALTER TABLE data_import.import_destinations DROP routing_tag_name;

      ALTER TABLE data_import.import_dialpeers DROP routing_tag_id;
      ALTER TABLE data_import.import_dialpeers DROP routing_tag_name;
    }
  end

  def down
    execute %q{
      ALTER TABLE class4.dialpeers ADD routing_tag_id integer;
      ALTER TABLE class4.destinations ADD routing_tag_id integer;
      ALTER TABLE class4.routing_tag_detection_rules ADD routing_tag_id integer;

      ALTER TABLE data_import.import_destinations ADD routing_tag_id integer;
      ALTER TABLE data_import.import_destinations ADD routing_tag_name character varying;

      ALTER TABLE data_import.import_dialpeers ADD routing_tag_id integer;
      ALTER TABLE data_import.import_dialpeers ADD routing_tag_name character varying;
    }
  end
end
