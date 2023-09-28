# frozen_string_literal: true

class AddRemoteIpToApiLogTable < ActiveRecord::Migration[7.0]
  def change
    add_column 'logs.api_requests', :remote_ip, :inet
  end
end
