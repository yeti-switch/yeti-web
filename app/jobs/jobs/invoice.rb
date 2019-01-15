# frozen_string_literal: true

module Jobs
  class Invoice < ::BaseJob
    def execute
      customers_accounts.each do |acc_id|
        ActiveRecord::Base.transaction do
          account = Account.find(acc_id)
          start_date = account.last_customer_invoice_date
          end_date = account.next_customer_invoice_at
          invoice_type = account.next_customer_invoice_type_id
          generate_invoice(account.id, start_date, end_date, invoice_type, false)
          account.schedule_next_customer_invoice!
        end
      end

      vendors_accounts.each do |acc_id|
        ActiveRecord::Base.transaction do
          account = Account.find(acc_id)
          start_date = account.last_vendor_invoice_date
          end_date = account.next_vendor_invoice_at
          invoice_type = account.next_vendor_invoice_type_id
          generate_invoice(account.id, start_date, end_date, invoice_type, true)
          account.schedule_next_vendor_invoice!
        end
      end
    end

    def customers_accounts
      Account.where('customer_invoice_period_id is not null and next_customer_invoice_at < NOW()').pluck(:id)
    end

    def vendors_accounts
      Account.where('vendor_invoice_period_id is not null and next_vendor_invoice_at < NOW()').pluck(:id)
    end

    def generate_invoice(acc_id, start_dt, end_dt, invoice_type, is_vendor)
      account = begin
                  Account.find(acc_id)
                rescue StandardError
                  nil
                end
      if account

        inv = Billing::Invoice.new(
          contractor_id: account.contractor_id,
          account_id: account.id,
          start_date: start_dt,
          vendor_invoice: is_vendor,
          end_date: end_dt,
          type_id: invoice_type
        )
        account.transaction do
          InvoiceGenerator.new(inv).save!
        end
      else
        # log
      end
    end

    handle_asynchronously :generate_invoice
  end
end
