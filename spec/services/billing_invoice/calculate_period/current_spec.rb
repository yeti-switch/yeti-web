# frozen_string_literal: true

RSpec.describe BillingInvoice::CalculatePeriod::Current, '.call' do
  subject do
    described_class.call(service_params)
  end

  let(:service_params) { { account: account } }

  include_context :timezone_helpers
  let!(:contractor) { FactoryBot.create(:contractor, vendor: true, customer: true) }
  let!(:account) { FactoryBot.create(:account, account_attrs) }
  let(:account_attrs) { { contractor: contractor, timezone: account_timezone } }
  let(:account_timezone) { utc_timezone }

  # stubbing current time during calculation
  include_context :stub_calculate_period_current_time
  let(:account_time_zone) { ActiveSupport::TimeZone.new(account_timezone) }
  let(:current_account_time) { account_time_zone.parse('2020-03-17 05:15:32') }
  before do
    Billing::Invoice.where(account_id: account.id).delete_all
  end

  context 'when invoice_period is daily and today is Tue 2020-03-17 in account timezone' do
    let(:account_attrs) do
      next_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
      super().merge invoice_period_id: Billing::InvoicePeriod::DAILY,
                    next_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                    next_invoice_at: next_invoice_at
    end

    it 'returns 2020-03-17 to 2020-03-18 AUTO_FULL' do
      is_expected.to match(
                       start_time: account_time_zone.parse('2020-03-17 00:00:00'),
                       end_time: account_time_zone.parse('2020-03-18 00:00:00'),
                       type_id: Billing::InvoiceType::AUTO_FULL
                     )
    end

    context 'when account timezone is LA' do
      let(:account_timezone) { la_timezone }

      it 'returns 2020-03-17 to 2020-03-18 AUTO_FULL' do
        is_expected.to match(
                         start_time: account_time_zone.parse('2020-03-17 00:00:00'),
                         end_time: account_time_zone.parse('2020-03-18 00:00:00'),
                         type_id: Billing::InvoiceType::AUTO_FULL
                       )
      end
    end
  end

  context 'when invoice_period is weekly and today is Tue 2020-03-17 in account timezone' do
    let(:account_attrs) do
      next_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
      super().merge invoice_period_id: Billing::InvoicePeriod::WEEKLY,
                    next_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                    next_invoice_at: next_invoice_at
    end

    it 'returns 2020-03-16 to 2020-03-23 AUTO_FULL' do
      is_expected.to match(
                       start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                       end_time: account_time_zone.parse('2020-03-23 00:00:00'),
                       type_id: Billing::InvoiceType::AUTO_FULL
                     )
    end

    context 'when account timezone is LA' do
      let(:account_timezone) { la_timezone }

      it 'returns 2020-03-16 to 2020-03-23 AUTO_FULL' do
        is_expected.to match(
                         start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                         end_time: account_time_zone.parse('2020-03-23 00:00:00'),
                         type_id: Billing::InvoiceType::AUTO_FULL
                       )
      end
    end
  end

  context 'when invoice_period is weekly split' do
    let(:account_attrs) do
      next_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
      super().merge invoice_period_id: Billing::InvoicePeriod::WEEKLY_SPLIT,
                    next_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                    next_invoice_at: next_invoice_at
    end

    context 'when today is Tue 2020-03-17 in account timezone' do
      it 'returns 2020-03-16 to 2020-03-23 AUTO_FULL' do
        is_expected.to match(
                         start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                         end_time: account_time_zone.parse('2020-03-23 00:00:00'),
                         type_id: Billing::InvoiceType::AUTO_FULL
                       )
      end

      context 'when account timezone is LA' do
        let(:account_timezone) { la_timezone }

        it 'returns 2020-03-16 to 2020-03-23 AUTO_FULL' do
          is_expected.to match(
                           start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                           end_time: account_time_zone.parse('2020-03-23 00:00:00'),
                           type_id: Billing::InvoiceType::AUTO_FULL
                         )
        end
      end
    end

    # Tue 2020-03-31 - last day of month
    context 'when today is Mon 2020-03-30 in account timezone' do
      let(:current_account_time) { account_time_zone.parse('2020-03-30 01:00:00') }

      it 'returns 2020-03-30 to 2020-04-01 AUTO_PARTIAL' do
        is_expected.to match(
                         start_time: account_time_zone.parse('2020-03-30 00:00:00'),
                         end_time: account_time_zone.parse('2020-04-01 00:00:00'),
                         type_id: Billing::InvoiceType::AUTO_PARTIAL
                       )
      end

      context 'when account timezone is LA' do
        let(:account_timezone) { la_timezone }

        it 'returns 2020-03-30 to 2020-04-01 AUTO_PARTIAL' do
          is_expected.to match(
                           start_time: account_time_zone.parse('2020-03-30 00:00:00'),
                           end_time: account_time_zone.parse('2020-04-01 00:00:00'),
                           type_id: Billing::InvoiceType::AUTO_PARTIAL
                         )
        end
      end
    end
  end

  context 'when invoice_period is biweekly and today is Tue 2020-03-17 in account timezone' do
    let(:account_attrs) do
      next_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
      super().merge invoice_period_id: Billing::InvoicePeriod::BIWEEKLY,
                    next_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                    next_invoice_at: next_invoice_at
    end

    it 'returns 2020-03-16 to 2020-03-30 AUTO_FULL' do
      is_expected.to match(
                       start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                       end_time: account_time_zone.parse('2020-03-30 00:00:00'),
                       type_id: Billing::InvoiceType::AUTO_FULL
                     )
    end

    context 'when account timezone is LA' do
      let(:account_timezone) { la_timezone }

      it 'returns 2020-03-16 to 2020-03-30 AUTO_FULL' do
        is_expected.to match(
                         start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                         end_time: account_time_zone.parse('2020-03-30 00:00:00'),
                         type_id: Billing::InvoiceType::AUTO_FULL
                       )
      end
    end
  end

  context 'when invoice_period is biweekly split and today is Tue 2020-03-17 in account timezone' do
    let(:account_attrs) do
      next_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
      super().merge invoice_period_id: Billing::InvoicePeriod::BIWEEKLY_SPLIT,
                    next_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                    next_invoice_at: next_invoice_at
    end

    context 'when today is Tue 2020-03-17 in account timezone' do
      it 'returns 2020-03-16 to 2020-03-30 AUTO_FULL' do
        is_expected.to match(
                         start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                         end_time: account_time_zone.parse('2020-03-30 00:00:00'),
                         type_id: Billing::InvoiceType::AUTO_FULL
                       )
      end

      context 'when account timezone is LA' do
        let(:account_timezone) { la_timezone }

        it 'returns 2020-03-16 to 2020-03-30 AUTO_FULL' do
          is_expected.to match(
                           start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                           end_time: account_time_zone.parse('2020-03-30 00:00:00'),
                           type_id: Billing::InvoiceType::AUTO_FULL
                         )
        end
      end
    end

    # Tue 2020-03-31 - last day of month
    context 'when today is Mon 2020-03-30 in account timezone' do
      let(:current_account_time) { account_time_zone.parse('2020-03-30 01:00:00') }

      it 'returns 2020-03-30 to 2020-04-01 AUTO_PARTIAL' do
        is_expected.to match(
                         start_time: account_time_zone.parse('2020-03-30 00:00:00'),
                         end_time: account_time_zone.parse('2020-04-01 00:00:00'),
                         type_id: Billing::InvoiceType::AUTO_PARTIAL
                       )
      end

      context 'when account timezone is LA' do
        let(:account_timezone) { la_timezone }

        it 'returns 2020-03-30 to 2020-04-01 AUTO_PARTIAL' do
          is_expected.to match(
                           start_time: account_time_zone.parse('2020-03-30 00:00:00'),
                           end_time: account_time_zone.parse('2020-04-01 00:00:00'),
                           type_id: Billing::InvoiceType::AUTO_PARTIAL
                         )
        end
      end
    end
  end

  context 'when invoice_period is monthly and today is Tue 2020-03-17 in account timezone' do
    let(:account_attrs) do
      next_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
      super().merge invoice_period_id: Billing::InvoicePeriod::MONTHLY,
                    next_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                    next_invoice_at: next_invoice_at
    end

    it 'returns 2020-03-01 to 2020-04-01 AUTO_FULL' do
      is_expected.to match(
                       start_time: account_time_zone.parse('2020-03-01 00:00:00'),
                       end_time: account_time_zone.parse('2020-04-01 00:00:00'),
                       type_id: Billing::InvoiceType::AUTO_FULL
                     )
    end

    context 'when account timezone is LA' do
      let(:account_timezone) { la_timezone }

      it 'returns 2020-03-01 to 2020-04-01 AUTO_FULL' do
        is_expected.to match(
                         start_time: account_time_zone.parse('2020-03-01 00:00:00'),
                         end_time: account_time_zone.parse('2020-04-01 00:00:00'),
                         type_id: Billing::InvoiceType::AUTO_FULL
                       )
      end
    end

    context 'when account has manual invoice with end_date 2020-03-14 12:00:01' do
      before do
        FactoryBot.create(
          :invoice,
          :manual,
          account: account,
          start_date: account_time_zone.parse('2020-03-10 00:00:00').in_time_zone(server_time_zone),
          end_date: account_time_zone.parse('2020-03-14 12:00:01').in_time_zone(server_time_zone)
        )
      end

      it 'returns 2020-03-14 to 2020-04-01 AUTO_FULL' do
        is_expected.to match(
                         start_time: account_time_zone.parse('2020-03-14 12:00:01'),
                         end_time: account_time_zone.parse('2020-04-01 00:00:00'),
                         type_id: Billing::InvoiceType::AUTO_FULL
                       )
      end

      context 'when account timezone is LA' do
        let(:account_timezone) { la_timezone }

        it 'returns 2020-03-14 to 2020-04-01 AUTO_FULL' do
          is_expected.to match(
                           start_time: account_time_zone.parse('2020-03-14 12:00:01'),
                           end_time: account_time_zone.parse('2020-04-01 00:00:00'),
                           type_id: Billing::InvoiceType::AUTO_FULL
                         )
        end
      end
    end
  end

  context 'when account does not have invoice_period' do
    let(:account_attrs) do
      next_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
      super().merge invoice_period_id: nil,
                    next_invoice_type_id: nil,
                    next_invoice_at: nil
    end

    include_examples :raises_exception,
                     ApplicationService::Error,
                     'account invoice period is required'
  end

  context 'when timezone is invalid' do
    let(:current_account_time) { Time.parse('2020-03-17 05:15:32') }
    let(:account_attrs) { super().merge invoice_period_id: Billing::InvoicePeriod::DAILY, next_invoice_type_id: Billing::InvoiceType::AUTO_FULL, next_invoice_at: Time.parse('2020-01-01 00:00:00') }

    before { allow_any_instance_of(BillingInvoice::CalculatePeriod::Current).to receive(:time_zone).and_return(nil) }

    include_examples :raises_exception, ApplicationService::Error, 'failed to find time zone UTC'
  end
end
