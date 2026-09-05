# frozen_string_literal: true

RSpec.describe Billing::Provisioning::PhoneSystems::GatewayService do
  let(:telecom_center_api_host) { 'https://api.telecom.center' }
  let(:telecom_center_api_endpoint) { "#{telecom_center_api_host}/api/rest/public/operator/termination_gateways" }
  let(:service_type_attrs) { { variables: { endpoint: telecom_center_api_host, username: 'user', password: 'pass' } } }
  let(:service_type) { FactoryBot.create(:service_type, service_type_attrs) }
  let(:ps_trm_gw) do
    {
      host: 'sip.yeti-switch.org',
      port: 5060,
      codecs: %w[telephone-event]
    }
  end
  let(:service_attrs) do
    {
      type: service_type,
      uuid: SecureRandom.uuid,
      variables: { ps_trm_gw: ps_trm_gw }
    }
  end
  let(:service) { FactoryBot.create(:service, service_attrs) }
  let(:auth_header) { 'Basic dXNlcjpwYXNz' }
  let(:generated_username) { 'generatedAuthUsername' }
  let(:generated_password) { 'generatedAuthPassword' }

  before do
    WebMock.reset!
    allow(SecureRandom).to receive(:alphanumeric).and_call_original
    allow(SecureRandom).to receive(:alphanumeric).with(described_class::AUTH_CREDENTIAL_LENGTH)
                                                 .and_return(generated_username, generated_password)
  end

  describe '#create_remote_gateway' do
    subject { described_class.new(service, response).create_remote_gateway }

    let(:response) { { 'data' => { 'id' => SecureRandom.uuid, type: 'incoming_trunks' } } }
    let(:expected_attributes) do
      ps_trm_gw.merge(
        name: "gw-#{service.uuid}",
        authorization_name: generated_username,
        authorization_password: generated_password
      )
    end

    context 'when gateway creation is successful' do
      before do
        WebMock
          .stub_request(:post, telecom_center_api_endpoint)
          .with(
            body: {
              data: {
                type: 'termination_gateways',
                attributes: expected_attributes,
                relationships: {
                  customer: {
                    data: {
                      type: 'customers',
                      id: service.id
                    }
                  }
                }
              }
            }.to_json,
            headers: {
              'Authorization' => auth_header,
              'Content-Type' => 'application/vnd.api+json'
            }
          )
          .to_return(status: 200, body: { data: { id: 123, type: 'termination_gateways' } }.to_json)
      end

      it 'sends a POST request to create the Gateway' do
        subject
        expect(WebMock).to have_requested(:post, telecom_center_api_endpoint).once
      end
    end

    context 'when ps_trm_gw defines the credentials' do
      let(:ps_trm_gw) { super().merge(authorization_name: 'acme_ltd', authorization_password: 'secret_password') }
      let(:expected_attributes) { ps_trm_gw.merge(name: "gw-#{service.uuid}") }

      before do
        WebMock
          .stub_request(:post, telecom_center_api_endpoint)
          .with(body: hash_including(data: hash_including(attributes: expected_attributes.as_json)))
          .to_return(status: 200, body: { data: { id: 123, type: 'termination_gateways' } }.to_json)
      end

      it 'sends them unchanged instead of generating a pair' do
        subject
        expect(WebMock).to have_requested(:post, telecom_center_api_endpoint).once
      end
    end

    context 'when ps_trm_gw is not defined at all' do
      let(:service_attrs) { super().merge(variables: {}) }

      before do
        WebMock.stub_request(:post, telecom_center_api_endpoint)
      end

      it 'does not create a termination gateway on the phone.systems side' do
        subject
        expect(WebMock).not_to have_requested(:post, telecom_center_api_endpoint)
      end

      it 'returns nil so that the termination route is skipped' do
        expect(subject).to be_nil
      end
    end

    context 'when gateway creation fails with a validation error' do
      let(:error_body) { { errors: [{ title: 'Some validation error!', detail: 'Some validation error!' }] } }

      before do
        WebMock.stub_request(:post, telecom_center_api_endpoint).to_return(status: 422, body: error_body.to_json)
      end

      it 'raises a validation error' do
        expect { subject }.to raise_error(Billing::Provisioning::Errors::Error, 'Some validation error!')
      end
    end

    context 'when customer creation fails with a server error' do
      before do
        WebMock.stub_request(:post, telecom_center_api_endpoint).to_return(status: 500, body: nil)
      end

      it 'raises an unknown error' do
        expect { subject }.to raise_error(Billing::Provisioning::Errors::Error, 'Unknown error')
      end
    end
  end

  describe '#create_yeti_gateway!' do
    subject { gateway_service.create_yeti_gateway! }

    let(:domain) { 'trunk-domain.telecom.center' }
    let(:response) { { 'data' => { 'attributes' => { 'domain' => domain } } } }
    let(:gateway_service) { described_class.new(service, response) }

    let!(:codec_group) { FactoryBot.create(:codec_group) }

    let(:created_gateway) { Gateway.find_by(name: "ps-#{service.id}") }

    it 'creates the Yeti gateway with the generated incoming auth credentials' do
      expect { subject }.to change { Gateway.where(name: "ps-#{service.id}").count }.by(1)

      expect(created_gateway).to have_attributes(
        host: domain,
        enabled: true,
        contractor_id: service.account.contractor_id,
        incoming_auth_username: generated_username,
        incoming_auth_password: generated_password
      )
    end

    context 'when ps_trm_gw defines the credentials' do
      let(:ps_trm_gw) { super().merge(authorization_name: 'acme_ltd', authorization_password: 'secret_password') }

      it 'uses them as the incoming auth credentials' do
        subject

        expect(created_gateway).to have_attributes(
          incoming_auth_username: 'acme_ltd',
          incoming_auth_password: 'secret_password'
        )
      end
    end

    context 'when ps_trm_gw is not defined at all' do
      let(:service_attrs) { super().merge(variables: {}) }

      it 'still creates the gateway but leaves the incoming auth empty' do
        expect { subject }.to change { Gateway.where(name: "ps-#{service.id}").count }.by(1)

        expect(created_gateway).to have_attributes(
          host: domain,
          incoming_auth_username: nil,
          incoming_auth_password: nil
        )
      end
    end

    context 'when the remote gateway was created first' do
      before do
        WebMock
          .stub_request(:post, telecom_center_api_endpoint)
          .to_return(status: 200, body: { data: { id: 123, type: 'termination_gateways' } }.to_json)
        gateway_service.create_remote_gateway
      end

      it 'reuses the very same credentials that were sent to phone.systems' do
        subject

        expect(WebMock).to have_requested(:post, telecom_center_api_endpoint).with { |request|
          attributes = JSON.parse(request.body).dig('data', 'attributes')

          attributes['authorization_name'] == created_gateway.incoming_auth_username &&
            attributes['authorization_password'] == created_gateway.incoming_auth_password
        }
      end
    end
  end
end
