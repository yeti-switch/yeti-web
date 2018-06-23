RSpec.describe Api::Rest::Customer::V1::RatesController, type: :controller do

  # Rates for the other customer
  before { create_list(:customers_auth, 2) }

  before(:each, :with_rateplan_with_customer) do
    create(:customers_auth, customer_id: customer.id)
  end

  before(:each, :with_rateplans_with_accounts) do
    accounts.each do |account|
      create(:customers_auth, customer_id: customer.id, account_id: account.id)
    end
  end

  let(:api_access) { create(:api_access) }
  let(:customer) { api_access.customer }

  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: api_access.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index' do

    context 'account_ids is empty', :with_rateplan_with_customer do
      before { create_list(:rate, 2) }
      let!(:rates) { create_list(:rate, 2, rateplan: customer.rateplans.first) }
      before { get :index }

      it 'returns records of this customer' do
        expect(response.status).to eq(200)
        expect(response_data).to match_array(
          [
            hash_including('id' => rates.first.reload.uuid),
            hash_including('id' => rates.second.reload.uuid)
          ]
        )
      end
    end

    context 'with account_ids', :with_rateplans_with_accounts do
      let(:accounts) { create_list :account, 4, contractor: customer }
      let(:allowed_accounts) { accounts.slice(0, 2) }

      before do
        api_access.update!(account_ids: allowed_accounts.map(&:id))
      end

      let!(:rates) { create_list(:rate, 2, rateplan: Rateplan.where_account(allowed_accounts.first.id).first) }

      before do
        create_list(:rate, 2) # other customer
        get :index
      end

      it 'returns Rates connected to allowed_accounts' do
        expect(response_data).to match_array(
          [
            hash_including('id' => CustomersAuth.find_by(account_id: allowed_accounts.first).destinations.first.uuid),
            hash_including('id' => CustomersAuth.find_by(account_id: allowed_accounts.first).destinations.last.uuid)
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

    let!(:rate) { create(:rate, rateplan: rateplan) }

    context 'when record exists' do
      before { get :show, params: { id: rate.reload.uuid } }

      it 'returnds record with expected attributes' do
        expect(response_data).to include({
          'id' => rate.reload.uuid,
          'type' => 'rates',
          'links' => anything,
          'attributes' => {
            'prefix' => rate.prefix,
            'initial-rate' => rate.initial_rate.to_s,
            'initial-interval' => rate.initial_interval,
            'next-rate' => rate.next_rate.to_s,
            'next-interval' => rate.next_interval,
            'connect-fee' => rate.connect_fee.to_s,
            'reject-calls' => rate.reject_calls,
            'valid-from' => rate.valid_from.iso8601(3),
            'valid-till' => rate.valid_till.iso8601(3),
            'network-prefix-id' => rate.network_prefix_id
          }
        })
      end
    end

    context 'request rate not listed in allowed_ids' do
      let(:allowed_account) { create(:account, contractor: customer) }
      let(:customers_auth) { create(:customers_auth, customer_id: customer.id) }
      let(:rate) { create(:rate, rateplan: customers_auth.rateplan) }

      before { api_access.update!(account_ids: [allowed_account.id]) }

      before { get :show, params: { id: rate.reload.uuid } }

      it { expect(response.status).to eq(404) }
    end

  end

end
