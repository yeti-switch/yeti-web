class DestinationsImportFix < ActiveRecord::Migration[7.2]
  def up
    execute %q{
      alter table data_import.import_destinations add cdo smallint;
    }
  end

  def down
    execute %q{
      alter table data_import.import_destinations drop column cdo;
    }
  end
end
