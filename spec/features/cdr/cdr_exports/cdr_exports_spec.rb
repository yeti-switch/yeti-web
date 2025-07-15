# frozen_string_literal: true

RSpec.describe 'CDR exports', type: :feature do
  include_context :login_as_admin

  describe 'index' do
    subject do
      visit cdr_exports_path(q: { time_zone_name_eq: 'europe/kiev' })
    end

    let!(:account1) { create(:account, :with_customer) }
    let!(:account2) { create(:account, :with_customer) }
    let!(:cdr_exports) do
      [
        create(:cdr_export, time_zone_name: 'europe/kiev'),
        create(:cdr_export, :completed, time_zone_name: 'europe/kiev'),
        create(:cdr_export, :failed, time_zone_name: 'europe/kiev'),
        create(:cdr_export, :deleted, time_zone_name: 'europe/kiev'),
        create(:cdr_export, customer_account: account1, time_zone_name: 'europe/kiev'),
        create(:cdr_export, :completed, customer_account: account1, time_zone_name: 'europe/kiev'),
        create(:cdr_export, :deleted, customer_account: account2, time_zone_name: 'europe/kiev')
      ]
    end

    it 'cdr export should be displayed' do
      subject
      expect(page).to have_table_row count: cdr_exports.size
      expect(page).to have_select 'Time zone name', selected: 'europe/kiev', visible: false

      cdr_exports.each do |cdr_export|
        within_table_row(id: cdr_export.id) do
          expect(page).to have_table_cell column: 'ID', exact_text: cdr_export.id.to_s
          expect(page).to have_table_cell column: 'Download'
          expect(page).to have_table_cell column: 'Status', exact_text: cdr_export.status
          expect(page).to have_table_cell column: 'Fields', exact_text: cdr_export.fields.join(', ')
          expect(page).to have_table_cell column: 'Filters', exact_text: cdr_export.filters.as_json.to_s
          expect(page).to have_table_cell column: 'Callback Url', exact_text: cdr_export.callback_url.to_s
          expect(page).to have_table_cell column: 'Created At', exact_text: cdr_export.created_at.strftime('%F %T')
          expect(page).to have_table_cell column: 'Updated At', exact_text: cdr_export.updated_at.strftime('%F %T')
          expect(page).to have_table_cell column: 'UUID', exact_text: cdr_export.reload.uuid
        end
      end
    end
  end

  describe 'download', :js do
    subject do
      visit cdr_export_path(cdr_export)
      click_on 'Download'
    end

    let(:cdr_export) { FactoryBot.create(:cdr_export, :completed, customer_account: account1, time_zone_name: 'europe/kiev') }
    let!(:account1) { create(:account, :with_customer) }

    it 'should setup X-Accel-Redirect header' do
      expect(Cdr::DownloadCdrExport).to receive(:call).with(cdr_export:, response_object: be_present).and_call_original

      subject

      expect(response_headers['X-Accel-Redirect']).to eq("/x-redirect/cdr_export/#{cdr_export.filename}")
    end

    context 'when s3 storage is configured' do
      before do
        allow(YetiConfig).to receive(:s3_storage).and_return(
          OpenStruct.new(
            endpoint: 'http::some_example_s3_storage_url',
            cdr_export: OpenStruct.new(bucket: 'test-bucket')
          )
        )

        allow(S3AttachmentWrapper).to receive(:stream_to!).and_yield('dummy data')
      end

      it 'should download cdr_export file from S3' do
        expect(Cdr::DownloadCdrExport).to receive(:call).with(cdr_export:, response_object: be_present).and_call_original

        subject

        expect(response_headers['Content-Disposition']).to eq("attachment; filename=\"#{cdr_export.filename}\"")
        expect(page.current_path).to eq(cdr_export_path(cdr_export))
      end
    end

    context 'when Cdr::DownloadCdrExport::NotFoundError raised' do
      before do
        allow(Cdr::DownloadCdrExport).to receive(:call).and_raise(Cdr::DownloadCdrExport::NotFoundError, 'Cdr Export file not found')
      end

      it 'shows an error message' do
        subject

        expect(page).to have_flash_message('Cdr Export file not found', type: :error)
      end
    end

    context 'when Cdr::DownloadCdrExport::Error raised' do
      before do
        allow(Cdr::DownloadCdrExport).to receive(:call).and_raise(Cdr::DownloadCdrExport::Error, 'some error')
      end

      it 'shows an error message' do
        subject

        expect(page).to have_flash_message('An unexpected error occurred: some error', type: :error)
      end
    end

    context 'when any other error raised' do
      before do
        allow(Cdr::DownloadCdrExport).to receive(:call).and_raise(StandardError, 'some error')
      end

      it 'shows an error message' do
        subject

        expect(page).to have_flash_message('An unexpected error occurred: some error', type: :error)
      end
    end
  end
end
