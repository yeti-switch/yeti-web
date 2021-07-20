class CreateTagActions < ActiveRecord::Migration[4.2]
  def up
    execute %q{
      -- Table
      CREATE TABLE class4.tag_actions(
        id smallint PRIMARY KEY,
        name varchar NOT NULL UNIQUE
      );

      -- Data
      INSERT INTO class4.tag_actions(id,name) VALUES(1, 'Clear tags');
      INSERT INTO class4.tag_actions(id,name) VALUES(2, 'Remove selected tags');
      INSERT INTO class4.tag_actions(id,name) VALUES(3, 'Append selected tags');
      INSERT INTO class4.tag_actions(id,name) VALUES(4, 'Intersection with selected tags');
      INSERT INTO class4.tag_actions(id,name) VALUES(5, 'Replace with selected tags');

      -- References
      ALTER TABLE class4.customers_auth ADD tag_action_id smallint REFERENCES class4.tag_actions(id);
      ALTER TABLE class4.numberlists ADD tag_action_id smallint REFERENCES class4.tag_actions(id);
      ALTER TABLE class4.numberlist_items ADD tag_action_id smallint REFERENCES class4.tag_actions(id);
      ALTER TABLE class4.routing_tag_detection_rules ADD tag_action_id smallint REFERENCES class4.tag_actions(id);

      -- tag_action_value
      ALTER TABLE class4.customers_auth ADD tag_action_value smallint[] NOT NULL DEFAULT '{}'::smallint[];
      ALTER TABLE class4.numberlists ADD tag_action_value smallint[] NOT NULL DEFAULT '{}'::smallint[];
      ALTER TABLE class4.numberlist_items ADD tag_action_value smallint[] NOT NULL DEFAULT '{}'::smallint[];
      ALTER TABLE class4.routing_tag_detection_rules ADD tag_action_value smallint[] NOT NULL DEFAULT '{}'::smallint[];

      -- routing_tag_ids
      ALTER TABLE class4.destinations ADD routing_tag_ids smallint[] NOT NULL DEFAULT '{}'::smallint[];
      ALTER TABLE class4.dialpeers ADD routing_tag_ids smallint[] NOT NULL DEFAULT '{}'::smallint[];

      -- Migrate data RoutingTagDetectionRule, Dialpeer, Destination
      UPDATE class4.routing_tag_detection_rules SET tag_action_id=3, tag_action_value=array_append('{}', routing_tag_id) WHERE routing_tag_id IS NOT NULL;
      UPDATE class4.dialpeers SET routing_tag_ids=array_append('{}', routing_tag_id) WHERE routing_tag_id IS NOT NULL;
      UPDATE class4.destinations SET routing_tag_ids=array_append('{}', routing_tag_id) WHERE routing_tag_id IS NOT NULL;

      -- Importing: Dialpeer, Destination, CustomersAuth
      ALTER TABLE data_import.import_customers_auth ADD tag_action_id smallint;
      ALTER TABLE data_import.import_customers_auth ADD tag_action_value smallint[] NOT NULL DEFAULT '{}'::smallint[];
      ALTER TABLE data_import.import_destinations ADD routing_tag_ids smallint[] NOT NULL DEFAULT '{}'::smallint[];
      ALTER TABLE data_import.import_dialpeers ADD routing_tag_ids smallint[] NOT NULL DEFAULT '{}'::smallint[];
    }
  end

  def down
    execute %q{
      -- Importing: Dialpeer, Destination, CustomersAuth
      ALTER TABLE data_import.import_customers_auth DROP tag_action_id;
      ALTER TABLE data_import.import_customers_auth DROP tag_action_value;
      ALTER TABLE data_import.import_destinations DROP routing_tag_ids;
      ALTER TABLE data_import.import_dialpeers DROP routing_tag_ids;

      -- Migrate data RoutingTagDetectionRule, Dialpeer, Destination
      UPDATE class4.routing_tag_detection_rules SET routing_tag_id=tag_action_value[array_upper(tag_action_value, 1)] WHERE array_length(tag_action_value, 1) > 0;
      UPDATE class4.dialpeers SET routing_tag_id=routing_tag_ids[array_upper(routing_tag_ids, 1)] WHERE array_length(routing_tag_ids, 1) > 0;
      UPDATE class4.destinations SET routing_tag_id=routing_tag_ids[array_upper(routing_tag_ids, 1)] WHERE array_length(routing_tag_ids, 1) > 0;

      -- routing_tag_ids
      ALTER TABLE class4.destinations DROP routing_tag_ids;
      ALTER TABLE class4.dialpeers DROP routing_tag_ids;

      -- tag_action_value
      ALTER TABLE class4.customers_auth DROP tag_action_value;
      ALTER TABLE class4.numberlists DROP tag_action_value;
      ALTER TABLE class4.numberlist_items DROP tag_action_value;
      ALTER TABLE class4.routing_tag_detection_rules DROP tag_action_value;

      -- References
      ALTER TABLE class4.customers_auth DROP tag_action_id;
      ALTER TABLE class4.numberlists DROP tag_action_id;
      ALTER TABLE class4.numberlist_items DROP tag_action_id;
      ALTER TABLE class4.routing_tag_detection_rules DROP tag_action_id;

      -- Table
      DROP TABLE class4.tag_actions;
    }
  end
end
