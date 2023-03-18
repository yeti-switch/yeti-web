class FixGwImport < ActiveRecord::Migration[6.1]
  def up
    execute %q{
        alter table data_import.import_gateways
            add diversion_domain varchar,
            add registered_aor_mode_id smallint,
            add registered_aor_mode_name varchar;
        alter table data_import.import_gateways drop column use_registered_aor;
    }
  end

  def down
    execute %q{
        alter table data_import.import_gateways
            drop column diversion_domain,
            drop column registered_aor_mode_id,
            drop column registered_aor_mode_name;
        alter table data_import.import_gateways add use_registered_aor boolean;
    }
  end
end
