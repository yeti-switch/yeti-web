class AddRoutingTagIdsToRtdr < ActiveRecord::Migration[4.2]
  def up
    execute %q{
      ALTER TABLE class4.routing_tag_detection_rules ADD routing_tag_ids smallint[] NOT NULL DEFAULT '{}'::smallint[];
    }
  end

  def down
    execute %q{
      ALTER TABLE class4.routing_tag_detection_rules DROP routing_tag_ids;
    }
  end
end
