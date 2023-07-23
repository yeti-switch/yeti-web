# frozen_string_literal: true

RSpec.describe CryptomusPayment::Create do
  describe '.call' do
    subject do
      described_class.call(order_id:, amount:)
    end

    let!(:order_id) { 123_456 }
    let!(:amount) { 100.to_d }

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
        order_id: order_id.to_s,
        amount: amount.to_s,
        currency: 'USDT',
        network: 'TRON',
        url_callback: YetiConfig.cryptomus&.url_callback,
        url_return: YetiConfig.cryptomus&.url_return,
        lifetime: CryptomusPayment::Create::EXPIRATION_SECONDS,
        subtract: 100,
        is_payment_multiple: true
      }
    end
    let(:cryptomus_response_status) { 200 }
    let(:cryptomus_response_body) do
      {
        "state": 0,
        "result": {
          "uuid": 'f1386fb5-ecfa-41d4-a85d-b151d98df5e1',
          "order_id": order_id.to_s,
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
          "expired_at": CryptomusPayment::Create::EXPIRATION_SECONDS.seconds.from_now.to_i,
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

    it 'returns cryptomus url' do
      expect(subject).to eq(cryptomus_url)
      expect(stub_create_cryptomus_payment).to have_been_requested.once
    end

    context 'when cryptomus returns error' do
      let(:cryptomus_response_status) { 400 }
      let(:cryptomus_response_body) do
        {
          "state": 1,
          "error": {
            "code": 400,
            "message": 'Invalid amount'
          }
        }
      end

      it 'raises error' do
        msg = 'Response 400, {"state":1,"error":{"code":400,"message":"Invalid amount"}}'
        expect { subject }.to raise_error(CryptomusPayment::Create::Error, msg)
        expect(stub_create_cryptomus_payment).to have_been_requested.once
      end
    end
  end
end
