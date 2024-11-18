# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::PaymentsController, type: :controller do
  include_context :jsonapi_admin_headers

  describe 'GET index' do
    let!(:payments) { create_list :payment, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(payments.size) }
  end

  describe 'GET index with ransack filters' do
    subject do
      get :index, params: json_api_request_query
    end
    let(:factory) { :payment }
    let(:json_api_request_query) { nil }

    it_behaves_like :jsonapi_filters_by_number_field, :amount
    it_behaves_like :jsonapi_filters_by_string_field, :notes
  end

  describe 'GET show' do
    let!(:payment) { create :payment }

    context 'when payment exists' do
      before { get :show, params: { id: payment.to_param } }

      it { expect(response.status).to eq(200) }
      it { expect(response_data['id']).to eq(payment.id.to_s) }
    end

    context 'when payment does not exist' do
      before { get :show, params: { id: payment.id + 10 } }

      it { expect(response.status).to eq(404) }
      it { expect(response_data).to eq(nil) }
    end
  end

  describe 'POST create' do
    before do
      post :create, params: {
        data: { type: 'payments',
                attributes: attributes,
                relationships: relationships }
      }
    end

    context 'when attributes are valid' do
      let(:attributes) { { amount: 10 } }
      let(:relationships) { { account: wrap_relationship(:accounts, create(:account).id) } }

      it { expect(response.status).to eq(201) }
      it { expect(Payment.count).to eq(1) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { amount: nil } }
      let(:relationships) { {} }

      it { expect(response.status).to eq(422) }
      it { expect(Payment.count).to eq(0) }
    end
  end
end
