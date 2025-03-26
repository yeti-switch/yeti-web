# frozen_string_literal: true

RSpec.describe Worker::CdrExportJob, type: :job do
  subject do
    described_class.perform_now(cdr_export.id)
  end

  let!(:cdr_export) do
    FactoryBot.create(:cdr_export, cdr_export_attrs)
  end
  let(:cdr_export_attrs) do
    { callback_url: callback_url }
  end
  let(:callback_url) { nil }

  shared_examples :performs_cdr_export do
    it 'SQL request copy to CSV should be performed' do
      cdr_connection = double(:cdr_connection)
      expect(Cdr::Cdr).to receive(:connection).and_return(cdr_connection)
      # let's say this SQL should be performed
      # valid SQL will be tested in model spec
      export_sql = 'SELECT * FROM cdr.cdr'
      expect_any_instance_of(CdrExport).to receive(:export_sql).and_return(export_sql)
      expect(cdr_connection).to receive(:execute).with("COPY (#{export_sql}) TO PROGRAM 'gzip > /tmp/#{cdr_export.id}.csv.gz' WITH (FORMAT CSV, HEADER, FORCE_QUOTE *);")
      subject
    end

    it 'cdr_export status should be completed' do
      expect { subject }.to change { cdr_export.reload.status }.from(CdrExport::STATUS_PENDING).to(CdrExport::STATUS_COMPLETED)
    end

    it 'rows_count should be saved to cdr_export' do
      allow_any_instance_of(PG::Result).to receive(:cmd_tuples).and_return(5)
      expect { subject }.to change { cdr_export.reload.rows_count }.from(nil).to(5)
    end
  end

  it 'ping callback dj should not be enqueued' do
    expect { subject }.not_to have_enqueued_job(Worker::PingCallbackUrlJob)
  end

  include_examples :performs_cdr_export

  context 'when failure' do
    before do
      expect(Cdr::Cdr).to receive(:connection).and_raise
    end
    it 'cdr_export status should be failed' do
      expect { subject }.to change { cdr_export.reload.status }.from(CdrExport::STATUS_PENDING).to(CdrExport::STATUS_FAILED)
    end
  end

  context 'when callback_url is an empty string' do
    let(:callback_url) { '' }

    it 'ping callback dj should not be enqueued' do
      expect { subject }.not_to have_enqueued_job(Worker::PingCallbackUrlJob)
    end

    include_examples :performs_cdr_export
  end

  context 'when callback_url defined' do
    let(:cdr_export_attrs) do
      super().merge callback_url: 'http://example.com/notify'
    end

    it 'ping callback dj should be enqueued' do
      expect { subject }.to have_enqueued_job(Worker::PingCallbackUrlJob).with(
        cdr_export_attrs[:callback_url],
        export_id: cdr_export.id,
        status: 'Completed'
      )
    end

    include_examples :performs_cdr_export
  end

  context 'when time_zone_name defined' do
    let(:cdr_export_attrs) { super().merge time_zone_name: 'europe/kiev' }

    include_examples :performs_cdr_export
  end

  context 'when cdr_export has time_start_lt filter' do
    let(:cdr_export_attrs) do
      super().merge filters: {
        time_start_gteq: '2018-01-01 00:00:00',
        time_start_lt: '2018-03-01 00:00:00'
      }
    end

    include_examples :performs_cdr_export
  end
end
