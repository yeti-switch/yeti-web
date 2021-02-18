# frozen_string_literal: true

RSpec.describe InvoiceRefTemplate, '.call' do
  subject do
    InvoiceRefTemplate.call(invoice, template)
  end

  let!(:contractor) { FactoryBot.create(:vendor) }
  let!(:account) { FactoryBot.create(:account, account_attrs) }
  let(:account_attrs) do
    { contractor: contractor }
  end
  let(:invoice) { FactoryBot.create(:invoice, :vendor, :manual, invoice_attrs) }
  let(:invoice_attrs) do
    { account: account }
  end

  context 'when template is "$id"' do
    let(:template) { '$id' }

    it { is_expected.to eq invoice.id.to_s }
  end

  context 'when template is "test_$id"' do
    let(:template) { 'test_$id' }

    it { is_expected.to eq "test_#{invoice.id}" }
  end

  context 'when template is "$id_test"' do
    let(:template) { '$id_test' }

    it { is_expected.to eq "#{invoice.id}_test" }
  end

  context 'when template is "$id_test_$id"' do
    let(:template) { '$id_test_$id' }

    it { is_expected.to eq "#{invoice.id}_test_#{invoice.id}" }
  end

  context 'when template is "test"' do
    let(:template) { 'test' }

    it { is_expected.to eq 'test' }
  end
end
