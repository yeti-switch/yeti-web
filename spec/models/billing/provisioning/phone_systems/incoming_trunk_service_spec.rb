# frozen_string_literal: true

RSpec.describe Billing::Provisioning::PhoneSystems::IncomingTrunkService do
  let(:telecom_center_api_host) { 'https://api.telecom.center' }
  let(:telecom_center_api_endpoint) { "#{telecom_center_api_host}/api/rest/public/operator/incoming_trunks" }
  let(:service_type_attrs) { { variables: { endpoint: telecom_center_api_host, username: 'user', password: 'pass' } } }
  let(:service_type) { FactoryBot.create(:service_type, service_type_attrs) }
  let(:random_uuid) { SecureRandom.uuid }
  let(:generate_trunk_name) { "gw-#{random_uuid}" }
  let(:service_attrs) do
    {
      type: service_type,
      uuid: random_uuid,
      variables: {
        ps_incoming_trunk: {
          transport_protocol: 'UDP',
          codecs: %w[g729 G722 PCMU OPUS telephone-event],
          destination_field: 'RURI_USERPART'
        }
      }
    }
  end
  let(:service) { FactoryBot.create(:service, service_attrs) }
  # TODO remove or use
  let(:response_body_from_telecom_center) do
    {
      data: {
        id: 123,
        type: 'incoming_trunks',
        attributes: {
          transport_protocol: 'UDP',
          codecs: %w[g729 G722 PCMU OPUS telephone-event],
          destination_field: 'RURI_USERPART'
        }
      }
    }
  end
  let(:auth_header) { 'Basic dXNlcjpwYXNz' }

  before do
    allow(service).to receive(:update)
    WebMock.reset!
  end

  describe '#create_trunk' do
    subject { described_class.new(service).create_trunk }

    context 'when trunk creation is successful' do
      before do
        WebMock
          .stub_request(:post, telecom_center_api_endpoint)
          .with(
            body: {
              data: {
                type: 'incoming_trunks',
                attributes: service.variables['ps_incoming_trunk'].merge(name: generate_trunk_name)
              }
            }.to_json,
            headers: {
              'Authorization' => auth_header,
              'Content-Type' => 'application/vnd.api+json'
            }
          )
          .to_return(status: 200, body: { data: { id: 123, type: 'incoming_trunks' } }.to_json)
      end

      it 'sends a POST request to create the trunk' do
        subject
        expect(WebMock).to have_requested(:post, telecom_center_api_endpoint).once
      end
    end

    context 'when customer creation fails with a validation error' do
      let(:error_body) { { errors: [{ title: 'Some validation error!', detail: 'Some validation error!' }] } }

      before do
        WebMock
          .stub_request(:post, telecom_center_api_endpoint)
          .to_return(status: 422, body: error_body.to_json)
      end

      it 'raises a validation error' do
        expect { subject }.to raise_error(Billing::Provisioning::Errors::Error, 'Some validation error!')
      end
    end

    context 'when customer creation fails with a server error' do
      before do
        WebMock
          .stub_request(:post, telecom_center_api_endpoint)
          .to_return(status: 500, body: nil)
      end

      it 'raises an unknown error' do
        expect { subject }.to raise_error(Billing::Provisioning::Errors::Error, 'Unknown error')
      end
    end
  end
end
