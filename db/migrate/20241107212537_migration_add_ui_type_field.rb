# frozen_string_literal: true

class MigrationAddUiTypeField < ActiveRecord::Migration[7.0]
  def change
    add_column 'billing.service_types', :ui_type, :string
  end
end
