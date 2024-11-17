# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::AccountsController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index' do
    let!(:accounts) { create_list :account, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(accounts.size) }
  end

  describe 'GET index with filters' do
    subject do
      get :index, params: json_api_request_query
    end
    before { create_list :account, 2 }
    let(:json_api_request_query) { nil }

    it_behaves_like :jsonapi_filter_by_name do
      let(:subject_record) { create(:account) }
    end
  end

  describe 'GET index with ransack filters' do
    subject do
      get :index, params: json_api_request_query
    end
    let(:factory) { :account }
    let(:trait) { :with_max_balance }
    let(:json_api_request_query) { nil }

    it_behaves_like :jsonapi_filters_by_string_field, :name
    it_behaves_like :jsonapi_filters_by_number_field, :balance
    it_behaves_like :jsonapi_filters_by_number_field, :min_balance
    it_behaves_like :jsonapi_filters_by_number_field, :max_balance
    it_behaves_like :jsonapi_filters_by_number_field, :balance_low_threshold
    it_behaves_like :jsonapi_filters_by_number_field, :balance_high_threshold
    it_behaves_like :jsonapi_filters_by_number_field, :destination_rate_limit
    it_behaves_like :jsonapi_filters_by_number_field, :max_call_duration
    it_behaves_like :jsonapi_filters_by_number_field, :external_id
    it_behaves_like :jsonapi_filters_by_uuid_field, :uuid
    it_behaves_like :jsonapi_filters_by_number_field, :origination_capacity
    it_behaves_like :jsonapi_filters_by_number_field, :termination_capacity
    it_behaves_like :jsonapi_filters_by_number_field, :total_capacity
  end

  describe 'GET show' do
    let!(:account) { create :account }

    context 'when account exists' do
      before { get :show, params: { id: account.to_param } }

      it { expect(response.status).to eq(200) }
      it { expect(response_data['id']).to eq(account.id.to_s) }
      it 'has balance threshold attributes' do
        expect(response_data['attributes']).to include(
          'name',
          'balance', 'min-balance', 'max-balance',
          'uuid',
          'external-id',
          'origination-capacity', 'termination-capacity', 'total-capacity',
          'send-invoices-to',
          'balance-low-threshold',
          'balance-high-threshold',
          'destination-rate-limit',
          'max-call-duration',
          'send-balance-notifications-to'
        )
      end
    end

    context 'when account does not exist' do
      before { get :show, params: { id: account.id + 10 } }

      it { expect(response.status).to eq(404) }
      it { expect(response_data).to eq(nil) }
    end
  end

  describe 'POST create' do
    before do
      post :create, params: request_payload
    end

    let(:request_payload) do
      {
        data: {
          type: 'accounts',
          attributes: attributes,
          relationships: relationships
        }
      }
    end
    let(:attributes) do
      {
        name: 'name',
        'min-balance': 1,
        'external-id': 100,
        'uuid': '29161666-c29c-11e8-a11d-a088b4454590',
        'max-balance': 10,
        'balance-low-threshold': 90,
        'balance-high-threshold': 95,
        'destination-rate-limit': 0.333,
        'max-call-duration': 24_000,
        'send-balance-notifications-to': Array.wrap(Billing::Contact.collection.first.id),
        'send-invoices-to': Billing::Contact.collection.first.id,
        'origination-capacity': 10,
        'termination-capacity': 3,
        'total-capacity': 11
      }
    end
    let(:relationships) do
      {
        timezone: wrap_relationship(:timezones, 1),
        contractor: wrap_relationship(:contractors, create(:contractor, vendor: true).id)
      }
    end

    context 'when attributes and relationships are valid' do
      it { expect(response.status).to eq(201) }
      it { expect(Account.count).to eq(1) }
      it { expect(AccountBalanceNotificationSetting.count).to eq(1) }
    end

    context 'when attributes and relationships are invalid' do
      let(:attributes) { { name: 'name', 'max-balance': -1 } }
      let(:relationships) { {} }

      it { expect(response.status).to eq(422) }
      it { expect(Account.count).to eq(0) }
      it { expect(AccountBalanceNotificationSetting.count).to eq(0) }
    end

    context 'when only required attributes and relationships' do
      let(:attributes) do
        {
          name: 'name'
        }
      end
      let(:relationships) do
        {
          contractor: wrap_relationship(:contractors, create(:contractor, vendor: true).id)
        }
      end

      it { expect(response.status).to eq(201) }
      it { expect(Account.count).to eq(1) }
      it { expect(AccountBalanceNotificationSetting.count).to eq(1) }
    end

    context 'with attributes balance-low-threshold = balance-high-threshold' do
      let(:attributes) do
        super().merge 'balance-low-threshold': 90,
                      'balance-high-threshold': 90
      end

      it { expect(response.status).to eq(422) }
      it { expect(Account.count).to eq(0) }
    end

    context 'with attributes balance-low-threshold > balance-high-threshold' do
      let(:attributes) do
        super().merge 'balance-low-threshold': 91,
                      'balance-high-threshold': 90
      end

      it { expect(response.status).to eq(422) }
      it { expect(Account.count).to eq(0) }
    end
  end

  describe 'PUT update' do
    let!(:account) { create :account }
    before do
      put :update, params: request_payload
    end
    let(:request_payload) do
      {
        id: account.to_param,
        data: {
          type: 'accounts',
          id: account.to_param,
          attributes: attributes
        }
      }
    end

    context 'when attributes are valid' do
      let(:attributes) do
        {
          name: 'name',
          'external-id': 110,
          'uuid': '5d24297a-c29c-11e8-a11d-a088b4454590',
          'min-balance': -100,
          'max-balance': 100,
          'balance-low-threshold': 90,
          'balance-high-threshold': 95,
          'destination-rate-limit': 0.333,
          'max-call-duration': 24_001,
          'send-balance-notifications-to': Billing::Contact.collection.first.id,
          'send-invoices-to': Billing::Contact.collection.first.id,
          'origination-capacity': 10,
          'termination-capacity': 3,
          'total-capacity': 11
        }
      end

      it { expect(response.status).to eq(200) }
      it { expect(account.reload.name).to eq('name') }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { name: 'name', 'min-balance': 10, 'max-balance': 0 } }

      it { expect(response.status).to eq(422) }
      it { expect(account.reload.name).to_not eq('name') }
    end

    context 'when attributes are not updatable' do
      let(:attributes) { { 'balance': 2100.2 } }

      it { expect(response.status).to eq(400) }
      it { expect(account.reload.balance).to_not eq(2100.2) }
    end

    context 'with attributes balance-low-threshold = balance-high-threshold' do
      let(:attributes) do
        {
          'balance-low-threshold': 90,
          'balance-high-threshold': 90
        }
      end

      it { expect(response.status).to eq(422) }
      it { expect(account.reload.balance_notification_setting.low_threshold).to_not eq(90) }
      it { expect(account.reload.balance_notification_setting.high_threshold).to_not eq(90) }
    end

    context 'with attributes balance-low-threshold > balance-high-threshold' do
      let(:attributes) do
        {
          'balance-low-threshold': 91,
          'balance-high-threshold': 90
        }
      end

      it { expect(response.status).to eq(422) }
      it { expect(account.reload.balance_notification_setting.low_threshold).to_not eq(91) }
      it { expect(account.reload.balance_notification_setting.high_threshold).to_not eq(90) }
    end
  end

  describe 'DELETE destroy' do
    let!(:account) { create :account }

    before { delete :destroy, params: { id: account.to_param } }

    it { expect(response.status).to eq(204) }
    it { expect(Account.count).to eq(0) }

    context 'when account has balance_notifications' do
      before do
        FactoryBot.create_list(:balance_notification, 2, account: account)
      end

      it { expect(response.status).to eq(204) }
      it { expect(Account.count).to eq(0) }
      it { expect(Log::BalanceNotification.count).to eq(2) }
    end
  end
end
