# frozen_string_literal: true

RSpec.describe 'Index interval cdr interval items', js: true do
  subject do
    visit report_interval_cdr_interval_items_path report_interval_cdr_id: report.id
  end

  include_context :login_as_admin

  let!(:report) do
    FactoryBot.create(:interval_cdr, group_by: group_by)
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
  let(:vendor_invoice) { FactoryBot.create(:invoice, :approved, :auto_full, account: vendor_acc) }
  let(:customer_invoice) { FactoryBot.create(:invoice, :approved, :auto_full, account: customer_acc) }
  let(:node) { FactoryBot.create(:node) }
  let(:pop) { FactoryBot.create(:pop) }
  let(:dst_country) { System::Country.take }
  let(:dst_network) { System::Network.take }
  let(:timestamp) { Time.now.utc }
  let(:aggregated_value) { 755.0 }

  it 'should render index page properly' do
    subject
    expect(page).to have_table
    within_table_row(id: interval_data.id) do
      expect(page).to have_table_cell(text: customer.display_name, column: 'Customer')
      expect(page).to have_table_cell(text: vendor.display_name, column: 'Vendor')
      expect(page).to have_table_cell(text: rateplan.display_name, column: 'Rateplan')
      expect(page).to have_table_cell(text: routing_group.display_name, column: 'Routing Group')
      expect(page).to have_table_cell(text: orig_gw.display_name, column: 'Orig Gw')
      expect(page).to have_table_cell(text: term_gw.display_name, column: 'Term Gw')
      expect(page).to have_table_cell(text: destination.display_name, column: 'Destination')
      expect(page).to have_table_cell(text: dialpeer.display_name, column: 'Dialpeer')
      expect(page).to have_table_cell(text: customer_auth.display_name, column: 'Customer Auth')
      expect(page).to have_table_cell(text: vendor_acc.display_name, column: 'Vendor Acc')
      expect(page).to have_table_cell(text: customer_acc.display_name, column: 'Customer Acc')
      expect(page).to have_table_cell(text: vendor_invoice.display_name, column: 'Vendor Invoice')
      expect(page).to have_table_cell(text: customer_invoice.display_name, column: 'Customer Invoice')
      expect(page).to have_table_cell(text: node.display_name, column: 'Node')
      expect(page).to have_table_cell(text: pop.display_name, column: 'Pop')
      expect(page).to have_table_cell(text: dst_country.display_name, column: 'Dst Country')
      expect(page).to have_table_cell(text: dst_network.display_name, column: 'Dst Network')
      expect(page).to have_table_cell(text: 'Fixed', column: 'Destination Rate Policy')
      expect(page).to have_table_cell(text: 'Switch', column: 'Disconnect Initiator')
    end

    expect(page).to have_select 'Customer', visible: false
    expect(page).to have_select 'Vendor', visible: false
    expect(page).to have_select 'Rateplan', visible: false
    expect(page).to have_select 'Routing group', visible: false
    expect(page).to have_select 'Orig gw', visible: false
    expect(page).to have_select 'Term gw', visible: false
    expect(page).to have_select 'Customer auth', visible: false
    expect(page).to have_select 'Vendor acc', visible: false
    expect(page).to have_select 'Customer acc', visible: false
    expect(page).to have_select 'Vendor invoice', visible: false
    expect(page).to have_select 'Customer invoice', visible: false
    expect(page).to have_select 'Node', visible: false
    expect(page).to have_select 'Pop', visible: false
    expect(page).to have_select 'Dst country', visible: false
    expect(page).to have_select 'Dst network', visible: false
  end

  describe 'csv', js: false do
    subject do
      super()
      click_on 'CSV'
    end

    let(:expected_filename) { "interval-items-#{Time.zone.today.strftime('%F')}.csv" }

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

    it 'downloads correct csv' do
      subject
      expect(page.response_headers['Content-Disposition']).to eq("attachment; filename=\"#{expected_filename}\"")
      expect(page.status_code).to eq(200)
      expect(page.response_headers['Content-Type']).to eq('text/csv; charset=utf-8')
      expect(page_csv).to match_array(expected_csv)
    end
  end
end
