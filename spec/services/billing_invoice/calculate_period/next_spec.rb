# frozen_string_literal: true

RSpec.describe BillingInvoice::CalculatePeriod::Next, '.call' do
  subject do
    described_class.call(service_params)
  end

  let(:service_params) { { account: account, is_vendor: true, period_end: account.next_vendor_invoice_at } }

  include_context :timezone_helpers
  let!(:contractor) { FactoryBot.create(:vendor) }
  let!(:account) { FactoryBot.create(:account, account_attrs) }
  let(:account_attrs) { { contractor: contractor, timezone: account_timezone } }
  let(:account_timezone) { utc_timezone }
  let(:account_time_zone) { ActiveSupport::TimeZone.new(account_timezone.name) }
  before do
    Billing::Invoice.where(account_id: account.id).delete_all
  end

  context 'with vendor account' do
    context 'when vendor_invoice_period is daily and next_vendor_invoice_at is Tue 2020-03-18 in account timezone' do
      let(:account_attrs) do
        next_customer_invoice_at = account_time_zone.parse('2020-03-18 00:00:00').in_time_zone(server_time_zone)
        super().merge vendor_invoice_period_id: Billing::InvoicePeriod::DAILY_ID,
                      next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_vendor_invoice_at: next_customer_invoice_at
      end

      it 'returns 2020-03-17 to 2020-03-18 AUTO_FULL' do
        is_expected.to match(
                           start_time: account_time_zone.parse('2020-03-17 00:00:00'),
                           next_end_time: account_time_zone.parse('2020-03-19 00:00:00'),
                           next_type_id: Billing::InvoiceType::AUTO_FULL
                         )
      end

      context 'when account timezone is LA' do
        let(:account_timezone) { la_timezone }

        it 'returns 2020-03-17 to 2020-03-18 AUTO_FULL' do
          is_expected.to match(
                             start_time: account_time_zone.parse('2020-03-17 00:00:00'),
                             next_end_time: account_time_zone.parse('2020-03-19 00:00:00'),
                             next_type_id: Billing::InvoiceType::AUTO_FULL
                           )
        end
      end
    end

    context 'when vendor_invoice_period is weekly and next_vendor_invoice_at is Mon 2020-03-23 in account timezone' do
      let(:account_attrs) do
        next_vendor_invoice_at = account_time_zone.parse('2020-03-23 00:00:00').in_time_zone(server_time_zone)
        super().merge vendor_invoice_period_id: Billing::InvoicePeriod::WEEKLY_ID,
                      next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_vendor_invoice_at: next_vendor_invoice_at
      end

      it 'returns 2020-03-16 to 2020-03-23 AUTO_FULL' do
        is_expected.to match(
                           start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                           next_end_time: account_time_zone.parse('2020-03-30 00:00:00'),
                           next_type_id: Billing::InvoiceType::AUTO_FULL
                         )
      end

      context 'when account timezone is LA' do
        let(:account_timezone) { la_timezone }

        it 'returns 2020-03-16 to 2020-03-23 AUTO_FULL' do
          is_expected.to match(
                             start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                             next_end_time: account_time_zone.parse('2020-03-30 00:00:00'),
                             next_type_id: Billing::InvoiceType::AUTO_FULL
                           )
        end
      end
    end

    context 'when vendor_invoice_period is weekly split' do
      let(:account_attrs) do
        super().merge vendor_invoice_period_id: Billing::InvoicePeriod::WEEKLY_SPLIT_ID,
                      next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL
      end

      context 'when next_vendor_invoice_at is Tue 2020-03-23 in account timezone' do
        let(:account_attrs) do
          next_vendor_invoice_at = account_time_zone.parse('2020-03-23 00:00:00').in_time_zone(server_time_zone)
          super().merge next_vendor_invoice_at: next_vendor_invoice_at
        end

        it 'returns 2020-03-16 to 2020-03-23 AUTO_FULL' do
          is_expected.to match(
                             start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                             next_end_time: account_time_zone.parse('2020-03-30 00:00:00'),
                             next_type_id: Billing::InvoiceType::AUTO_FULL
                           )
        end

        context 'when account timezone is LA' do
          let(:account_timezone) { la_timezone }

          it 'returns 2020-03-16 to 2020-03-23 AUTO_FULL' do
            is_expected.to match(
                               start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                               next_end_time: account_time_zone.parse('2020-03-30 00:00:00'),
                               next_type_id: Billing::InvoiceType::AUTO_FULL
                             )
          end
        end
      end

      # Tue 2020-03-31 - last day of month
      context 'when next_vendor_invoice_at is Wed 2020-04-01 in account timezone' do
        let(:account_attrs) do
          next_vendor_invoice_at = account_time_zone.parse('2020-04-01 00:00:00').in_time_zone(server_time_zone)
          super().merge next_vendor_invoice_at: next_vendor_invoice_at
        end

        it 'returns 2020-03-30 to 2020-04-01 AUTO_PARTIAL' do
          is_expected.to match(
                             start_time: account_time_zone.parse('2020-03-30 00:00:00'),
                             next_end_time: account_time_zone.parse('2020-04-06 00:00:00'),
                             next_type_id: Billing::InvoiceType::AUTO_PARTIAL
                           )
        end

        context 'when account timezone is LA' do
          let(:account_timezone) { la_timezone }

          it 'returns 2020-03-30 to 2020-04-01 AUTO_FULL' do
            is_expected.to match(
                               start_time: account_time_zone.parse('2020-03-30 00:00:00'),
                               next_end_time: account_time_zone.parse('2020-04-06 00:00:00'),
                               next_type_id: Billing::InvoiceType::AUTO_PARTIAL
                             )
          end
        end
      end
    end

    context 'when vendor_invoice_period is biweekly and next_vendor_invoice_at is Mon 2020-03-30 in account timezone' do
      let(:account_attrs) do
        next_vendor_invoice_at = account_time_zone.parse('2020-03-30 00:00:00').in_time_zone(server_time_zone)
        super().merge vendor_invoice_period_id: Billing::InvoicePeriod::BIWEEKLY_ID,
                      next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_vendor_invoice_at: next_vendor_invoice_at
      end

      it 'returns 2020-03-16 to 2020-04-13 AUTO_FULL' do
        is_expected.to match(
                           start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                           next_end_time: account_time_zone.parse('2020-04-13 00:00:00'),
                           next_type_id: Billing::InvoiceType::AUTO_FULL
                         )
      end

      context 'when account timezone is LA' do
        let(:account_timezone) { la_timezone }

        it 'returns 2020-03-16 to 2020-04-13 AUTO_FULL' do
          is_expected.to match(
                             start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                             next_end_time: account_time_zone.parse('2020-04-13 00:00:00'),
                             next_type_id: Billing::InvoiceType::AUTO_FULL
                           )
        end
      end
    end

    context 'when vendor_invoice_period is biweekly split' do
      let(:account_attrs) do
        super().merge vendor_invoice_period_id: Billing::InvoicePeriod::BIWEEKLY_SPLIT_ID,
                      next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL
      end

      context 'when next_vendor_invoice_at is Mon 2020-03-30 in account timezone' do
        let(:account_attrs) do
          next_vendor_invoice_at = account_time_zone.parse('2020-03-30 00:00:00').in_time_zone(server_time_zone)
          super().merge next_vendor_invoice_at: next_vendor_invoice_at
        end

        it 'returns 2020-03-16 to 2020-03-30 AUTO_FULL' do
          is_expected.to match(
                             start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                             next_end_time: account_time_zone.parse('2020-04-01 00:00:00'),
                             next_type_id: Billing::InvoiceType::AUTO_PARTIAL
                           )
        end

        context 'when account timezone is LA' do
          let(:account_timezone) { la_timezone }

          it 'returns 2020-03-16 to 2020-03-30 AUTO_FULL' do
            is_expected.to match(
                               start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                               next_end_time: account_time_zone.parse('2020-04-01 00:00:00'),
                               next_type_id: Billing::InvoiceType::AUTO_PARTIAL
                             )
          end
        end
      end

      # Tue 2020-03-31 - last day of month
      context 'when next_vendor_invoice_at is Wed 2020-04-01 in account timezone' do
        let(:account_attrs) do
          next_vendor_invoice_at = account_time_zone.parse('2020-04-01 00:00:00').in_time_zone(server_time_zone)
          super().merge next_vendor_invoice_at: next_vendor_invoice_at
        end

        it 'returns 2020-03-30 to 2020-04-01 AUTO_PARTIAL' do
          is_expected.to match(
                             start_time: account_time_zone.parse('2020-03-30 00:00:00'),
                             next_end_time: account_time_zone.parse('2020-04-13 00:00:00'),
                             next_type_id: Billing::InvoiceType::AUTO_PARTIAL
                           )
        end

        context 'when account timezone is LA' do
          let(:account_timezone) { la_timezone }

          it 'returns 2020-03-16 to 2020-03-17 AUTO_FULL' do
            is_expected.to match(
                               start_time: account_time_zone.parse('2020-03-30 00:00:00'),
                               next_end_time: account_time_zone.parse('2020-04-13 00:00:00'),
                               next_type_id: Billing::InvoiceType::AUTO_PARTIAL
                             )
          end
        end
      end
    end

    context 'when vendor_invoice_period is monthly and next_vendor_invoice_at is Tue 2020-04-01 in account timezone' do
      let(:account_attrs) do
        next_vendor_invoice_at = account_time_zone.parse('2020-04-01 00:00:00').in_time_zone(server_time_zone)
        super().merge vendor_invoice_period_id: Billing::InvoicePeriod::MONTHLY_ID,
                      next_vendor_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_vendor_invoice_at: next_vendor_invoice_at
      end

      it 'returns 2020-03-01 to 2020-04-01 AUTO_FULL' do
        is_expected.to match(
                           start_time: account_time_zone.parse('2020-03-01 00:00:00'),
                           next_end_time: account_time_zone.parse('2020-05-01 00:00:00'),
                           next_type_id: Billing::InvoiceType::AUTO_FULL
                         )
      end

      context 'when account timezone is LA' do
        let(:account_timezone) { la_timezone }

        it 'returns 2020-03-01 to 2020-04-01 AUTO_FULL' do
          is_expected.to match(
                             start_time: account_time_zone.parse('2020-03-01 00:00:00'),
                             next_end_time: account_time_zone.parse('2020-05-01 00:00:00'),
                             next_type_id: Billing::InvoiceType::AUTO_FULL
                           )
        end
      end
    end
  end

  context 'with customer account' do
    let(:contractor) { FactoryBot.create(:customer) }
    let(:service_params) { super().merge period_end: account.next_customer_invoice_at, is_vendor: false }

    context 'when customer_invoice_period is daily and next_customer_invoice_at is Tue 2020-03-18 in account timezone' do
      let(:account_attrs) do
        next_customer_invoice_at = account_time_zone.parse('2020-03-18 00:00:00').in_time_zone(server_time_zone)
        super().merge customer_invoice_period_id: Billing::InvoicePeriod::DAILY_ID,
                      next_customer_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_customer_invoice_at: next_customer_invoice_at
      end

      it 'returns 2020-03-17 to 2020-03-18 AUTO_FULL' do
        is_expected.to match(
                           start_time: account_time_zone.parse('2020-03-17 00:00:00'),
                           next_end_time: account_time_zone.parse('2020-03-19 00:00:00'),
                           next_type_id: Billing::InvoiceType::AUTO_FULL
                         )
      end

      context 'when account timezone is LA' do
        let(:account_timezone) { la_timezone }

        it 'returns 2020-03-17 to 2020-03-18 AUTO_FULL' do
          is_expected.to match(
                             start_time: account_time_zone.parse('2020-03-17 00:00:00'),
                             next_end_time: account_time_zone.parse('2020-03-19 00:00:00'),
                             next_type_id: Billing::InvoiceType::AUTO_FULL
                           )
        end
      end
    end

    context 'when customer_invoice_period is weekly and next_customer_invoice_at is Mon 2020-03-23 in account timezone' do
      let(:account_attrs) do
        next_customer_invoice_at = account_time_zone.parse('2020-03-23 00:00:00').in_time_zone(server_time_zone)
        super().merge customer_invoice_period_id: Billing::InvoicePeriod::WEEKLY_ID,
                      next_customer_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_customer_invoice_at: next_customer_invoice_at
      end

      it 'returns 2020-03-16 to 2020-03-23 AUTO_FULL' do
        is_expected.to match(
                           start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                           next_end_time: account_time_zone.parse('2020-03-30 00:00:00'),
                           next_type_id: Billing::InvoiceType::AUTO_FULL
                         )
      end

      context 'when account timezone is LA' do
        let(:account_timezone) { la_timezone }

        it 'returns 2020-03-16 to 2020-03-23 AUTO_FULL' do
          is_expected.to match(
                             start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                             next_end_time: account_time_zone.parse('2020-03-30 00:00:00'),
                             next_type_id: Billing::InvoiceType::AUTO_FULL
                           )
        end
      end
    end

    context 'when customer_invoice_period is weekly split' do
      let(:account_attrs) do
        super().merge customer_invoice_period_id: Billing::InvoicePeriod::WEEKLY_SPLIT_ID,
                      next_customer_invoice_type_id: Billing::InvoiceType::AUTO_FULL
      end

      context 'when next_customer_invoice_at is Tue 2020-03-23 in account timezone' do
        let(:account_attrs) do
          next_customer_invoice_at = account_time_zone.parse('2020-03-23 00:00:00').in_time_zone(server_time_zone)
          super().merge next_customer_invoice_at: next_customer_invoice_at
        end

        it 'returns 2020-03-16 to 2020-03-23 AUTO_FULL' do
          is_expected.to match(
                             start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                             next_end_time: account_time_zone.parse('2020-03-30 00:00:00'),
                             next_type_id: Billing::InvoiceType::AUTO_FULL
                           )
        end

        context 'when account timezone is LA' do
          let(:account_timezone) { la_timezone }

          it 'returns 2020-03-16 to 2020-03-23 AUTO_FULL' do
            is_expected.to match(
                               start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                               next_end_time: account_time_zone.parse('2020-03-30 00:00:00'),
                               next_type_id: Billing::InvoiceType::AUTO_FULL
                             )
          end
        end
      end

      # Tue 2020-03-31 - last day of month
      context 'when next_customer_invoice_at is Wed 2020-04-01 in account timezone' do
        let(:account_attrs) do
          next_customer_invoice_at = account_time_zone.parse('2020-04-01 00:00:00').in_time_zone(server_time_zone)
          super().merge next_customer_invoice_at: next_customer_invoice_at
        end

        it 'returns 2020-03-30 to 2020-04-01 AUTO_PARTIAL' do
          is_expected.to match(
                             start_time: account_time_zone.parse('2020-03-30 00:00:00'),
                             next_end_time: account_time_zone.parse('2020-04-06 00:00:00'),
                             next_type_id: Billing::InvoiceType::AUTO_PARTIAL
                           )
        end

        context 'when account timezone is LA' do
          let(:account_timezone) { la_timezone }

          it 'returns 2020-03-30 to 2020-04-01 AUTO_FULL' do
            is_expected.to match(
                               start_time: account_time_zone.parse('2020-03-30 00:00:00'),
                               next_end_time: account_time_zone.parse('2020-04-06 00:00:00'),
                               next_type_id: Billing::InvoiceType::AUTO_PARTIAL
                             )
          end
        end
      end
    end

    context 'when customer_invoice_period is biweekly and next_customer_invoice_at is Mon 2020-03-30 in account timezone' do
      let(:account_attrs) do
        next_customer_invoice_at = account_time_zone.parse('2020-03-30 00:00:00').in_time_zone(server_time_zone)
        super().merge customer_invoice_period_id: Billing::InvoicePeriod::BIWEEKLY_ID,
                      next_customer_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_customer_invoice_at: next_customer_invoice_at
      end

      it 'returns 2020-03-16 to 2020-03-30 AUTO_FULL' do
        is_expected.to match(
                           start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                           next_end_time: account_time_zone.parse('2020-04-13 00:00:00'),
                           next_type_id: Billing::InvoiceType::AUTO_FULL
                         )
      end

      context 'when account timezone is LA' do
        let(:account_timezone) { la_timezone }

        it 'returns 2020-03-16 to 2020-03-30 AUTO_FULL' do
          is_expected.to match(
                             start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                             next_end_time: account_time_zone.parse('2020-04-13 00:00:00'),
                             next_type_id: Billing::InvoiceType::AUTO_FULL
                           )
        end
      end
    end

    context 'when customer_invoice_period is biweekly split' do
      let(:account_attrs) do
        super().merge customer_invoice_period_id: Billing::InvoicePeriod::BIWEEKLY_SPLIT_ID,
                      next_customer_invoice_type_id: Billing::InvoiceType::AUTO_FULL
      end

      context 'when next_customer_invoice_at is Mon 2020-03-30 in account timezone' do
        let(:account_attrs) do
          next_customer_invoice_at = account_time_zone.parse('2020-03-30 00:00:00').in_time_zone(server_time_zone)
          super().merge next_customer_invoice_at: next_customer_invoice_at
        end

        it 'returns 2020-03-16 to 2020-03-30 AUTO_FULL' do
          is_expected.to match(
                             start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                             next_end_time: account_time_zone.parse('2020-04-01 00:00:00'),
                             next_type_id: Billing::InvoiceType::AUTO_PARTIAL
                           )
        end

        context 'when account timezone is LA' do
          let(:account_timezone) { la_timezone }

          it 'returns 2020-03-16 to 2020-03-30 AUTO_FULL' do
            is_expected.to match(
                               start_time: account_time_zone.parse('2020-03-16 00:00:00'),
                               next_end_time: account_time_zone.parse('2020-04-01 00:00:00'),
                               next_type_id: Billing::InvoiceType::AUTO_PARTIAL
                             )
          end
        end
      end

      # Tue 2020-03-31 - last day of month
      context 'when next_customer_invoice_at is Wed 2020-04-01 in account timezone' do
        let(:account_attrs) do
          next_customer_invoice_at = account_time_zone.parse('2020-04-01 00:00:00').in_time_zone(server_time_zone)
          super().merge next_customer_invoice_at: next_customer_invoice_at
        end

        it 'returns 2020-03-30 to 2020-04-01 AUTO_PARTIAL' do
          is_expected.to match(
                             start_time: account_time_zone.parse('2020-03-30 00:00:00'),
                             next_end_time: account_time_zone.parse('2020-04-13 00:00:00'),
                             next_type_id: Billing::InvoiceType::AUTO_PARTIAL
                           )
        end

        context 'when account timezone is LA' do
          let(:account_timezone) { la_timezone }

          it 'returns 2020-03-16 to 2020-03-17 AUTO_FULL' do
            is_expected.to match(
                               start_time: account_time_zone.parse('2020-03-30 00:00:00'),
                               next_end_time: account_time_zone.parse('2020-04-13 00:00:00'),
                               next_type_id: Billing::InvoiceType::AUTO_PARTIAL
                             )
          end
        end
      end
    end

    context 'when customer_invoice_period is monthly and next_customer_invoice_at is Tue 2020-04-01 in account timezone' do
      let(:account_attrs) do
        next_customer_invoice_at = account_time_zone.parse('2020-04-01 00:00:00').in_time_zone(server_time_zone)
        super().merge customer_invoice_period_id: Billing::InvoicePeriod::MONTHLY_ID,
                      next_customer_invoice_type_id: Billing::InvoiceType::AUTO_FULL,
                      next_customer_invoice_at: next_customer_invoice_at
      end

      it 'returns 2020-03-01 to 2020-04-01 AUTO_FULL' do
        is_expected.to match(
                           start_time: account_time_zone.parse('2020-03-01 00:00:00'),
                           next_end_time: account_time_zone.parse('2020-05-01 00:00:00'),
                           next_type_id: Billing::InvoiceType::AUTO_FULL
                         )
      end

      context 'when account timezone is LA' do
        let(:account_timezone) { la_timezone }

        it 'returns 2020-03-01 to 2020-04-01 AUTO_FULL' do
          is_expected.to match(
                             start_time: account_time_zone.parse('2020-03-01 00:00:00'),
                             next_end_time: account_time_zone.parse('2020-05-01 00:00:00'),
                             next_type_id: Billing::InvoiceType::AUTO_FULL
                           )
        end
      end
    end
  end
end
