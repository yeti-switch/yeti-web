# frozen_string_literal: true

RSpec.describe 'Copy CDR Export', js: :true do
  subject do
    visit cdr_export_path(cdr_export)
    click_link 'Copy'
    click_button 'Create Base'
  end

  include_context :login_as_admin

  let!(:account) { create(:account, :with_customer) }
  let!(:vendor) { create(:contractor, vendor: true, external_id: 302) }
  let!(:vendor_acc) { create(:account, external_id: 303, contractor: vendor) }
  let!(:customer_auth) { create(:customers_auth, external_id: 300, external_type: 'term') }
  let!(:country) { create(:country_uniq) }
  let!(:gateway) { create(:gateway, external_id: 301) }
  let!(:routing_tag) { create(:routing_tag) }
  let(:filters) do
    {
      time_start_gteq: '2018-01-01',
      time_start_lteq: '2018-03-01',
      time_start_lt: '2018-03-01',
      customer_id_eq: account.contractor.id,
      customer_external_id_eq: 124,
      customer_acc_id_eq: account.id,
      customer_acc_external_id_eq: 126,
      success_eq: true,
      duration_eq: 999,
      duration_lteq: 1000,
      duration_gteq: 998,
      failed_resource_type_id_eq: 127,
      vendor_id_eq: vendor_acc.contractor.id,
      vendor_external_id_eq: vendor_acc.contractor.external_id,
      vendor_acc_id_eq: vendor_acc.id,
      vendor_acc_external_id_eq: vendor_acc.external_id,
      customer_auth_id_eq: customer_auth.id,
      customer_auth_external_id_eq: customer_auth.external_id,
      is_last_cdr_eq: true,
      src_prefix_in_contains: '123',
      src_prefix_in_eq: '124',
      src_prefix_routing_contains: '125',
      src_prefix_routing_eq: '126',
      src_prefix_out_contains: '127',
      src_prefix_out_eq: '128',
      dst_prefix_in_contains: '129',
      dst_prefix_routing_contains: '130',
      dst_prefix_routing_eq: '131',
      dst_prefix_out_contains: '132',
      dst_prefix_out_eq: '133',
      src_country_id_eq: country.id,
      dst_country_id_eq: country.id,
      routing_tag_ids_include: routing_tag.id,
      routing_tag_ids_exclude: routing_tag.id,
      routing_tag_ids_empty: false,
      orig_gw_id_eq: gateway.id,
      orig_gw_external_id_eq: gateway.external_id,
      term_gw_id_eq: gateway.id,
      term_gw_external_id_eq: gateway.external_id,
      customer_auth_external_type_eq: customer_auth.external_type,
      customer_auth_external_type_not_eq: customer_auth.external_type,
      customer_auth_external_id_in: [],
      src_country_iso_in: [country.iso2, country.iso2],
      dst_country_iso_in: [country.iso2, country.iso2]
    }
  end
  let!(:cdr_export) { create(:cdr_export, :completed, filters:) }
  let(:formated_time_filters) do
    {
      time_start_gteq: '2018-01-01T00:00:00.000Z',
      time_start_lt: '2018-03-01T00:00:00.000Z',
      time_start_lteq: '2018-03-01T00:00:00.000Z'
    }
  end

  it 'creates new cdr_export from current' do
    expect {
      subject
      expect(page).to have_flash_message('Cdr export was successfully created.')
    }.to change { CdrExport.count }.by(1)

    new_cdr_export = CdrExport.last!
    expect(page).to have_current_path cdr_export_path(new_cdr_export)

    expect(new_cdr_export).to have_attributes(
                            type: cdr_export.type,
                            callback_url: cdr_export.callback_url.to_s,
                            fields: match_array(cdr_export.fields),
                            status: 'Pending',
                            filters_json: filters.merge(formated_time_filters)
                          )
  end

  context 'with wrong filters' do
    let(:filters) do
      {
        time_start_gteq: '2018-01-01',
        time_start_lteq: '2018-03-01',
        customer_id_eq: 9999,
        customer_external_id_eq: 9998,
        customer_acc_id_eq: 9997,
        customer_auth_id_eq: 9996,
        src_country_id_eq: 9995,
        dst_country_id_eq: 9994,
        orig_gw_id_eq: 9993,
        term_gw_id_eq: 9992,
        src_country_iso_in: %w[DD],
        dst_country_iso_in: %w[FF]
      }
    end

    it 'creates new cdr_export from current' do
      expect {
        subject
        expect(page).to have_flash_message('Cdr export was successfully created.')
      }.to change { CdrExport.count }.by(1)

      new_cdr_export = CdrExport.last!
      expect(page).to have_current_path cdr_export_path(new_cdr_export)

      expect(new_cdr_export).to have_attributes(
                              type: cdr_export.type,
                              callback_url: cdr_export.callback_url.to_s,
                              fields: match_array(cdr_export.fields),
                              status: 'Pending',
                              filters_json: {
                                time_start_gteq: '2018-01-01T00:00:00.000Z',
                                time_start_lteq: '2018-03-01T00:00:00.000Z',
                                customer_auth_external_id_in: [],
                                src_country_iso_in: [],
                                dst_country_iso_in: [],
                                customer_external_id_eq: 9998
                              }
                            )
    end
  end
end
