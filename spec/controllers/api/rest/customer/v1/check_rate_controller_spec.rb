require 'spec_helper'

describe Api::Rest::Customer::V1::CheckRateController, type: :controller do

  let(:api_access) { create(:api_access) }
  let(:customer) { api_access.customer }
  let(:account) { create(:account, contractor: customer) }

  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: api_access.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  before do
    @r1 = create :destination, rateplan: rateplan, prefix: '444', routing_tag: create(:routing_tag)
    @r2 = create :destination, rateplan: rateplan, prefix: '4444', routing_tag: create(:routing_tag)
    create :destination, rateplan: rateplan, prefix: '3333' # out of range
  end

  before do
    post :create, data: { type: 'check-rates',
                          attributes: attributes }
  end

  let(:attributes) do
    { 'rateplan-id': rateplan.uuid, number: number }
  end

  let(:number) { '444444444' }
  let(:rateplan) { create(:rateplan).reload }

  context 'success' do
    it 'returns two plans' do
      expect(response_data).to a_hash_including(
        'id' => anything,
        'type' => 'check-rates',
        'attributes' => a_hash_including(
          'rateplan-id' => rateplan.uuid,
          'number' => number,
          'rates' => match_array(
            [
              a_hash_including(
                'id' => @r1.reload.uuid,
                'prefix' => @r1.prefix,
                'initial_rate' => @r1.initial_rate.as_json,
                'initial_interval' => @r1.initial_interval,
                'next_rate' => @r1.next_rate.as_json,
                'next_interval' => @r1.next_interval,
                'connect_fee' => @r1.connect_fee.as_json,
                'reject_calls' => @r1.reject_calls,
                'valid_from' => @r1.valid_from.to_s,
                'valid_till' => @r1.valid_till.to_s,
                'network_prefix_id' => @r1.network_prefix_id,
                'routing_tag_name' => @r1.routing_tag.name
              ),
              a_hash_including('id' => @r2.reload.uuid)
            ]
          )
        )
      )
    end
  end

  context 'when Rateplan not exists' do
    let(:attributes) do
      { 'rateplan-id': '12123123', number: number }
    end

    it 'return error Rateplan not found' do
      expect(response_body).to include(
        errors: match_array([include(detail: "rateplan-id - Rateplan not found")])
      )
    end
  end

  context 'when proper rate not found for this number' do
    let(:number) { '8888888888' }

    it 'return empty rates array' do
      expect(response_data).to a_hash_including(
        'id' => anything,
        'type' => 'check-rates',
        'attributes' => a_hash_including(
          'rateplan-id' => rateplan.uuid,
          'number' => number,
          'rates' => []
        )
      )
    end
  end

end
