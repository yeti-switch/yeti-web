# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::CryptomusPaymentsController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :'cryptomus-payments'

  let!(:account) { create(:account, contractor: customer) }
  let!(:prev_payment) { create(:payment, account:) }

  shared_examples :responds_with_resource do |status: 200|
    # let(:expected_resource_id) { ... }

    include_examples :responds_with_status, status

    it 'responds with payment uuid' do
      subject
      expect(response_json).to match(
                                 data: {
                                   id: expected_resource_id,
                                   type: 'cryptomus-payments',
                                   attributes: {
                                     url: cryptomus_url
                                   },
                                   links: anything
                                 }
                               )
    end
  end

  describe 'POST /api/rest/customer/v1/cryptomus-payments' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    shared_examples :creates_successfully do
      it 'creates pending payment' do
        expect { subject }.to change { Payment.count }.by(1)
        expect(Payment.last).to have_attributes(
                                  account_id: account.id,
                                  amount: json_api_attributes[:amount].to_d,
                                  notes: json_api_attributes[:notes],
                                  status_id: Payment::CONST::STATUS_ID_PENDING,
                                  private_notes: nil
                                )
      end

      it 'does not change account balance' do
        expect { subject }.not_to change { account.reload.balance }
      end

      include_examples :responds_with_resource, status: 201 do
        let(:expected_resource_id) { Payment.last.uuid }
      end
    end

    shared_examples :creation_failed do |errors:|
      include_examples :returns_json_api_errors, errors: errors

      it 'does not create payment' do
        expect(CryptomusPayment::Create).not_to receive(:call)
        expect { subject }.not_to change { Payment.count }
      end

      it 'does not change account balance' do
        expect { subject }.not_to change { account.reload.balance }
      end
    end

    let(:json_api_request_body) do
      {
        data: {
          type: 'cryptomus-payments',
          attributes: json_api_attributes,
          relationships: json_api_relationships
        }
      }
    end
    let(:json_api_attributes) do
      { amount: '100' }
    end
    let(:json_api_relationships) do
      {
        account: { data: { type: 'accounts', id: account.reload.uuid } }
      }
    end
    let(:cryptomus_url) do
      'https://pay.cryptomus.com/pay/f1386fb5-ecfa-41d4-a85d-b151d98df5e1'
    end

    before do
      allow(CryptomusPayment::Create).to receive(:call).with(
        order_id: (prev_payment.id + 1),
        amount: json_api_attributes[:amount].to_d
      ).and_return(cryptomus_url)
    end

    include_examples :creates_successfully

    context 'with notes attribute' do
      let(:json_api_attributes) do
        super().merge notes: 'qweasd'
      end

      include_examples :creates_successfully
    end

    context 'with no attributes and no relationships' do
      let(:json_api_attributes) { {} }
      let(:json_api_relationships) { {} }

      include_examples :creation_failed, errors: [
        { detail: "amount - can't be blank", source: { pointer: '/data/attributes/amount' } },
        { detail: "account - can't be blank", source: { pointer: '/data/relationships/account' } }
      ]
    end
  end

  describe 'GET /api/rest/customer/v1/cryptomus-payments' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{resource_id}" }
    let(:resource_id) { payment.uuid }
    let!(:payment) { create(:payment, :pending, account:) }
    let!(:stub_cryptomus_payment) do
      WebMock.stub_request(:post, "#{Cryptomus::CONST::URL}/v1/payment/info")
             .with(
        headers: { 'Content-Type': 'application/json' },
        body: { order_id: payment.id.to_s }.to_json
      )
             .and_return(
        headers: { 'Content-Type': 'application/json' },
        status: cryptomus_response_status,
        body: cryptomus_response_body.to_json
      )
    end
    let(:cryptomus_response_status) { 200 }
    let(:cryptomus_response_body) do
      {
        "state": 0,
        "result": {
          "uuid": 'f1386fb5-ecfa-41d4-a85d-b151d98df5e1',
          "order_id": payment.id.to_s,
          "amount": '100.00000000',
          "payment_amount": '110.95000000',
          "payer_amount": '10.123123',
          "payer_currency": 'USDT',
          "currency": 'USDT',
          "comments": nil,
          "network": 'TRON',
          "address": nil,
          "from": nil,
          "txid": nil,
          "payment_status": 'check',
          "url": cryptomus_url,
          "expired_at": 1.hour.from_now.to_i,
          "status": 'check',
          "is_final": false,
          "additional_data": nil,
          "is_payment_multiple": true
        }
      }
    end
    let(:cryptomus_url) do
      'https://pay.cryptomus.com/pay/f1386fb5-ecfa-41d4-a85d-b151d98df5e1'
    end

    it 'requests cryptomus payment api once' do
      subject
      expect(stub_cryptomus_payment).to have_been_requested.once
    end

    include_examples :responds_with_resource do
      let(:expected_resource_id) { resource_id }
    end

    context 'when cryptomus api returns error' do
      let(:cryptomus_response_status) { 404 }
      let(:cryptomus_response_body) do
        {
          state: 1,
          message: 'No query results for model [App\\Models\\MerchantPayment].'
        }
      end

      include_examples :responds_with_status, 500
      include_examples :captures_error, request: true do
        let(:capture_error_exception_class) { Cryptomus::Errors::ApiError }
        let(:capture_error_user) { be_present }
      end
    end

    context 'when payment type=cryptomus, status=completed' do
      let!(:payment) { create(:payment, :cryptomus_completed, account:) }
      let(:cryptomus_response_body) do
        super().deep_merge result: {
          status: 'paid',
          is_final: true
        }
      end
      let(:cryptomus_url) { nil }

      it 'requests cryptomus payment api once' do
        subject
        expect(stub_cryptomus_payment).to have_been_requested.once
      end

      include_examples :responds_with_resource do
        let(:expected_resource_id) { resource_id }
      end
    end

    context 'when payment type=cryptomus, status=canceled' do
      let!(:payment) { create(:payment, :canceled, account:) }
      let(:cryptomus_response_body) do
        super().deep_merge result: {
          status: 'canceled',
          is_final: true
        }
      end
      let(:cryptomus_url) { nil }

      it 'requests cryptomus payment api once' do
        subject
        expect(stub_cryptomus_payment).to have_been_requested.once
      end

      include_examples :responds_with_resource do
        let(:expected_resource_id) { resource_id }
      end
    end

    context 'when payment type=manual, status=completed' do
      let!(:payment) { create(:payment, account:) }

      include_examples :responds_with_status, 404
    end

    context 'when payment account not listed in allowed_ids' do
      before do
        allowed_account = create(:account, contractor: customer)
        api_access.update!(account_ids: [allowed_account.id])
      end

      include_examples :responds_with_status, 404
    end

    context 'when payment account belongs to another customer' do
      let!(:another_customer) { create(:customer) }
      let!(:another_account) { create(:account, contractor: another_customer) }
      let(:payment) { create(:payment, :pending, account: another_account) }

      include_examples :responds_with_status, 404
    end
  end
end
