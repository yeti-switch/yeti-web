# frozen_string_literal: true

RSpec.describe Payment::Rollback do
  describe '.call' do
    subject { described_class.call(service_params) }

    let(:service_params) { {} }

    context 'when payment is completed' do
      let(:service_params) { { payment: record } }
      let!(:account) { FactoryBot.create(:account, balance: 100) }
      let!(:record) { FactoryBot.create(:payment, :completed, account:, amount: 50) }

      it 'changes to "rolled back" status' do
        expect { subject }.to change { record.reload.status_id }.from(Payment::CONST::STATUS_ID_COMPLETED)

        expect(record).to have_attributes(
          rolledback_at: be_present,
          status_id: Payment::CONST::STATUS_ID_ROLLED_BACK
        )
      end

      it 'changes balance' do
        expect { subject }.to change { account.reload.balance }.from(150).to(100)
      end
    end

    context 'when status is pending' do
      let(:service_params) { { payment: record } }
      let!(:record) { FactoryBot.create(:payment, :pending) }
      let(:err_message) { 'Status of payment should be completed' }

      it 'raises error' do
        expect { subject }.to raise_error Payment::Rollback::Error, err_message

        expect(record).to have_attributes(
          rolledback_at: nil,
          status_id: Payment::CONST::STATUS_ID_PENDING
        )
      end
    end
  end
end
