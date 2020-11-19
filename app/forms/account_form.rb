# frozen_string_literal: true

class AccountForm < ProxyForm
  def self.policy_class
    AccountPolicy
  end

  with_model_name 'Account'
  model_class 'Account'

  model_attributes :name,
                   :contractor_id,
                   :min_balance,
                   :max_balance,
                   :vat,
                   :balance_low_threshold,
                   :balance_high_threshold,
                   :destination_rate_limit,
                   :max_call_duration,
                   :origination_capacity,
                   :termination_capacity,
                   :total_capacity,
                   :vendor_invoice_period_id,
                   :customer_invoice_period_id,
                   :vendor_invoice_template_id,
                   :customer_invoice_template_id,
                   :send_invoices_to,
                   :send_balance_notifications_to,
                   :timezone_id,
                   :uuid

  before_save :apply_vendor_invoice_period
  before_save :apply_customer_invoice_period

  private

  def apply_customer_invoice_period
    return unless customer_invoice_period_id_changed?

    if customer_invoice_period_id

      invoice_params = BillingInvoice::CalculatePeriod::Current.call(account: model, is_vendor: false)
      model.next_customer_invoice_at = invoice_params[:end_time]
      model.next_customer_invoice_type_id = invoice_params[:type_id]
    else
      model.next_customer_invoice_at = nil
      model.next_customer_invoice_type_id = nil
    end
  end

  def apply_vendor_invoice_period
    return unless vendor_invoice_period_id_changed?

    if vendor_invoice_period_id
      invoice_params = BillingInvoice::CalculatePeriod::Current.call(account: model, is_vendor: true)
      model.next_vendor_invoice_at = invoice_params[:end_time]
      model.next_vendor_invoice_type_id = invoice_params[:type_id]
    else
      model.next_vendor_invoice_at = nil
      model.next_vendor_invoice_type_id = nil
    end
  end
end
