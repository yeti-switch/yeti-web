# frozen_string_literal: true

RSpec.describe CryptomusPayment::CheckStatus do
  describe '.call' do
    subject do
      described_class.call(payment:)
    end

    let!(:payment) { create(:payment, payment_attrs) }
    let!(:payment_attrs) { { amount: 100, status_id: Payment::CONST::STATUS_ID_PENDING } }

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
          "payer_amount": '100.00000000',
          "payer_currency": 'USDT',
          "currency": 'USDT',
          "comments": nil,
          "network": 'tron_trc20',
          "address": nil,
          "from": nil,
          "txid": nil,
          "payment_status": 'paid',
          "url": 'https://pay.cryptomus.com/pay/f1386fb5-ecfa-41d4-a85d-b151d98df5e1',
          "expired_at": 1.hour.from_now.to_i,
          "status": 'paid',
          "is_final": true,
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

    context 'when cryptomus payment is paid' do
      it 'updates payment status to completed' do
        expect { subject }.to change { payment.reload.status_id }.to(Payment::CONST::STATUS_ID_COMPLETED)
        expect(payment.reload.amount).to eq 100
      end
    end

    context 'when cryptomus payment is paid_over' do
      let(:cryptomus_response_body) do
        super().deep_merge(
          result: {
            "status": 'paid_over',
            "amount": '105.00000000',
            "payment_amount": '115.95000000',
            "payer_amount": '105.00000000'
          }
        )
      end

      it 'updates payment status to completed' do
        expect { subject }.to change { payment.reload.status_id }.to(Payment::CONST::STATUS_ID_COMPLETED)
        expect(payment.reload.amount).to eq 105
      end
    end

    context 'when cryptomus payment is check' do
      let(:cryptomus_response_body) do
        super().deep_merge(
          result: {
            "status": 'check',
            "is_final": false
          }
        )
      end

      it 'raises Error' do
        expect { subject }.to raise_error(
                                described_class::Error,
                                'Cryptomus Payment status is not final: check'
                              )
      end

      it 'does not change payment' do
        expect { safe_subject }.not_to change { payment.reload.attributes }
      end

      it 'does not change account balance' do
        expect { safe_subject }.not_to change { payment.account.reload.balance }
      end
    end

    context 'when cryptomus payment is cancel' do
      let(:cryptomus_response_body) do
        super().deep_merge(
          result: {
            "status": 'cancel'
          }
        )
      end

      it 'updates payment status to canceled' do
        expect { subject }.to change { payment.reload.status_id }.to(Payment::CONST::STATUS_ID_CANCELED)
      end

      it 'does not change account balance' do
        expect { subject }.not_to change { payment.account.reload.balance }
      end
    end

    context 'with completed payment' do
      let!(:payment_attrs) { super().merge status_id: Payment::CONST::STATUS_ID_COMPLETED }

      it 'raises Error' do
        expect { subject }.to raise_error(described_class::Error, 'Payment is not pending')
      end

      it 'does not change payment' do
        expect { safe_subject }.not_to change { payment.reload.attributes }
      end

      it 'does not change account balance' do
        expect { safe_subject }.not_to change { payment.account.reload.balance }
      end
    end

    context 'with canceled payment' do
      let!(:payment_attrs) { super().merge status_id: Payment::CONST::STATUS_ID_COMPLETED }

      it 'raises Error' do
        expect { subject }.to raise_error(described_class::Error, 'Payment is not pending')
      end

      it 'does not change payment' do
        expect { safe_subject }.not_to change { payment.reload.attributes }
      end

      it 'does not change account balance' do
        expect { safe_subject }.not_to change { payment.account.reload.balance }
      end
    end
  end
end
