require 'spec_helper'

RSpec.describe Worker::CdrExportJob, type: :job do
  subject do
    described_class.perform_now(cdr_export.id)
  end
  let(:cdr_export) do
    FactoryGirl.create(:cdr_export, callback_url: callback_url)
  end
  let(:callback_url) { nil }

  it 'SQL request copy to CSV should be performed' do
    cdr_connection = double(:cdr_connection)
    expect(Cdr::Cdr).to receive(:connection).and_return(cdr_connection)
    #let's say this SQL should be performed
    #valid SQL will be tested in model spec
    export_sql = 'SELECT * FROM cdr.cdr'
    expect_any_instance_of(CdrExport).to receive(:export_sql).and_return(export_sql)
    expect(cdr_connection).to receive(:execute).with("COPY (#{export_sql}) TO '/tmp/#{cdr_export.id}.csv' WITH CSV HEADER;")
    subject
  end

  it 'cdr_export status should be completed' do
    expect { subject }.to change { cdr_export.reload.status }.from(CdrExport::STATUS_PENDING).to(CdrExport::STATUS_COMPLETED)
  end

  context 'when failure' do
    before do
      expect(Cdr::Cdr).to receive(:connection).and_raise
    end
    it 'cdr_export status should be failed' do
      expect { subject }.to change { cdr_export.reload.status }.from(CdrExport::STATUS_PENDING).to(CdrExport::STATUS_FAILED)
    end
  end

  context 'when callback_url defined' do
    let(:callback_url) do
      'http://example.com/notify'
    end
    it 'ping callback dj should be enqueued' do
      expect { subject }.to have_enqueued_job(Worker::PingCallbackUrlJob).with(
        callback_url, {
          export_id: cdr_export.id,
          status: 'Completed'
        })
    end
  end

  context 'when callback_url not defined' do
    let(:callback_url) do
      nil
    end
    it 'ping callback dj should not be enqueued' do
      expect { subject }.not_to have_enqueued_job(Worker::PingCallbackUrlJob)
    end
  end
end
