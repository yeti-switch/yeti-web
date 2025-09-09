# frozen_string_literal: true

RSpec.describe 'CDR Exports Retry', :js, type: :feature do
  include_context :login_as_admin

  subject do
    visit cdr_export_path(cdr_export)
    click_on_action!
  end

  let(:click_on_action!) { click_on 'Retry' }

  let!(:cdr_export) { FactoryBot.create(:cdr_export, *cdr_export_traits) }
  let(:cdr_export_traits) { [:failed] }

  it 'should enqueue CdrExportJob' do
    expect(Cdr::Export::Retry).to receive(:call).with(cdr_export:).and_call_original

    expect do
      subject

      expect(page).to have_flash_message('CDR export has been scheduled for retry!', type: :notice)
    end.to change { cdr_export.reload.status }.from(CdrExport::STATUS_FAILED).to(CdrExport::STATUS_PENDING)
                                              .and have_enqueued_job(Worker::CdrExportJob).with(cdr_export.id)
  end

  context 'when cdr_export is completed' do
    let(:cdr_export_traits) { [:completed] }
    let(:click_on_action!) { nil }

    it 'should raise validation error' do
      subject

      expect(page).not_to have_action_item('Retry')
    end
  end

  context 'when Cdr::Export::Retry raises error' do
    before do
      allow(Cdr::Export::Retry).to receive(:call).and_raise(Cdr::Export::Retry::Error, 'Some error')
    end

    it 'should display error message' do
      expect do
        subject

        expect(page).to have_flash_message('Some error', type: :error)
      end.not_to change { cdr_export.reload.status }
    end
  end
end
