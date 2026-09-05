# frozen_string_literal: true

RSpec.describe 'billing.bill_cdr_batch_start' do
  subject do
    SqlCaller::Yeti.select_value('SELECT billing.bill_cdr_batch_start(?)', batch_id)
  end

  let(:batch_id) { 1 }

  it 'returns true' do
    expect(subject).to eq(true)
  end

  it 'marks the batch' do
    expect { subject }.to change { Billing::CdrBatch.where(id: batch_id).count }.from(0).to(1)
  end

  it 'claims the batch for the transaction' do
    subject
    claim = SqlCaller::Yeti.select_value("SELECT current_setting('billing.cdr_batch', true)")
    expect(claim).to eq(batch_id.to_s)
  end

  context 'when the batch was already billed' do
    before { SqlCaller::Yeti.select_value('SELECT billing.bill_cdr_batch_start(?)', batch_id) }

    it 'returns false' do
      expect(subject).to eq(false)
    end

    it 'does not mark the batch twice' do
      expect { subject }.not_to change { Billing::CdrBatch.where(id: batch_id).count }.from(1)
    end
  end
end
