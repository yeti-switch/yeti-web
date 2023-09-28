# frozen_string_literal: true

RSpec.describe 'Create new CDR export', js: true do
  subject do
    visit new_cdr_export_path
    fill_form!
    click_submit 'Create Cdr export'
  end

  include_context :login_as_admin

  let!(:customer) { create(:customer) }
  let!(:account) do
    create(:account, name: 'rspec', contractor: customer)
  end

  context 'with all filled attributes' do
    let(:fill_form!) do
      fill_in_chosen 'Fields', with: 'success', multiple: true
      fill_in_chosen 'Fields', with: 'id', multiple: true, exact: true
      fill_in_chosen 'Customer acc id eq', with: account.name, ajax: true
      fill_in 'Time start gteq', with: '2018-01-01'
      fill_in 'Time start lteq', with: '2018-03-01'
    end

    it 'cdr export should be created' do
      subject
      expect(page).to have_flash_message('Cdr export was successfully created.', type: :notice)

      cdr_export = CdrExport.last!
      expect(page).to have_current_path cdr_export_path(cdr_export)

      expect(cdr_export).to have_attributes(
        callback_url: '',
        fields: %w[id success],
        status: 'Pending',
        filters: a_kind_of(CdrExport::FiltersModel)
      )
      expect(cdr_export.filters_json).to match(
        time_start_gteq: '2018-01-01T00:00:00.000Z',
        time_start_lteq: '2018-03-01T00:00:00.000Z',
        customer_acc_id_eq: account.id,
        customer_auth_external_id_in: [],
        dst_country_iso_in: [],
        src_country_iso_in: []
      )
    end
  end

  context 'with inherited fields' do
    before do
      create :cdr_export, :completed, fields: %w[id success customer_id]
    end

    let(:fill_form!) do
      fill_in_chosen 'Customer acc id eq', with: account.name, ajax: true
      fill_in 'Time start gteq', with: '2018-01-01'
      fill_in 'Time start lteq', with: '2018-03-01'
    end

    it 'cdr export should be created' do
      subject
      expect(page).to have_text('Cdr export was successfully created.')

      cdr_export = CdrExport.last!
      expect(page).to have_current_path cdr_export_path(cdr_export)

      expect(cdr_export).to have_attributes(
        callback_url: '',
        fields: %w[id customer_id success],
        status: 'Pending',
        filters: a_kind_of(CdrExport::FiltersModel)
      )
      expect(cdr_export.filters_json).to match(
        time_start_gteq: '2018-01-01T00:00:00.000Z',
        time_start_lteq: '2018-03-01T00:00:00.000Z',
        customer_acc_id_eq: account.id,
        customer_auth_external_id_in: [],
        dst_country_iso_in: [],
        src_country_iso_in: []
      )
    end
  end

  context 'with all filled filters' do
    let!(:countries) { create_list(:country, 2, :uniq_name) }
    let!(:vendor) { create(:vendor) }
    let!(:vendor_acc) { create(:account, name: 'test', contractor: vendor) }
    let!(:customer_auth) { create(:customers_auth, external_id: 1235, external_type: 'term') }
    let!(:gateway1) { create(:gateway) }
    let!(:gateway2) { create(:gateway) }

    let(:fill_form!) do
      within_form_for do
        fill_in_chosen 'Fields', with: 'success', multiple: true
        fill_in_chosen 'Fields', with: 'id', multiple: true, exact: true

        # filters
        fill_in 'Customer external id eq', with: '1231'
        fill_in_chosen 'Customer id eq', with: "#{customer.name} | #{customer.id}"
        fill_in 'Customer acc external id eq', with: '1232'
        fill_in_chosen 'Customer acc id eq', with: "#{account.name} | #{account.id}"
        fill_in 'Vendor external id eq', with: '1233'
        fill_in_chosen 'Vendor id eq', with: "#{vendor.name} | #{vendor.id}"
        fill_in 'Vendor acc external id eq', with: '1234'
        fill_in_chosen 'Vendor acc id eq', with: "#{vendor_acc.name} | #{vendor_acc.id}"
        fill_in 'Customer auth external id eq', with: '1235'
        fill_in_chosen 'Customer auth id eq', with: "#{customer_auth.name} | #{customer_auth.id}"
        fill_in 'Src prefix in contains', with: 'src_prefix_in_test'
        fill_in 'Src prefix in eq', with: 'src_prefix_in_test'
        fill_in 'Src prefix routing contains', with: 'src_prefix_routing_test'
        fill_in 'Src prefix routing eq', with: 'src_prefix_routing_test'
        fill_in 'Src prefix out contains', with: 'src_prefix_out_test'
        fill_in 'Src prefix out eq', with: 'src_prefix_out_test'
        fill_in 'Dst prefix in contains', with: 'dst_prefix_in_test'
        fill_in 'Dst prefix in eq', with: 'dst_prefix_in_test'
        fill_in 'Dst prefix routing contains', with: 'dst_prefix_routing_test'
        fill_in 'Dst prefix routing eq', with: 'dst_prefix_routing_test'
        fill_in 'Dst prefix out contains', with: 'dst_prefix_out_test'
        fill_in 'Dst prefix out eq', with: 'dst_prefix_out_test'
        fill_in_chosen 'Src country id eq', with: countries.first.name
        fill_in_chosen 'Dst country id eq', with: countries.last.name
        fill_in 'Routing tag ids include', with: 2
        fill_in 'Routing tag ids exclude', with: 25
        fill_in_chosen 'Routing tag ids empty', with: 'No'
        fill_in_chosen 'Success eq', with: 'Yes'
        fill_in 'Duration eq', with: '30'
        fill_in 'Duration gteq', with: '0'
        fill_in 'Duration lteq', with: '60'
        fill_in_chosen 'Is last cdr eq', with: 'Yes'
        fill_in 'Failed resource type id eq', with: '10'
        fill_in 'Orig gw external id eq', with: '1236'
        fill_in_chosen 'Orig gw id eq', with: "#{gateway1.name} | #{gateway1.id}"
        fill_in 'Term gw external id eq', with: '1237'
        fill_in_chosen 'Term gw id eq', with: "#{gateway2.name} | #{gateway2.id}"
        fill_in 'Time start gteq', with: '2018-01-01'
        fill_in 'Time start lteq', with: '2018-03-01'
        fill_in 'Time start lt', with: '2018-03-01', exact: true
        fill_in 'Customer auth external type eq', with: 'term'
        fill_in 'Customer auth external type not eq', with: 'em'
        fill_in_chosen 'Customer auth external id in', with: customer_auth.name, multiple: true, ajax: true
        fill_in_chosen 'Src country iso in', with: countries.first.name, multiple: true
        fill_in_chosen 'Dst country iso in', with: countries.first.name, multiple: true

        # all allowed filters must be filled in this test.
        CdrExport::FiltersModel.attribute_types.each_key do |filter_key|
          selector = "#cdr_export_filters_#{filter_key}"
          field_node = page.find("input#{selector}, select#{selector}", visible: :all)
          expect(field_node.value).to(
            be_present,
            -> { "expect #{field_node.tag_name}#{selector} to be present, but got #{field_node.value.inspect}" }
          )
        end
      end
    end

    it 'should be created' do
      subject
      expect(page).to have_text('Cdr export was successfully created.')

      cdr_export = CdrExport.last!
      expect(page).to have_current_path cdr_export_path(cdr_export)

      expect(cdr_export).to have_attributes(
                              callback_url: '',
                              fields: %w[id success],
                              status: 'Pending',
                              filters: a_kind_of(CdrExport::FiltersModel)
                            )
      expect(cdr_export.filters_json).to match(
                           time_start_gteq: '2018-01-01T00:00:00.000Z',
                           time_start_lteq: '2018-03-01T00:00:00.000Z',
                           time_start_lt: '2018-03-01T00:00:00.000Z',
                           customer_external_id_eq: 1231,
                           customer_id_eq: customer.id,
                           customer_acc_external_id_eq: 1232,
                           customer_acc_id_eq: account.id,
                           vendor_external_id_eq: 1233,
                           vendor_id_eq: vendor.id,
                           vendor_acc_external_id_eq: 1234,
                           vendor_acc_id_eq: vendor_acc.id,
                           customer_auth_external_id_eq: 1235,
                           customer_auth_id_eq: customer_auth.id,
                           src_prefix_in_contains: 'src_prefix_in_test',
                           src_prefix_in_eq: 'src_prefix_in_test',
                           src_prefix_routing_contains: 'src_prefix_routing_test',
                           src_prefix_routing_eq: 'src_prefix_routing_test',
                           src_prefix_out_contains: 'src_prefix_out_test',
                           src_prefix_out_eq: 'src_prefix_out_test',
                           dst_prefix_in_contains: 'dst_prefix_in_test',
                           dst_prefix_in_eq: 'dst_prefix_in_test',
                           dst_prefix_routing_contains: 'dst_prefix_routing_test',
                           dst_prefix_routing_eq: 'dst_prefix_routing_test',
                           dst_prefix_out_contains: 'dst_prefix_out_test',
                           dst_prefix_out_eq: 'dst_prefix_out_test',
                           src_country_id_eq: countries.first.id,
                           dst_country_id_eq: countries.last.id,
                           routing_tag_ids_include: 2,
                           routing_tag_ids_exclude: 25,
                           routing_tag_ids_empty: false,
                           success_eq: true,
                           is_last_cdr_eq: true,
                           failed_resource_type_id_eq: 10,
                           orig_gw_external_id_eq: 1236,
                           orig_gw_id_eq: gateway1.id,
                           term_gw_external_id_eq: 1237,
                           term_gw_id_eq: gateway2.id,
                           duration_eq: 30,
                           duration_gteq: 0,
                           duration_lteq: 60,
                           customer_auth_external_type_eq: 'term',
                           customer_auth_external_type_not_eq: 'em',
                           customer_auth_external_id_in: [customer_auth.external_id],
                           dst_country_iso_in: [countries.first.iso2],
                           src_country_iso_in: [countries.first.iso2]
                         )
    end
  end

  context 'with only required filters' do
    let(:fill_form!) do
      within_form_for do
        fill_in_chosen 'Fields', with: 'id', multiple: true, exact: true
        fill_in 'Time start gteq', with: '2018-01-01'
        fill_in 'Time start lteq', with: '2018-03-01'
      end
    end

    it 'creates correct cdr_export' do
      subject
      expect(page).to have_text('Cdr export was successfully created.')

      cdr_export = CdrExport.last!
      expect(page).to have_current_path cdr_export_path(cdr_export)

      expect(cdr_export).to have_attributes(
                              callback_url: '',
                              fields: %w[id],
                              status: 'Pending',
                              filters: a_kind_of(CdrExport::FiltersModel)
                            )
      expect(cdr_export.filters_json).to match(
        time_start_gteq: '2018-01-01T00:00:00.000Z',
        time_start_lteq: '2018-03-01T00:00:00.000Z',
        customer_auth_external_id_in: [],
        dst_country_iso_in: [],
        src_country_iso_in: []
      )
    end
  end

  context 'with filter time_start_lt' do
    let(:fill_form!) do
      fill_in_chosen 'Fields', with: 'success', multiple: true
      fill_in_chosen 'Fields', with: 'id', multiple: true, exact: true
      fill_in 'Time start gteq', with: '2018-01-01'
      fill_in 'Time start lt', with: '2018-03-01', exact: true
    end

    it 'cdr export should be created' do
      subject
      expect(page).to have_text('Cdr export was successfully created.')

      cdr_export = CdrExport.last!
      expect(page).to have_current_path cdr_export_path(cdr_export)

      expect(cdr_export).to have_attributes(
                              callback_url: '',
                              fields: %w[id success],
                              status: 'Pending',
                              filters: a_kind_of(CdrExport::FiltersModel)
                            )
      expect(cdr_export.filters_json).to match(
        time_start_gteq: '2018-01-01T00:00:00.000Z',
        time_start_lt: '2018-03-01T00:00:00.000Z',
        customer_auth_external_id_in: [],
        dst_country_iso_in: [],
        src_country_iso_in: []
      )
    end
  end

  context 'with incorrect filters' do
    let(:fill_form!) do
      fill_in_chosen 'Fields', with: 'success', multiple: true
      fill_in_chosen 'Fields', with: 'id', multiple: true, exact: true
    end

    it 'should rise semantic error' do
      subject
      expect(page).to have_semantic_errors(count: 1)
      expect(page).to have_semantic_error "Filters can't be blank"
    end
  end

  context 'without fields' do
    let(:fill_form!) do
      fill_in 'Time start gteq', with: '2018-01-01'
      fill_in 'Time start lteq', with: '2018-03-01', exact: true
    end

    it 'should rise semantic error' do
      subject
      expect(page).to have_semantic_errors(count: 1)
      expect(page).to have_semantic_error(
                        'Fields can\'t be blank'
                      )
    end
  end
end
