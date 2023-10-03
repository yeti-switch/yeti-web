# frozen_string_literal: true

class AddMetaAttributeToApiLog < ActiveRecord::Migration[7.0]
  def change
    add_column 'logs.api_requests', :meta, :jsonb
  end
end
