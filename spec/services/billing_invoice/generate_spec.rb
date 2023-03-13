# frozen_string_literal: true

RSpec.describe BillingInvoice::Generate do
  subject do
    described_class.call(service_params)
  end

  let(:service_params) { { account: account, is_vendor: true } }

  include_context :timezone_helpers
  let!(:contractor) { FactoryBot.create(:vendor) }
  let!(:account) { FactoryBot.create(:account, account_attrs) }
  let(:account_timezone) { la_timezone }
  let(:account_time_zone) { ActiveSupport::TimeZone.new(account_timezone.name) }
  let(:account_attrs) do
    {
      contractor: contractor,
      timezone: account_timezone,
      vendor_invoice_period_id: Billing::InvoicePeriod::DAILY_ID,
      next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
      next_vendor_invoice_at: account_time_zone.now.beginning_of_day
    }
  end
  before { Billing::Invoice.where(account_id: account.id).delete_all }

  context 'with invoice period daily' do
    before do
      expect(BillingInvoice::CalculatePeriod::Next).to receive(:call).with(
        account: account,
        is_vendor: true,
        period_end: account.next_vendor_invoice_at
      ).once.and_call_original
    end

    it 'calls BillingInvoice::Create correctly' do
      expect(BillingInvoice::Create).to receive(:call).with(
        account: account,
        is_vendor: true,
        start_time: (account_time_zone.now.beginning_of_day - 1.day),
        end_time: account_time_zone.now.beginning_of_day,
        type_id: Billing::InvoiceType::AUTO_FULL
      ).once.and_call_original

      subject
    end

    it 'schedules next invoice correctly' do
      subject
      expect(account.reload).to have_attributes(
                                  next_vendor_invoice_at: (account_time_zone.now.beginning_of_day + 1.day),
                                  next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL
                                )
    end

    context 'when another account has vendor invoice with end_date > account.next_vendor_invoice_at' do
      let!(:another_account) { FactoryBot.create(:account, account_attrs) }
      let!(:other_invoice) { FactoryBot.create(:invoice, other_invoice_attrs) }
      let(:other_invoice_attrs) do
        {
          vendor_invoice: true,
          account: another_account,
          start_date: (account_time_zone.now.beginning_of_day - 2.days),
          end_date: account_time_zone.now.beginning_of_day + 12.hours
        }
      end

      it 'calls BillingInvoice::Create correctly' do
        expect(BillingInvoice::Create).to receive(:call).with(
          account: account,
          is_vendor: true,
          start_time: (account_time_zone.now.beginning_of_day - 1.day),
          end_time: account_time_zone.now.beginning_of_day,
          type_id: Billing::InvoiceType::AUTO_FULL
        ).once.and_call_original

        subject
      end

      it 'schedules next invoice correctly' do
        subject
        expect(account.reload).to have_attributes(
                                    next_vendor_invoice_at: (account_time_zone.now.beginning_of_day + 1.day),
                                    next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL
                                  )
      end
    end

    context 'when account has customer invoice with end_date > account.next_vendor_invoice_at' do
      let!(:other_invoice) { FactoryBot.create(:invoice, other_invoice_attrs) }
      let(:other_invoice_attrs) do
        {
          vendor_invoice: false,
          account: account,
          start_date: (account_time_zone.now.beginning_of_day - 2.days),
          end_date: account_time_zone.now.beginning_of_day + 12.hours
        }
      end

      it 'calls BillingInvoice::Create correctly' do
        expect(BillingInvoice::Create).to receive(:call).with(
          account: account,
          is_vendor: true,
          start_time: (account_time_zone.now.beginning_of_day - 1.day),
          end_time: account_time_zone.now.beginning_of_day,
          type_id: Billing::InvoiceType::AUTO_FULL
        ).once.and_call_original

        subject
      end

      it 'schedules next invoice correctly' do
        subject
        expect(account.reload).to have_attributes(
                                    next_vendor_invoice_at: (account_time_zone.now.beginning_of_day + 1.day),
                                    next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL
                                  )
      end
    end

    context 'when account has vendor invoice' do
      let!(:other_invoice) { FactoryBot.create(:invoice, other_invoice_attrs) }
      let(:other_invoice_attrs) do
        { vendor_invoice: true, account: account }
      end

      context 'when invoice has end_date < calculated start_date' do
        let(:other_invoice_attrs) do
          super().merge start_date: (account_time_zone.now.beginning_of_day - 2.days),
                        end_date: (account_time_zone.now.beginning_of_day - 1.day)
        end

        it 'calls BillingInvoice::Create correctly' do
          expect(BillingInvoice::Create).to receive(:call).with(
            account: account,
            is_vendor: true,
            start_time: (account_time_zone.now.beginning_of_day - 1.day),
            end_time: account_time_zone.now.beginning_of_day,
            type_id: Billing::InvoiceType::AUTO_FULL
          ).once.and_call_original

          subject
        end

        it 'schedules next invoice correctly' do
          subject
          expect(account.reload).to have_attributes(
                                      next_vendor_invoice_at: (account_time_zone.now.beginning_of_day + 1.day),
                                      next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL
                                    )
        end
      end

      context 'when invoice has end_date > calculated start_date' do
        let(:other_invoice_attrs) do
          super().merge start_date: (account_time_zone.now.beginning_of_day - 2.days),
                        end_date: (account_time_zone.now.beginning_of_day - 12.hours)
        end

        it 'calls BillingInvoice::Create correctly' do
          expect(BillingInvoice::Create).to receive(:call).with(
            account: account,
            is_vendor: true,
            start_time: (account_time_zone.now.beginning_of_day - 12.hours),
            end_time: account_time_zone.now.beginning_of_day,
            type_id: Billing::InvoiceType::AUTO_FULL
          ).once.and_call_original

          subject
        end

        it 'schedules next invoice correctly' do
          subject
          expect(account.reload).to have_attributes(
                                      next_vendor_invoice_at: (account_time_zone.now.beginning_of_day + 1.day),
                                      next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL
                                    )
        end
      end

      context 'when invoice has end_date = account.next_vendor_invoice_at' do
        let(:other_invoice_attrs) do
          super().merge start_date: (account_time_zone.now.beginning_of_day - 2.days),
                        end_date: account_time_zone.now.beginning_of_day
        end

        include_examples :raises_exception,
                         BillingInvoice::Generate::Error,
                         'invoice exists with end_date greater than or equal to current end_date'
      end

      context 'when invoice has end_date > account.next_vendor_invoice_at' do
        let(:other_invoice_attrs) do
          super().merge start_date: (account_time_zone.now.beginning_of_day - 2.days),
                        end_date: account_time_zone.now.beginning_of_day + 12.hours
        end

        include_examples :raises_exception,
                         BillingInvoice::Generate::Error,
                         'invoice exists with end_date greater than or equal to current end_date'
      end
    end
  end

  context 'when BillingInvoice::CalculatePeriod respond with partial' do
    let(:account_attrs) do
      super().merge vendor_invoice_period_id: Billing::InvoicePeriod::WEEKLY_SPLIT_ID,
                    next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                    next_vendor_invoice_at: account_time_zone.parse('2020-10-26 00:00:00')
    end
    let(:calc_period_result) do
      {
        start_time: account_time_zone.parse('2020-10-19 00:00:00'),
        next_end_time: account_time_zone.parse('2020-11-01 00:00:00'),
        next_type_id: Billing::InvoiceType::AUTO_PARTIAL
      }
    end

    before do
      expect(BillingInvoice::CalculatePeriod::Next).to receive(:call).with(
        account: account,
        is_vendor: true,
        period_end: account.next_vendor_invoice_at
      ).once.and_return(calc_period_result)
    end

    it 'calls BillingInvoice::Create correctly' do
      expect(BillingInvoice::Create).to receive(:call).with(
        account: account,
        is_vendor: true,
        start_time: calc_period_result[:start_time],
        end_time: account.next_vendor_invoice_at,
        type_id: account.next_vendor_invoice_type_id
      ).once.and_call_original

      subject
    end

    it 'schedules next invoice correctly' do
      subject
      expect(account.reload).to have_attributes(
                                  next_vendor_invoice_at: calc_period_result[:next_end_time],
                                  next_vendor_invoice_type_id: calc_period_result[:next_type_id]
                                )
    end
  end
end
