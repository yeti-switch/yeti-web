# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::CdrExportsController, type: :request do
  include_context :json_api_admin_helpers, type: 'cdr-exports'

  describe 'GET /api/rest/admin/cdr-exports' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let!(:cdr_exports) { create_list(:cdr_export, 3) }

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) do
        cdr_exports.map { |r| r.id.to_s }
      end
    end
  end

  describe 'GET /api/rest/admin/cdr-exports/:id' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { cdr_export.id.to_s }

    let!(:cdr_export) { create(:cdr_export, callback_url: 'https://api.rubyonrails.org') }

    include_examples :returns_json_api_record, relationships: [] do
      let(:json_api_record_id) { record_id }
      let(:json_api_record_attributes) do
        {
          'callback-url': cdr_export.callback_url,
          'created-at': cdr_export.created_at.iso8601(3),
          'export-type': cdr_export.export_type,
          status: cdr_export.status,
          fields: cdr_export.fields,
          filters: cdr_export.filters_json
        }
      end
    end
  end

  describe 'GET /api/rest/admin/cdr-exports/:id/download' do
    subject do
      get json_api_request_path, params: nil, headers: { 'Authorization' => json_api_auth_token }
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}/download" }
    let(:record_id) { cdr_export.id.to_s }

    let!(:cdr_export) { create(:cdr_export, :completed) }

    it 'responds with X-Accel-Redirect' do
      subject
      expect(response.status).to eq 200
      expect(response.body).to be_blank
      expect(response.headers['X-Accel-Redirect']).to eq "/x-redirect/cdr_export/#{cdr_export.id}.csv.gz"
      expect(response.headers['Content-Type']).to eq 'text/csv; charset=utf-8'
      expect(response.headers['Content-Disposition']).to eq "attachment; filename=\"#{cdr_export.id}.csv.gz\""
    end

    context 'when cdr_export is pending' do
      let!(:cdr_export) { create(:cdr_export) }

      it 'responds 404' do
        subject
        expect(response.status).to eq 404
        expect(response.body).to be_blank
        expect(response.headers['X-Accel-Redirect']).to be_nil
        expect(response.headers['Content-Disposition']).to be_nil
      end
    end

    context 'when cdr_export is deleted' do
      let!(:cdr_export) { create(:cdr_export, :deleted) }

      it 'responds 404' do
        subject
        expect(response.status).to eq 404
        expect(response.body).to be_blank
        expect(response.headers['X-Accel-Redirect']).to be_nil
        expect(response.headers['Content-Disposition']).to be_nil
      end
    end
  end

  describe 'POST /api/rest/admin/cdr-exports' do
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
        expect(last_record.filters_json).to match(expected_cdr_export_filters)
      end

      it 'enqueues Worker::CdrExportJob' do
        subject
        expect(Worker::CdrExportJob).to have_been_enqueued.with(last_record.id)
      end
    end

    it_behaves_like :json_api_admin_check_authorization, status: 201

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

    context 'with time_start_lt' do
      let(:json_api_request_attributes) do
        super().merge filters: {
          time_start_gteq: '2018-01-01T00:00:00.000Z',
          time_start_lt: '2018-01-02T00:00:00.000Z'
        }
      end

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
          src_prefix_in_eq: '1111',
          dst_prefix_in_contains: '2222',
          dst_prefix_in_eq: '2222',
          src_prefix_routing_contains: '3333',
          src_prefix_routing_eq: '3333',
          dst_prefix_routing_contains: '4444',
          dst_prefix_routing_eq: '4444',
          src_prefix_out_contains: '5555',
          src_prefix_out_eq: '5555',
          dst_prefix_out_contains: '6666',
          dst_prefix_out_eq: '6666',
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

    context 'with not supported filters' do
      let(:json_api_request_attributes) do
        super().deep_merge filters: { 'unknown-filter' => '123' }
      end

      include_examples :returns_json_api_errors, errors: [
        detail: 'filters - unknown-filter not allowed'
      ]
    end

    context 'with not supported fields' do
      let(:json_api_request_attributes) do
        super().merge fields: ['unknown_field']
      end

      include_examples :returns_json_api_errors, errors: [
        detail: 'fields - unknown_field not allowed'
      ]
    end

    context 'with invalid filter value for dst_country_iso_eq' do
      let(:json_api_request_attributes) do
        super().merge filters: {
          'time_start_gteq' => '2018-01-01',
          'time_start_lteq' => '2018-03-01',
          'dst_country_iso_eq' => 'invalid'
        }
      end

      include_examples :returns_json_api_errors, status: 400, errors: [
        detail: 'invalid is not a valid value for dst_country_iso_eq.'
      ]
    end

    context 'with invalid filter value for src_country_iso_eq' do
      let(:json_api_request_attributes) do
        super().merge filters: {
          'time_start_gteq' => '2018-01-01',
          'time_start_lteq' => '2018-03-01',
          'src_country_iso_eq' => 'invalid'
        }
      end

      include_examples :returns_json_api_errors, status: 400, errors: [
        detail: 'invalid is not a valid value for src_country_iso_eq.'
      ]
    end
  end

  describe 'DELETE /api/rest/admin/cdr-exports/:id' do
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

    it 'enqueues Worker::RemoveCdrExportFileJob' do
      subject
      expect(Worker::RemoveCdrExportFileJob).to have_been_enqueued.with(cdr_export.id)
    end

    include_examples :responds_with_status, 204, without_body: true

    it_behaves_like :json_api_admin_check_authorization, status: 204
  end
end
