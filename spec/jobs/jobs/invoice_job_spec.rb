# frozen_string_literal: true

RSpec.describe Jobs::Invoice do
  describe '#execute' do
    subject do
      travel_to(job_execution_time) do
        described_class.first!.execute
      end
    end

    let(:monthly_invoice_period) { Billing::InvoicePeriod.find(Billing::InvoicePeriod::MONTHLY_ID) }
    let!(:vendor) { FactoryGirl.create(:vendor) }
    let(:job_execution_time) { Time.parse('2019-05-01 05:30:06') }

    context 'account was created at 2019-04-03' do
      let(:account_creation_time) { Time.parse('2019-04-03 02:55:54') }

      let!(:account) do
        travel_to(account_creation_time) do
          FactoryGirl.create(:account, contractor: vendor, vendor_invoice_period: monthly_invoice_period)
        end
      end
      # before { expect(account).to have_attributes(next_vendor_invoice_at: Time.parse('2019-05-01 00:00:00')) }

      it 'enqueues Worker::GenerateInvoiceJob' do
        expect { subject }.to have_enqueued_job(Worker::GenerateInvoiceJob).with(
          account_id: account.id,
          start_date: '2019-04-01 00:00:00 UTC',
          end_date: '2019-05-01 00:00:00 UTC',
          invoice_type_id: Billing::InvoiceType::AUTO_FULL,
          is_vendor: true
        ).once
      end

      it 'moves account.next_customer_invoice_at to correct datetime' do
        subject
        expect(account.reload).to have_attributes(
          next_vendor_invoice_at: Time.parse('2019-06-01 00:00:00 UTC')
        )
      end
    end
  end
end
