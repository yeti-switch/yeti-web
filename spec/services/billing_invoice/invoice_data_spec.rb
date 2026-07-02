# frozen_string_literal: true

RSpec.describe BillingInvoice::InvoiceData do
  subject(:payload) { described_class.call(invoice: invoice) }

  let!(:contractor) { FactoryBot.create(:vendor) }
  let!(:invoice_template) { FactoryBot.create(:invoice_template) }
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

  # NOTE: line-item collections (destinations/networks) are exercised in CI,
  # where the network/prefix seed data exists; here we assert the payload shape,
  # value types, and that the collections are always present as arrays.

  it 'returns nested account/contractor/invoice sections' do
    expect(payload[:account]).to include(id: account.id, name: account.name)
    expect(payload[:contractor]).to include(name: contractor.name)
    expect(payload[:invoice]).to include(:id, :reference, :amount_total, :originated, :terminated, :services)
  end

  it 'exposes every collection as an array' do
    %i[originated_destinations originated_destinations_succ
       terminated_destinations terminated_destinations_succ
       originated_networks originated_networks_succ
       terminated_networks terminated_networks_succ service_data].each do |key|
      expect(payload[key]).to be_an(Array), "expected #{key} to be an Array"
    end
  end

  it 'sends raw numeric types, not pre-formatted strings' do
    expect(payload[:invoice][:amount_total]).to be_a(Numeric).or be_nil
    expect(payload[:invoice][:originated][:calls_count]).to be_a(Integer).or be_nil
  end

  it 'formats timestamps as ISO-8601 strings' do
    expect(payload[:invoice][:start_date]).to eq(invoice.start_date.iso8601)
  end
end
