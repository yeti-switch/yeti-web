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

    it_behaves_like :json_api_admin_check_authorization
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
    let(:gateway) { FactoryBot.create(:gateway, vendor: vendor) }

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
        'reverse-billing': 'true',
        'prefix': '_test_',
        'asr-limit': '0.02',
        'next-rate': '0.01',
        'initial-rate': '0.01',
        'connect-fee': '0.01',
        'valid-from': '2020-02-02',
        'valid-till': '2020-02-03',
        'routing-tag-ids': [tag_ua.id]
      }
    end
    let(:json_api_request_relationships) do
      {
        'routing-group': { data: { id: routing_group.id.to_s, type: 'routing_groups' } },
        'account': { data: { id: account.id.to_s, type: 'accounts' } },
        'routing-tag-mode': { data: { id: routing_tag_mode.id.to_s, type: 'routing_tag_modes' } },
        'routeset-discriminator': { data: { id: routeset_discriminator.id.to_s, type: 'routeset_discriminators' } },
        'vendor': { data: { id: vendor.id.to_s, type: 'contractors' } },
        'gateway': { data: { id: gateway.id.to_s, type: 'gateways' } }
      }
    end
    let(:last_dialpeer) { Dialpeer.last! }

    relationships = %i[
      routing-group
      account
      routing-tag-mode
      routeset-discriminator
      vendor
      dialpeer-next-rates
      gateway
      gateway-group
    ]
    include_examples :returns_json_api_record, relationships: relationships, status: 201 do
      let(:json_api_record_id) { last_dialpeer.id.to_s }
      let(:json_api_record_attributes) do
        {
          'acd-limit': 0.01,
          'asr-limit': 0.02,
          'connect-fee': '0.01',
          'created-at': last_dialpeer.created_at.iso8601(3),
          'dst-number-max-length': 100,
          'dst-number-min-length': 0,
          'dst-rewrite-result': nil,
          'dst-rewrite-rule': nil,
          'exclusive-route': false,
          'external-id': nil,
          'force-hit-rate': nil,
          'initial-interval': 1,
          'initial-rate': '0.01',
          'lcr-rate-multiplier': '1.0',
          'network-prefix-id': nil,
          'next-interval': 1,
          'next-rate': '0.01',
          'routing-tag-ids': [tag_ua.id],
          'short-calls-limit': 1.0,
          'src-rewrite-result': nil,
          'src-rewrite-rule': nil,
          'valid-from': Time.parse('2020-02-02').in_time_zone.iso8601(3),
          'valid-till': Time.parse('2020-02-03').in_time_zone.iso8601(3),
          capacity: nil,
          enabled: true,
          'reverse-billing': true,
          locked: false,
          prefix: '_test_',
          priority: 100
        }
      end
    end

    include_examples :changes_records_qty_of, Dialpeer, by: 1

    it_behaves_like :json_api_admin_check_authorization, status: 201

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
          'reverse-billing': 'true',
          'prefix': '_test_',
          'asr-limit': '0.02',
          'next-rate': '0.01',
          'initial-rate': '0.01',
          'connect-fee': '0.01',
          'valid-from': '2020-02-02',
          'valid-till': '2020-02-03'

        }
      end
      let(:json_api_request_relationships) do
        {
          'routing-group': { data: { id: routing_group.id.to_s, type: 'routing_groups' } },
          'account': { data: { id: account.id.to_s, type: 'accounts' } },
          'routing-tag-mode': { data: { id: routing_tag_mode.id.to_s, type: 'routing_tag_modes' } },
          'routeset-discriminator': { data: { id: routeset_discriminator.id.to_s, type: 'routeset_discriminators' } },
          'vendor': { data: { id: vendor.id.to_s, type: 'contractors' } },
          'routing-tag-ids': { data: { id: [tag_ua], type: 'routing_tags' } },
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
          'reverse-billing': true,
          'prefix': '_test_',
          'asr-limit': '0.02',
          'next-rate': '0.01',
          'initial-rate': '0.01',
          'connect-fee': '0.01',
          'valid-from': '2020-02-02',
          'valid-till': '2020-02-03',

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
          'routing-tag-ids': { data: { id: [tag_ua], type: 'routing_tags' } },
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
