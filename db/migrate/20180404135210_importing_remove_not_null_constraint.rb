class ImportingRemoveNotNullConstraint < ActiveRecord::Migration
  def up
    execute %q{
      ALTER TABLE data_import.import_customers_auth
        ALTER tag_action_value_names DROP DEFAULT,
        ALTER tag_action_value_names DROP NOT NULL;

      ALTER TABLE data_import.import_destinations
        ALTER routing_tag_names DROP DEFAULT,
        ALTER routing_tag_names DROP NOT NULL;

      ALTER TABLE data_import.import_dialpeers
        ALTER routing_tag_names DROP DEFAULT,
        ALTER routing_tag_names DROP NOT NULL;
    }
  end

  def down
    execute %q{
      ALTER TABLE data_import.import_customers_auth
        ALTER tag_action_value_names SET DEFAULT '',
        ALTER tag_action_value_names SET NOT NULL;

      ALTER TABLE data_import.import_destinations
        ALTER routing_tag_names SET DEFAULT '',
        ALTER routing_tag_names SET NOT NULL;

      ALTER TABLE data_import.import_dialpeers
        ALTER routing_tag_names SET DEFAULT '',
        ALTER routing_tag_names SET NOT NULL;
    }
  end
end
