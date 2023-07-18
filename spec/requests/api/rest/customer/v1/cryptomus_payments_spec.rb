# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::CryptomusPaymentsController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :'cryptomus-payments'

  let!(:account) { create(:account, contractor: customer) }
  let!(:prev_payment) { create(:payment, account:) }

  describe 'POST /api/rest/customer/v1/cryptomus-payments' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    shared_examples :creates_successfully do
      it 'creates pending payment' do
        expect { subject }.to change { Payment.count }.by(1)
        expect(stub_cryptomus_payment_services).to have_been_requested.once
        expect(stub_create_cryptomus_payment).to have_been_requested.once
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

      include_examples :responds_with_status, 201

      it 'responds with payment uuid' do
        subject
        expect(response_json).to match(
                                   data: {
                                     id: Payment.last.uuid,
                                     type: 'cryptomus-payments',
                                     attributes: {
                                       url: cryptomus_url
                                     },
                                     links: anything
                                   }
                                 )
      end
    end

    shared_examples :creation_failed do |errors:|
      include_examples :returns_json_api_errors, errors: errors

      it 'does not create payment' do
        expect { subject }.not_to change { Payment.count }
        expect(stub_cryptomus_payment_services).not_to have_been_requested
        expect(stub_create_cryptomus_payment).not_to have_been_requested
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

    let!(:payment_services_body) do
      File.read Rails.root.join('spec/fixtures/json/cryptomus_payment_services.json')
    end
    let!(:stub_cryptomus_payment_services) do
      WebMock.stub_request(:post, "#{Cryptomus::CONST::URL}/v1/payment/services")
             .with(headers: { 'Content-Type': 'application/json' }, body: '{}')
             .and_return(headers: { 'Content-Type': 'application/json' }, status: 201, body: payment_services_body)
    end
    let(:cryptomus_currencies) do
      JSON.parse(payment_services_body, symbolize_names: true)[:result].map { |row| row.slice(:currency) }.uniq
    end

    let!(:stub_create_cryptomus_payment) do
      WebMock.stub_request(:post, "#{Cryptomus::CONST::URL}/v1/payment")
             .with(
               headers: { 'Content-Type': 'application/json' },
               body: cryptomus_request_body.to_json
             )
             .and_return(
               headers: { 'Content-Type': 'application/json' },
               status: cryptomus_response_status,
               body: cryptomus_response_body.to_json
             )
    end
    let(:cryptomus_request_body) do
      {
        order_id: (prev_payment.id + 1).to_s,
        amount: json_api_attributes[:amount].to_d.to_s,
        currency: 'USD',
        currencies: cryptomus_currencies,
        url_callback: YetiConfig.cryptomus&.url_callback,
        url_return: YetiConfig.cryptomus&.url_return,
        lifetime: CustomerApi::CryptomusPaymentForm::EXPIRATION_SEC,
        subtract: 100
      }
    end
    let(:cryptomus_response_status) { 200 }
    let(:cryptomus_response_body) do
      {
        "state": 0,
        "result": {
          "uuid": 'f1386fb5-ecfa-41d4-a85d-b151d98df5e1',
          "order_id": (prev_payment.id + 1).to_s,
          "amount": '100.00000000',
          "payment_amount": '110.95000000',
          "payer_amount": '100.00000000',
          "payer_currency": 'USDT',
          "currency": 'USDT',
          "comments": nil,
          "network": 'tron_trc20',
          "address": nil,
          "from": nil,
          "txid": nil,
          "payment_status": 'check',
          "url": cryptomus_url,
          "expired_at": CustomerApi::CryptomusPaymentForm::EXPIRATION_SEC.seconds.from_now.to_i,
          "status": 'check',
          "is_final": false,
          "additional_data": nil,
          "currencies": [
            {
              "currency": 'USDT',
              "network": 'tron_trc20'
            },
            {
              "currency": 'USDT',
              "network": 'eth_erc20'
            }
          ]
        }
      }
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
end
