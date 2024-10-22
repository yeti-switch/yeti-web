# frozen_string_literal: true

RSpec.describe Billing::Provisioning::PhoneSystems do
  let(:random_uuid) { SecureRandom.uuid }
  let(:gateway_uuid) { SecureRandom.uuid }
  let(:generate_name) { "gw-#{random_uuid}" }
  let(:telecom_center_api_host) { 'https://api.telecom.center' }
  let(:telecom_center_api_endpoint) { "#{telecom_center_api_host}/api/rest/public/operator/customers" }
  let(:service_type_attrs) { { variables: { endpoint: telecom_center_api_host, username: 'user', password: 'pass' } } }
  let(:service_type) { FactoryBot.create(:service_type, service_type_attrs) }
  let(:service) { FactoryBot.create(:service, service_attrs) }
  let(:stub_customer_post_request!) do
    WebMock.stub_request(:post, "#{telecom_center_api_host}/api/rest/public/operator/customers")
           .to_return(status: 201, body: { data: { id: 123, type: 'customers' } }.to_json)
  end
  let(:stub_incoming_trunks_post_request!) do
    WebMock.stub_request(:post, "#{telecom_center_api_host}/api/rest/public/operator/incoming_trunks")
           .with(
             body: {
               data: {
                 type: 'incoming_trunks',
                 attributes: { name: generate_name },
                 relationships: {
                   customer: {
                     data: {
                       type: 'customers',
                       id: service.id
                     }
                   }
                 }
               }
             }.to_json
           )
           .to_return(
             status: 201,
             body: {
               data: {
                 id: random_uuid,
                 type: 'incoming_trunks',
                 attributes: {
                   domain: '3391285728100.did-gw-sandbox.phone.systems'
                 }
               }
             }.to_json
           )
  end
  let(:stub_gateway_post_request!) do
    WebMock.stub_request(:post, "#{telecom_center_api_host}/api/rest/public/operator/termination_gateways")
           .with(
             body: {
               data: {
                 type: 'termination_gateways',
                 attributes: { host: 'sip.yeti-switch.org', authorization_name: username, authorization_password: password, name: generate_name },
                 relationships: {
                   customer: {
                     data: {
                       type: 'customers',
                       id: service.id
                     }
                   }
                 }
               }
             }.to_json
           )
           .to_return(
             status: 201,
             body: {
               data: {
                 id: gateway_uuid,
                 type: 'termination_gateways',
                 attributes: {
                   operator: true,
                   name: generate_name
                 }
               }
             }.to_json
           )
  end
  let(:stub_termination_route_post_request!) do
    WebMock.stub_request(:post, "#{telecom_center_api_host}/api/rest/public/operator/termination_routes")
           .with(
             body: {
               data: {
                 type: 'termination_routes',
                 attributes: { name: generate_name },
                 relationships: {
                   gateway: {
                     data: {
                       type: 'termination_gateways',
                       id: gateway_uuid
                     }
                   },
                   customer: {
                     data: {
                       type: 'customers',
                       id: service.reload.id
                     }
                   }
                 }
               }
             }.to_json
           )
           .to_return(
             status: 201,
             body: {
               data: {
                 id: SecureRandom.uuid,
                 type: 'termination_routes',
                 attributes: {
                   name: generate_name
                 }
               }
             }.to_json
           )
  end
  let(:password) { SecureRandom.alphanumeric(20) }
  let(:username) { SecureRandom.alphanumeric(20) }
  let(:service_attrs) do
    {
      type: service_type,
      uuid: random_uuid,
      variables: {
        attributes: {
          name: 'Test Service'
        }
      }
    }
  end

  before do
    allow_any_instance_of(Billing::Provisioning::PhoneSystems::IncomingTrunkService).to receive(:generate_name).and_return(generate_name)
    allow_any_instance_of(Billing::Provisioning::PhoneSystems::GatewayService).to receive(:generate_auth_username).and_return(username)
    allow_any_instance_of(Billing::Provisioning::PhoneSystems::GatewayService).to receive(:generate_auth_password).and_return(password)
    allow_any_instance_of(Billing::Provisioning::PhoneSystems::GatewayService).to receive(:phone_systems_gateway_name).and_return(generate_name)
    allow_any_instance_of(Billing::Provisioning::PhoneSystems::RouteService).to receive(:generate_name).and_return(generate_name)
    allow(service).to receive(:update)
    WebMock.reset!
  end

  describe '#after_create' do
    context 'when valid data' do
      subject { described_class.new(service).after_create }

      before do
        FactoryBot.create(:codec_group)
        stub_customer_post_request!
        stub_incoming_trunks_post_request!
        stub_gateway_post_request!
        stub_termination_route_post_request!
      end

      it 'should perform post request to create Customer on the Phone Systems server' do
        subject
        expect(stub_customer_post_request!).to have_been_requested
      end

      it 'should perform post request to create Incoming Trunk on the Phone Systems server' do
        subject
        expect(stub_incoming_trunks_post_request!).to have_been_requested
      end

      it 'should perform post request to create Gateway on the Phone Systems server' do
        subject
        expect(stub_gateway_post_request!).to have_been_requested
      end

      it 'should perform post request to create Termination Route on the Phone Systems server' do
        subject
        expect(stub_termination_route_post_request!).to have_been_requested
      end
    end
  end

  describe '#verify_service_variables!' do
    subject { described_class.new(service).verify_service_variables! }

    context 'with valid attributes' do
      it 'returns the service variables' do
        expect(subject).to eq(service.variables)
      end
    end

    context 'when attributes are partially provided' do
      let(:service_attrs) { { type: service_type, variables: { attributes: { name: 'Service name' } } } }

      it 'validates and returns the partial attributes' do
        expect(subject).to eq('attributes' => { 'name' => 'Service name' })
      end
    end

    context 'when attributes: { name: nil }' do
      let(:service_attrs) { { type: service_type, variables: { attributes: { name: nil } } } }
      let(:err_msg) { 'Validation error: attributes.name - must be a string' }

      it 'should raise error' do
        expect { subject }.to raise_error Billing::Provisioning::Errors::InvalidVariablesError, err_msg
      end
    end

    context 'when attributes: nil' do
      let(:service_attrs) { { type: service_type, variables: { attributes: nil } } }
      let(:err_msg) { 'Validation error: .attributes - must be a hash' }

      it 'should raise error' do
        expect { subject }.to raise_error Billing::Provisioning::Errors::InvalidVariablesError, err_msg
      end
    end

    context 'when attributes: ""' do
      let(:service_attrs) { { type: service_type, variables: { attributes: '' } } }
      let(:err_msg) { 'Validation error: .attributes - must be a hash' }

      it 'should raise error' do
        expect { subject }.to raise_error Billing::Provisioning::Errors::InvalidVariablesError, err_msg
      end
    end
  end

  describe '.verify_service_type_variables!' do
    subject { described_class.verify_service_type_variables!(service_type) }

    context 'with valid data' do
      let(:service_type_attrs) do
        super().deep_merge(variables: { attributes: { name: 'Test Service', language: 'EN', trm_mode: 'AUTO', capacity_limit: 100, sip_account_limit: 10 } })
      end

      it 'returns the service type variables' do
        expect(subject).to eq(service_type.variables)
      end
    end

    context 'when name attribute is provided only' do
      let(:service_type_attrs) { super().deep_merge(variables: { attributes: { name: 'Test Service' } }) }

      it 'validates and returns the service type variables' do
        expect(subject).to eq service_type.variables
      end
    end

    context 'when attributes: {}' do
      let(:service_type_attrs) { super().deep_merge variables: { attributes: {} } }
      let(:err_msg) { 'Validation error: .attributes - must be filled' }

      it 'should raise error' do
        expect { subject }.to raise_error Billing::Provisioning::Errors::InvalidVariablesError, err_msg
      end
    end

    context 'when attributes: { name: '' }' do
      let(:service_type_attrs) { super().deep_merge variables: { attributes: { name: '' } } }
      let(:err_msg) { 'Validation error: attributes.name - must be filled' }

      it 'should raise error' do
        expect { subject }.to raise_error Billing::Provisioning::Errors::InvalidVariablesError, err_msg
      end
    end

    context 'when attributes: { name: nil }' do
      let(:service_type_attrs) { super().deep_merge variables: { attributes: { name: nil } } }
      let(:err_msg) { 'Validation error: attributes.name - must be a string' }

      it 'should raise error' do
        expect { subject }.to raise_error Billing::Provisioning::Errors::InvalidVariablesError, err_msg
      end
    end

    context 'when attributes: nil' do
      let(:service_type_attrs) { super().deep_merge variables: { attributes: nil } }
      let(:err_msg) { 'Validation error: .attributes - must be a hash' }

      it 'should raise error' do
        expect { subject }.to raise_error Billing::Provisioning::Errors::InvalidVariablesError, err_msg
      end
    end

    context 'when attributes: ""' do
      let(:service_type_attrs) { super().deep_merge variables: { attributes: '' } }
      let(:err_msg) { 'Validation error: .attributes - must be a hash' }

      it 'should raise error' do
        expect { subject }.to raise_error Billing::Provisioning::Errors::InvalidVariablesError, err_msg
      end
    end
  end
end
