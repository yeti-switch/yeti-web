# frozen_string_literal: true

# Dispatch behaviour of GenerateDocument (ODT vs yeti-pdf HTML path). Kept
# separate from generate_document_spec.rb so it doesn't depend on the
# destination/network factories (and their seed data) — here the invoice has no
# line items, which is enough to exercise the branch selection.
RSpec.describe BillingInvoice::GenerateDocument do
  subject { described_class.call(invoice: invoice) }

  let!(:contractor) { FactoryBot.create(:vendor) }
  let!(:invoice_template) { FactoryBot.create(:invoice_template, invoice_template_attrs) }
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

  context 'when the template has an html_template and pdf_api is configured' do
    let(:invoice_template_attrs) do
      { filename: nil, data: nil, html_template: '<p>{{ invoice.reference }}</p>' }
    end
    let(:pdf_bytes) { '%PDF-1.7 rendered' }

    before do
      allow(YetiPdf::Client).to receive(:configured?).and_return(true)
      allow(YetiPdf::Client).to receive(:render_pdf).and_return(pdf_bytes)
      allow(YetiPdf::Client).to receive(:render_html).and_return('<p>INV</p>')
    end

    it 'renders via yeti-pdf and stores the pdf plus the merged html' do
      expect { subject }.to change { Billing::InvoiceDocument.count }.by(1)
      doc = Billing::InvoiceDocument.last!
      expect(doc.pdf_data).to eq(pdf_bytes)
      expect(doc.data).to eq('<p>INV</p>')
    end

    it 'sends the html_template and the nested raw data payload to the client' do
      subject
      expect(YetiPdf::Client).to have_received(:render_pdf).with(
        template: '<p>{{ invoice.reference }}</p>',
        data: hash_including(:account, :contractor, :invoice, :originated_destinations, :service_data)
      )
    end

    it 'does not shell out to the ODT converter' do
      expect(Open3).not_to receive(:capture3)
      subject
    end
  end

  context 'when the template has an html_template but pdf_api is not configured' do
    let(:invoice_template_attrs) { { filename: nil, data: nil, html_template: '<p>x</p>' } }

    before { allow(YetiPdf::Client).to receive(:configured?).and_return(false) }

    it 'raises PdfApiNotConfigured rather than falling back to the ODT path' do
      expect { subject }.to raise_error(described_class::PdfApiNotConfigured)
    end
  end

  context 'when the account has no template' do
    let(:invoice_template_attrs) { { html_template: '<p>x</p>' } }

    before { account.update!(invoice_template: nil) }

    it 'raises TemplateUndefined' do
      expect { subject }.to raise_error(described_class::TemplateUndefined)
    end
  end
end
