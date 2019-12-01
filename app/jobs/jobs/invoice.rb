# frozen_string_literal: true

module Jobs
  class Invoice < ::BaseJob
    def execute
      customers_accounts.each do |acc_id|
        capture_job_extra(id: acc_id, type: :customer) do
          ActiveRecord::Base.transaction do
            account = Account.find(acc_id)
            start_date = account.last_customer_invoice_date
            end_date = account.next_customer_invoice_at
            invoice_type = account.next_customer_invoice_type_id
            Worker::GenerateInvoiceJob.perform_later account_id: account.id,
                                                     start_date: serialize_time(start_date),
                                                     end_date: serialize_time(end_date),
                                                     invoice_type_id: invoice_type,
                                                     is_vendor: false
            account.schedule_next_customer_invoice!
          end
        end
      end

      vendors_accounts.each do |acc_id|
        capture_job_extra(id: acc_id, type: :vendor) do
          ActiveRecord::Base.transaction do
            account = Account.find(acc_id)
            start_date = account.last_vendor_invoice_date
            end_date = account.next_vendor_invoice_at
            invoice_type = account.next_vendor_invoice_type_id
            Worker::GenerateInvoiceJob.perform_later account_id: account.id,
                                                     start_date: serialize_time(start_date),
                                                     end_date: serialize_time(end_date),
                                                     invoice_type_id: invoice_type,
                                                     is_vendor: true
            account.schedule_next_vendor_invoice!
          end
        end
      end
    end

    def customers_accounts
      Account.where('customer_invoice_period_id is not null and next_customer_invoice_at < ?', Time.now.utc).pluck(:id)
    end

    def vendors_accounts
      Account.where('vendor_invoice_period_id is not null and next_vendor_invoice_at < ?', Time.now.utc).pluck(:id)
    end

    def serialize_time(time)
      time.utc.to_s
    end
  end
end
