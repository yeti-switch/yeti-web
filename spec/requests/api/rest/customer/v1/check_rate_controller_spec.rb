# frozen_string_literal: true

require 'spec_helper'

describe Api::Rest::Customer::V1::CheckRateController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :check_rates
  let(:json_api_request_path) { "#{json_api_request_path_prefix}/check-rate" }
  let(:account) { create(:account, contractor: customer) }

  before do
    @r1 = create :destination, rateplan: rateplan, prefix: '444', routing_tag_ids: [create(:routing_tag, :ua).id, create(:routing_tag, :us).id]
    @r2 = create :destination, rateplan: rateplan, prefix: '4444', routing_tag_ids: [create(:routing_tag, :emergency).id]
    create :destination, rateplan: rateplan, prefix: '3333' # out of range
  end

  describe 'POST /api/rest/customer/v1/check-rate' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_attributes) do
      { 'rateplan-id': rateplan.uuid, number: '444444444' }
    end

    let(:rateplan) { create(:rateplan).reload }

    it_behaves_like :json_api_check_authorization

    context 'success' do
      it 'returns two plans' do
        subject
        expect(response.status).to eq(201)
        expect(response_json[:data]).to a_hash_including(
          'id': anything,
          'type': json_api_resource_type,
          'attributes': a_hash_including(
            'rateplan-id': rateplan.uuid,
            'number': json_api_request_attributes[:number],
            'rates': match_array(
              [
                a_hash_including(
                  'id': @r1.reload.uuid,
                  'prefix': @r1.prefix,
                  'initial_rate': @r1.initial_rate.as_json,
                  'initial_interval': @r1.initial_interval,
                  'next_rate': @r1.next_rate.as_json,
                  'next_interval': @r1.next_interval,
                  'connect_fee': @r1.connect_fee.as_json,
                  'reject_calls': @r1.reject_calls,
                  'valid_from': @r1.valid_from.iso8601(3),
                  'valid_till': @r1.valid_till.iso8601(3),
                  'network_prefix_id': @r1.network_prefix_id,
                  'routing_tag_names': @r1.routing_tags.map(&:name)
                ),
                a_hash_including('id': @r2.reload.uuid)
              ]
            )
          )
        )
      end
    end

    context 'when Rateplan not exists' do
      let(:json_api_request_attributes) { super().merge 'rateplan-id': '12123123' }

      include_examples :returns_json_api_errors, errors: {
        detail: 'rateplan-id - Rateplan not found'
      }
    end

    context 'when proper rate not found for this number' do
      let(:json_api_request_attributes) { super().merge number: '8888888888' }

      it 'return empty rates array' do
        subject
        expect(response.status).to eq(201)
        expect(response_json[:data]).to a_hash_including(
          'id': anything,
          'type': json_api_resource_type,
          'attributes': a_hash_including(
            'rateplan-id': rateplan.uuid,
            'number': json_api_request_attributes[:number],
            'rates': []
          )
        )
      end
    end
  end
end
