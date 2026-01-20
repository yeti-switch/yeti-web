# frozen_string_literal: true

RSpec.describe 'switch22.load_sip_options_probers' do
  subject do
    SqlCaller::Yeti.select_all(sql, *sql_params).map(&:deep_symbolize_keys)
  end

  let(:sql) { 'SELECT * FROM switch22.load_sip_options_probers(?)' }
  let(:sql_params) do
    [node.id]
  end

  let!(:pop) { create(:pop) }
  let!(:node) { create(:node, pop: pop) }
  let!(:probers) do
    [
      create(:sip_options_prober, :filled, node: node, pop: pop),
      create(:sip_options_prober, node: node, pop: pop),
      create(:sip_options_prober, node: node, pop: nil),
      create(:sip_options_prober, node: nil, pop: pop),
      create(:sip_options_prober, node: nil, pop: nil)
    ]
  end
  let!(:another_pop) { create(:pop) }
  let!(:another_node) { create(:node, pop: pop) }
  before do
    # not included registrations
    create(:sip_options_prober, node: another_node, pop: pop, enabled: false)
    create(:sip_options_prober, node: another_node, pop: another_pop)
    create(:sip_options_prober, node: another_node, pop: pop)
    create(:sip_options_prober, node: another_node, pop: another_pop)
  end

  it 'responds with correct rows' do
    expect(subject).to match_array(
                         probers.map do |p|
                           {
                             id: p.id,
                             name: p.name,
                             ruri_domain: p.ruri_domain,
                             ruri_username: p.ruri_username,
                             transport_protocol_id: p.transport_protocol_id,
                             sip_schema_id: p.sip_schema_id,
                             from_uri: p.from_uri,
                             to_uri: p.to_uri,
                             contact_uri: p.contact_uri,
                             route_set: p.route_set.join(','),
                             interval: p.interval,
                             append_headers: p.append_headers,
                             sip_interface_name: p.sip_interface_name,
                             auth_username: p.auth_username,
                             auth_password: p.auth_password,
                             created_at: anything,
                             updated_at: anything
                           }
                         end
                       )
  end

  context 'when specific i_prober_id is passed' do
    let(:sql) { 'SELECT * FROM switch22.load_sip_options_probers(?, ?)' }
    let(:sql_params) do
      [node.id, p.id]
    end

    context 'with id of valid prober' do
      let(:p) { probers.first }

      it 'responds with correct row' do
        expect(subject).to match_array(
                             [
                               {
                                 id: p.id,
                                 name: p.name,
                                 ruri_domain: p.ruri_domain,
                                 ruri_username: p.ruri_username,
                                 transport_protocol_id: p.transport_protocol_id,
                                 sip_schema_id: p.sip_schema_id,
                                 from_uri: p.from_uri,
                                 to_uri: p.to_uri,
                                 contact_uri: p.contact_uri,
                                 route_set: p.route_set.join(','),
                                 interval: p.interval,
                                 append_headers: p.append_headers,
                                 sip_interface_name: p.sip_interface_name,
                                 auth_username: p.auth_username,
                                 auth_password: p.auth_password,
                                 created_at: anything,
                                 updated_at: anything
                               }
                             ]
                           )
      end
    end

    context 'with id of disabled prober' do
      let(:p) { create(:sip_options_prober, node: node, pop: pop, enabled: false) }

      it 'responds with empty' do
        expect(subject).to eq []
      end
    end

    context 'with id of prober from another node' do
      let(:p) { create(:sip_options_prober, node: another_node, pop: pop) }

      it 'responds with empty' do
        expect(subject).to eq []
      end
    end

    context 'when o_registration_id is NULL' do
      let(:sql_params) do
        [node.id, nil]
      end

      it 'responds with correct rows' do
        expect(subject).to match_array(
                             probers.map do |p|
                               {
                                 id: p.id,
                                 name: p.name,
                                 ruri_domain: p.ruri_domain,
                                 ruri_username: p.ruri_username,
                                 transport_protocol_id: p.transport_protocol_id,
                                 sip_schema_id: p.sip_schema_id,
                                 from_uri: p.from_uri,
                                 to_uri: p.to_uri,
                                 contact_uri: p.contact_uri,
                                 route_set: p.route_set.join(','),
                                 interval: p.interval,
                                 append_headers: p.append_headers,
                                 sip_interface_name: p.sip_interface_name,
                                 auth_username: p.auth_username,
                                 auth_password: p.auth_password,
                                 created_at: anything,
                                 updated_at: anything
                               }
                             end
                           )
      end
    end
  end
end
