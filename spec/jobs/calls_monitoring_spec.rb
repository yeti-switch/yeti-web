require 'spec_helper'

describe Jobs::CallsMonitoring do

  shared_context :customer_acc do |balance: 1_000, max_balance: nil, vat: 0, min_balance: 0|
    let(:account) do
      create(:account,
             balance: balance,
             min_balance: min_balance,
             max_balance: max_balance || (balance * 2),
             vat: vat,
             contractor: create(:customer))
    end
  end

  shared_context :vendor_acc do |balance: 1_000, max_balance: nil|
    let(:vendor_acc) do
        create(:account,
             balance: balance,
             min_balance: 0,
             max_balance: max_balance || (balance * 2),
             contractor: create(:vendor))
    end
  end

  shared_examples :keep_emergency_calls do
    let(:customer_acc_check_balance) { false }
    include_examples :keep_calls
  end

  shared_examples :keep_calls do
    it 'does not drop any calls' do
      expect_any_instance_of(Node).not_to receive(:drop_call)
      subject
    end
  end

  shared_examples :drop_calls do
    it 'drop calls' do
      expect_any_instance_of(Node).to receive(:drop_call).at_least(:once)
      subject
    end
  end

  let(:job) do
    described_class.create!
  end

  subject do
    job.start!
    job.run!
  end

  context '#run!' do
    let(:node) { Node.take }

    let(:cdr_filter_mock) do
      double('Yeti::CdrsFilter', raw_cdrs: [ {'node_id' => 1}, {'node_id' => 2} ])
    end

    let(:customer_acc_check_balance) { true }

    let(:cdr_list_unsorted) do
      [
        #first call_price is equal to 1.02 without vat
        {
          'local_tag' => 'normal-call',
          'node_id' => node.id,
          # Customer
          'customer_id' => account.contractor.id,
          'customer_acc_id' => account.id,
          'customer_acc_vat' => account.vat,
          # Vendor
          'vendor_id' => vendor_acc.contractor.id,
          'vendor_acc_id' => vendor_acc.id,
          'duration' => 61,
          # destination
          'destination_fee' => '1.0000',
          'destination_initial_interval' => 60,
          'destination_initial_rate' => '0.0100',

          'destination_next_interval' => 30,
          'destination_next_rate' => '0.0200',
          # dialpeer
          'dialpeer_fee' => '9.0000',
          'dialpeer_initial_interval' => 60,
          'dialpeer_initial_rate' => '0.0000',
          'dialpeer_next_interval' => 30,
          'dialpeer_next_rate' => '0.0000',
          'customer_acc_check_balance' => customer_acc_check_balance,
          'destination_reverse_billing' => false,
          'dialpeer_reverse_billing' => false
        },
        {
          'local_tag' => 'reverse-call',
          'node_id' => node.id,
          # Customer
          'customer_id' => account.contractor.id,
          'customer_acc_id' => account.id,
          'customer_acc_vat' => account.vat,
          # Vendor
          'vendor_id' => vendor_acc.contractor.id,
          'vendor_acc_id' => vendor_acc.id,
          'duration' => 36,
          # destination
          'destination_fee' => '5.0000',
          'destination_initial_interval' => 60,
          'destination_initial_rate' => '0.0000',
          'destination_next_interval' => 30,
          'destination_next_rate' => '0.0000',
          # dialpeer
          'dialpeer_fee' => '4.0000',
          'dialpeer_initial_interval' => 60,
          'dialpeer_initial_rate' => '0.0000',
          'dialpeer_next_interval' => 30,
          'dialpeer_next_rate' => '0.0000',
          'customer_acc_check_balance' => customer_acc_check_balance,
          'destination_reverse_billing' => true,
          'dialpeer_reverse_billing' => true
        }
      ]
    end

    before do
      # Yeti::CdrsFilter.new(Node.all).raw_cdrs(*)
      allow(Yeti::CdrsFilter).to receive(:new) { cdr_filter_mock }
      allow(cdr_filter_mock).to receive(:raw_cdrs) { cdr_list_unsorted }
      allow(job).to receive(:save_stats)
    end

    context 'when Customer and Vendor have enough money' do
      include_context :customer_acc
      include_context :vendor_acc

      include_examples :keep_calls
    end

    context 'when Customer' do
      include_context :customer_acc, balance: 0
      include_context :vendor_acc

      include_examples :drop_calls
    end

    context 'when Customer has money for the call' do
      let(:cdr_list_unsorted) do
        super().select{|c| c['local_tag'] == 'normal-call'}
      end
      include_context :customer_acc, balance: 1.02
      include_context :vendor_acc

      include_examples :keep_calls

    end

    context 'when Customer has no money for the call after vat apply' do
      let(:cdr_list_unsorted) do
        super().select{|c| c['local_tag'] == 'normal-call'}
      end
      include_context :customer_acc, balance: 1.02, vat: 30
      include_context :vendor_acc

      include_examples :drop_calls

    end

    context 'when Vendor has no money for the call' do
      include_context :customer_acc
      include_context :vendor_acc, balance: 0

      include_examples :drop_calls
    end

    context 'Customer calls' do

      context 'when calls cost is within mim-max balance' do
        include_context :customer_acc, balance: 6
        include_context :vendor_acc

        include_examples :keep_calls
      end

      context 'when calls cost is below min_balance' do
        include_context :customer_acc, balance: 1.15, min_balance: 1.14, max_balance: 10000
        include_context :vendor_acc
        context 'when reserved call exits' do
          include_examples :keep_calls
        end

        context 'when reserved does not exit' do
          let(:cdr_list_unsorted) do
            super().select{|c| c['local_tag'] == 'normal-call'}
          end
          it 'total calls cost exceeds min_balance. Drop normal calls' do
            expect_any_instance_of(Node).to receive(:drop_call).with('normal-call')
            subject
          end
          it_behaves_like :keep_emergency_calls
        end
        
      end

      context 'when calls cost is above max_balance' do
        include_context :customer_acc, balance: 10, max_balance: 4
        include_context :vendor_acc

        it 'total calls cost exceeds max_balance. Drop reverse calls' do
          expect_any_instance_of(Node).to receive(:drop_call).with('reverse-call')
          subject
        end

        it_behaves_like :keep_emergency_calls
      end

    end # Customer


    context 'Vendor calls' do

      context 'when calls cost is within mim-max balance' do
        include_context :customer_acc
        include_context :vendor_acc

        include_examples :keep_calls
      end

      context 'when calls cost is below min_balance' do
        include_context :customer_acc
        include_context :vendor_acc, balance: -6, max_balance: 100

        it 'total calls cost exceeds min_balance. Drop reverse calls' do
          expect_any_instance_of(Node).to receive(:drop_call).with('reverse-call')
          subject
        end

        it_behaves_like :keep_emergency_calls
      end

      context 'when calls cost is above max_balance' do
        include_context :customer_acc
        include_context :vendor_acc, balance: 0, max_balance: 4

        it 'total calls cost exceeds max_balance. Drop normal calls' do
          expect_any_instance_of(Node).to receive(:drop_call).with('normal-call')
          subject
        end

        it_behaves_like :keep_emergency_calls
      end

    end # vendor

  end

end
