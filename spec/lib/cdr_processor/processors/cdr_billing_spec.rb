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

  let(:batch_id) { (Time.now.to_f * 1000).to_i }

  before do
    consumer.instance_variable_set(:@batch_id, batch_id)
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

  describe '#perform_events' do
    let(:cdr_data) do
      {
        'id' => 1,
        'dialpeer_reverse_billing' => vendor_reverse,
        'vendor_price' => 5.0,
        'vendor_acc_id' => vendor_acc.id,
        'destination_reverse_billing' => customer_reverse,
        'customer_price' => 10.0,
        'customer_acc_id' => customer_acc.id,
        'lega_q850_params' => 'reason=q850',
        'dump_level_id' => 3
      }
    end
    let(:events) { [instance_double(CdrProcessor::Event, data: cdr_data)] }

    subject { consumer.perform_events(events) }

    it 'sends only billing.cdr_v2 fields to the stored procedure' do
      expect(consumer).to receive(:perform_group) do |group|
        expect(group.size).to eq(1)
        expect(group.first.keys).to match_array(cdr_data.keys - %w[lega_q850_params dump_level_id])
      end
      subject
    end

    it 'bills the CDR' do
      subject
      expect(vendor_acc.reload.balance.to_f).to eq(105.0)
      expect(customer_acc.reload.balance.to_f).to eq(90.0)
    end
  end

  describe 'BILLED_FIELDS' do
    let(:cdr_v2_attributes) do
      CdrProcessor::PrimaryDb.connection.select_values(<<~SQL)
        SELECT attname FROM pg_attribute
        WHERE attrelid = 'billing.cdr_v2'::regclass AND attnum > 0 AND NOT attisdropped
        ORDER BY attnum
      SQL
    end

    it 'matches the billing.cdr_v2 composite type' do
      expect(described_class::BILLED_FIELDS).to eq(cdr_v2_attributes)
    end
  end

  context 'when the group spans several parts' do
    let(:cdrs) do
      Array.new(2) do |i|
        {
          id: i,
          dialpeer_reverse_billing: vendor_reverse,
          vendor_price: 5.0,
          vendor_acc_id: vendor_acc.id,
          destination_reverse_billing: customer_reverse,
          customer_price: 10.0,
          customer_acc_id: customer_acc.id
        }
      end
    end

    before { stub_const("#{described_class}::PART_SIZE", 1) }

    it 'bills every part' do
      subject
      expect(vendor_acc.reload.balance.to_f).to eq(110.0)
      expect(customer_acc.reload.balance.to_f).to eq(80.0)
    end

    it 'sends one statement per part' do
      expect(consumer).to receive(:bill_part).twice.and_call_original
      subject
    end

    it 'wraps the parts in a transaction' do
      expect(consumer.primary_connection).to receive(:transaction).and_call_original
      subject
    end

    # requires_new gives the savepoint that perform_group's own transaction is
    # in production - under transactional fixtures it would otherwise join the
    # example's transaction and never roll back on its own.
    it 'rolls the whole batch back when a part fails' do
      calls = 0
      allow(consumer).to receive(:bill_part).and_wrap_original do |method, *args|
        calls += 1
        raise 'part failed' if calls == 2

        method.call(*args)
      end

      expect do
        consumer.primary_connection.transaction(requires_new: true) { subject }
      end.to raise_error(RuntimeError, 'part failed')

      expect(customer_acc.reload.balance.to_f).to eq(100.0)
      expect(vendor_acc.reload.balance.to_f).to eq(100.0)
      expect(Billing::CdrBatch.where(id: batch_id)).to be_empty
    end
  end

  context 'when the batch was already billed' do
    before { SqlCaller::Yeti.select_value('SELECT billing.bill_cdr_batch_start(?)', batch_id) }

    it 'does not bill it again' do
      subject
      expect(vendor_acc.reload.balance.to_f).to eq(100.0)
      expect(customer_acc.reload.balance.to_f).to eq(100.0)
    end

    it 'does not send any part' do
      expect(consumer).not_to receive(:bill_part)
      subject
    end
  end
end
