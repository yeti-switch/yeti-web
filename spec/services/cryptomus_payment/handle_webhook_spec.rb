# frozen_string_literal: true

RSpec.describe CryptomusPayment::HandleWebhook do
  describe '.call' do
    subject do
      described_class.call(payload:)
    end

    shared_examples :completes_payment do
      # let(:complete_amount) { original_amount }

      it 'updates payment status to completed' do
        expect { subject }.to change { payment.reload.status_id }.to(Payment::CONST::STATUS_ID_COMPLETED)
        expect(payment.reload.amount).to eq complete_amount
      end

      it 'updates account balance' do
        expect { subject }.to change { payment.account.reload.balance }.by(complete_amount)
      end
    end

    shared_examples :cancel_payment do
      it 'updates payment status to canceled' do
        expect { subject }.to change { payment.reload.status_id }.to(Payment::CONST::STATUS_ID_CANCELED)
      end

      it 'does not change account balance' do
        expect { subject }.not_to change { payment.account.reload.balance }
      end
    end

    shared_examples :do_nothing do
      it 'does not change payment' do
        expect { safe_subject }.not_to change { payment.reload.attributes }
      end

      it 'does not change account balance' do
        expect { safe_subject }.not_to change { payment.account.reload.balance }
      end
    end

    let!(:payment) { create(:payment, payment_attrs) }
    let(:original_amount) { 100.55 }
    let(:payment_attrs) do
      {
        amount: original_amount,
        status_id: Payment::CONST::STATUS_ID_PENDING,
        type_id: Payment::CONST::TYPE_ID_CRYPTOMUS
      }
    end

    let(:signed_payload) do
      sign = Cryptomus::Signature.generate JSON.generate(payload)
      payload.merge(sign:)
    end
    let(:payload) do
      {
        type: 'payment',
        uuid: 'ccc92ca9-3d2b-4bfa-8fd0-ff8f983abfc3',
        order_id: payment.id.to_s,
        amount: original_amount.to_s,
        payment_amount: '3.00000000',
        payment_amount_usd: '3.00',
        merchant_amount: original_amount.to_s,
        commission: '0.06000000',
        is_final: true,
        status: 'paid',
        from: 'TJDELwkVCQyobK5EuHMcB3uFwxfgqs5siX',
        wallet_address_uuid: nil,
        network: 'tron',
        currency: 'USD',
        payer_currency: 'USDT',
        additional_data: nil,
        txid: 'a2df0a1d9b38e588bc2d10ff84b17df0d13e1666859ba958fd66c7642301ef47'
      }
    end

    context 'with payload status paid' do
      include_examples :completes_payment do
        let(:complete_amount) { original_amount }
      end

      context 'when payment is type=cryptomus status=canceled' do
        let!(:payment_attrs) do
          super().merge status_id: Payment::CONST::STATUS_ID_CANCELED,
                        type_id: Payment::CONST::TYPE_ID_CRYPTOMUS
        end

        it 'raises Error' do
          expect { subject }.to raise_error(described_class::Error, 'success webhook received but payment is canceled')
        end

        include_examples :do_nothing
      end

      context 'when payment is type=cryptomus status=completed' do
        let!(:payment_attrs) do
          super().merge status_id: Payment::CONST::STATUS_ID_COMPLETED,
                        type_id: Payment::CONST::TYPE_ID_CRYPTOMUS
        end

        context 'when merchant amount is not equal to payment amount' do
          let(:payload) do
            super().merge merchant_amount: '99.90'
          end

          it 'raises Error' do
            msg = "success webhook received with amount 99.9 but payment is completed with amount #{original_amount}"
            expect { subject }.to raise_error(described_class::Error, msg)
          end
        end

        context 'when merchant amount is equal to payment amount' do
          it 'does not raise error' do
            expect { subject }.not_to raise_error
          end

          include_examples :do_nothing
        end
      end
    end

    context 'with payload status paid_over' do
      let(:payload) do
        super().merge(
          status: 'paid_over',
          merchant_amount: '105.66000000'
        )
      end

      include_examples :completes_payment do
        let(:complete_amount) { 105.66 }
      end

      context 'when payment is type=cryptomus status=canceled' do
        let!(:payment_attrs) do
          super().merge status_id: Payment::CONST::STATUS_ID_CANCELED,
                        type_id: Payment::CONST::TYPE_ID_CRYPTOMUS
        end

        it 'raises Error' do
          expect { subject }.to raise_error(described_class::Error, 'success webhook received but payment is canceled')
        end

        include_examples :do_nothing
      end

      context 'when payment is type=cryptomus status=completed' do
        let!(:payment_attrs) do
          super().merge status_id: Payment::CONST::STATUS_ID_COMPLETED,
                        type_id: Payment::CONST::TYPE_ID_CRYPTOMUS
        end

        context 'when merchant amount is not equal to payment amount' do
          it 'raises Error' do
            msg = "success webhook received with amount 105.66 but payment is completed with amount #{original_amount}"
            expect { subject }.to raise_error(described_class::Error, msg)
          end
        end

        context 'when merchant amount is equal to payment amount' do
          let(:original_amount) { 105.66 }

          it 'does not raise error' do
            expect { subject }.not_to raise_error
          end

          include_examples :do_nothing
        end
      end
    end

    context 'with payload status check' do
      let(:payload) do
        super().merge(
          status: 'check',
          is_final: false
        )
      end

      it 'does not raise error' do
        expect { subject }.not_to raise_error
      end

      include_examples :do_nothing

      context 'when payment is type=cryptomus status=canceled' do
        let!(:payment_attrs) do
          super().merge status_id: Payment::CONST::STATUS_ID_CANCELED,
                        type_id: Payment::CONST::TYPE_ID_CRYPTOMUS
        end

        it 'does not raise error' do
          expect { subject }.not_to raise_error
        end

        include_examples :do_nothing
      end

      context 'when payment is type=cryptomus status=completed' do
        let!(:payment_attrs) do
          super().merge status_id: Payment::CONST::STATUS_ID_COMPLETED,
                        type_id: Payment::CONST::TYPE_ID_CRYPTOMUS
        end

        it 'does not raise error' do
          expect { subject }.not_to raise_error
        end

        include_examples :do_nothing
      end
    end

    context 'with payload status cancel' do
      let(:payload) do
        super().merge(
          status: 'cancel'
        )
      end

      include_examples :cancel_payment

      context 'when payment is type=cryptomus status=completed' do
        let!(:payment_attrs) do
          super().merge status_id: Payment::CONST::STATUS_ID_COMPLETED,
                        type_id: Payment::CONST::TYPE_ID_CRYPTOMUS
        end

        it 'raises Error' do
          expect { subject }.to raise_error(described_class::Error, 'failed webhook received but payment is completed')
        end

        include_examples :do_nothing
      end

      context 'when payment is type=cryptomus status=canceled' do
        let!(:payment_attrs) do
          super().merge status_id: Payment::CONST::STATUS_ID_CANCELED,
                        type_id: Payment::CONST::TYPE_ID_CRYPTOMUS
        end

        it 'does not raise error' do
          expect { subject }.not_to raise_error
        end

        include_examples :do_nothing
      end
    end

    context 'when payment with such id does not exist' do
      let(:payload) do
        super().merge order_id: '123456789'
      end

      it 'raises Error' do
        expect { subject }.to raise_error(described_class::Error, 'Payment with id "123456789" not found')
      end

      include_examples :do_nothing
    end

    context 'when payment is type=manual status=completed' do
      let!(:payment_attrs) do
        super().merge status_id: Payment::CONST::STATUS_ID_COMPLETED,
                      type_id: Payment::CONST::TYPE_ID_MANUAL
      end

      it 'raises Error' do
        expect { subject }.to raise_error(described_class::Error, 'Payment type is not cryptomus')
      end

      include_examples :do_nothing
    end
  end
end
