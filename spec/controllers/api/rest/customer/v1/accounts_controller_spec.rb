# frozen_string_literal: true

require 'spec_helper'

describe Api::Rest::Customer::V1::AccountsController, type: :controller do
  let!(:api_access) { create :api_access }
  let(:customer) { api_access.customer }

  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: api_access.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  before do
    # Accounts not belongs to current customer
    create_list :account, 1
  end

  describe 'GET index' do
    let!(:accounts) { create_list :account, 2, contractor: customer }

    context 'account_ids is empty' do
      before { get :index }

      it 'returns records of this customer' do
        expect(response.status).to eq(200)
        expect(response_data).to match_array(
          [
            hash_including('id' => accounts.first.reload.uuid),
            hash_including('id' => accounts.second.reload.uuid)
          ]
        )
      end
    end

    context 'with account_ids' do
      let!(:accounts) { create_list :account, 4, contractor: customer }
      let(:allowed_accounts) { accounts.slice(0, 2) }

      before do
        api_access.update!(account_ids: allowed_accounts.map(&:id))
        get :index
      end

      it 'returns only Accounts listed in account_ids' do
        expect(response_data).to match_array(
          [
            hash_including('id' => allowed_accounts.first.reload.uuid),
            hash_including('id' => allowed_accounts.second.reload.uuid)
          ]
        )
      end
    end

    # TODO: context when no entity found fin index-action
  end

  describe 'GET show' do
    let!(:account) { create(:account, contractor: customer) }

    context 'when record exists' do
      before { get :show, params: { id: account.reload.uuid } }

      it 'returnds record with expected attributes' do
        expect(response_data).to include(
          'id' => account.reload.uuid,
          'type' => 'accounts',
          'links' => anything,
          'attributes' => {
            'name' => account.name,
            'balance' => account.balance.to_s,
            'min-balance' => account.min_balance.to_s,
            'max-balance' => account.max_balance.to_s,
            'destination-rate-limit' => account.destination_rate_limit.to_s,
            'origination-capacity' => account.origination_capacity,
            'termination-capacity' => account.termination_capacity,
            'total-capacity' => account.total_capacity
          }
        )
      end
    end

    context 'request accout not listed in allowed_ids' do
      let(:allowed_account) { create(:account, contractor: customer) }
      before { api_access.update!(account_ids: [allowed_account.id]) }
      before { get :show, params: { id: account.reload.uuid } }

      it { expect(response.status).to eq(404) }
    end
  end
end
