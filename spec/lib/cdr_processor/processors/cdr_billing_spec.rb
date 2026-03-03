# frozen_string_literal: true

RSpec.describe CdrProcessor::Processors::CdrBilling do
  let(:logger) { Logger.new(IO::NULL) }
  let(:config) { {} }
  let(:consumer) { described_class.new(logger, 'cdr_billing', 'cdr_billing', config) }

  let(:vendor_reverse) { false }
  let(:customer_reverse) { false }

  let!(:vendor_acc) do
    create(:account, contractor: create(:contractor, vendor: true), balance: 100, min_balance: 0, max_balance: 200)
  end

  let!(:customer_acc) do
    create(:account, contractor: create(:contractor, customer: true), balance: 100, min_balance: 0, max_balance: 200)
  end

  let(:cdrs) do
    [
      {
        id: 1,
        dialpeer_reverse_billing: vendor_reverse,
        vendor_price: 5.0,
        vendor_acc_id: vendor_acc.id,
        destination_reverse_billing: customer_reverse,
        customer_price: 10.0,
        customer_acc_id: customer_acc.id
      }
    ]
  end

  before do
    consumer.instance_variable_set(:@batch_id, (Time.now.to_f * 1000).to_i)
  end

  subject { consumer.perform_group cdrs }

  context 'normal billing mode' do
    it 'customer balance changes by minus $10, vendor plus $5' do
      subject
      expect(vendor_acc.reload.balance.to_f).to eq(105.0)
      expect(customer_acc.reload.balance.to_f).to eq(90.0)
    end
  end

  context 'reverse billing for customer' do
    let(:customer_reverse) { true }

    it 'customer balance increase' do
      subject
      expect(vendor_acc.reload.balance.to_f).to eq(105.0)
      expect(customer_acc.reload.balance.to_f).to eq(110.0)
    end
  end

  context 'reverse billing for vendor' do
    let(:vendor_reverse) { true }

    it 'vendor balance decrease' do
      subject
      expect(vendor_acc.reload.balance.to_f).to eq(95.0)
      expect(customer_acc.reload.balance.to_f).to eq(90.0)
    end
  end
end
