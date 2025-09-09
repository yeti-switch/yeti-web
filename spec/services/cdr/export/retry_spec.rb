# frozen_string_literal: true

RSpec.describe Cdr::Export::Retry do
  subject { described_class.call(cdr_export:) }

  let!(:cdr_export) { FactoryBot.create(:cdr_export, *cdr_export_traits) }
  let(:cdr_export_traits) { [:failed] }

  it 'should enqueue CdrExportJob' do
    expect { subject }.to have_enqueued_job(Worker::CdrExportJob).with(cdr_export.id)
  end

  it 'should set cdr_export status to pending' do
    expect { subject }.to change { cdr_export.reload.status }
      .from(CdrExport::STATUS_FAILED).to(CdrExport::STATUS_PENDING)
  end

  context 'when cdr_export is completed' do
    let(:cdr_export_traits) { [:completed] }

    it 'should raise validation error' do
      expect { subject }.to raise_error(described_class::Error, 'Only failed exports can be retried')
    end

    it 'should not change cdr_export status' do
      expect { safe_subject }.not_to change { cdr_export.reload.status }
    end
  end

  context 'when cdr_export is deleted' do
    let(:cdr_export_traits) { [:deleted] }

    it 'should raise validation error' do
      expect { subject }.to raise_error(described_class::Error, 'Only failed exports can be retried')
    end

    it 'should not change cdr_export status' do
      expect { safe_subject }.not_to change { cdr_export.reload.status }
    end
  end

  context 'when cdr_export is pending' do
    let(:cdr_export_traits) { [] }

    it 'should raise validation error' do
      expect { subject }.to raise_error(described_class::Error, 'Only failed exports can be retried')
    end

    it 'should not change cdr_export status' do
      expect { safe_subject }.not_to change { cdr_export.reload.status }
    end
  end
end
