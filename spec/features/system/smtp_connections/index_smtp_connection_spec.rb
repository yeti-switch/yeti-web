# frozen_string_literal: true

RSpec.describe 'Index System SMTP Connections', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    system_smtp_connections = create_list(:smtp_connection, 2, :filled)
    visit system_smtp_connections_path
    system_smtp_connections.each do |system_smtp_connection|
      expect(page).to have_css('.resource_id_link', text: system_smtp_connection.id)
    end
  end
end
