# frozen_string_literal: true

RSpec.describe 'Export Equipment Registrations', type: :feature do
  include_context :login_as_admin

  before { create(:registration) }

  let!(:item) do
    create :registration,
           pop: create(:pop),
           node: create(:node)
  end

  before do
    visit equipment_registrations_path(format: :csv)
  end

  subject { CSV.parse(page.body).slice(0, 2).transpose }

  it 'has expected header and values' do
    expect(subject).to match_array(
      [
        ['Id', item.id.to_s],
        ['Name', item.name],
        ['Enabled', item.enabled.to_s],
        ['Pop name', item.pop.name],
        ['Node name', item.node.name],
        ['Sip schema name', item.sip_schema.name],
        ['Transport protocol name', item.transport_protocol.name],
        ['Domain', item.domain],
        ['Username', item.username],
        ['Display username', item.display_username.to_s],
        ['Auth user', item.auth_user.to_s],
        ['Auth password', item.auth_password.to_s],
        ['Proxy', item.proxy.to_s],
        ['Proxy transport protocol name', item.proxy_transport_protocol.name],
        ['Contact', item.contact],
        ['Expire', item.expire.to_s],
        ['Force expire', item.force_expire.to_s],
        ['Retry delay', item.retry_delay.to_s],
        ['Max attempts', item.max_attempts.to_s]
      ]
    )
  end
end
