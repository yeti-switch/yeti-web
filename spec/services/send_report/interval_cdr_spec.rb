# frozen_string_literal: true

RSpec.describe SendReport::IntervalCdr do
  describe '.call' do
    subject { described_class.call(report: report) }

    let(:contact) { FactoryBot.create(:contact, contractor: contractor) }
    let(:contractor) { FactoryBot.create(:vendor, smtp_connection: smtp_connection) }
    let(:smtp_connection) { FactoryBot.create(:smtp_connection) }

    let!(:report) do
      FactoryBot.create(:interval_cdr, group_by: group_by, send_to: [contact.id])
    end

    let!(:interval_data) do
      FactoryBot.create(:interval_data,
                        rateplan: rateplan,
                        report: report,
                        customer: customer,
                        vendor: vendor,
                        destination_rate_policy_id: destination_rate_policy_id,
                        routing_group: routing_group,
                        orig_gw: orig_gw,
                        term_gw: term_gw,
                        destination: destination,
                        dialpeer: dialpeer,
                        customer_auth: customer_auth,
                        vendor_acc: vendor_acc,
                        customer_acc: customer_acc,
                        vendor_invoice: vendor_invoice,
                        customer_invoice: customer_invoice,
                        node: node,
                        pop: pop,
                        dst_country: dst_country,
                        dst_network: dst_network,
                        timestamp: timestamp,
                        aggregated_value: aggregated_value)
    end

    let(:group_by) do
      %w[
        rateplan_id
        routing_group_id
        orig_gw_id
        term_gw_id
        destination_id
        dialpeer_id
        customer_auth_id
        vendor_acc_id
        customer_acc_id
        vendor_id
        customer_id
        vendor_invoice_id
        customer_invoice_id
        node_id
        pop_id
        dst_country_id
        dst_network_id
        destination_rate_policy_id
        disconnect_initiator_id
      ]
    end

    let(:customer) { FactoryBot.create(:customer) }
    let(:vendor) { FactoryBot.create(:vendor) }
    let(:rateplan) { FactoryBot.create(:rateplan) }
    let(:destination_rate_policy_id) { Routing::DestinationRatePolicy::POLICY_FIXED }
    let(:routing_group) { FactoryBot.create(:routing_group) }
    let(:orig_gw) { FactoryBot.create(:gateway) }
    let(:term_gw) { FactoryBot.create(:gateway) }
    let(:destination) { FactoryBot.create(:destination, prefix: '380') }
    let(:dialpeer) { FactoryBot.create(:dialpeer, prefix: '380') }
    let(:customer_auth) { FactoryBot.create(:customers_auth) }
    let(:vendor_acc) { FactoryBot.create(:account) }
    let(:customer_acc) { FactoryBot.create(:account, :with_customer) }
    let(:vendor_invoice) { FactoryBot.create(:invoice, :vendor, :approved, :auto_full, account: vendor_acc) }
    let(:customer_invoice) { FactoryBot.create(:invoice, :customer, :approved, :auto_full, account: customer_acc) }
    let(:node) { FactoryBot.create(:node) }
    let(:pop) { FactoryBot.create(:pop) }
    let(:dst_country) { System::Country.take }
    let(:dst_network) { System::Network.take }
    let(:timestamp) { Time.now.utc }
    let(:aggregated_value) { 755.0 }

    let(:expected_csv) do
      headers = [
        'Rateplan',
        'Routing group',
        'Orig gw',
        'Term gw',
        'Destination',
        'Dialpeer',
        'Customer auth',
        'Vendor acc',
        'Customer acc',
        'Vendor',
        'Customer',
        'Vendor invoice',
        'Customer invoice',
        'Node',
        'Pop',
        'Dst country',
        'Dst network',
        'Destination rate policy',
        'Disconnect initiator',
        'Timestamp',
        'Aggregated value'
      ]
      rows = [
        [
          rateplan.display_name,
          routing_group.display_name,
          orig_gw.display_name,
          term_gw.display_name,
          destination.display_name,
          dialpeer.display_name,
          customer_auth.display_name,
          vendor_acc.display_name,
          customer_acc.display_name,
          vendor.display_name,
          customer.display_name,
          vendor_invoice.display_name,
          customer_invoice.display_name,
          node.display_name,
          pop.display_name,
          dst_country.display_name,
          dst_network.display_name,
          'Fixed',
          'Switch',
          timestamp.to_s,
          aggregated_value.to_s
        ]
      ]

      [headers, *rows]
    end

    let(:email_log) { Log::EmailLog.last! }

    it 'correct email log should be created' do
      expect { subject }.to change { Log::EmailLog.count }.by(1)

      csv_attachment = CSV.parse(email_log.attachments.first.data)
      expect(csv_attachment).to match_array(expected_csv)
      expect(email_log.subject).to eq('Interval CDR report')
    end
  end
end
