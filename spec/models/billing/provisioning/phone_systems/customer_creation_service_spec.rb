# frozen_string_literal: true

RSpec.describe Billing::Provisioning::PhoneSystems::CustomerCreationService do
  let(:telecom_center_api_host) { 'https://api.telecom.center' }
  let(:telecom_center_api_endpoint) { "#{telecom_center_api_host}/api/rest/public/operator/customers" }
  let(:service_type_attrs) { { variables: { endpoint: telecom_center_api_host, username: 'user', password: 'pass' } } }
  let(:service_type) { FactoryBot.create(:service_type, service_type_attrs) }
  let(:service_attrs) do
    {
      type: service_type,
      variables: {
        attributes: {
          name: 'Test Service', language: 'EN', trm_mode: 'AUTO', capacity_limit: 100, sip_account_limit: 10
        }
      }
    }
  end
  let(:service) { FactoryBot.create(:service, service_attrs) }
  let(:auth_header) { 'Basic dXNlcjpwYXNz' }

  before do
    allow(service).to receive(:update)
    WebMock.reset!
  end

  describe '#create_customer' do
    subject { described_class.new(service).create_customer }

    context 'when customer creation is successful' do
      before do
        WebMock
          .stub_request(:post, telecom_center_api_endpoint)
          .with(
            body: { data: { id: service.id, type: 'customers', attributes: service.variables['attributes'] } }.to_json,
            headers: {
              'Authorization' => auth_header,
              'Content-Type' => 'application/vnd.api+json'
            }
          )
          .to_return(status: 200, body: { data: { id: 123, type: 'customers' } }.to_json)
      end

      it 'sends a POST request to create the customer' do
        subject
        expect(WebMock).to have_requested(:post, telecom_center_api_endpoint).once
        expect(service).to have_received(:update).with(id: 123)
      end
    end

    context 'when customer creation fails with a validation error' do
      let(:error_body) { { errors: [{ title: 'Language not found!', detail: 'Language not found!' }] } }

      before do
        WebMock
          .stub_request(:post, telecom_center_api_endpoint)
          .to_return(status: 422, body: error_body.to_json)
      end

      it 'raises a validation error' do
        expect { subject }.to raise_error(Billing::Provisioning::Errors::Error, 'Language not found!')
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

  describe '#delete_customer' do
    subject { described_class.new(service).delete_customer }

    context 'when customer deletion is successful' do
      before do
        WebMock.stub_request(:delete, "#{telecom_center_api_endpoint}/#{service.id}").to_return(status: 204)
      end

      it 'sends a DELETE request to delete the customer' do
        subject
        expect(WebMock).to have_requested(:delete, "#{telecom_center_api_endpoint}/#{service.id}").once
      end
    end

    context 'when customer deletion fails' do
      let(:error_body) { { errors: [{ title: 'Validation error', detail: 'Validation error' }] } }

      before do
        WebMock
          .stub_request(:delete, "#{telecom_center_api_endpoint}/#{service.id}")
          .to_return(status: 422, body: error_body.to_json)
      end

      it 'raises a validation error' do
        expect { subject }.to raise_error(Billing::Provisioning::Errors::Error)
      end
    end

    context 'when customer not found' do
      let(:error_body) do
        {
          errors: [{ title: 'Record not found', detail: "The record identified by #{service.id} could not be found." }]
        }
      end

      before do
        WebMock
          .stub_request(:delete, "#{telecom_center_api_endpoint}/#{service.id}")
          .to_return(status: 404, body: error_body.to_json)
      end

      it 'raises a validation error' do
        expect { subject }.to raise_error(Billing::Provisioning::PhoneSystems::PhoneSystemsApiClient::NotFoundError)
      end
    end
  end
end
