# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Routing::DestinationsController, type: :request do
  include_context :json_api_admin_helpers, type: :destinations, prefix: 'routing'

  describe 'GET /api/rest/admin/routing/destinations' do
    subject do
      get json_api_request_path, params: index_params, headers: json_api_request_headers
    end
    let(:index_params) { {} }

    let!(:destinations) do
      [
        FactoryBot.create(:destination, prefix: '12345', rate_group:, routing_tag_ids: []),
        FactoryBot.create(:destination, rate_group:, routing_tag_ids: [routing_tag.id, nil])
      ]
    end
    let!(:rate_group) { FactoryBot.create(:rate_group, rateplans:) }
    let!(:rateplans) { FactoryBot.create_list(:rateplan, 2) }
    let!(:routing_tag) { FactoryBot.create(:routing_tag) }

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        destinations.map { |r| r.id.to_s }
      end
    end

    it_behaves_like :json_api_admin_check_authorization

    context 'with included country, next_rate and network' do
      let(:index_params) do
        {
          filter: {
            rateplan_id_eq: rateplans[0].id
          },
          include: 'destination-next-rates,country,network',
          page: {
            number: 1,
            size: 1000
          }
        }
      end
      let!(:next_rate) do
        FactoryBot.create(:destination_next_rate, destination: destinations.first)
      end
      let(:network_prefix) { destinations[0].network_prefix }

      before do
        # not affected destinations
        another_plan = FactoryBot.create(:rateplan)
        another_group = FactoryBot.create(:rate_group, rateplans: [rateplans[1], another_plan])
        FactoryBot.create_list(:destination, 2, rate_group: another_group)
      end

      include_examples :jsonapi_responds_with_pagination_links

      it 'should return correct response' do
        subject

        expect(response.status).to eq(200)
        expect(response_json).to match(
                                   hash_including(
                                     data: match_array(
                                       [
                                         hash_including(
                                           id: destinations[0].id.to_s,
                                           type: 'destinations',
                                           attributes: {
                                             'acd-limit': destinations[0].acd_limit,
                                             'asr-limit': destinations[0].asr_limit,
                                             'connect-fee': destinations[0].connect_fee.to_s,
                                             'dp-margin-fixed': destinations[0].dp_margin_fixed.to_s,
                                             'dp-margin-percent': destinations[0].dp_margin_percent.to_s,
                                             'dst-number-max-length': destinations[0].dst_number_max_length,
                                             'dst-number-min-length': destinations[0].dst_number_min_length,
                                             enabled: destinations[0].enabled,
                                             'external-id': destinations[0].external_id,
                                             'initial-interval': destinations[0].initial_interval,
                                             'initial-rate': destinations[0].initial_rate.to_s,
                                             'next-interval': destinations[0].next_interval,
                                             'next-rate': destinations[0].next_rate.to_s,
                                             prefix: destinations[0].prefix,
                                             'profit-control-mode-id': destinations[0].profit_control_mode_id,
                                             'rate-policy-id': destinations[0].rate_policy_id,
                                             'reject-calls': destinations[0].reject_calls,
                                             'reverse-billing': destinations[0].reverse_billing,
                                             'routing-tag-ids': destinations[0].routing_tag_ids,
                                             'short-calls-limit': destinations[0].short_calls_limit,
                                             'use-dp-intervals': destinations[0].use_dp_intervals,
                                             'valid-from': destinations[0].valid_from.iso8601(3),
                                             'valid-till': destinations[0].valid_till.iso8601(3)
                                           },
                                           relationships: hash_including(
                                             'destination-next-rates': {
                                               :data => [{ :id => next_rate.id.to_s, :type => 'destination-next-rates' }]
                                             },
                                             country: {
                                               :data => { :id => network_prefix.country.id.to_s, :type => 'countries' },
                                               links: be_present
                                             },
                                             network: {
                                               :data => { id: network_prefix.network.id.to_s, type: 'networks' },
                                               links: be_present
                                             }
                                           )
                                         ),
                                         hash_including(
                                           id: destinations[1].id.to_s,
                                           type: 'destinations',
                                           attributes: {
                                             'acd-limit': destinations[1].acd_limit,
                                             'asr-limit': destinations[1].asr_limit,
                                             'connect-fee': destinations[1].connect_fee.to_s,
                                             'dp-margin-fixed': destinations[1].dp_margin_fixed.to_s,
                                             'dp-margin-percent': destinations[1].dp_margin_percent.to_s,
                                             'dst-number-max-length': destinations[1].dst_number_max_length,
                                             'dst-number-min-length': destinations[1].dst_number_min_length,
                                             enabled: destinations[1].enabled,
                                             'external-id': destinations[1].external_id,
                                             'initial-interval': destinations[1].initial_interval,
                                             'initial-rate': destinations[1].initial_rate.to_s,
                                             'next-interval': destinations[1].next_interval,
                                             'next-rate': destinations[1].next_rate.to_s,
                                             prefix: destinations[1].prefix,
                                             'profit-control-mode-id': destinations[1].profit_control_mode_id,
                                             'rate-policy-id': destinations[1].rate_policy_id,
                                             'reject-calls': destinations[1].reject_calls,
                                             'reverse-billing': destinations[1].reverse_billing,
                                             'routing-tag-ids': destinations[1].routing_tag_ids,
                                             'short-calls-limit': destinations[1].short_calls_limit,
                                             'use-dp-intervals': destinations[1].use_dp_intervals,
                                             'valid-from': destinations[1].valid_from.iso8601(3),
                                             'valid-till': destinations[1].valid_till.iso8601(3)
                                           },
                                           relationships: hash_including(
                                             'destination-next-rates': { :data => [] },
                                             country: { :data => nil, links: be_present },
                                             network: { :data => nil, links: be_present }
                                           )
                                         )
                                       ]
                                     ),
                                     included: match_array(
                                       [
                                         hash_including(
                                            id: next_rate.id.to_s,
                                            type: 'destination-next-rates',
                                            attributes: {
                                              applied: next_rate.applied,
                                              'apply-time': next_rate.apply_time.iso8601(3),
                                              'connect-fee': next_rate.connect_fee.to_s,
                                              'external-id': next_rate.external_id,
                                              'initial-interval': next_rate.initial_interval,
                                              'initial-rate': next_rate.initial_rate.to_s,
                                              'next-interval': next_rate.next_interval,
                                              'next-rate': next_rate.next_rate.to_s
                                            }
                                          ),
                                         hash_including(
                                           id: network_prefix.country.id.to_s,
                                           type: 'countries',
                                           attributes: {
                                             name: network_prefix.country.name,
                                             iso2: network_prefix.country.iso2
                                           }
                                         ),
                                         hash_including(
                                            id: network_prefix.network.id.to_s,
                                            type: 'networks',
                                            attributes: {
                                              name: network_prefix.network.name
                                            }
                                          )
                                       ]
                                     ),
                                     meta: { 'total-count': destinations.size }
                                   )
                                 )
      end
    end
  end
end
