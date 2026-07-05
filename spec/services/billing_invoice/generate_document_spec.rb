# frozen_string_literal: true

RSpec.describe BillingInvoice::GenerateDocument do
  subject { described_class.call(invoice: invoice) }

  let!(:contractor) { FactoryBot.create(:vendor) }
  let!(:invoice_template) do
    FactoryBot.create(:invoice_template, html_template: '<p>{{ invoice.reference }}</p>')
  end
  let!(:account) do
    FactoryBot.create(:account, contractor: contractor, invoice_template: invoice_template)
  end
  let!(:invoice) do
    FactoryBot.create(:invoice,
                      account: account,
                      type_id: Billing::InvoiceType::MANUAL,
                      state_id: Billing::InvoiceState::NEW,
                      start_date: Time.zone.parse('2020-01-01 00:00:00'),
                      end_date: Time.zone.parse('2020-02-01 00:00:00'))
  end

  context 'when yeti-pdf is configured and succeeds' do
    let(:pdf_bytes) { '%PDF-1.7 rendered' }

    before do
      allow(YetiPdf::Client).to receive(:configured?).and_return(true)
      allow(YetiPdf::Client).to receive(:render_pdf).and_return(pdf_bytes)
    end

    it 'stores the pdf on a new invoice document' do
      expect { subject }.to change { Billing::InvoiceDocument.count }.by(1)
      doc = Billing::InvoiceDocument.last!
      expect(doc).to have_attributes(
        invoice: invoice,
        filename: invoice.file_name.to_s,
        pdf_data: pdf_bytes
      )
    end

    it 'sends the html_template and the nested raw data payload to the client' do
      subject
      expect(YetiPdf::Client).to have_received(:render_pdf).with(
        template: '<p>{{ invoice.reference }}</p>',
        data: hash_including(:account, :contractor, :invoice)
      )
    end

    it 'clears a previously recorded pdf_error' do
      invoice.update_column(:pdf_error, 'old error')
      subject
      expect(invoice.reload.pdf_error).to be_nil
    end
  end

  context 'when yeti-pdf returns an error' do
    before do
      allow(YetiPdf::Client).to receive(:configured?).and_return(true)
      allow(YetiPdf::Client).to receive(:render_pdf).and_raise(YetiPdf::Client::Error, 'boom')
    end

    it 'records the error on the invoice without raising or creating a document' do
      expect { subject }.not_to raise_error
      expect(invoice.reload.pdf_error).to eq('boom')
      expect(Billing::InvoiceDocument.count).to eq(0)
    end
  end

  context 'when pdf_api is not configured' do
    before { allow(YetiPdf::Client).to receive(:configured?).and_return(false) }

    it 'records a PdfApiNotConfigured error' do
      subject
      expect(invoice.reload.pdf_error).to match(/pdf_api is not configured/)
    end
  end

  context 'when the account has no template' do
    before { account.update!(invoice_template: nil) }

    it 'records a TemplateUndefined error' do
      subject
      expect(invoice.reload.pdf_error).to match(/Template blank/)
    end
  end
end
