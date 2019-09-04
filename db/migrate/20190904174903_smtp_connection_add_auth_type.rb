class SmtpConnectionAddAuthType < ActiveRecord::Migration[5.2]
  def change
    add_column 'sys.smtp_connections', :auth_type, :string, null: false, default: 'plain'
  end
end
