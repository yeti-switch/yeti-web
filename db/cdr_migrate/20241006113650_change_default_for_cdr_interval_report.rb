# frozen_string_literal: true

class ChangeDefaultForCdrIntervalReport < ActiveRecord::Migration[7.0]
  def change
    change_column_default 'reports.cdr_interval_report', :group_by, from: nil, to: []
  end
end
