# frozen_string_literal: true

RSpec.describe 'Cryptomus Webhooks', type: :request do
  describe 'POST /cryptomus_webhooks' do
    subject do
      post '/cryptomus_webhooks',
           params: request_body.to_json,
           headers: { 'Content-Type': 'application/json' }
    end

    let(:request_body) { payload.merge(sign:) }
    let(:sign) { Cryptomus::Signature.generate(payload.to_json) }
    let!(:payment) { create(:payment) }
    let(:payload) do
      {
        type: 'payment',
        uuid: '99d3473f-ce0f-43dc-ba25-d42b4802fb0c',
        order_id: payment.id.to_s,
        amount: '70.00000000',
        payment_amount: '70.00000000',
        payment_amount_usd: '4.30',
        merchant_amount: '67.90000000',
        commission: '2.10000000',
        is_final: true,
        status: 'paid',
        from: nil,
        wallet_address_uuid: nil,
        network: 'tron',
        currency: 'TRX',
        payer_currency: 'TRX',
        additional_data: 'Some additional info',
        convert: {
          "to_currency": 'USDT',
          "commission": nil,
          "rate": '0.06193320',
          "amount": '4.16321164'
        }
      }
    end

    context 'with success handle webhook' do
      before do
        allow(CryptomusPayment::HandleWebhook).to receive(:call).with(payload:)
      end

      it 'returns 200' do
        expect(CryptomusPayment::HandleWebhook).to receive(:call).with(payload:).once
        subject
        expect(response.status).to eq(200)
      end

      include_examples :does_not_capture_error
    end

    context 'when signature is invalid' do
      let(:sign) { 'invalid' }

      it 'returns 400' do
        expect(CryptomusPayment::HandleWebhook).not_to receive(:call)
        subject
        expect(response.status).to eq(400)
      end

      include_examples :does_not_capture_error
    end

    context 'when CryptomusPayment::HandleWebhook::Error raised' do
      before do
        allow(CryptomusPayment::HandleWebhook).to receive(:call).with(payload:).once.and_raise(
          CryptomusPayment::HandleWebhook::Error, 'some error'
        )
      end

      it 'returns 500' do
        subject
        expect(response.status).to eq(500)
      end

      include_examples :captures_error, request: true do
        let(:capture_error_exception_class) { CryptomusPayment::HandleWebhook::Error }
        let(:capture_error_extra) { hash_including(params: a_kind_of(Hash)) }
      end
    end

    context 'when unknown error raised' do
      let(:unknown_error_class) { Class.new(StandardError) }
      before do
        allow(CryptomusPayment::HandleWebhook).to receive(:call).with(payload:).once.and_raise(
          unknown_error_class, 'some error'
        )
      end

      it 'returns 500' do
        subject
        expect(response.status).to eq(500)
      end

      include_examples :captures_error, request: true do
        let(:capture_error_exception_class) { unknown_error_class }
        let(:capture_error_extra) { hash_including(params: a_kind_of(Hash)) }
      end
    end
  end
end
