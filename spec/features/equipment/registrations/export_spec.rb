# frozen_string_literal: true

RSpec.describe 'Equipment Registrations export' do
  subject do
    visit equipment_registrations_path(format: :csv)
  end

  include_context :login_as_admin

  let!(:node) { create(:node) }
  let!(:registrations) do
    [
      create(:registration),
      create(:registration, :filled),
      create(:registration, pop: node.pop, node: node)
    ]
  end

  it 'responds with correct csv' do
    subject
    expected_collection = registrations.map do |registration|
      {
        'Id' => registration.id.to_s,
        'Name' => registration.name,
        'Enabled' => registration.enabled.to_s,
        'Pop name' => registration.pop&.name.to_s,
        'Node name' => registration.node&.name.to_s,
        'Sip schema name' => registration.sip_schema.name,
        'Transport protocol name' => registration.transport_protocol.name,
        'Domain' => registration.domain,
        'Username' => registration.username,
        'Display username' => registration.display_username.to_s,
        'Auth user' => registration.auth_user.to_s,
        'Auth password' => registration.auth_password.to_s,
        'Proxy' => registration.proxy.to_s,
        'Proxy transport protocol name' => registration.proxy_transport_protocol.name,
        'Contact' => registration.contact,
        'Expire' => registration.expire.to_s,
        'Force expire' => registration.force_expire.to_s,
        'Retry delay' => registration.retry_delay.to_s,
        'Max attempts' => registration.max_attempts.to_s,
        'Sip interface name' => registration.sip_interface_name.to_s
      }
    end
    expect(response_csv_collection).to match_array(expected_collection)
  end
end
