# frozen_string_literal: true

class RemoveDebugColumn < ActiveRecord::Migration[7.0]
  def change
    remove_column 'sys.api_log_config', :debug, :boolean
  end
end
