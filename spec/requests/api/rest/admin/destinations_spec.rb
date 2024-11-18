# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::DestinationsController, type: :request do
  include_context :json_api_admin_helpers, type: :destinations

  describe 'GET /api/rest/admin/destinations' do
    subject do
      get json_api_request_path, params: index_params, headers: json_api_request_headers
    end
    let(:index_params) { {} }

    let!(:destinations) do
      [
        FactoryBot.create(:destination, prefix: '370614', rate_group:, routing_tag_ids: []),
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
      include_examples :responds_with_status, 200

      context 'destinations[0]' do
        include_examples :returns_json_api_record, type: 'destinations', relationships: %i[country network destination-next-rates rate-group routing-tag-mode] do
          let(:json_api_record_data) { json_api_data_detect_by_id_type }
          let(:json_api_record_id) { destinations[0].id.to_s }
          let(:json_api_record_attributes) do
            {
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
            }
          end
        end
        it_behaves_like :returns_json_api_record_relationship, :'destination-next-rates' do
          let(:json_api_record_data) { json_api_data_detect_by_id_type }
          let(:json_api_relationship_data) { [id: next_rate.id.to_s, type: 'destination-next-rates'] }
        end
        it_behaves_like :returns_json_api_record_relationship, :country do
          let(:json_api_record_data) { json_api_data_detect_by_id_type }
          let(:json_api_relationship_data) { { id: network_prefix.country.id.to_s, type: 'countries' } }
        end
        it_behaves_like :returns_json_api_record_relationship, :network do
          let(:json_api_record_data) { json_api_data_detect_by_id_type }
          let(:json_api_relationship_data) { { id: network_prefix.network.id.to_s, type: 'networks' } }
        end
      end

      context 'destinations[1]' do
        include_examples :returns_json_api_record, type: 'destinations', relationships: %i[country network destination-next-rates rate-group routing-tag-mode] do
          let(:json_api_record_data) { json_api_data_detect_by_id_type }
          let(:json_api_record_id) { destinations[1].id.to_s }
          let(:json_api_record_attributes) do
            {
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
            }
          end
        end
        it_behaves_like :returns_json_api_record_relationship, :'destination-next-rates' do
          let(:json_api_record_data) { json_api_data_detect_by_id_type }
          let(:json_api_relationship_data) { [] }
        end
        it_behaves_like :returns_json_api_record_relationship, :country do
          let(:json_api_record_data) { json_api_data_detect_by_id_type }
          let(:json_api_relationship_data) { nil }
        end
        it_behaves_like :returns_json_api_record_relationship, :network do
          let(:json_api_record_data) { json_api_data_detect_by_id_type }
          let(:json_api_relationship_data) { nil }
        end
      end

      it_behaves_like :returns_json_api_record_include, type: :'destination-next-rates' do
        let(:json_api_include_id) { next_rate.id.to_s }
        let(:json_api_include_attributes) do
          {
            applied: next_rate.applied,
            'apply-time': next_rate.apply_time.iso8601(3),
            'connect-fee': next_rate.connect_fee.to_s,
            'external-id': next_rate.external_id,
            'initial-interval': next_rate.initial_interval,
            'initial-rate': next_rate.initial_rate.to_s,
            'next-interval': next_rate.next_interval,
            'next-rate': next_rate.next_rate.to_s
          }
        end
      end

      it_behaves_like :returns_json_api_record_include, type: :countries do
        let(:json_api_include_id) { network_prefix.country.id.to_s }
        let(:json_api_include_attributes) do
          { name: network_prefix.country.name, iso2: network_prefix.country.iso2 }
        end
      end

      it_behaves_like :returns_json_api_record_include, type: :networks do
        let(:json_api_include_id) { network_prefix.network.id.to_s }
        let(:json_api_include_attributes) { { name: network_prefix.network.name } }
      end

      it 'should return correct response' do
        subject

        expect(response_json[:meta]).to match('total-count': destinations.size)
        expect(response_json[:included].size).to eq(3)
      end
    end
  end
end
