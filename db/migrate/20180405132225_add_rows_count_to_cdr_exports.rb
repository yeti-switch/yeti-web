class AddRowsCountToCdrExports < ActiveRecord::Migration[5.0]
  def change
    add_column :cdr_exports, :rows_count, :integer
  end
end
