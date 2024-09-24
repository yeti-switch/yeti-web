# frozen_string_literal: true

RSpec.describe Billing::Provisioning::PhoneSystems::GatewayService do
  let(:telecom_center_api_host) { 'https://api.telecom.center' }
  let(:telecom_center_api_endpoint) { "#{telecom_center_api_host}/api/rest/public/operator/termination_gateways" }
  let(:service_type_attrs) { { variables: { endpoint: telecom_center_api_host, username: 'user', password: 'pass' } } }
  let(:service_type) { FactoryBot.create(:service_type, service_type_attrs) }
  let(:service_attrs) do
    {
      type: service_type,
      uuid: SecureRandom.uuid,
      variables: {
        ps_trm_gw: {
          host: 'sip.yeti-switch.org',
          port: 5060,
          codecs: %w[telephone-event]
        }
      }
    }
  end
  let(:service) { FactoryBot.create(:service, service_attrs) }
  let(:auth_header) { 'Basic dXNlcjpwYXNz' }

  before do
    WebMock.reset!
  end

  describe '#create_remote_gateway' do
    subject { described_class.new(service, response).create_remote_gateway }

    let(:response) { { 'data' => { 'id' => SecureRandom.uuid, type: 'incoming_trunks' } } }

    context 'when gateway creation is successful' do
      before do
        WebMock
          .stub_request(:post, telecom_center_api_endpoint)
          .with(
            body: {
              data: {
                type: 'termination_gateways',
                attributes: service.variables.fetch('ps_trm_gw').merge(name: "gw-#{service.uuid}"),
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
end
