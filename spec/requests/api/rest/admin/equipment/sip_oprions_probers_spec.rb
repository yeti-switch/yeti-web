# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Equipment::SipOptionsProbersController do
  include_context :json_api_admin_helpers, type: :'sip-options-probers', prefix: :equipment

  let!(:nodes) { create_list(:node, 2) }
  let(:transport_protocols) { Equipment::TransportProtocol.all.to_a }
  let(:pops) { Pop.all.to_a }
  let(:sip_schemas) { System::SipSchema.all.to_a }

  shared_examples :responds_jsonapi_sip_options_prober do
    it 'responds with correct data' do
      subject
      sip_options_prober.reload
      expect(response_json[:data]).to have_jsonapi_id(sip_options_prober.id)
      expect(response_json[:data]).to have_jsonapi_type(json_api_resource_type)
      expect(response_json[:data]).to have_jsonapi_attributes(
          'append-headers': sip_options_prober.append_headers,
          'auth-password': sip_options_prober.auth_password,
          'auth-username': sip_options_prober.auth_username,
          'contact-uri': sip_options_prober.contact_uri,
          'enabled': sip_options_prober.enabled,
          'from-uri': sip_options_prober.from_uri,
          'interval': sip_options_prober.interval,
          'name': sip_options_prober.name,
          'proxy': sip_options_prober.proxy,
          'ruri-domain': sip_options_prober.ruri_domain,
          'ruri-username': sip_options_prober.ruri_username,
          'sip-interface-name': sip_options_prober.sip_interface_name,
          'to-uri': sip_options_prober.to_uri,
          'created-at': sip_options_prober.created_at.iso8601(3),
          'updated-at': sip_options_prober.updated_at.iso8601(3),
          'external-id': sip_options_prober.external_id
        )
      expect(response_json[:data]).to have_jsonapi_relationships(
                                        :pop,
                                        :node,
                                        :'transport-protocol',
                                        :'proxy-transport-protocol',
                                        :'sip-schema'
                                      )
    end
  end

  describe 'GET /api/rest/admin/equipment/sip-options-probers' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:sip_options_probers) { create_list(:sip_options_prober, 3) }

    it 'responds with correct data items' do
      subject
      expect(response_json[:data]).to have_jsonapi_data_items sip_options_probers.map(&:id),
                                                              type: json_api_resource_type

      sip_options_probers.each do |sip_options_prober|
        data = response_jsonapi_data_item(sip_options_prober.id, json_api_resource_type)
        expect(data).to have_jsonapi_attributes hash_including(name: sip_options_prober.name)
      end
    end

    include_examples :responds_with_status, 200
    include_examples :jsonapi_responds_with_pagination_links
  end

  describe 'GET /api/rest/admin/equipment/sip-options-probers/:id' do
    subject do
      get json_api_request_path, params: request_params, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { sip_options_prober.id.to_s }
    let(:request_params) { nil }
    let!(:sip_options_prober) { create(:sip_options_prober, sip_options_prober_attrs) }
    let(:sip_options_prober_attrs) { { pop: pops[0], node: nodes[0] } }

    context 'without query' do
      it 'does not have relationships data' do
        subject
        expect(response_json[:data]).to_not have_jsonapi_relationship_data(:pop)
        expect(response_json[:data]).to_not have_jsonapi_relationship_data(:node)
        expect(response_json[:data]).to_not have_jsonapi_relationship_data(:'sip-schema')
        expect(response_json[:data]).to_not have_jsonapi_relationship_data(:'transport-protocol')
        expect(response_json[:data]).to_not have_jsonapi_relationship_data(:'proxy-transport-protocol')
      end

      include_examples :responds_with_status, 200
      include_examples :responds_jsonapi_sip_options_prober
    end

    context 'with include pop,sip-schema,transport-protocol,proxy-transport-protocol,node' do
      let(:request_params) { { include: 'pop,sip-schema,transport-protocol,proxy-transport-protocol,node' } }

      it 'responds correct included relationships' do
        subject

        expect(response_json[:data]).to have_jsonapi_relationship_data(
                                          :pop,
                                          id: sip_options_prober.pop_id,
                                          type: 'pops'
                                        )
        expect(response_json[:included]).to have_jsonapi_data_item(
                                              sip_options_prober.pop_id,
                                              'pops'
                                            )

        expect(response_json[:data]).to have_jsonapi_relationship_data(
                                          :node,
                                          id: sip_options_prober.node_id,
                                          type: 'nodes'
                                        )
        expect(response_json[:included]).to have_jsonapi_data_item(
                                              sip_options_prober.node_id,
                                              'nodes'
                                            )

        expect(response_json[:data]).to have_jsonapi_relationship_data(
                                          :'sip-schema',
                                          id: sip_options_prober.sip_schema_id,
                                          type: 'sip-schemas'
                                        )
        expect(response_json[:included]).to have_jsonapi_data_item(
                                              sip_options_prober.sip_schema_id,
                                              'sip-schemas'
                                            )

        expect(response_json[:data]).to have_jsonapi_relationship_data(
                                          :'transport-protocol',
                                          id: sip_options_prober.transport_protocol_id,
                                          type: 'transport-protocols'
                                        )
        expect(response_json[:included]).to have_jsonapi_data_item(
                                              sip_options_prober.transport_protocol_id,
                                              'transport-protocols'
                                            )

        expect(response_json[:data]).to have_jsonapi_relationship_data(
                                          :'proxy-transport-protocol',
                                          id: sip_options_prober.proxy_transport_protocol_id,
                                          type: 'transport-protocols'
                                        )
        expect(response_json[:included]).to have_jsonapi_data_item(
                                              sip_options_prober.proxy_transport_protocol_id,
                                              'transport-protocols'
                                            )
      end

      include_examples :responds_jsonapi_sip_options_prober
    end
  end

  describe 'POST /api/rest/admin/equipment/sip-oprions-probers' do
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
        name: 'Sip Options Prober Tets123',
        'ruri-domain': 'example.com',
        'ruri-username': 'sip:qwe@asd'
      }
    end
    let(:json_api_request_relationships) { {} }
    let(:sip_options_prober) { Equipment::SipOptionsProber.last! }

    context 'with only required fields' do
      it 'creates sip options prober' do
        expect { subject }.to change { Equipment::SipOptionsProber.count }.by(1)
        expect(sip_options_prober).to have_attributes(
            append_headers: nil,
            auth_password: nil,
            auth_username: nil,
            contact_uri: nil,
            enabled: true,
            from_uri: nil,
            interval: 60,
            name: json_api_request_attributes[:name],
            proxy: nil,
            ruri_domain: json_api_request_attributes[:'ruri-domain'],
            ruri_username: json_api_request_attributes[:'ruri-username'],
            sip_interface_name: nil,
            to_uri: nil,
            external_id: nil
          )
      end

      include_examples :responds_with_status, 201
      include_examples :responds_jsonapi_sip_options_prober
    end

    context 'with all fields' do
      let(:json_api_request_attributes) do
        super().merge 'auth-password': 'passwd',
                      'auth-username': 'sop_test',
                      enabled: true,
                      interval: 60,
                      'append-headers': 'append-headers-test',
                      'contact-uri': 'sip:test@test',
                      'from-uri': '//test_uri.com',
                      'proxy': '//proxy',
                      'sip-interface-name': 'sip interface name test',
                      'to-uri': '//to_uri_test.com',
                      'external-id': 52_352_125_521_632
      end
      let(:json_api_request_relationships) do
        {
          node: jsonapi_relationship(nodes.first.id, 'nodes'),
          pop: jsonapi_relationship(nodes.first.pop_id, 'pops'),
          'sip-schema': jsonapi_relationship(sip_schemas.last.id, 'sip-schemas'),
          'transport-protocol': jsonapi_relationship(transport_protocols.last.id, 'transport-protocols'),
          'proxy-transport-protocol': jsonapi_relationship(transport_protocols.first.id, 'transport-protocols')
        }
      end

      it 'creates sip options prober' do
        expect { subject }.to change { Equipment::SipOptionsProber.count }.by(1)
        expect(sip_options_prober).to have_attributes(
                                    append_headers: json_api_request_attributes[:'append-headers'],
                                    auth_password: json_api_request_attributes[:'auth-password'],
                                    auth_username: json_api_request_attributes[:'auth-username'],
                                    contact_uri: json_api_request_attributes[:'contact-uri'],
                                    enabled: true,
                                    from_uri: json_api_request_attributes[:'from-uri'],
                                    interval: 60,
                                    name: json_api_request_attributes[:name],
                                    proxy: json_api_request_attributes[:proxy],
                                    ruri_domain: json_api_request_attributes[:'ruri-domain'],
                                    ruri_username: json_api_request_attributes[:'ruri-username'],
                                    sip_interface_name: json_api_request_attributes[:'sip-interface-name'],
                                    to_uri: json_api_request_attributes[:'to-uri'],
                                    external_id: json_api_request_attributes[:'external-id'],
                                    pop_id: nodes.first.pop_id,
                                    node_id: nodes.first.id,
                                    transport_protocol_id: transport_protocols.last.id,
                                    proxy_transport_protocol_id: transport_protocols.first.id,
                                    sip_schema_id: sip_schemas.last.id
                                  )
      end

      include_examples :responds_with_status, 201
      include_examples :responds_jsonapi_sip_options_prober
    end
  end

  describe 'PATCH /api/rest/admin/equipment/sip-options-probers/:id' do
    subject do
      patch json_api_request_path, params: request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { sip_options_prober.id.to_s }
    let!(:sip_options_prober) { create(:sip_options_prober, sip_options_prober_attrs) }
    let(:sip_options_prober_attrs) { {} }
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
        { name: 'test sip options name' }
      end

      it 'changes sip options prober name' do
        subject
        expect(sip_options_prober.reload).to have_attributes(
                                         name: json_api_request_attributes[:name]
                                       )
      end

      include_examples :responds_with_status, 200
      include_examples :responds_jsonapi_sip_options_prober
    end

    context 'when update external id to exist external id' do
      let(:json_api_request_relationships) { {} }
      let(:exist_external_id) { create(:sip_options_prober, external_id: 1_222_456).external_id }
      let(:json_api_request_attributes) do
        { 'external-id': exist_external_id }
      end

      it 'can`t change to exist external id' do
        subject
        expect(response_json[:errors]).to match(
            [
              title: 'has already been taken',
              detail: 'external-id - has already been taken',
              source: { pointer: '/data/attributes/external-id' },
              code: '100',
              status: '422'
            ]
          )
      end

      include_examples :responds_with_status, 422
    end
  end

  describe 'DELETE /api/rest/admin/equipment/sip-options-probers/:id' do
    subject do
      delete json_api_request_path, params: request_params, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { sip_options_prober.id.to_s }
    let(:request_params) { nil }
    let!(:sip_options_prober) { create(:sip_options_prober, sip_options_prober_attrs) }
    let(:sip_options_prober_attrs) { {} }

    it 'deletes sip options prober' do
      expect { subject }.to change { Equipment::SipOptionsProber.count }.by(-1)
      expect(Equipment::SipOptionsProber.where(id: sip_options_prober.id).count).to eq 0
    end

    include_examples :responds_with_status, 204, without_body: true
  end
end
