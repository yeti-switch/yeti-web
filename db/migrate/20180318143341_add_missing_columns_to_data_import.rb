class AddMissingColumnsToDataImport < ActiveRecord::Migration
  def up
    execute %q{
      --
      -- Contractor
      --
      ALTER TABLE data_import.import_contractors
        ADD smtp_connection_id integer,
        ADD smtp_connection_name varchar,
        DROP tech_contact,
        DROP fin_contact;

      --
      -- CustomersAuth
      --
      ALTER TABLE data_import.import_customers_auth
        ADD tag_action_name varchar,
        ADD tag_action_value_names varchar DEFAULT '' NOT NULL,
        ADD dst_number_min_length integer,
        ADD dst_number_max_length integer,
        ALTER COLUMN ip SET DATA TYPE varchar USING NULL;

      --
      -- Destination
      --
      ALTER TABLE data_import.import_destinations
        ADD routing_tag_names varchar DEFAULT '' NOT NULL,
        ADD dst_number_min_length integer,
        ADD dst_number_max_length integer;

      --
      -- Dialpeer
      --
      ALTER TABLE data_import.import_dialpeers
        ADD routing_tag_names varchar DEFAULT '' NOT NULL,
        ADD dst_number_min_length integer,
        ADD dst_number_max_length integer;

      --
      -- Rateplan
      --
      ALTER TABLE data_import.import_rateplans
        ADD profit_control_mode_id integer,
        ADD profit_control_mode_name varchar;

      --
      -- Gateway
      --
      ALTER TABLE data_import.import_gateways
        ADD relay_update boolean,
        ADD suppress_early_media boolean,
        ADD send_lnp_information boolean,
        ADD force_one_way_early_media boolean,
        ADD max_30x_redirects integer;
    }
  end

  def down
    execute %q{
      --
      -- Contractor
      --
      ALTER TABLE data_import.import_contractors
        DROP smtp_connection_id,
        DROP smtp_connection_name,
        ADD tech_contact varchar,
        ADD fin_contact varchar;

      --
      -- CustomersAuth
      --
      ALTER TABLE data_import.import_customers_auth
        DROP tag_action_name,
        DROP tag_action_value_names,
        DROP dst_number_min_length,
        DROP dst_number_max_length,
        ALTER COLUMN ip SET DATA TYPE inet USING NULL;

      --
      -- Destination
      --
      ALTER TABLE data_import.import_destinations
        DROP routing_tag_names,
        DROP dst_number_min_length,
        DROP dst_number_max_length;

      --
      -- Dialpeer
      --
      ALTER TABLE data_import.import_dialpeers
        DROP routing_tag_names,
        DROP dst_number_min_length,
        DROP dst_number_max_length;

      --
      -- Rateplan
      --
      ALTER TABLE data_import.import_rateplans
        DROP profit_control_mode_id,
        DROP profit_control_mode_name;

      --
      -- Gateway
      --
      ALTER TABLE data_import.import_gateways
        DROP relay_update,
        DROP suppress_early_media,
        DROP send_lnp_information,
        DROP force_one_way_early_media,
        DROP max_30x_redirects;
    }
  end
end
