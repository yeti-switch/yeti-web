require 'spec_helper'

describe Api::Rest::Customer::V1::RateplansController, type: :controller do

  # RatePlans for the other customer
  before { create_list(:rateplan, 2) }

  let(:api_access) { create(:api_access) }
  let(:customer) { api_access.customer }

  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: api_access.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index' do

    context 'account_ids is empty' do
      before do
        create(:customers_auth, customer_id: customer.id)
      end

      before { get :index }

      it 'returns records of this customer' do
        expect(response.status).to eq(200)
        expect(response_data).to match_array(
          [
            hash_including('id' => customer.rateplans.first.uuid)
          ]
        )
      end
    end

    context 'with account_ids' do

      before do
        create_list(:rateplan, 1)
      end

      let(:rateplans) { create_list(:rateplan, 2) }

      let(:customers_auths) { create_list(:customers_auth, 2, customer_id: customer.id) }

      let(:accounts) { create_list :account, 4, contractor: customer }
      let(:allowed_accounts) { accounts.slice(0, 2) }

      before do
        customers_auths.first.update!(account_id: accounts.first.id)
        customers_auths.second.update!(account_id: accounts.second.id)
        api_access.update!(account_ids: allowed_accounts.map(&:id))
      end

      before { get :index }

      it 'returns Rateplans connected to allowed_accounts' do
        expect(response_data).to match_array(
          [
            hash_including('id' => CustomersAuth.find_by(account_id: allowed_accounts.first).rateplan.uuid),
            hash_including('id' => CustomersAuth.find_by(account_id: allowed_accounts.second).rateplan.uuid)
          ]
        )
      end
    end

  end

  describe 'GET show' do
    let(:customers_auth) do
      create(:customers_auth, customer_id: customer.id)
    end

    let(:rateplan) { customers_auth.rateplan.reload }

    context 'when record exists' do
      before { get :show, params: { id: rateplan.uuid } }

      it 'returnds record with expected attributes' do
        expect(response_data).to include({
          'id' => rateplan.uuid,
          'type' => 'rateplans',
          'links' => anything,
          'attributes' => {
            'name' => rateplan.name
          }
        })
      end
    end

    context 'request rateplan not listed in allowed_ids' do
      let(:allowed_account) { create(:account, contractor: customer) }
      let(:customers_auth) { create(:customers_auth, customer_id: customer.id) }
      let(:rateplan) { customers_auth.rateplan.reload }

      before { api_access.update!(account_ids: [allowed_account.id]) }

      before { get :show, params: { id: rateplan.uuid } }

      it { expect(response.status).to eq(404) }
    end

  end

end
