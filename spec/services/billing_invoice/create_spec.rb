# frozen_string_literal: true

RSpec.describe BillingInvoice::Create do
  subject do
    described_class.call(service_params)
  end

  shared_examples :creates_an_invoice do
    it 'creates an invoice with correct params' do
      expect { subject }.to change { Billing::Invoice.count }.by(1)
      invoice = Billing::Invoice.last!

      expect(invoice).to have_attributes(
                             contractor_id: account.contractor_id,
                             account_id: account.id,
                             start_date: service_params[:start_time],
                             end_date: service_params[:end_time],
                             vendor_invoice: service_params[:is_vendor],
                             type_id: service_params[:type_id],
                             state_id: Billing::InvoiceState::NEW,
                             amount: 0,
                             billing_duration: 0,
                             calls_count: 0,
                             calls_duration: 0,
                             first_call_at: nil,
                             first_successful_call_at: nil,
                             last_call_at: nil,
                             last_successful_call_at: nil,
                             successful_calls_count: nil
                           )
    end

    it 'enqueues Worker::FillInvoiceJob with invoice.id' do
      subject
      invoice = Billing::Invoice.last!

      expect(Worker::FillInvoiceJob).to have_been_enqueued.with(invoice.id)
    end
  end

  shared_examples :does_not_create_invoice do
    let(:service_error) { nil }

    it 'raises BillingInvoice::Create::Error' do
      expect { subject }.to raise_error(BillingInvoice::Create::Error, service_error)
    end

    it 'does not create invoice' do
      expect {
        begin
                 subject
        rescue StandardError
          nil
               end
      }.to_not change { Billing::Invoice.count }
    end

    it 'does not enqueue Worker::FillInvoiceJob' do
      expect {
        begin
                 subject
        rescue StandardError
          nil
               end
      }.to_not have_enqueued_job(Worker::FillInvoiceJob)
    end
  end

  include_context :timezone_helpers

  let!(:contractor) { FactoryBot.create(:vendor) }
  let!(:account) { FactoryBot.create(:account, account_attrs) }
  let(:account_attrs) { { contractor: contractor, timezone: account_timezone } }
  let(:account_timezone) { la_timezone }
  let(:account_time_zone) { account_timezone.time_zone }
  before { Billing::Invoice.where(account_id: account.id).delete_all }

  let(:service_params) do
    {
      account: account,
      is_vendor: true,
      start_time: account_time_zone.parse('2020-01-01 00:00:00'),
      end_time: account_time_zone.parse('2020-02-01 00:00:00'),
      type_id: Billing::InvoiceType::MANUAL
    }
  end

  context 'when type_id MANUAL' do
    include_examples :creates_an_invoice
  end

  context 'when type_id AUTO_FULL' do
    let(:service_params) { super().merge type_id: Billing::InvoiceType::AUTO_FULL }

    include_examples :creates_an_invoice
  end

  context 'when type_id AUTO_PARTIAL' do
    let(:service_params) { super().merge type_id: Billing::InvoiceType::AUTO_PARTIAL }

    include_examples :creates_an_invoice
  end

  context 'with is_vendor=false' do
    let(:service_params) { super().merge is_vendor: false }

    include_examples :creates_an_invoice
  end

  context 'when other invoice exists' do
    before { FactoryBot.create(:invoice, other_invoice_attrs) }
    let(:other_invoice_attrs) do
      {
        vendor_invoice: true,
        account: account,
        start_date: account_time_zone.parse('2020-01-01 00:00:00'),
        end_date: account_time_zone.parse('2020-02-01 00:00:00')
      }
    end

    context 'when other invoice starts at start_time and ends at end_time' do
      include_examples :does_not_create_invoice do
        let(:service_error) { 'have invoice inside provided period' }
      end
    end

    context 'when other invoice starts at start_time and ends earlier than end_time' do
      let(:other_invoice_attrs) do
        super().merge start_date: account_time_zone.parse('2020-01-01 00:00:00'),
                      end_date: account_time_zone.parse('2020-01-02 00:00:00')
      end

      include_examples :does_not_create_invoice do
        let(:service_error) { 'have invoice inside provided period' }
      end
    end

    context 'when other invoice starts at start_time and ends later than end_time' do
      let(:other_invoice_attrs) do
        super().merge start_date: account_time_zone.parse('2020-01-01 00:00:00'),
                      end_date: account_time_zone.parse('2020-02-02 00:00:00')
      end

      include_examples :does_not_create_invoice do
        let(:service_error) { 'have invoice inside provided period' }
      end
    end

    context 'when other invoice starts earlier than start_time and ends at end_time' do
      let(:other_invoice_attrs) do
        super().merge start_date: account_time_zone.parse('2019-12-31 00:00:00'),
                      end_date: account_time_zone.parse('2020-02-01 00:00:00')
      end

      include_examples :does_not_create_invoice do
        let(:service_error) { 'have invoice inside provided period' }
      end
    end

    context 'when other invoice starts earlier than start_time and ends earlier than end_time' do
      let(:other_invoice_attrs) do
        super().merge start_date: account_time_zone.parse('2019-12-31 00:00:00'),
                      end_date: account_time_zone.parse('2020-01-02 00:00:00')
      end

      include_examples :does_not_create_invoice do
        let(:service_error) { 'have invoice inside provided period' }
      end
    end

    context 'when other invoice starts earlier than start_time and ends later than end_time' do
      let(:other_invoice_attrs) do
        super().merge start_date: account_time_zone.parse('2019-12-31 00:00:00'),
                      end_date: account_time_zone.parse('2020-02-02 00:00:00')
      end

      include_examples :does_not_create_invoice do
        let(:service_error) { 'have invoice inside provided period' }
      end
    end

    context 'when other invoice starts earlier than start_time and ends at start_time' do
      let(:other_invoice_attrs) do
        super().merge start_date: account_time_zone.parse('2019-12-31 00:00:00'),
                      end_date: account_time_zone.parse('2020-01-01 00:00:00')
      end

      include_examples :creates_an_invoice
    end

    context 'when other invoice starts earlier than start_time and ends earlier than start_time' do
      let(:other_invoice_attrs) do
        super().merge start_date: account_time_zone.parse('2019-12-30 00:00:00'),
                      end_date: account_time_zone.parse('2019-12-31 00:00:00')
      end

      include_examples :creates_an_invoice
    end

    context 'when other invoice starts later than start_time and ends at end_time' do
      let(:other_invoice_attrs) do
        super().merge start_date: account_time_zone.parse('2020-01-31 00:00:00'),
                      end_date: account_time_zone.parse('2020-02-01 00:00:00')
      end

      include_examples :does_not_create_invoice do
        let(:service_error) { 'have invoice inside provided period' }
      end
    end

    context 'when other invoice starts later than start_time and ends earlier than end_time' do
      let(:other_invoice_attrs) do
        super().merge start_date: account_time_zone.parse('2020-01-30 00:00:00'),
                      end_date: account_time_zone.parse('2020-01-31 00:00:00')
      end

      include_examples :does_not_create_invoice do
        let(:service_error) { 'have invoice inside provided period' }
      end
    end

    context 'when other invoice starts later than start_time and ends later than end_time' do
      let(:other_invoice_attrs) do
        super().merge start_date: account_time_zone.parse('2020-01-31 00:00:00'),
                      end_date: account_time_zone.parse('2020-02-02 00:00:00')
      end

      include_examples :does_not_create_invoice do
        let(:service_error) { 'have invoice inside provided period' }
      end
    end

    context 'when other invoice starts at end_time and ends later than end_time' do
      let(:other_invoice_attrs) do
        super().merge start_date: account_time_zone.parse('2020-02-01 00:00:00'),
                      end_date: account_time_zone.parse('2020-02-02 00:00:00')
      end

      include_examples :creates_an_invoice
    end

    context 'when other invoice starts later than end_time and ends later than end_time' do
      let(:other_invoice_attrs) do
        super().merge start_date: account_time_zone.parse('2020-02-02 00:00:00'),
                      end_date: account_time_zone.parse('2020-02-03 00:00:00')
      end

      include_examples :creates_an_invoice
    end

    context 'when other invoice is customer' do
      let(:other_invoice_attrs) { super().merge vendor_invoice: false }

      include_examples :creates_an_invoice
    end

    context 'when other invoice is for different account' do
      let(:other_invoice_attrs) { super().merge account: different_account }
      let!(:different_account) { FactoryBot.create(:account, account_attrs) }

      include_examples :creates_an_invoice
    end
  end
end
