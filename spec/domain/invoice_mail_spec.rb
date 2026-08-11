# frozen_string_literal: true

RSpec.describe InvoiceMail do
  subject(:mail) { described_class.new(invoice_document) }

  let!(:contractor) { FactoryBot.create(:vendor) }
  let!(:account) { FactoryBot.create(:account, contractor: contractor) }
  let!(:invoice) do
    FactoryBot.create(:invoice,
                      account: account,
                      type_id: Billing::InvoiceType::MANUAL,
                      state_id: Billing::InvoiceState::NEW,
                      start_date: Time.zone.parse('2020-01-01 00:00:00'),
                      end_date: Time.zone.parse('2020-02-01 00:00:00'))
  end
  let!(:invoice_document) do
    FactoryBot.create(:invoice_document, :filled, invoice: invoice, filename: 'invoice-77')
  end
  let(:template) { Billing::InvoiceEmailTemplate.instance }

  describe '#assigns' do
    it 'exposes the same vocabulary as the PDF payload' do
      expect(mail.assigns).to include(:account, :contractor, :invoice, :service_data, :document)
    end

    it 'omits the per-destination and per-network breakdowns an email never quotes' do
      expect(mail.assigns).not_to include(:originated_destinations, :terminated_destinations,
                                          :originated_networks, :terminated_networks)
    end

    it 'names the attachment carried by this very message' do
      expect(mail.assigns[:document]).to eq(filename: 'invoice-77.pdf')
    end

    it 'covers every variable the documented contract promises' do
      # A key in sample_assigns that #assigns omits would validate at save time
      # and then render blank in production — the one drift that matters.
      expect(mail.assigns.keys).to include(*described_class.sample_assigns.keys)
    end
  end

  describe '#subject' do
    it 'renders the stored template' do
      template.update!(subject: 'Invoice {{ invoice.reference }}')
      expect(mail.subject).to eq("Invoice #{invoice.reference}")
    end

    it 'falls back to the invoice name when the template renders to blank' do
      template.update_column(:subject, '   ')
      expect(mail.subject).to eq(invoice.display_name)
    end

    context 'when the template row is missing' do
      before { allow(Billing::InvoiceEmailTemplate).to receive(:instance).and_return(nil) }

      it 'falls back to the invoice name rather than raising mid-delivery' do
        expect(mail.subject).to eq(invoice.display_name)
      end
    end

    context 'when rendering blows up' do
      before do
        allow(Billing::InvoiceEmailTemplate).to receive(:instance).and_return(template)
        allow(template).to receive(:render_subject).and_raise(StandardError, 'boom')
      end

      it 'falls back instead of losing the email' do
        expect(mail.subject).to eq(invoice.display_name)
      end

      it 'captures the error so the broken template gets fixed' do
        expect(CaptureError).to receive(:capture)
        mail.subject
      end
    end
  end

  describe '#html_body and #text_body' do
    before do
      template.update!(html_body: '<b>{{ invoice.reference }}</b>', text_body: 'ref {{ invoice.reference }}')
    end

    it 'renders both parts' do
      expect(mail.html_body).to eq("<b>#{invoice.reference}</b>")
      expect(mail.text_body).to eq("ref #{invoice.reference}")
    end

    context 'when the template row is missing' do
      before { allow(Billing::InvoiceEmailTemplate).to receive(:instance).and_return(nil) }

      it 'returns nil, which keeps the message single-part as it was before templates' do
        expect(mail.html_body).to be_nil
        expect(mail.text_body).to be_nil
      end
    end
  end

  describe '.sample_assigns' do
    it 'renders the seeded templates, so the admin preview always works' do
      expect { template.render_subject(described_class.sample_assigns) }.not_to raise_error
      expect { template.render_html_body(described_class.sample_assigns) }.not_to raise_error
      expect { template.render_text_body(described_class.sample_assigns) }.not_to raise_error
    end
  end

  describe '.variable_reference' do
    it 'documents every scalar the contract exposes' do
      names = described_class.variable_reference.map { |r| r[:name] }
      expect(names).to include('invoice.reference', 'invoice.originated.calls_count',
                               'account.name', 'contractor.name', 'document.filename')
    end
  end
end
