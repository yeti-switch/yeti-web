require 'spec_helper'

describe Api::Rest::Private::PaymentsController, type: :controller do
  let(:account) { create(:account) }

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index' do
    let!(:payments) { create_list :payment, 2 }

    before { get :index }

    it { expect(response.status).to eq(200) }
    it { expect(response_data.size).to eq(payments.size) }
  end

  describe 'GET show' do
    let!(:payment) { create :payment }

    context 'when payment exists' do
      before { get :show, id: payment.to_param }

      it { expect(response.status).to eq(200) }
      it { expect(response_data['id']).to eq(payment.id.to_s) }
    end

    context 'when payment does not exist' do
      before { get :show, id: payment.id + 10 }

      it { expect(response.status).to eq(404) }
      it { expect(response_data).to eq(nil) }
    end
  end

  describe 'POST create' do
    before { post :create, data: { type: 'payments', attributes: attributes } }

    context 'when attributes are valid' do
      let(:attributes) { { amount: 10, 'account-id': account.id } }

      it { expect(response.status).to eq(201) }
      it { expect(Payment.count).to eq(1) }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { amount: nil } }

      it { expect(response.status).to eq(422) }
      it { expect(Payment.count).to eq(0) }
    end
  end
end

