# frozen_string_literal: true

RSpec.describe Jobs::CallsMonitoring, '#call' do
  subject do
    job.call
  end

  let(:job) do
    described_class.new(double)
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

  let(:account_balance) do
    1_000
  end

  let(:vendor_balance) do
    1_000
  end

  let!(:codec_group) do
    create(:codec_group)
  end

  let!(:origin_gateway) do
    create(:gateway,
           enabled: true,
           allow_origination: true,
           codec_group: codec_group,
           contractor: account.contractor)
  end

  let!(:term_gateway) do
    create(:gateway,
           enabled: true,
           allow_termination: true,
           codec_group: codec_group,
           contractor: vendor_acc.contractor)
  end

  let!(:account) do
    create(:account,
           balance: account_balance,
           min_balance: 0,
           max_balance: account_balance * 2,
           vat: 0,
           external_id: 123,
           contractor: create(:customer))
  end

  let!(:vendor_acc) do
    create(:account,
           balance: vendor_balance,
           min_balance: 0,
           max_balance: vendor_balance * 2,
           external_id: 456,
           contractor: create(:vendor))
  end

  let(:customers_auth) do
    create(:customers_auth,
           reject_calls: customers_auth_reject_calls,
           customer: account.contractor,
           account: account,
           gateway: origin_gateway)
  end

  let(:customer_auth_id) do
    customers_auth.id
  end

  let(:customers_auth_reject_calls) do
    false
  end

  let(:node) { create(:node) }

  let(:cdr_filter_mock) do
    double('Yeti::CdrsFilter', raw_cdrs: [{ 'node_id' => 1 }, { 'node_id' => 2 }])
  end

  let(:customer_acc_check_balance) { true }

  let(:cdr_list_unsorted) do
    [
      # first call_price is equal to 1.02 without vat
      {
        'local_tag' => 'normal-call',
        'node_id' => node.id,
        # Customer
        'customer_id' => account.contractor.id,
        'customer_acc_id' => account.id,
        'customer_acc_vat' => account.vat.to_s,
        'customer_acc_external_id' => account.external_id,
        # Vendor
        'vendor_id' => vendor_acc.contractor.id,
        'vendor_acc_id' => vendor_acc.id,
        'vendor_acc_external_id' => vendor_acc.external_id,
        'customer_auth_id' => customer_auth_id,
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
        'dialpeer_reverse_billing' => false,
        'src_prefix_routing' => '123457',
        'dst_prefix_routing' => '654320',

        'orig_gw_id' => origin_gateway.id,
        'term_gw_id' => term_gateway.id

      },
      {
        'local_tag' => 'reverse-call',
        'node_id' => node.id,
        # Customer
        'customer_id' => account.contractor.id,
        'customer_acc_id' => account.id,
        'customer_acc_vat' => account.vat.to_s,
        'customer_acc_external_id' => account.external_id,
        # Vendor
        'vendor_id' => vendor_acc.contractor.id,
        'vendor_acc_id' => vendor_acc.id,
        'vendor_acc_external_id' => vendor_acc.external_id,
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
        'dialpeer_reverse_billing' => true,
        'src_prefix_routing' => '123456',
        'dst_prefix_routing' => '654321',

        'orig_gw_id' => origin_gateway.id,
        'term_gw_id' => term_gateway.id
      }
    ].map(&:symbolize_keys)
  end

  let!(:another_account) do
    FactoryBot.create(:account)
  end

  before do
    # Yeti::CdrsFilter.new(Node.all).raw_cdrs(*)
    allow(Yeti::CdrsFilter).to receive(:new) { cdr_filter_mock }
    allow(cdr_filter_mock).to receive(:raw_cdrs) { cdr_list_unsorted }
    allow(Stats::ActiveCall).to receive(:create_stats)
    allow(Stats::ActiveCallOrigGateway).to receive(:create_stats)
    allow(Stats::ActiveCallTermGateway).to receive(:create_stats)
  end

  context 'when YetiConfig.calls_monitoring.write_account_stats=true' do
    before do
      expect(YetiConfig.calls_monitoring).to receive(:write_account_stats).and_return(true)
    end

    it 'creates Stats::ActiveCallAccount' do
      expect(ActiveCalls::CreateAccountStats).to receive(:call).with(
        customer_calls: be_present,
        vendor_calls: be_present,
        current_time: be_within(2).of(Time.now)
      ).and_call_original

      # account + vendor_acc + another_account
      expect { subject }.to change { Stats::ActiveCallAccount.count }.by(3)

      account_stats = Stats::ActiveCallAccount.where(account_id: account.id).to_a
      expect(account_stats.size).to eq 1
      expect(account_stats.first).to have_attributes(
                                       terminated_count: 0,
                                       originated_count: 2
                                     )

      vendor_acc_stats = Stats::ActiveCallAccount.where(account_id: vendor_acc.id).to_a
      expect(vendor_acc_stats.size).to eq 1
      expect(vendor_acc_stats.first).to have_attributes(
                                          terminated_count: 2,
                                          originated_count: 0
                                        )

      another_account_stats = Stats::ActiveCallAccount.where(account_id: another_account.id).to_a
      expect(another_account_stats.size).to eq(1)
      expect(another_account_stats.first).to have_attributes(
                                               terminated_count: 0,
                                               originated_count: 0
                                             )
    end
  end

  context 'when YetiConfig.calls_monitoring.write_account_stats=false' do
    before do
      expect(YetiConfig.calls_monitoring).to receive(:write_account_stats).and_return(false)
    end

    it 'creates Stats::ActiveCallAccount' do
      expect(ActiveCalls::CreateAccountStats).not_to receive(:call)
      expect { subject }.to change { Stats::ActiveCallAccount.count }.by(0)
    end
  end

  context 'when Customer and Vendor have enough money' do
    it 'does not send prometheus metrics' do
      expect { subject }.to send_prometheus_metrics.exactly(0)
    end

    include_examples :keep_calls

    context 'with prometheus enabled' do
      before { allow(PrometheusConfig).to receive(:enabled?).and_return(true) }

      it 'sends prometheus metrics' do
        expect { subject }.to send_prometheus_metrics
          .exactly(3)
          .with(type: 'yeti_ac', total: 2)
          .with(
                                type: 'yeti_ac',
                                account_originated: 2,
                                account_originated_unique_src: 2,
                                account_originated_unique_dst: 2,
                                account_price_originated: -3.96, # +1.04 normal call -5 reverse call
                                metric_labels: {
                                  account_id: account.id,
                                  account_external_id: account.external_id
                                }
                              )
          .with(
                                type: 'yeti_ac',
                                account_terminated: 2,
                                account_price_terminated: 5.0, # +9 normal call -4 reverse call
                                metric_labels: {
                                  account_id: vendor_acc.id,
                                  account_external_id: vendor_acc.external_id
                                }
                              )
      end
    end
  end

  context 'when origin gw disabled for origination' do
    before do
      origin_gateway.update!(allow_origination: false)
    end
    include_examples :drop_calls
  end

  context 'when term gw disabled' do
    before do
      term_gateway.disable!
    end
    include_examples :drop_calls
  end

  context 'when term gw disabled for termination' do
    before do
      term_gateway.update!(allow_termination: false)
    end
    include_examples :drop_calls
  end

  context 'when origin gw disabled' do
    before do
      origin_gateway.disable!
    end
    include_examples :drop_calls
  end

  context 'when Customer has zero balance' do
    let(:account_balance) do
      0
    end
    include_examples :drop_calls
  end

  context 'when Customer has money for the call' do
    let(:cdr_list_unsorted) do
      super().select { |c| c[:local_tag] == 'normal-call' }
    end
    let(:account_balance) do
      # active calls cost on next calls monitoring run (after 1 min)
      2.04 # 1.02 * 2
    end

    include_examples :keep_calls
  end

  context 'when vendor contractor disabled' do
    before do
      vendor_acc.contractor.disable!
    end
    include_examples :drop_calls
  end

  context 'when vendor contractor is customer' do
    before do
      vendor_acc.contractor.update!(vendor: false, customer: true)
    end
    include_examples :drop_calls
  end

  context 'when account contractor disabled' do
    before do
      account.contractor.disable!
    end
    include_examples :drop_calls
  end

  context 'when account contractor is vendor' do
    before do
      account.contractor.update!(customer: false, vendor: true)
    end
    include_examples :drop_calls
  end

  context 'when Customer has no money for the call after vat apply' do
    let(:cdr_list_unsorted) do
      super().select { |c| c[:local_tag] == 'normal-call' }
    end
    let(:account_balance) do
      1.02
    end

    before do
      account.update!(vat: 30)
    end

    include_examples :drop_calls
  end

  context 'when Vendor has no money for the call' do
    let(:vendor_balance) do
      0
    end

    include_examples :drop_calls
  end

  context 'when GuiConfig.random_disconnect_enable=true' do
    before do
      allow(GuiConfig).to receive(:random_disconnect_enable).and_return(true)
      allow(GuiConfig).to receive(:random_disconnect_length).and_return(max_length)
    end

    context 'when max_length greater than calls duration' do
      let(:max_length) { 600 }

      include_examples :keep_calls
    end

    context 'when duration is nil' do
      let(:max_length) { 10 }
      let(:cdr_list_unsorted) do
        super().map { |r| r.merge(duration: nil) }
      end

      include_examples :keep_calls
    end
  end

  context 'Customer calls' do
    context 'when calls cost is within mim-max balance' do
      let(:account_balance) do
        50
      end

      include_examples :keep_calls
    end

    context 'when calls cost is below min_balance' do
      before do
        account.update!(balance: 1.15, min_balance: 1.14, max_balance: 10_000)
      end

      context 'when reserved call exits' do
        include_examples :keep_calls
      end

      context 'when reserved does not exit' do
        let(:cdr_list_unsorted) do
          super().select { |c| c[:local_tag] == 'normal-call' }
        end
        it 'total calls cost exceeds min_balance. Drop normal calls' do
          expect_any_instance_of(Node).to receive(:drop_call).with('normal-call')
          subject
        end

        it_behaves_like :keep_emergency_calls
      end
    end

    context 'when calls cost is above max_balance' do
      before do
        account.update!(balance: 10, max_balance: 4, min_balance: 1)
      end
      it 'total calls cost exceeds max_balance. Drop reverse calls' do
        expect_any_instance_of(Node).to receive(:drop_call).with('reverse-call')
        subject
      end

      it_behaves_like :keep_emergency_calls
    end
  end # Customer

  context 'Vendor calls' do
    context 'when calls cost is within mim-max balance' do
      include_examples :keep_calls
    end

    context 'when calls cost is below min_balance' do
      before do
        vendor_acc.update!(balance: -6, max_balance: 100)
      end

      it 'total calls cost exceeds min_balance. Drop reverse calls' do
        expect_any_instance_of(Node).to receive(:drop_call).with('reverse-call')
        subject
      end

      it_behaves_like :keep_emergency_calls
    end

    context 'when calls cost is above max_balance' do
      before do
        vendor_acc.update!(balance: 0, max_balance: 4)
      end

      it 'total calls cost exceeds max_balance. Drop normal calls' do
        expect_any_instance_of(Node).to receive(:drop_call).with('normal-call')
        subject
      end

      it_behaves_like :keep_emergency_calls
    end
  end # vendor

  context 'CustomersAuth#reject_calls' do
    context 'when CDR#customer_auth_id is NULL' do
      let(:customer_auth_id) { '' }
      include_examples :keep_calls
    end

    context 'when not linked to real CustomersAuth' do
      let(:customer_auth_id) { customers_auth.id + 11_122 }
      include_examples :keep_calls
    end

    context 'when CustomersAuth#reject_calls = FALSE' do
      let(:customers_auth_reject_calls) { false }
      include_examples :keep_calls
    end

    context 'when CustomersAuth#reject_calls = TRUE' do
      let(:customers_auth_reject_calls) { true }

      it 'drop first call(with customer_auth_id)' do
        expect_any_instance_of(Node).to receive(:drop_call).with('normal-call')
        expect_any_instance_of(Node).not_to receive(:drop_call).with('reverse-call')
        subject
      end
    end
  end # CustomersAuth#reject_calls
end
