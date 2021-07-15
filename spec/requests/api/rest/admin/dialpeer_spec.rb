# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::DialpeersController do
  include_context :json_api_admin_helpers, type: :dialpeers

  describe 'GET /api/rest/admin/dialpeers' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:dialpeers) do
      FactoryBot.create_list(:dialpeer, 2)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        dialpeers.map { |r| r.id.to_s }
      end
    end
  end

  describe 'POST api/rest/admin/dialpeers' do
    include_context :init_routing_tag_collection
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:routing_group) { FactoryBot.create(:routing_group) }
    let(:vendor) { FactoryBot.create(:vendor) }
    let(:account) { FactoryBot.create(:account, contractor: vendor) }
    let(:routing_tag_mode) { Routing::RoutingTagMode.take! }
    let(:routeset_discriminator) { Routing::RoutesetDiscriminator.take || FactoryBot.create(:routeset_discriminator) }

    context 'without gateway_id and gateway_group_id' do
      let(:json_api_request_body) do
        {
          data: {
            type: json_api_resource_type,
            attributes: json_api_request_attributes,
            relationships: json_api_request_relationships
          }
        }
      end
      let(:json_api_request_attributes) do
        {
          'acd-limit': '0.01',
          'enabled': 'true',
          'prefix': '_test_',
          'asr-limit': '0.02',
          'next-rate': '0.01',
          'initial-rate': '0.01',
          'connect-fee': '0.01',
          'valid-from': '2020-02-02',
          'valid-till': '2020-02-02'

        }
      end
      let(:json_api_request_relationships) do
        {
          'routing-group': { data: { id: routing_group.id.to_s, type: 'routing_groups' } },
          'account': { data: { id: account.id.to_s, type: 'accounts' } },
          'routing-tag-mode': { data: { id: routing_tag_mode.id.to_s, type: 'routing_tag_modes' } },
          'routeset-discriminator': { data: { id: routeset_discriminator.id.to_s, type: 'routeset_discriminators' } },
          'vendor': { data: { id: vendor.id.to_s, type: 'contractors' } },
          'routing-tag-ids': { data: { id: [@tag_ua], type: 'routing_tags' } },
          'gateway': { data: { id: 0, type: 'gateways' } },
          'gateway-group': { data: { id: 0, type: 'gateway_groups' } }
        }
      end

      include_examples :returns_json_api_errors, status: 422, errors: [
        {
          detail: 'Specify a gateway_group or a gateway',
          title: 'Specify a gateway_group or a gateway',
          source: { pointer: '/data' }
        }
      ]
    end

    context 'without lcr-rate-multiplier' do
      let!(:gateway) { create :gateway, contractor: vendor }
      let(:json_api_request_body) do
        {
          data: {
            type: json_api_resource_type,
            attributes: json_api_request_attributes,
            relationships: json_api_request_relationships
          }
        }
      end
      let(:json_api_request_attributes) do
        {
          'acd-limit': '0.01',
          'enabled': 'true',
          'prefix': '_test_',
          'asr-limit': '0.02',
          'next-rate': '0.01',
          'initial-rate': '0.01',
          'connect-fee': '0.01',
          'valid-from': '2020-02-02',
          'valid-till': '2020-02-02',

          'lcr-rate-multiplier': ''

        }
      end
      let(:json_api_request_relationships) do
        {
          'routing-group': { data: { id: routing_group.id.to_s, type: 'routing_groups' } },
          'account': { data: { id: account.id.to_s, type: 'accounts' } },
          'routing-tag-mode': { data: { id: routing_tag_mode.id.to_s, type: 'routing_tag_modes' } },
          'routeset-discriminator': { data: { id: routeset_discriminator.id.to_s, type: 'routeset_discriminators' } },
          'vendor': { data: { id: vendor.id.to_s, type: 'contractors' } },
          'routing-tag-ids': { data: { id: [@tag_ua], type: 'routing_tags' } },
          'gateway': { data: { id: gateway.id, type: 'gateways' } }
        }
      end

      include_examples :returns_json_api_errors, errors: [
        { detail: "lcr-rate-multiplier - can't be blank" },
        { detail: 'lcr-rate-multiplier - is not a number' }
      ], status: 422
    end
  end
end
