# frozen_string_literal: true

RSpec.describe Worker::RemoveCdrExportFileJob, type: :job do
  subject do
    described_class.perform_now(cdr_export.id)
  end

  let(:cdr_export) do
    FactoryBot.create(:cdr_export, :completed)
  end

  context 'when cdr export storage not configured' do
    let(:delete_url) do
      [
        YetiConfig.cdr_export.delete_url.chomp('/'),
        cdr_export.filename
      ].join('/')
    end

    let!(:http_mock) do
      stub_request(:delete, delete_url).to_return(status: http_code)
    end

    shared_examples :valid_deleting do
      it 'http request should be sent' do
        expect(Cdr::DeleteCdrExport).to receive(:call).with(cdr_export:).and_call_original
        expect(S3AttachmentWrapper).not_to receive(:delete!)

        expect { subject }.not_to raise_error
        expect(http_mock).to have_been_requested.once
      end
    end

    context 'when http code 204' do
      let(:http_code) do
        204
      end

      include_examples :valid_deleting
    end

    context 'when http code 200' do
      let(:http_code) do
        200
      end

      include_examples :valid_deleting
    end

    context 'when http code 404' do
      let(:http_code) do
        404
      end

      include_examples :valid_deleting
    end

    context 'when http code 400' do
      let(:http_code) do
        400
      end

      it 'error should be raised' do
        expect { subject }.to raise_error(Cdr::DeleteCdrExport::Error, 'File was not deleted! http code: 400')
      end
    end
  end

  context 'when cdr export storage configured' do
    before do
      allow(YetiConfig).to receive(:s3_storage).and_return(
        OpenStruct.new(
          endpoint: 'http::some_example_s3_storage_url',
          cdr_export: OpenStruct.new(bucket: 'test-bucket')
        )
      )

      allow(S3AttachmentWrapper).to receive(:delete!).and_return(true)
    end

    it 'should delete from s3 storage' do
      expect(Cdr::DeleteCdrExport).to receive(:call).with(cdr_export:).and_call_original
      expect(S3AttachmentWrapper).to receive(:delete!).with('test-bucket', cdr_export.filename)

      expect { subject }.not_to raise_error
    end

    context 'when CDR export file not found' do
      before do
        allow(S3AttachmentWrapper).to receive(:delete!).and_raise(
          Aws::S3::Errors::NoSuchKey.new('test context', 'test error')
        )
      end

      it 'should ignore error' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when error raised' do
      before do
        allow(S3AttachmentWrapper).to receive(:delete!).and_raise(
          Aws::S3::Errors::ServiceError.new('test context', 'test error')
        )
      end

      it 'should raise error' do
        expect { subject }.to raise_error(Cdr::DeleteCdrExport::Error, 'Failed to delete Cdr Export file: test error')
      end
    end
  end
end
