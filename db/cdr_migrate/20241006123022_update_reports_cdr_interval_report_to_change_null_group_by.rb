# frozen_string_literal: true

class UpdateReportsCdrIntervalReportToChangeNullGroupBy < ActiveRecord::Migration[7.0]
  def up
    execute "UPDATE reports.cdr_interval_report SET group_by = '{}' WHERE group_by IS NULL;"
    change_column_null 'reports.cdr_interval_report', 'group_by', false
  end

  def down
    change_column_null 'reports.cdr_interval_report', 'group_by', true
    execute "UPDATE reports.cdr_interval_report SET group_by = NULL WHERE group_by = '{}';"
  end
end
