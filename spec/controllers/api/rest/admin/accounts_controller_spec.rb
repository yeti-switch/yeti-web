RSpec.describe Api::Rest::Admin::AccountsController, type: :controller do
  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index' do
    let!(:accounts) { create_list :account, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(accounts.size) }
  end

  describe 'GET index with filters' do
    before { create_list :account, 2 }

    it_behaves_like :jsonapi_filter_by_name do
      let(:subject_record) { create(:account) }
    end
  end

  describe 'GET show' do
    let!(:account) { create :account }

    context 'when account exists' do
      before { get :show, params: { id: account.to_param } }

      it { expect(response.status).to eq(200) }
      it { expect(response_data['id']).to eq(account.id.to_s) }
    end

    context 'when account does not exist' do
      before { get :show, params: { id: account.id + 10 } }

      it { expect(response.status).to eq(404) }
      it { expect(response_data).to eq(nil) }
    end
  end

  describe 'POST create' do
    before do
      post :create, params: {
        data: { type: 'accounts',
                attributes: attributes,
                relationships: relationships }
      }
    end

    context 'when attributes are valid' do
      let(:attributes) do
        { name: 'name',
          'min-balance': 1,
          'external-id': 100,
          'max-balance': 10 }
      end

      let(:relationships) do
        { timezone: wrap_relationship(:'timezones', 1),
          contractor: wrap_relationship(:contractors, create(:contractor, vendor: true).id) }
      end

      it { expect(response.status).to eq(201) }
      it { expect(Account.count).to eq(1) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: 'name', 'max-balance': -1 } }
      let(:relationships) { {} }

      it { expect(response.status).to eq(422) }
      it { expect(Account.count).to eq(0) }
    end
  end

  describe 'PUT update' do
    let!(:account) { create :account }
    before do
      put :update, params: {
        id: account.to_param,
        data: { type: 'accounts',
                id: account.to_param,
                attributes: attributes }
      }
    end

    context 'when attributes are valid' do
      let(:attributes) { { name: 'name' } }

      it { expect(response.status).to eq(200) }
      it { expect(account.reload.name).to eq('name') }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: 'name', 'min-balance': 10, 'max-balance': 0 } }

      it { expect(response.status).to eq(422) }
      it { expect(account.reload.name).to_not eq('name') }
    end

    context 'when attributes are not updatable' do
      let(:attributes) { { 'external-id': 200 } }

      it { expect(response.status).to eq(400) }
      it { expect(account.reload.external_id).to_not eq(200) }
    end
  end

  describe 'DELETE destroy' do
    let!(:account) { create :account }

    before { delete :destroy, params: { id: account.to_param } }

    it { expect(response.status).to eq(204) }
    it { expect(Account.count).to eq(0) }
  end
end
