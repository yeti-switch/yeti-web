class Api::Rest::Admin::AccountResource < ::BaseResource
  attributes :name, :min_balance, :max_balance,
             :origination_capacity, :termination_capacity, :send_invoices_to

  has_one :contractor
  has_one :timezone, class_name: 'System::Timezone'

  has_one :customer_invoice_period, class_name: 'Billing::InvoicePeriod'
  has_one :vendor_invoice_period, class_name: 'Billing::InvoicePeriod'
  has_one :customer_invoice_template, class_name: 'Billing::InvoiceTemplate'
  has_one :vendor_invoice_template, class_name: 'Billing::InvoiceTemplate'

  filter :name

  def self.updatable_fields(context)
    [
      :name,
      :min_balance,
      :max_balance,
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
    self.updatable_fields(context)
  end
end
