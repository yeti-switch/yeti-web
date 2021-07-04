# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::Cdr::CdrsController, type: :request do
  include_context :json_api_admin_helpers, prefix: 'cdr', type: 'cdr-exports'

  describe 'POST /api/rest/admin/cdr/cdr-exports' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    let(:json_api_request_body) do
      {
        data: {
          type: json_api_resource_type,
          attributes: json_api_request_attributes
        }
      }
    end
    let(:json_api_request_attributes) do
      {
        fields: ['id'],
        filters: {
          time_start_gteq: '2018-01-01T00:00:00.000Z',
          time_start_lteq: '2018-01-02T00:00:00.000Z'
        }
      }
    end
    let(:last_record) { CdrExport.last! }

    let(:expected_cdr_export_attrs) do
      defaults = { callback_url: nil, export_type: 'Base' }
      attrs = json_api_request_attributes.transform_keys { |k| k.to_s.underscore.to_sym }
      defaults.merge(attrs).except(:filters)
    end
    let(:expected_cdr_export_filters) do
      json_api_request_attributes[:filters]
    end

    shared_examples :creates_cdr_export do
      # let(:expected_cdr_export_attrs) {}
      # let(:expected_cdr_export_filters) {}

      it 'creates cdr_export' do
        expect { subject }.to change { CdrExport.count }.by(1)
        expect(last_record).to have_attributes(expected_cdr_export_attrs)
        filters = last_record.filters.as_json.symbolize_keys
        expect(filters).to match(expected_cdr_export_filters)
      end
    end

    context 'with only required attributes' do
      include_examples :creates_cdr_export
      include_examples :returns_json_api_record, relationships: [], status: 201 do
        let(:json_api_record_id) { last_record.id.to_s }
        let(:json_api_record_attributes) do
          json_api_request_attributes.merge 'callback-url': nil,
                                            'created-at': be_present,
                                            'export-type': 'Base',
                                            status: 'Pending'
        end
      end
    end

    context 'with all allowed filters' do
      let(:json_api_request_attributes) do
        super().merge filters: {
          time_start_gteq: '2018-01-01T00:00:00.000Z',
          time_start_lteq: '2018-01-02T00:00:00.000Z',
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
          src_country_iso_eq: country1.iso2,
          dst_country_iso_eq: country2.iso2,
          routing_tag_ids_include: 2,
          routing_tag_ids_exclude: 5,
          routing_tag_ids_empty: false,
          orig_gw_id_eq: 1242,
          orig_gw_external_id_eq: 1243,
          term_gw_id_eq: 1244,
          term_gw_external_id_eq: 1245
        }
      end
      let(:expected_cdr_export_filters) do
        super()
          .except(:src_country_iso_eq, :dst_country_iso_eq)
          .merge(src_country_id_eq: country1.id, dst_country_id_eq: country2.id)
      end

      let(:country1) { System::Country.find_by!(name: 'France') }
      let(:country2) { System::Country.find_by!(name: 'Ukraine') }

      include_examples :creates_cdr_export
      include_examples :returns_json_api_record, relationships: [], status: 201 do
        let(:json_api_record_id) { last_record.id.to_s }
        let(:json_api_record_attributes) do
          filters = json_api_request_attributes[:filters]
                    .except(:src_country_iso_eq, :dst_country_iso_eq)
                    .merge(src_country_id_eq: country1.id, dst_country_id_eq: country2.id)

          json_api_request_attributes.merge 'callback-url': nil,
                                            'created-at': be_present,
                                            'export-type': 'Base',
                                            status: 'Pending',
                                            filters: filters
        end
      end
    end

    context 'with all allowed attributes' do
      let(:json_api_request_attributes) do
        super().merge 'callback-url': 'https://test.example.com/qwe',
                      'export-type': 'Base'
      end

      include_examples :creates_cdr_export
      include_examples :returns_json_api_record, relationships: [], status: 201 do
        let(:json_api_record_id) { last_record.id.to_s }
        let(:json_api_record_attributes) do
          json_api_request_attributes.merge 'created-at': be_present,
                                            status: 'Pending'
        end
      end
    end
  end

  describe 'DELETE /api/rest/admin/cdr/cdr-exports/:id' do
    subject do
      delete json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { cdr_export.id.to_s }

    let!(:cdr_export) { create(:cdr_export) }

    it 'sets deleted status for cdr_export' do
      expect { subject }.to change { CdrExport.count }.by(0)
      expect(cdr_export.reload).to have_attributes(
                                     status: CdrExport::STATUS_DELETED
                                   )
    end

    include_examples :responds_with_status, 204, without_body: true
  end
end
