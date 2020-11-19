# frozen_string_literal: true

RSpec.describe BillingInvoice::CalculatePeriod::Current, '.call' do
  subject do
    described_class.call(service_params)
  end

  let(:service_params) { { account: account, is_vendor: true } }

  include_context :timezone_helpers
  let!(:contractor) { FactoryBot.create(:vendor) }
  let!(:account) { FactoryBot.create(:account, account_attrs) }
  let(:account_attrs) { { contractor: contractor, timezone: account_timezone } }
  let(:account_timezone) { utc_timezone }

  # stubbing current time during calculation
  include_context :stub_calculate_period_current_time
  let(:account_time_zone) { ActiveSupport::TimeZone.new(account_timezone.name) }
  let(:current_account_time) { account_time_zone.parse('2020-03-17 05:15:32') }
  before do
    Billing::Invoice.where(account_id: account.id).delete_all
  end

  context 'with vendor account' do
    context 'when vendor_invoice_period is daily and today is Tue 2020-03-17 in account timezone' do
      let(:account_attrs) do
        next_vendor_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
        super().merge vendor_invoice_period_id: Billing::InvoicePeriod::DAILY_ID,
                      next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_vendor_invoice_at: next_vendor_invoice_at
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

    context 'when vendor_invoice_period is weekly and today is Tue 2020-03-17 in account timezone' do
      let(:account_attrs) do
        next_vendor_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
        super().merge vendor_invoice_period_id: Billing::InvoicePeriod::WEEKLY_ID,
                      next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_vendor_invoice_at: next_vendor_invoice_at
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

    context 'when vendor_invoice_period is weekly split' do
      let(:account_attrs) do
        next_vendor_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
        super().merge vendor_invoice_period_id: Billing::InvoicePeriod::WEEKLY_SPLIT_ID,
                      next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_vendor_invoice_at: next_vendor_invoice_at
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

    context 'when vendor_invoice_period is biweekly and today is Tue 2020-03-17 in account timezone' do
      let(:account_attrs) do
        next_vendor_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
        super().merge vendor_invoice_period_id: Billing::InvoicePeriod::BIWEEKLY_ID,
                      next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_vendor_invoice_at: next_vendor_invoice_at
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

    context 'when vendor_invoice_period is biweekly split and today is Tue 2020-03-17 in account timezone' do
      let(:account_attrs) do
        next_vendor_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
        super().merge vendor_invoice_period_id: Billing::InvoicePeriod::BIWEEKLY_SPLIT_ID,
                      next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_vendor_invoice_at: next_vendor_invoice_at
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

    context 'when vendor_invoice_period is monthly and today is Tue 2020-03-17 in account timezone' do
      let(:account_attrs) do
        next_vendor_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
        super().merge vendor_invoice_period_id: Billing::InvoicePeriod::MONTHLY_ID,
                      next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_vendor_invoice_at: next_vendor_invoice_at
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

      context 'when account has manual vendor invoice with end_date 2020-03-14 12:00:01' do
        before do
          FactoryBot.create(
              :invoice,
              :vendor,
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

      context 'when account has manual customer invoice with end_date 2020-03-14 12:00:01' do
        before do
          FactoryBot.create(
              :invoice,
              :customer,
              :manual,
              account: account,
              start_date: account_time_zone.parse('2020-03-10 00:00:00').in_time_zone(server_time_zone),
              end_date: account_time_zone.parse('2020-03-14 12:00:01').in_time_zone(server_time_zone)
            )
        end

        it 'returns 2020-03-01 to 2020-04-01 AUTO_FULL' do
          is_expected.to match(
                             start_time: account_time_zone.parse('2020-03-01 00:00:00'),
                             end_time: account_time_zone.parse('2020-04-01 00:00:00'),
                             type_id: Billing::InvoiceType::AUTO_FULL
                           )
        end
      end
    end

    context 'when account does not have vendor_invoice_period' do
      let(:account_attrs) do
        next_vendor_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
        super().merge customer_invoice_period_id: Billing::InvoicePeriod::DAILY_ID,
                      next_customer_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_customer_invoice_at: next_vendor_invoice_at
      end

      include_examples :raises_exception,
                       ApplicationService::Error,
                       'account vendor invoice period is required'
    end

    context 'when account timezone has invalid name' do
      let(:current_account_time) { Time.parse('2020-03-17 05:15:32') }
      let(:account_timezone) do
        FactoryBot.create(:timezone, name: 'RSpec', abbrev: 'RSP', utc_offset: '11:00')
      end
      let(:account_attrs) do
        super().merge vendor_invoice_period_id: Billing::InvoicePeriod::DAILY_ID,
                      next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_vendor_invoice_at: Time.parse('2020-01-01 00:00:00')
      end

      include_examples :raises_exception,
                       ApplicationService::Error,
                       'failed to find time zone RSpec'
    end
  end

  context 'with customer account' do
    let(:contractor) { FactoryBot.create(:customer) }
    let(:service_params) { super().merge is_vendor: false }

    context 'when customer_invoice_period is daily and today is Tue 2020-03-17 in account timezone' do
      let(:account_attrs) do
        next_customer_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
        super().merge customer_invoice_period_id: Billing::InvoicePeriod::DAILY_ID,
                      next_customer_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_customer_invoice_at: next_customer_invoice_at
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

    context 'when customer_invoice_period is weekly and today is Tue 2020-03-17 in account timezone' do
      let(:account_attrs) do
        next_customer_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
        super().merge customer_invoice_period_id: Billing::InvoicePeriod::WEEKLY_ID,
                      next_customer_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_customer_invoice_at: next_customer_invoice_at
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

    context 'when customer_invoice_period is weekly split' do
      let(:account_attrs) do
        next_customer_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
        super().merge customer_invoice_period_id: Billing::InvoicePeriod::WEEKLY_SPLIT_ID,
                      next_customer_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_customer_invoice_at: next_customer_invoice_at
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

    context 'when customer_invoice_period is biweekly and today is Tue 2020-03-17 in account timezone' do
      let(:account_attrs) do
        next_customer_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
        super().merge customer_invoice_period_id: Billing::InvoicePeriod::BIWEEKLY_ID,
                      next_customer_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_customer_invoice_at: next_customer_invoice_at
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

    context 'when customer_invoice_period is biweekly split and today is Tue 2020-03-17 in account timezone' do
      let(:account_attrs) do
        next_customer_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
        super().merge customer_invoice_period_id: Billing::InvoicePeriod::BIWEEKLY_SPLIT_ID,
                      next_customer_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_customer_invoice_at: next_customer_invoice_at
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

    context 'when customer_invoice_period is monthly and today is Tue 2020-03-17 in account timezone' do
      let(:account_attrs) do
        next_customer_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
        super().merge customer_invoice_period_id: Billing::InvoicePeriod::MONTHLY_ID,
                      next_customer_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_customer_invoice_at: next_customer_invoice_at
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

      context 'when account has manual customer invoice with end_date 2020-03-14 12:00:01' do
        before do
          FactoryBot.create(
              :invoice,
              :customer,
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

      context 'when account has manual vendor invoice with end_date 2020-03-14 12:00:01' do
        before do
          FactoryBot.create(
              :invoice,
              :vendor,
              :manual,
              account: account,
              start_date: account_time_zone.parse('2020-03-10 00:00:00').in_time_zone(server_time_zone),
              end_date: account_time_zone.parse('2020-03-14 12:00:01').in_time_zone(server_time_zone)
            )
        end

        it 'returns 2020-03-01 to 2020-04-01 AUTO_FULL' do
          is_expected.to match(
                             start_time: account_time_zone.parse('2020-03-01 00:00:00'),
                             end_time: account_time_zone.parse('2020-04-01 00:00:00'),
                             type_id: Billing::InvoiceType::AUTO_FULL
                           )
        end
      end
    end

    context 'when account does not have customer_invoice_period' do
      let(:account_attrs) do
        next_vendor_invoice_at = account_time_zone.parse('2020-01-01 00:00:00').in_time_zone(server_time_zone)
        super().merge vendor_invoice_period_id: Billing::InvoicePeriod::DAILY_ID,
                      next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_vendor_invoice_at: next_vendor_invoice_at
      end

      include_examples :raises_exception,
                       ApplicationService::Error,
                       'account customer invoice period is required'
    end
  end
end
