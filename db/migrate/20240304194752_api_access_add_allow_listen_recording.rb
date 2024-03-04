class ApiAccessAddAllowListenRecording < ActiveRecord::Migration[7.0]
  def change
    add_column 'sys.api_access', :allow_listen_recording, :boolean, default: false, null: false
  end
end
