# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::RegistrationsController do
  include_context :json_api_admin_helpers, type: :registrations

  let!(:nodes) { create_list(:node, 2) }
  let(:transport_protocols) { Equipment::TransportProtocol.all.to_a }
  let(:pops) { Pop.all.to_a }

  shared_examples :responds_jsonapi_registration do
    it 'responds with correct data' do
      subject
      registration.reload
      expect(response_json[:data]).to have_jsonapi_id(registration.id)
      expect(response_json[:data]).to have_jsonapi_type(json_api_resource_type)
      expect(response_json[:data]).to have_jsonapi_attributes(
                                        'auth-password': registration.auth_password,
                                        'auth-user': registration.auth_user,
                                        contact: registration.contact,
                                        'display-username': registration.display_username,
                                        domain: registration.domain,
                                        enabled: registration.enabled,
                                        expire: registration.expire,
                                        'force-expire': registration.force_expire,
                                        'max-attempts': registration.max_attempts,
                                        name: registration.name,
                                        proxy: registration.proxy,
                                        'retry-delay': registration.retry_delay,
                                        'sip-interface-name': registration.sip_interface_name,
                                        'sip-schema-id': registration.sip_schema_id,
                                        username: registration.username
                                      )
      expect(response_json[:data]).to have_jsonapi_relationships(
                                        :pop,
                                        :node,
                                        :'transport-protocol',
                                        :'proxy-transport-protocol'
                                      )
    end
  end

  describe 'GET /api/rest/admin/registrations' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:registrations) { create_list(:registration, 3, :filled) }

    it 'responds with correct data items' do
      subject
      expect(response_json[:data]).to have_jsonapi_data_items registrations.map(&:id),
                                                              type: json_api_resource_type

      registrations.each do |registration|
        data = response_jsonapi_data_item(registration.id, json_api_resource_type)
        expect(data).to have_jsonapi_attributes hash_including(name: registration.name)
      end
    end

    include_examples :responds_with_status, 200
    include_examples :jsonapi_responds_with_pagination_links

    it_behaves_like :json_api_admin_check_authorization
  end

  describe 'GET /api/rest/admin/registrations/:id' do
    subject do
      get json_api_request_path, params: request_params, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { registration.id.to_s }
    let(:request_params) { nil }
    let!(:registration) { create(:registration, :filled, registration_attrs) }
    let(:registration_attrs) { {} }

    it_behaves_like :json_api_admin_check_authorization

    context 'without query' do
      it 'does not have relationships data' do
        subject
        expect(response_json[:data]).to_not have_jsonapi_relationship_data(:pop)
        expect(response_json[:data]).to_not have_jsonapi_relationship_data(:node)
        expect(response_json[:data]).to_not have_jsonapi_relationship_data(:'transport-protocol')
        expect(response_json[:data]).to_not have_jsonapi_relationship_data(:'proxy-transport-protocol')
      end

      include_examples :responds_with_status, 200
      include_examples :responds_jsonapi_registration
    end

    context 'with include pop,transport-protocol,proxy-transport-protocol' do
      let(:request_params) { { include: 'pop,transport-protocol,proxy-transport-protocol,node' } }

      it 'responds correct included relationships' do
        subject

        expect(response_json[:data]).to have_jsonapi_relationship_data(
                                          :pop,
                                          id: registration.pop_id,
                                          type: 'pops'
                                        )
        expect(response_json[:included]).to have_jsonapi_data_item(
                                              registration.pop_id,
                                              'pops'
                                            )

        expect(response_json[:data]).to have_jsonapi_relationship_data(
                                          :node,
                                          id: registration.node_id,
                                          type: 'nodes'
                                        )
        expect(response_json[:included]).to have_jsonapi_data_item(
                                              registration.node_id,
                                              'nodes'
                                            )

        expect(response_json[:data]).to have_jsonapi_relationship_data(
                                          :'transport-protocol',
                                          id: registration.transport_protocol_id,
                                          type: 'transport-protocols'
                                        )
        expect(response_json[:included]).to have_jsonapi_data_item(
                                              registration.transport_protocol_id,
                                              'transport-protocols'
                                            )

        expect(response_json[:data]).to have_jsonapi_relationship_data(
                                          :'proxy-transport-protocol',
                                          id: registration.proxy_transport_protocol_id,
                                          type: 'transport-protocols'
                                        )
        expect(response_json[:included]).to have_jsonapi_data_item(
                                              registration.proxy_transport_protocol_id,
                                              'transport-protocols'
                                            )
      end

      include_examples :responds_jsonapi_registration
    end
  end

  describe 'POST /api/rest/admin/registrations' do
    subject do
      post json_api_request_path, params: request_body.to_json, headers: json_api_request_headers
    end

    let(:request_body) { { data: json_api_request_data } }
    let(:json_api_request_data) do
      {
        type: json_api_resource_type,
        attributes: json_api_request_attributes,
        relationships: json_api_request_relationships
      }
    end
    let(:json_api_request_attributes) do
      {
        name: 'reg name',
        domain: 'example.com',
        username: 'qwe.asd',
        contact: 'sip:contact123@example.com'
      }
    end
    let(:json_api_request_relationships) { {} }
    let(:registration) { Equipment::Registration.last! }

    it_behaves_like :json_api_admin_check_authorization, status: 201

    context 'with only required fields' do
      it 'creates registration' do
        expect { subject }.to change { Equipment::Registration.count }.by(1)
        expect(registration).to have_attributes(
                                  auth_password: nil,
                                  auth_user: nil,
                                  contact: json_api_request_attributes[:contact],
                                  display_username: nil,
                                  domain: json_api_request_attributes[:domain],
                                  enabled: true,
                                  expire: nil,
                                  force_expire: false,
                                  max_attempts: nil,
                                  name: json_api_request_attributes[:name],
                                  proxy: nil,
                                  retry_delay: 5,
                                  sip_interface_name: nil,
                                  username: json_api_request_attributes[:username],
                                  pop_id: nil,
                                  node_id: nil,
                                  transport_protocol_id: 1,
                                  proxy_transport_protocol_id: 1,
                                  sip_schema_id: 1
                                )
      end

      include_examples :responds_with_status, 201
      include_examples :responds_jsonapi_registration
    end

    context 'without fields' do
      let(:json_api_request_attributes) { {} }
    end

    context 'with all fields' do
      let(:json_api_request_attributes) do
        super().merge 'auth-password': 'passwd',
                      'auth-user': 'reg_test',
                      'display-username': 'test reg',
                      enabled: false,
                      expire: 789,
                      'force-expire': true,
                      'max-attempts': 456,
                      proxy: 'http://proxy.com:8123',
                      'retry-delay': 123,
                      'sip-interface-name': 'sip interface name',
                      'sip-schema-id': 1
      end
      let(:json_api_request_relationships) do
        {
          node: jsonapi_relationship(nodes.first.id, 'nodes'),
          pop: jsonapi_relationship(nodes.first.pop_id, 'pops'),
          'transport-protocol': jsonapi_relationship(transport_protocols.last.id, 'transport-protocols'),
          'proxy-transport-protocol': jsonapi_relationship(transport_protocols.first.id, 'transport-protocols')
        }
      end

      it 'creates registration' do
        expect { subject }.to change { Equipment::Registration.count }.by(1)
        expect(registration).to have_attributes(
                                  auth_password: json_api_request_attributes[:'auth-password'],
                                  auth_user: json_api_request_attributes[:'auth-user'],
                                  contact: json_api_request_attributes[:contact],
                                  display_username: json_api_request_attributes[:'display-username'],
                                  domain: json_api_request_attributes[:domain],
                                  enabled: json_api_request_attributes[:enabled],
                                  expire: json_api_request_attributes[:expire],
                                  force_expire: json_api_request_attributes[:'force-expire'],
                                  max_attempts: json_api_request_attributes[:'max-attempts'],
                                  name: json_api_request_attributes[:name],
                                  proxy: json_api_request_attributes[:proxy],
                                  retry_delay: json_api_request_attributes[:'retry-delay'],
                                  sip_interface_name: json_api_request_attributes[:'sip-interface-name'],
                                  username: json_api_request_attributes[:username],
                                  pop_id: nodes.first.pop_id,
                                  node_id: nodes.first.id,
                                  transport_protocol_id: transport_protocols.last.id,
                                  proxy_transport_protocol_id: transport_protocols.first.id,
                                  sip_schema_id: json_api_request_attributes[:'sip-schema-id']
                                )
      end

      include_examples :responds_with_status, 201
      include_examples :responds_jsonapi_registration
    end
  end

  describe 'PATCH /api/rest/admin/registrations/:id' do
    subject do
      patch json_api_request_path, params: request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { registration.id.to_s }
    let!(:registration) { create(:registration, :filled, registration_attrs) }
    let(:registration_attrs) { {} }
    let(:request_body) { { data: json_api_request_data } }
    let(:json_api_request_data) do
      {
        id: record_id,
        type: json_api_resource_type,
        attributes: json_api_request_attributes,
        relationships: json_api_request_relationships
      }
    end

    context 'when update name' do
      let(:json_api_request_relationships) { {} }
      let(:json_api_request_attributes) do
        { name: 'reg new name' }
      end

      it 'changes registration name' do
        subject
        expect(registration.reload).to have_attributes(
                                         name: json_api_request_attributes[:name]
                                       )
      end

      include_examples :responds_with_status, 200
      include_examples :responds_jsonapi_registration

      it_behaves_like :json_api_admin_check_authorization
    end

    context 'when update sip-schema' do
      let(:json_api_request_attributes) {
        { 'sip-schema-id': 2 }
      }
      let(:json_api_request_relationships) { {} }

      it 'changes registration sip_schema' do
        subject
        expect(registration.reload).to have_attributes(
                                         sip_schema_id: json_api_request_attributes[:'sip-schema-id']
                                       )
      end

      include_examples :responds_with_status, 200
      include_examples :responds_jsonapi_registration
    end
  end

  describe 'DELETE /api/rest/admin/registrations/:id' do
    subject do
      delete json_api_request_path, params: request_params, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { registration.id.to_s }
    let(:request_params) { nil }
    let!(:registration) { create(:registration, :filled, registration_attrs) }
    let(:registration_attrs) { {} }

    it 'deletes registration' do
      expect { subject }.to change { Equipment::Registration.count }.by(-1)
      expect(Equipment::Registration.where(id: registration.id).count).to eq 0
    end

    include_examples :responds_with_status, 204, without_body: true

    it_behaves_like :json_api_admin_check_authorization, status: 204
  end
end
