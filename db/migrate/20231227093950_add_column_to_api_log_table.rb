# frozen_string_literal: true

class AddColumnToApiLogTable < ActiveRecord::Migration[7.0]
  def change
    add_column 'logs.api_requests', :tags, :string, array: true, default: []
  end
end
