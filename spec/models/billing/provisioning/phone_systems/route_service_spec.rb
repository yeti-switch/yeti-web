# frozen_string_literal: true

RSpec.describe Billing::Provisioning::PhoneSystems::RouteService do
  let(:telecom_center_api_host) { 'https://api.telecom.center' }
  let(:telecom_center_api_endpoint) { "#{telecom_center_api_host}/api/rest/public/operator/termination_routes" }
  let(:service_type_attrs) { { variables: { endpoint: telecom_center_api_host, username: 'user', password: 'pass' } } }
  let(:service_type) { FactoryBot.create(:service_type, service_type_attrs) }
  let(:random_uuid) { SecureRandom.uuid }
  let(:generate_route_name) { "gw-#{random_uuid}" }
  let(:service_attrs) do
    {
      type: service_type,
      uuid: random_uuid,
      variables: {}
    }
  end
  let(:service) { FactoryBot.create(:service, service_attrs) }
  let(:response_body_from_telecom_center) do
    {
      data: {
        id: SecureRandom.uuid,
        type: 'termination_routes',
        attributes: {
          name: 'route name',
          src_prefix: 'string',
          dst_prefix: 'string',
          src_rewrite_rule: '',
          src_rewrite_result: '',
          dst_rewrite_rule: '',
          dst_rewrite_result: '',
          operator: true
        }
      }
    }
  end
  let(:auth_header) { 'Basic dXNlcjpwYXNz' }

  before do
    WebMock.reset!
  end

  describe '#create_route' do
    subject { described_class.new(service, response_from_previous_post_request).create_route }

    let(:response_from_previous_post_request) do
      {
        'data' => {
          'id' => SecureRandom.uuid,
          'type' => 'termination_gateway'
        }
      }
    end

    context 'when route creation is successful' do
      before do
        allow_any_instance_of(described_class).to receive(:generate_name).and_return(generate_route_name)
        WebMock
          .stub_request(:post, telecom_center_api_endpoint)
          .with(
            body: {
              data: {
                type: 'termination_routes',
                attributes: { name: generate_route_name },
                relationships: {
                  gateway: {
                    data: {
                      type: 'termination_gateways',
                      id: response_from_previous_post_request.dig('data', 'id')
                    }
                  },
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
          .to_return(status: 200, body: { data: { id: 123, type: 'termination_routes' } }.to_json)
      end

      it 'sends a POST request to create the Termination Route' do
        subject
        expect(WebMock).to have_requested(:post, telecom_center_api_endpoint).once
      end
    end

    context 'when route creation fails with a validation error' do
      let(:error_body) { { errors: [{ title: 'Some validation error!', detail: 'Some validation error!' }] } }

      before do
        WebMock.stub_request(:post, telecom_center_api_endpoint).to_return(status: 422, body: error_body.to_json)
      end

      it 'raises a validation error' do
        expect { subject }.to raise_error(Billing::Provisioning::Errors::Error, 'Some validation error!')
      end
    end

    context 'when route creation fails with a server error' do
      before do
        WebMock.stub_request(:post, telecom_center_api_endpoint).to_return(status: 500, body: nil)
      end

      it 'raises an unknown error' do
        expect { subject }.to raise_error(Billing::Provisioning::Errors::Error, 'Unknown error')
      end
    end
  end
end
