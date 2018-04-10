class AddRowsCountToCdrExports < ActiveRecord::Migration
  def change
    add_column :cdr_exports, :rows_count, :integer
  end
end
