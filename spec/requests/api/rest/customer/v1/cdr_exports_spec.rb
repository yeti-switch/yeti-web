# frozen_string_literal: true

RSpec.describe Api::Rest::Customer::V1::CdrExportsController, type: :request do
  include_context :json_api_customer_v1_helpers, type: :'cdr-exports'

  shared_examples :responds_single_cdr_export do |status:|
    include_examples :returns_json_api_record, relationships: [:account], status: status do
      let(:json_api_record_id) { cdr_export.uuid }
      let(:json_api_record_attributes) do
        {
          status: cdr_export.status,
          'rows-count': cdr_export.rows_count,
          'time-format': CdrExport::WITH_TIMEZONE_TIME_FORMAT,
          'time-zone-name': cdr_export.time_zone_name,
          'created-at': cdr_export.created_at.iso8601(3),
          'updated-at': cdr_export.updated_at.iso8601(3),
          filters: cdr_export.filters.as_json.slice(*CustomerApi::CdrExportForm::ALLOWED_FILTERS).symbolize_keys
        }
      end
    end
  end

  describe 'POST /api/rest/customer/v1/cdr-exports' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    shared_examples :creates_cdr_export do
      # let(:expected_cdr_export_attrs)
      # let(:expected_cdr_export_filters)

      it 'creates cdr_export' do
        expect { subject }.to change { CdrExport.count }.by(1)
        expect(cdr_export).to have_attributes(expected_cdr_export_attrs)
        expect(cdr_export.filters_json).to match(expected_cdr_export_filters)
      end
    end

    shared_examples :does_not_create_cdr_export do
      it 'does not create cdr_export' do
        expect { subject }.not_to change { CdrExport.count }
      end
    end

    let(:expected_cdr_export_attrs) do
      {
        callback_url: nil,
        fields: CustomerApi::CdrExportForm::FIELDS,
        rows_count: nil,
        status: CdrExport::STATUS_PENDING,
        type: 'Base',
        uuid: be_present,
        created_at: be_within(1).of(Time.current),
        updated_at: be_within(1).of(Time.current),
        customer_account_id: account.id
      }
    end
    let(:expected_cdr_export_filters) do
      {
        **json_api_attributes[:filters],
        customer_acc_id_eq: account.id
      }
    end

    let(:json_api_request_body) do
      {
        data: {
          type: 'cdr-exports',
          attributes: json_api_attributes,
          relationships: json_api_relationships
        }
      }
    end
    let(:json_api_attributes) do
      { filters: json_api_filter_attribute }
    end
    let(:json_api_filter_attribute) do
      {
        time_start_gteq: '2018-01-01T00:00:00.000Z',
        time_start_lt: '2018-01-02T00:00:00.000Z'
      }
    end
    let(:json_api_relationships) do
      {
        account: {
          data: { id: account.uuid, type: 'accounts' }
        }
      }
    end
    let!(:account) { FactoryBot.create(:account, contractor: customer).reload }
    let(:cdr_export) { CdrExport.last! }

    include_examples :creates_cdr_export
    include_examples :responds_single_cdr_export, status: 201

    context 'when customer has allowed_account_ids' do
      before { api_access.update!(account_ids: [account.id]) }

      include_examples :creates_cdr_export
      include_examples :responds_single_cdr_export, status: 201
    end

    context 'when time_zone_name' do
      context 'equal to europe/kyiv' do
        let(:json_api_attributes) { super().merge 'time-zone-name': 'europe/kyiv' }
        let(:expected_cdr_export_attrs) { super().merge time_zone_name: 'europe/kyiv' }

        it 'should create CDR export' do
          subject
          expect(response_json[:errors]).to eq nil

          expect(cdr_export).to have_attributes(expected_cdr_export_attrs)
          expect(cdr_export.filters_json).to match(expected_cdr_export_filters)
        end
      end

      context 'with invalid time_zone_name' do
        let(:json_api_attributes) { super().merge 'time-zone-name': 'invalid value' }

        include_examples :returns_json_api_errors, errors: {
          detail: 'time-zone-name - is invalid',
          source: { pointer: '/data/attributes/time-zone-name' }
        }
      end

      context 'when time_zone_name is empty string' do
        let(:json_api_attributes) { super().merge 'time-zone-name': '' }

        include_examples :returns_json_api_errors, errors: {
          detail: 'time-zone-name - is invalid',
          source: { pointer: '/data/attributes/time-zone-name' }
        }
      end
    end

    context 'with all allowed filters' do
      let(:json_api_filter_attribute) do
        super().merge success_eq: true,
                      duration_eq: 60,
                      duration_gteq: 0,
                      duration_lteq: 100,
                      src_prefix_routing_eq: '123',
                      dst_prefix_routing_eq: '456'
      end

      include_examples :creates_cdr_export
      include_examples :responds_single_cdr_export, status: 201
    end

    context 'without account relationship' do
      let(:json_api_relationships) { {} }

      include_examples :does_not_create_cdr_export
      include_examples :returns_json_api_errors, errors: {
        detail: "account - can't be blank",
        source: { pointer: '/data/relationships/account' }
      }
    end

    context 'without filters attribute' do
      let(:json_api_attributes) { {} }

      include_examples :does_not_create_cdr_export
      include_examples :returns_json_api_errors, errors: {
        detail: "filters - can't be blank",
        source: { pointer: '/data/attributes/filters' }
      }
    end

    context 'without filters.time_start_gteq' do
      let(:json_api_filter_attribute) do
        super().except(:time_start_gteq)
      end

      include_examples :does_not_create_cdr_export
      include_examples :returns_json_api_errors, errors: {
        detail: 'filters - requires time_start_gteq',
        source: { pointer: '/data/attributes/filters' }
      }
    end

    context 'without filters.time_start_lt' do
      let(:json_api_filter_attribute) do
        super().except(:time_start_lt)
      end

      include_examples :does_not_create_cdr_export
      include_examples :returns_json_api_errors, errors: {
        detail: 'filters - requires time_start_lt',
        source: { pointer: '/data/attributes/filters' }
      }
    end

    context 'without both filters.time_start_gteq and filters.time_start_lt' do
      let(:json_api_filter_attribute) do
        super().except(:time_start_gteq, :time_start_lt).merge(success_eq: true)
      end

      include_examples :does_not_create_cdr_export
      include_examples :returns_json_api_errors, errors: [
        {
          detail: 'filters - requires time_start_gteq',
          source: { pointer: '/data/attributes/filters' }
        },
        {
          detail: 'filters - requires time_start_lt',
          source: { pointer: '/data/attributes/filters' }
        }
      ]
    end

    context 'with not allowed filters' do
      let(:json_api_filter_attribute) do
        super().merge customer_id_eq: 123,
                      customer_acc_id_eq: 456
      end

      include_examples :does_not_create_cdr_export
      include_examples :returns_json_api_errors, errors: {
        detail: 'filters - customer_id_eq, customer_acc_id_eq not allowed',
        source: { pointer: '/data/attributes/filters' }
      }
    end

    context 'when account relationship from another customer' do
      let!(:another_customer) { create(:customer) }
      let!(:account) { create(:account, contractor: another_customer).reload }

      include_examples :does_not_create_cdr_export
      include_examples :returns_json_api_errors, errors: {
        detail: 'account - is invalid',
        source: { pointer: '/data/relationships/account' }
      }
    end

    context 'when account relationship from not allowed account_id' do
      let!(:allowed_account) { create(:account, contractor: customer) }

      before { api_access.update!(account_ids: [allowed_account.id]) }

      include_examples :does_not_create_cdr_export
      include_examples :returns_json_api_errors, errors: {
        detail: 'account - is invalid',
        source: { pointer: '/data/relationships/account' }
      }
    end
  end

  describe 'GET /api/rest/customer/v1/cdr_exports' do
    subject do
      get json_api_request_path, params: query_params, headers: json_api_request_headers
    end

    let(:query_params) { nil }
    let!(:account1) { FactoryBot.create(:account, contractor: customer).reload }
    let!(:account2) { FactoryBot.create(:account, contractor: customer).reload }
    let!(:account3) { FactoryBot.create(:account, contractor: customer).reload }
    let(:cdr_exports_attrs) { {} }
    let!(:cdr_exports) do
      [
        FactoryBot.create(:cdr_export, customer_account: account1, **cdr_exports_attrs).reload,
        FactoryBot.create(:cdr_export, :failed, customer_account: account1, **cdr_exports_attrs).reload,
        FactoryBot.create(:cdr_export, :completed, customer_account: account2, **cdr_exports_attrs).reload,
        FactoryBot.create(:cdr_export, :deleted, customer_account: account3, **cdr_exports_attrs).reload
      ]
    end

    before do
      # not included because no customer_account
      FactoryBot.create(:cdr_export)

      # not included because customer_account belongs to another customer
      another_cus = FactoryBot.create(:customer)
      another_acc = FactoryBot.create(:account, contractor: another_cus)
      FactoryBot.create(:cdr_export, customer_account: another_acc)
    end

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) { cdr_exports.map(&:uuid) }
    end

    CdrExport::STATUSES.each do |status|
      context "with filter[status_eq]=#{status}" do
        let(:query_params) do
          { filter: { status_eq: status } }
        end
        let!(:cdr_exports) do
          FactoryBot.create_list(:cdr_export, 3, customer_account: account1, status: status).map(&:reload)
        end

        before do
          (CdrExport::STATUSES - [status]).each do |another_status|
            FactoryBot.create(:cdr_export, customer_account: account1, status: another_status)
          end
        end

        include_examples :returns_json_api_collection do
          let(:json_api_collection_ids) { cdr_exports.map(&:uuid) }
        end
      end

      context "with filter[status_not_eq]=#{status}" do
        let(:query_params) do
          { filter: { status_not_eq: status } }
        end
        let!(:cdr_exports) do
          (CdrExport::STATUSES - [status]).map do |another_status|
            FactoryBot.create(:cdr_export, customer_account: account1, status: another_status).reload
          end
        end

        before do
          FactoryBot.create(:cdr_export, customer_account: account1, status: status)
        end

        include_examples :returns_json_api_collection do
          let(:json_api_collection_ids) { cdr_exports.map(&:uuid) }
        end
      end
    end

    context 'with filter[time_format]=round_to_seconds' do
      let(:query_params) { { filter: { time_format: CdrExport::ROUND_TO_SECONDS_TIME_FORMAT } } }
      let(:cdr_exports_attrs) { super().merge time_format: CdrExport::ROUND_TO_SECONDS_TIME_FORMAT }

      include_examples :returns_json_api_collection do
        let(:json_api_collection_ids) { cdr_exports.map(&:uuid) }
      end
    end

    context 'with filter[time_zone_name]=europe/kiev' do
      let(:query_params) { { filter: { time_zone_name: 'europe/kiev' } } }
      let(:cdr_exports_attrs) { super().merge time_zone_name: 'europe/kiev' }

      include_examples :returns_json_api_collection do
        let(:json_api_collection_ids) { cdr_exports.map(&:uuid) }
      end
    end

    context 'with filter[status_eq]=test' do
      let(:query_params) do
        { filter: { status_eq: 'test' } }
      end

      include_examples :returns_json_api_errors, status: 400, errors: {
        title: 'Invalid filter value',
        detail: 'test is not a valid value for status_eq.'
      }
    end

    context 'when customer has allowed_account_ids' do
      before { api_access.update!(account_ids: [account1.id, account2.id]) }

      let!(:cdr_exports) do
        [
          FactoryBot.create(:cdr_export, customer_account: account1).reload,
          FactoryBot.create(:cdr_export, customer_account: account1).reload,
          FactoryBot.create(:cdr_export, customer_account: account2).reload
        ]
      end

      before do
        # not included because customer_account not in allowed_account_ids
        FactoryBot.create(:cdr_export, customer_account: account3)
      end

      include_examples :returns_json_api_collection do
        let(:json_api_collection_ids) { cdr_exports.map(&:uuid) }
      end
    end
  end

  describe 'GET /api/rest/customer/v1/cdr_exports/:id' do
    subject do
      get json_api_request_path, params: query_params, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}" }
    let(:record_id) { cdr_export.uuid }
    let(:query_params) { nil }
    let!(:account) { FactoryBot.create(:account, contractor: customer).reload }
    let!(:cdr_export) { FactoryBot.create(:cdr_export, cdr_export_attrs).reload }
    let(:cdr_export_attrs) do
      { customer_account: account }
    end

    include_examples :responds_single_cdr_export, status: 200

    context 'with cdr_export does not have customer_account' do
      let(:cdr_export_attrs) do
        super().merge customer_account: nil
      end

      include_examples :returns_json_api_errors, status: 404, errors: {
        title: 'Record not found'
      }
    end

    context 'when customer has allowed_account_ids' do
      before { api_access.update!(account_ids: [account.id]) }

      include_examples :responds_single_cdr_export, status: 200
    end

    context 'when customer allowed_account_ids does not include cdr_export account' do
      let!(:allowed_account) { FactoryBot.create(:account, contractor: customer) }

      before { api_access.update!(account_ids: [allowed_account.id]) }

      include_examples :returns_json_api_errors, status: 404, errors: {
        title: 'Record not found'
      }
    end

    context 'with include=account' do
      let(:query_params) { { include: 'account' } }

      it 'responds with included account' do
        subject
        expect(response_json[:included]).to match(
                                              [
                                                hash_including(
                                                  id: account.uuid,
                                                  type: 'accounts'
                                                )
                                              ]
                                            )
      end

      include_examples :responds_single_cdr_export, status: 200
    end
  end

  describe 'GET /api/rest/customer/v1/cdr_exports/:id/download' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    let(:json_api_request_path) { "#{super()}/#{record_id}/download" }
    let(:record_id) { cdr_export.uuid }
    let!(:account) { FactoryBot.create(:account, contractor: customer).reload }
    let!(:cdr_export) { FactoryBot.create(:cdr_export, cdr_export_attrs).reload }
    let(:cdr_export_attrs) do
      { customer_account: account, status: CdrExport::STATUS_COMPLETED }
    end

    shared_examples :responds_404 do
      it 'responds 404' do
        subject
        expect(response.status).to eq(404)
        expect(response.body).to be_blank
        expect(response.headers['X-Accel-Redirect']).to be_nil
        expect(response.headers['Content-Disposition']).to be_nil
      end
    end

    it 'responds with X-Accel-Redirect' do
      subject
      expect(response.status).to eq 200
      expect(response.body).to be_blank
      expect(response.headers['X-Accel-Redirect']).to eq "/x-redirect/cdr_export/#{cdr_export.filename}"
      expect(response.headers['Content-Type']).to eq 'text/csv; charset=utf-8'
      expect(response.headers['Content-Disposition']).to eq "attachment; filename=\"#{cdr_export.public_filename}\""
    end

    context 'when cdr_export is pending' do
      let(:cdr_export_attrs) do
        super().merge status: CdrExport::STATUS_PENDING
      end

      include_examples :responds_404
    end

    context 'when cdr_export is failed' do
      let(:cdr_export_attrs) do
        super().merge status: CdrExport::STATUS_FAILED
      end

      include_examples :responds_404
    end

    context 'when cdr_export is deleted' do
      let(:cdr_export_attrs) do
        super().merge status: CdrExport::STATUS_DELETED
      end

      include_examples :responds_404
    end

    context 'when customer allowed_account_ids does not include cdr_export account' do
      let!(:allowed_account) { FactoryBot.create(:account, contractor: customer) }

      before { api_access.update!(account_ids: [allowed_account.id]) }

      include_examples :returns_json_api_errors, status: 404, errors: {
        title: 'Record not found'
      }
    end

    context 'when s3 storage configured' do
      before do
        allow(YetiConfig).to receive(:s3_storage).and_return(
          OpenStruct.new(
            endpoint: 'http::some_example_s3_storage_url',
            cdr_export: OpenStruct.new(bucket: 'test-bucket')
          )
        )

        allow(S3AttachmentWrapper).to receive(:stream_to!).and_yield("dummy data\n").and_yield('dummy data2')
      end

      it 'responds with attachment' do
        expect(Cdr::DownloadCdrExport).to receive(:call).with(
          cdr_export:, response_object: be_present, public: true
        ).and_call_original

        subject
        expect(response.status).to eq(200)
        expect(response.body).to eq("dummy data\ndummy data2")
        expect(response.headers['Content-Disposition']).to eq("attachment; filename=\"#{cdr_export.public_filename}\"")
      end
    end

    context 'when Cdr::DownloadCdrExport raise Cdr::DownloadCdrExport::NotFoundError' do
      before do
        allow(Cdr::DownloadCdrExport).to receive(:call).and_raise(Cdr::DownloadCdrExport::NotFoundError, 'Test error')
      end

      include_examples :responds_404
    end

    context 'when Cdr::DownloadCdrExport raise Cdr::DownloadCdrExport::Error' do
      before do
        allow(Cdr::DownloadCdrExport).to receive(:call).and_raise(Cdr::DownloadCdrExport::Error, 'Test error')
      end

      include_examples :jsonapi_server_error
    end

    context 'when Cdr::DownloadCdrExport raise any other error' do
      before do
        allow(Cdr::DownloadCdrExport).to receive(:call).and_raise(StandardError, 'Test error')
      end

      include_examples :jsonapi_server_error
    end
  end
end
