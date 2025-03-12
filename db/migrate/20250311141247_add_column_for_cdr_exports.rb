# frozen_string_literal: true

class AddColumnForCdrExports < ActiveRecord::Migration[7.2]
  def change
    add_column :cdr_exports, :time_format, :string, default: 'with_timezone', null: false
  end
end
