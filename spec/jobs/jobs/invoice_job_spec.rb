# frozen_string_literal: true

RSpec.describe Jobs::Invoice do
  describe '#execute' do
    subject do
      travel_to(job_execution_time) do
        described_class.first!.execute
      end
    end

    shared_examples :enqueues_invoice_generation do |options|
      options.assert_valid_keys(:is_vendor, :start_time, :end_time, :next_invoice_at, :invoice_type)
      is_vendor = options.fetch(:is_vendor)
      start_time = options.fetch(:start_time)
      end_time = options.fetch(:end_time)
      next_invoice_at = options.fetch(:next_invoice_at)
      invoice_type = options.fetch(:invoice_type) { Billing::InvoiceType::AUTO_FULL }

      next_invoice_at_col = :"next_#{is_vendor ? :vendor : :customer}_invoice_at"
      invoice_type_name = Billing::InvoiceType::NAMES[invoice_type]
      description_args = [
        "start_date '#{start_time}'",
        "end_date '#{end_time}'",
        "invoice_type '#{invoice_type_name}'"
      ]

      it "enqueues Worker::GenerateInvoiceJob with #{description_args.join(', ')}" do
        expect { subject }.to have_enqueued_job(Worker::GenerateInvoiceJob).with(
          account_id: account.id,
          start_date: start_time.utc.to_s,
          end_date: end_time.utc.to_s,
          invoice_type_id: invoice_type,
          is_vendor: is_vendor
        ).once
      end

      it "changes account #{next_invoice_at_col} from '#{end_time}' to '#{next_invoice_at}'" do
        expect { subject }.to change {
          account.reload[next_invoice_at_col].change(usec: 0)
        }.from(end_time).to(next_invoice_at)
      end
    end

    context 'vendor invoice' do
      let!(:vendor) { FactoryBot.create(:vendor) }
      let!(:account) do
        travel_to(account_creation_time) do
          FactoryBot.create(:account, contractor: vendor, vendor_invoice_period: invoice_period)
        end
      end

      context 'with invoice period monthly' do
        let(:invoice_period) { Billing::InvoicePeriod.find(Billing::InvoicePeriod::MONTHLY_ID) }

        context 'account was created at 2019-04-03 and now is 2019-05-01' do
          let(:account_creation_time) { Time.parse('2019-04-03 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-05-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-04-01 00:00:00'),
                           end_time: Time.parse('2019-05-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-06-01 00:00:00')
        end

        context 'account was created at 2019-04-28 and now is 2019-05-01' do
          let(:account_creation_time) { Time.parse('2019-04-28 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-05-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-04-01 00:00:00'),
                           end_time: Time.parse('2019-05-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-06-01 00:00:00')
        end
      end

      context 'with invoice period weekly simple' do
        let(:invoice_period) { Billing::InvoicePeriod.find(Billing::InvoicePeriod::WEEKLY_ID) }

        context 'when account was created at 2019-04-03 and now is 2019-04-08' do
          let(:account_creation_time) { Time.parse('2019-04-03 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-08 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-04-01 00:00:00'),
                           end_time: Time.parse('2019-04-08 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-15 00:00:00')
        end

        context 'when account was created at 2019-04-09 and now is 2019-04-15' do
          let(:account_creation_time) { Time.parse('2019-04-09 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-15 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-04-08 00:00:00'),
                           end_time: Time.parse('2019-04-15 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-22 00:00:00')
        end

        context 'when account was created at 2019-04-29 and now is 2019-05-06' do
          let(:account_creation_time) { Time.parse('2019-04-29 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-05-06 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-04-29 00:00:00'),
                           end_time: Time.parse('2019-05-06 00:00:00'),
                           next_invoice_at: Time.parse('2019-05-13 00:00:00')
        end
      end

      context 'with invoice period daily' do
        let(:invoice_period) { Billing::InvoicePeriod.find(Billing::InvoicePeriod::DAILY_ID) }

        context 'when account was created at 2019-04-09 and now is 2019-04-10' do
          let(:account_creation_time) { Time.parse('2019-04-09 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-10 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-04-09 00:00:00'),
                           end_time: Time.parse('2019-04-10 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-11 00:00:00')
        end

        context 'when account was created at 2019-04-30 and now is 2019-05-01' do
          let(:account_creation_time) { Time.parse('2019-04-30 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-05-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-04-30 00:00:00'),
                           end_time: Time.parse('2019-05-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-05-02 00:00:00')
        end
      end

      context 'with invoice period biweekly simple' do
        let(:invoice_period) { Billing::InvoicePeriod.find(Billing::InvoicePeriod::BIWEEKLY_ID) }

        context 'when account was created at 2019-04-02 and now is 2019-04-15' do
          let(:account_creation_time) { Time.parse('2019-04-02 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-15 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-04-01 00:00:00'),
                           end_time: Time.parse('2019-04-15 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-29 00:00:00')
        end

        context 'when account was created at 2019-04-17 and now is 2019-04-29' do
          let(:account_creation_time) { Time.parse('2019-04-17 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-29 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-04-15 00:00:00'),
                           end_time: Time.parse('2019-04-29 00:00:00'),
                           next_invoice_at: Time.parse('2019-05-13 00:00:00')
        end
      end

      context 'with invoice period weekly split' do
        let(:invoice_period) { Billing::InvoicePeriod.find(Billing::InvoicePeriod::WEEKLY_SPLIT_ID) }

        context 'when account was created at 2019-04-09 and now is 2019-04-15' do
          let(:account_creation_time) { Time.parse('2019-04-09 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-15 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-04-08 00:00:00'),
                           end_time: Time.parse('2019-04-15 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-22 00:00:00')
        end

        context 'when account was created at 2019-04-25 and now is 2019-04-29' do
          let(:account_creation_time) { Time.parse('2019-04-25 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-29 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-04-22 00:00:00'),
                           end_time: Time.parse('2019-04-29 00:00:00'),
                           next_invoice_at: Time.parse('2019-05-01 00:00:00')
        end

        context 'when account was created at 2019-04-30 and now is 2019-05-01' do
          let(:account_creation_time) { Time.parse('2019-04-30 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-05-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-04-29 00:00:00'),
                           end_time: Time.parse('2019-05-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-05-06 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_PARTIAL
        end

        context 'when account was created at 2018-12-31 and now is 2019-01-01' do
          let(:account_creation_time) { Time.parse('2018-12-31 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-01-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2018-12-31 00:00:00'),
                           end_time: Time.parse('2019-01-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-01-07 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_PARTIAL
        end

        context 'when account was created at 2019-08-28 and now is 2019-09-01' do
          let(:account_creation_time) { Time.parse('2019-08-28 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-09-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-08-26 00:00:00'),
                           end_time: Time.parse('2019-09-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-09-02 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_PARTIAL
        end

        context 'when account was created at 2019-09-01 and now is 2019-09-02' do
          let(:account_creation_time) { Time.parse('2019-09-01 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-09-02 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-09-01 00:00:00'),
                           end_time: Time.parse('2019-09-02 00:00:00'),
                           next_invoice_at: Time.parse('2019-09-09 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_FULL
        end

        context 'when account was created at 2019-03-29 and now is 2019-04-01' do
          let(:account_creation_time) { Time.parse('2019-03-29 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-03-25 00:00:00'),
                           end_time: Time.parse('2019-04-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-08 00:00:00')
        end
      end

      context 'with invoice period biweekly split' do
        let(:invoice_period) { Billing::InvoicePeriod.find(Billing::InvoicePeriod::BIWEEKLY_SPLIT_ID) }

        context 'when account was created at 2019-04-02 (even) and now is 2019-04-15' do
          let(:account_creation_time) { Time.parse('2019-04-01 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-15 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-04-01 00:00:00'),
                           end_time: Time.parse('2019-04-15 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-29 00:00:00')
        end

        context 'when account was created at 2019-04-08 (odd) and now is 2019-04-15' do
          let(:account_creation_time) { Time.parse('2019-04-08 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-15 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-04-01 00:00:00'),
                           end_time: Time.parse('2019-04-15 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-29 00:00:00')
        end

        context 'when account was created at 2019-04-15 (even) and now is 2019-04-29' do
          let(:account_creation_time) { Time.parse('2019-04-15 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-29 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-04-15 00:00:00'),
                           end_time: Time.parse('2019-04-29 00:00:00'),
                           next_invoice_at: Time.parse('2019-05-01 00:00:00')
        end

        context 'when account was created at 2019-04-29 (even) and now is 2019-05-01' do
          let(:account_creation_time) { Time.parse('2019-04-29 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-05-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-04-29 00:00:00'),
                           end_time: Time.parse('2019-05-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-05-13 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_PARTIAL
        end

        context 'when account was created at 2019-04-30 (even) and now is 2019-05-01' do
          let(:account_creation_time) { Time.parse('2019-04-30 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-05-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-04-29 00:00:00'),
                           end_time: Time.parse('2019-05-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-05-13 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_PARTIAL
        end

        context 'when account was created at 2018-12-31 (odd) and now is 2019-01-01' do
          let(:account_creation_time) { Time.parse('2018-12-31 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-01-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2018-12-24 00:00:00'),
                           end_time: Time.parse('2019-01-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-01-07 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_PARTIAL
        end

        context 'when account was created at 2019-08-28 (odd) and now is 2019-09-01' do
          let(:account_creation_time) { Time.parse('2019-08-28 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-09-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-08-19 00:00:00'),
                           end_time: Time.parse('2019-09-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-09-02 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_PARTIAL
        end

        context 'when account was created at 2019-08-20 (even) and now is 2019-09-01' do
          let(:account_creation_time) { Time.parse('2019-08-20 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-09-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-08-19 00:00:00'),
                           end_time: Time.parse('2019-09-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-09-02 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_PARTIAL
        end

        context 'when account was created at 2019-09-01 (odd) and now is 2019-09-02' do
          let(:account_creation_time) { Time.parse('2019-09-01 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-09-02 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-09-01 00:00:00'),
                           end_time: Time.parse('2019-09-02 00:00:00'),
                           next_invoice_at: Time.parse('2019-09-16 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_FULL
        end

        context 'when account was created at 2019-03-29 (odd) and now is 2019-04-01' do
          let(:account_creation_time) { Time.parse('2019-03-29 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-03-18 00:00:00'),
                           end_time: Time.parse('2019-04-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-15 00:00:00')
        end

        context 'when account was created at 2019-03-21 (even) and now is 2019-04-01' do
          let(:account_creation_time) { Time.parse('2019-03-21 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: true,
                           start_time: Time.parse('2019-03-18 00:00:00'),
                           end_time: Time.parse('2019-04-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-15 00:00:00')
        end
      end
    end

    context 'customer invoice' do
      let!(:customer) { FactoryBot.create(:customer) }
      let!(:account) do
        travel_to(account_creation_time) do
          FactoryBot.create(:account, contractor: customer, customer_invoice_period: invoice_period)
        end
      end

      context 'with invoice period monthly' do
        let(:invoice_period) { Billing::InvoicePeriod.find(Billing::InvoicePeriod::MONTHLY_ID) }

        context 'account was created at 2019-04-03 and now is 2019-05-01' do
          let(:account_creation_time) { Time.parse('2019-04-03 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-05-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-04-01 00:00:00'),
                           end_time: Time.parse('2019-05-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-06-01 00:00:00')
        end

        context 'account was created at 2019-04-28 and now is 2019-05-01' do
          let(:account_creation_time) { Time.parse('2019-04-28 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-05-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-04-01 00:00:00'),
                           end_time: Time.parse('2019-05-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-06-01 00:00:00')
        end
      end

      context 'with invoice period weekly simple' do
        let(:invoice_period) { Billing::InvoicePeriod.find(Billing::InvoicePeriod::WEEKLY_ID) }

        context 'when account was created at 2019-04-03 and now is 2019-04-08' do
          let(:account_creation_time) { Time.parse('2019-04-03 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-08 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-04-01 00:00:00'),
                           end_time: Time.parse('2019-04-08 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-15 00:00:00')
        end

        context 'when account was created at 2019-04-09 and now is 2019-04-15' do
          let(:account_creation_time) { Time.parse('2019-04-09 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-15 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-04-08 00:00:00'),
                           end_time: Time.parse('2019-04-15 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-22 00:00:00')
        end

        context 'when account was created at 2019-04-29 and now is 2019-05-06' do
          let(:account_creation_time) { Time.parse('2019-04-29 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-05-06 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-04-29 00:00:00'),
                           end_time: Time.parse('2019-05-06 00:00:00'),
                           next_invoice_at: Time.parse('2019-05-13 00:00:00')
        end
      end

      context 'with invoice period daily' do
        let(:invoice_period) { Billing::InvoicePeriod.find(Billing::InvoicePeriod::DAILY_ID) }

        context 'when account was created at 2019-04-09 and now is 2019-04-10' do
          let(:account_creation_time) { Time.parse('2019-04-09 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-10 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-04-09 00:00:00'),
                           end_time: Time.parse('2019-04-10 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-11 00:00:00')
        end

        context 'when account was created at 2019-04-30 and now is 2019-05-01' do
          let(:account_creation_time) { Time.parse('2019-04-30 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-05-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-04-30 00:00:00'),
                           end_time: Time.parse('2019-05-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-05-02 00:00:00')
        end
      end

      context 'with invoice period biweekly simple' do
        let(:invoice_period) { Billing::InvoicePeriod.find(Billing::InvoicePeriod::BIWEEKLY_ID) }

        context 'when account was created at 2019-04-02 and now is 2019-04-15' do
          let(:account_creation_time) { Time.parse('2019-04-02 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-15 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-04-01 00:00:00'),
                           end_time: Time.parse('2019-04-15 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-29 00:00:00')
        end

        context 'when account was created at 2019-04-17 and now is 2019-04-29' do
          let(:account_creation_time) { Time.parse('2019-04-17 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-29 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-04-15 00:00:00'),
                           end_time: Time.parse('2019-04-29 00:00:00'),
                           next_invoice_at: Time.parse('2019-05-13 00:00:00')
        end
      end

      context 'with invoice period weekly split' do
        let(:invoice_period) { Billing::InvoicePeriod.find(Billing::InvoicePeriod::WEEKLY_SPLIT_ID) }

        context 'when account was created at 2019-04-09 and now is 2019-04-15' do
          let(:account_creation_time) { Time.parse('2019-04-09 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-15 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-04-08 00:00:00'),
                           end_time: Time.parse('2019-04-15 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-22 00:00:00')
        end

        context 'when account was created at 2019-04-25 and now is 2019-04-29' do
          let(:account_creation_time) { Time.parse('2019-04-25 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-29 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-04-22 00:00:00'),
                           end_time: Time.parse('2019-04-29 00:00:00'),
                           next_invoice_at: Time.parse('2019-05-01 00:00:00')
        end

        context 'when account was created at 2019-04-30 and now is 2019-05-01' do
          let(:account_creation_time) { Time.parse('2019-04-30 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-05-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-04-29 00:00:00'),
                           end_time: Time.parse('2019-05-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-05-06 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_PARTIAL
        end

        context 'when account was created at 2018-12-31 and now is 2019-01-01' do
          let(:account_creation_time) { Time.parse('2018-12-31 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-01-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2018-12-31 00:00:00'),
                           end_time: Time.parse('2019-01-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-01-07 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_PARTIAL
        end

        context 'when account was created at 2019-08-28 and now is 2019-09-01' do
          let(:account_creation_time) { Time.parse('2019-08-28 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-09-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-08-26 00:00:00'),
                           end_time: Time.parse('2019-09-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-09-02 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_PARTIAL
        end

        context 'when account was created at 2019-09-01 and now is 2019-09-02' do
          let(:account_creation_time) { Time.parse('2019-09-01 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-09-02 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-09-01 00:00:00'),
                           end_time: Time.parse('2019-09-02 00:00:00'),
                           next_invoice_at: Time.parse('2019-09-09 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_FULL
        end

        context 'when account was created at 2019-03-29 and now is 2019-04-01' do
          let(:account_creation_time) { Time.parse('2019-03-29 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-03-25 00:00:00'),
                           end_time: Time.parse('2019-04-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-08 00:00:00')
        end
      end

      context 'with invoice period biweekly split' do
        let(:invoice_period) { Billing::InvoicePeriod.find(Billing::InvoicePeriod::BIWEEKLY_SPLIT_ID) }

        context 'when account was created at 2019-04-02 (even) and now is 2019-04-15' do
          let(:account_creation_time) { Time.parse('2019-04-01 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-15 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-04-01 00:00:00'),
                           end_time: Time.parse('2019-04-15 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-29 00:00:00')
        end

        context 'when account was created at 2019-04-08 (odd) and now is 2019-04-15' do
          let(:account_creation_time) { Time.parse('2019-04-08 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-15 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-04-01 00:00:00'),
                           end_time: Time.parse('2019-04-15 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-29 00:00:00')
        end

        context 'when account was created at 2019-04-15 (even) and now is 2019-04-29' do
          let(:account_creation_time) { Time.parse('2019-04-15 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-29 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-04-15 00:00:00'),
                           end_time: Time.parse('2019-04-29 00:00:00'),
                           next_invoice_at: Time.parse('2019-05-01 00:00:00')
        end

        context 'when account was created at 2019-04-29 (even) and now is 2019-05-01' do
          let(:account_creation_time) { Time.parse('2019-04-29 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-05-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-04-29 00:00:00'),
                           end_time: Time.parse('2019-05-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-05-13 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_PARTIAL
        end

        context 'when account was created at 2019-04-30 (even) and now is 2019-05-01' do
          let(:account_creation_time) { Time.parse('2019-04-30 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-05-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-04-29 00:00:00'),
                           end_time: Time.parse('2019-05-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-05-13 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_PARTIAL
        end

        context 'when account was created at 2018-12-31 (odd) and now is 2019-01-01' do
          let(:account_creation_time) { Time.parse('2018-12-31 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-01-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2018-12-24 00:00:00'),
                           end_time: Time.parse('2019-01-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-01-07 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_PARTIAL
        end

        context 'when account was created at 2019-08-28 (odd) and now is 2019-09-01' do
          let(:account_creation_time) { Time.parse('2019-08-28 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-09-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-08-19 00:00:00'),
                           end_time: Time.parse('2019-09-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-09-02 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_PARTIAL
        end

        context 'when account was created at 2019-08-20 (even) and now is 2019-09-01' do
          let(:account_creation_time) { Time.parse('2019-08-20 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-09-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-08-19 00:00:00'),
                           end_time: Time.parse('2019-09-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-09-02 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_PARTIAL
        end

        context 'when account was created at 2019-09-01 (odd) and now is 2019-09-02' do
          let(:account_creation_time) { Time.parse('2019-09-01 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-09-02 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-09-01 00:00:00'),
                           end_time: Time.parse('2019-09-02 00:00:00'),
                           next_invoice_at: Time.parse('2019-09-16 00:00:00'),
                           invoice_type: Billing::InvoiceType::AUTO_FULL
        end

        context 'when account was created at 2019-03-29 (odd) and now is 2019-04-01' do
          let(:account_creation_time) { Time.parse('2019-03-29 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-03-18 00:00:00'),
                           end_time: Time.parse('2019-04-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-15 00:00:00')
        end

        context 'when account was created at 2019-03-21 (even) and now is 2019-04-01' do
          let(:account_creation_time) { Time.parse('2019-03-21 02:55:54') }
          let(:job_execution_time) { Time.parse('2019-04-01 05:30:06') }

          include_examples :enqueues_invoice_generation,
                           is_vendor: false,
                           start_time: Time.parse('2019-03-18 00:00:00'),
                           end_time: Time.parse('2019-04-01 00:00:00'),
                           next_invoice_at: Time.parse('2019-04-15 00:00:00')
        end
      end
    end
  end
end
