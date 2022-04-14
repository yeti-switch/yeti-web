# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Cdr Exports' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'cdr-exports' }
  let(:country) { System::Country.take! }

  required_params = %i[fields filters]

  optional_params = %i[callback-url export-type]

  post '/api/rest/admin/cdr/cdr-exports' do
    parameter :type, 'Resource type (cdr-exports)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)

    let(:fields) { %w[id success] }
    let(:filters) do
      {
        time_start_gteq: '2018-01-01 00:00:00',
        time_start_lteq: '2018-01-01 23:59:59.999999',
        time_start_lt: '2018-01-02 00:00:00',
        customer_id_eq: 1234,
        customer_external_id_eq: 1235,
        customer_acc_id_eq: 1236,
        customer_acc_external_id_eq: 241_251,
        vendor_id_eq: 1237,
        vendor_external_id_eq: 1238,
        vendor_acc_id_eq: 1239,
        vendor_acc_external_id_eq: 1240,
        is_last_cdr_eq: true,
        success_eq: true,
        customer_auth_id_eq: 1241,
        customer_auth_external_id_eq: 2_151_321,
        failed_resource_type_id_eq: 25,
        src_prefix_in_contains: '1111',
        dst_prefix_in_contains: '2222',
        src_prefix_routing_contains: '3333',
        dst_prefix_routing_contains: '4444',
        src_prefix_out_contains: '5555',
        dst_prefix_out_contains: '6666',
        src_country_iso_eq: country.iso2,
        dst_country_iso_eq: country.iso2,
        routing_tag_ids_include: 2,
        routing_tag_ids_exclude: 5,
        routing_tag_ids_empty: false,
        orig_gw_id_eq: 1242,
        orig_gw_external_id_eq: 1243,
        term_gw_id_eq: 1244,
        term_gw_external_id_eq: 1245
      }
    end
    let(:'callback-url') { 'test.url.com' }
    let(:'export-type') { 'Base' }
    before do
      # add allowed filters must be filled in this test.
      allowed_filters = CdrExport::FiltersModel.attribute_types.keys.map(&:to_sym)
      allowed_filters -= %i[dst_country_id_eq src_country_id_eq]
      allowed_filters += %i[dst_country_iso_eq src_country_iso_eq]
      expect(filters.keys).to match_array(allowed_filters)
    end

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  delete '/api/rest/admin/cdr/cdr-exports/:id' do
    let(:id) { create(:cdr_export).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
