# frozen_string_literal: true

class AddRequestIdToApiLog < ActiveRecord::Migration[7.2]
  def up
    execute %q{alter table logs.api_requests add request_id varchar;}
  end

  def down
    execute %q{alter table logs.api_requests drop column request_id;}
  end
end
