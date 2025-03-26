class AddTimeZoneNameColumnForCdrExport < ActiveRecord::Migration[7.2]
  def change
    add_column :cdr_exports, :time_zone_name, :string
  end
end
