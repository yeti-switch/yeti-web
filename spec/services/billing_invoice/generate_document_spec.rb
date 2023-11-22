# frozen_string_literal: true

RSpec.describe BillingInvoice::GenerateDocument do
  subject do
    described_class.call(service_params)
  end

  let(:service_params) { { invoice: invoice } }

  let!(:contractor) { FactoryBot.create(:vendor) }
  let(:odt_fixture_binary) do
    IO.binread Rails.root.join('spec/fixtures/files/invoice_template.odt')
  end
  let!(:invoice_template) do
    FactoryBot.create(:invoice_template, data: odt_fixture_binary)
  end
  let!(:account) { FactoryBot.create(:account, account_attrs) }
  let(:account_attrs) do
    {
      contractor: contractor,
      invoice_template: invoice_template
    }
  end
  let!(:invoice) { FactoryBot.create(:invoice, invoice_attrs) }
  let(:invoice_attrs) do
    {
      account: account,
      type_id: Billing::InvoiceType::MANUAL,
      state_id: Billing::InvoiceState::NEW,
      start_date: Time.zone.parse('2020-01-01 00:00:00'),
      end_date: Time.zone.parse('2020-02-01 00:00:00')
    }
  end
  before do
    FactoryBot.create_list(:invoice_originated_destination, 20, :success, invoice: invoice)
    FactoryBot.create_list(:invoice_terminated_destination, 15, :success, invoice: invoice)
  end

  it 'creates invoice document' do
    expect { subject }.to change { Billing::InvoiceDocument.count }.by(1)
    doc = Billing::InvoiceDocument.last!
    expect(doc).to have_attributes(
                     invoice: invoice,
                     filename: invoice.file_name.to_s,
                     data: be_present
                   )
  end
end
