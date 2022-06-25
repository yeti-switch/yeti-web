# frozen_string_literal: true

RSpec.describe Worker::RemoveCdrExportFileJob, type: :job do
  subject do
    described_class.perform_now(cdr_export.id)
  end

  let(:cdr_export) do
    FactoryBot.create(:cdr_export, :completed)
  end

  let(:delete_url) do
    [
      YetiConfig.cdr_export.delete_url.chomp('/'),
      "#{cdr_export.id}.csv.gz"
    ].join('/')
  end

  let!(:http_mock) do
    stub_request(:delete, delete_url).to_return(status: http_code)
  end

  shared_examples :valid_deleting do
    it 'http mock should be requested' do
      subject
      expect(http_mock).to have_been_requested.once
    end

    it 'nothing should be raised' do
      expect { subject }.not_to raise_error
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
      expect { subject }.to raise_error(Worker::RemoveCdrExportFileJob::FileNotDeletedError, 'File was not deleted! http code: 400')
    end
  end
end
