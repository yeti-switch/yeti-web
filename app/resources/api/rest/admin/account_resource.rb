class Api::Rest::Admin::AccountResource < ::BaseResource
  attributes :name, :min_balance, :max_balance, :external_id,
             :balance_low_threshold, :balance_high_threshold, :send_balance_notifications_to,
             :origination_capacity, :termination_capacity, :send_invoices_to

  has_one :contractor
  has_one :timezone, class_name: 'System::Timezone'

  has_one :customer_invoice_period, class_name: 'Billing::InvoicePeriod'
  has_one :vendor_invoice_period, class_name: 'Billing::InvoicePeriod'
  has_one :customer_invoice_template, class_name: 'Billing::InvoiceTemplate'
  has_one :vendor_invoice_template, class_name: 'Billing::InvoiceTemplate'

  filter :name

  def send_invoices_to=(value)
    _model.send_invoices_to = Array.wrap(value)
  end

  def send_balance_notifications_to=(value)
    _model.send_balance_notifications_to = Array.wrap(value)
  end

  def self.updatable_fields(_context)
    [
      :name,
      :min_balance,
      :max_balance,
      :balance_low_threshold,
      :balance_high_threshold,
      :send_balance_notifications_to,
      :vat,
      :origination_capacity,
      :termination_capacity,
      :send_invoices_to,

      :contractor,
      :timezone,
      :customer_invoice_period,
      :vendor_invoice_period,
      :customer_invoice_template,
      :vendor_invoice_template
    ]
  end

  def self.creatable_fields(context)
    self.updatable_fields(context) + [:external_id]
  end
end
