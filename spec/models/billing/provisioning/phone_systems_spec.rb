# frozen_string_literal: true

RSpec.describe Billing::Provisioning::PhoneSystems, type: :model do
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
  let(:response_body_from_telecom_center) do
    {
      data: {
        id: 123,
        type: 'customers',
        attributes: {
          name: 'Test Service',
          language: 'EN',
          trm_mode: 'AUTO',
          capacity_limit: 100,
          sip_account_limit: 10
        }
      }
    }
  end
  let(:auth_header) { 'Basic dXNlcjpwYXNz' }

  before do
    allow(service).to receive(:update)
    WebMock.reset!
  end

  describe '#after_create' do
    subject { described_class.new(service).after_create }

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
          .to_return(status: 200, body: { data: { id: 123 } }.to_json)
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

  describe '#before_destroy' do
    subject { described_class.new(service).before_destroy }

    context 'when customer deletion is successful' do
      before do
        WebMock
          .stub_request(:delete, "#{telecom_center_api_endpoint}/#{service.id}")
          .to_return(status: 204)
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
