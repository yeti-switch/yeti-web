# frozen_string_literal: true

RSpec.describe 'switch19.load_registrations_out' do
  subject do
    yeti_select_all(sql, *sql_params)
  end

  let(:sql) { 'SELECT * FROM switch19.load_registrations_out(?, ?)' }
  let(:sql_params) do
    [pop.id, node.id]
  end

  let!(:pop) { create(:pop) }
  let!(:node) { create(:node, pop: pop) }
  let!(:registrations) do
    [
      create(:registration, :filled, node: node, pop: pop),
      create(:registration, node: node, pop: pop),
      create(:registration, node: node, pop: nil),
      create(:registration, node: nil, pop: pop),
      create(:registration, node: nil, pop: nil)
    ]
  end
  let!(:another_pop) { create(:pop) }
  let!(:another_node) { create(:node, pop: pop) }
  before do
    # not included registrations
    create(:registration, node: node, pop: pop, enabled: false)
    create(:registration, node: another_node, pop: another_pop)
    create(:registration, node: another_node, pop: pop)
    create(:registration, node: node, pop: another_pop)
  end

  it 'responds with correct rows' do
    expect(subject).to match_array(
                         registrations.map do |registration|
                           {
                             o_id: registration.id,
                             o_transport_protocol_id: registration.transport_protocol_id,
                             o_domain: registration.domain,
                             o_user: registration.username,
                             o_display_name: registration.display_username,
                             o_auth_user: registration.auth_user,
                             o_auth_password: registration.auth_password,
                             o_proxy: registration.proxy,
                             o_proxy_transport_protocol_id: registration.proxy_transport_protocol_id,
                             o_contact: registration.contact,
                             o_expire: registration.expire,
                             o_force_expire: registration.force_expire,
                             o_retry_delay: registration.retry_delay,
                             o_max_attempts: registration.max_attempts,
                             o_scheme_id: registration.sip_schema_id,
                             o_sip_interface_name: registration.sip_interface_name
                           }
                         end
                       )
  end

  context 'when specific i_registration_id is passed' do
    let(:sql) { 'SELECT * FROM switch19.load_registrations_out(?, ?, ?)' }
    let(:sql_params) do
      [pop.id, node.id, registration.id]
    end

    context 'with id of valid registration' do
      let(:registration) { registrations.first }

      it 'responds with correct row' do
        expect(subject).to match_array(
                             [
                               {
                                 o_id: registration.id,
                                 o_transport_protocol_id: registration.transport_protocol_id,
                                 o_domain: registration.domain,
                                 o_user: registration.username,
                                 o_display_name: registration.display_username,
                                 o_auth_user: registration.auth_user,
                                 o_auth_password: registration.auth_password,
                                 o_proxy: registration.proxy,
                                 o_proxy_transport_protocol_id: registration.proxy_transport_protocol_id,
                                 o_contact: registration.contact,
                                 o_expire: registration.expire,
                                 o_force_expire: registration.force_expire,
                                 o_retry_delay: registration.retry_delay,
                                 o_max_attempts: registration.max_attempts,
                                 o_scheme_id: registration.sip_schema_id,
                                 o_sip_interface_name: registration.sip_interface_name
                               }
                             ]
                           )
      end
    end

    context 'with id of disabled registration' do
      let(:registration) { create(:registration, node: node, pop: pop, enabled: false) }

      it 'responds with empty' do
        expect(subject).to eq []
      end
    end

    context 'with id of registration from another node' do
      let(:registration) { create(:registration, node: another_node, pop: pop) }

      it 'responds with empty' do
        expect(subject).to eq []
      end
    end

    context 'with id of registration from another pop' do
      let(:registration) { create(:registration, node: node, pop: another_pop) }

      it 'responds with empty' do
        expect(subject).to eq []
      end
    end

    context 'when o_registration_id is NULL' do
      let(:sql_params) do
        [pop.id, node.id, nil]
      end

      it 'responds with correct rows' do
        expect(subject).to match_array(
                             registrations.map do |registration|
                               {
                                 o_id: registration.id,
                                 o_transport_protocol_id: registration.transport_protocol_id,
                                 o_domain: registration.domain,
                                 o_user: registration.username,
                                 o_display_name: registration.display_username,
                                 o_auth_user: registration.auth_user,
                                 o_auth_password: registration.auth_password,
                                 o_proxy: registration.proxy,
                                 o_proxy_transport_protocol_id: registration.proxy_transport_protocol_id,
                                 o_contact: registration.contact,
                                 o_expire: registration.expire,
                                 o_force_expire: registration.force_expire,
                                 o_retry_delay: registration.retry_delay,
                                 o_max_attempts: registration.max_attempts,
                                 o_scheme_id: registration.sip_schema_id,
                                 o_sip_interface_name: registration.sip_interface_name
                               }
                             end
                           )
      end
    end
  end
end
