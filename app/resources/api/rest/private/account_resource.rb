class Api::Rest::Private::AccountResource < JSONAPI::Resource
  attributes :name, :min_balance, :max_balance, :contractor_id, :timezone_id,
             :origination_capacity, :termination_capacity, :customer_invoice_period_id, :vendor_invoice_period_id,
             :customer_invoice_template_id, :vendor_invoice_template_id, :send_invoices_to

  def self.updatable_fields(context)
    [
      :name,
      :contractor_id,
      :min_balance,
      :max_balance,
      :origination_capacity,
      :termination_capacity,
      :customer_invoice_period_id,
      :vendor_invoice_period_id,
      :customer_invoice_template_id,
      :vendor_invoice_template_id,
      :send_invoices_to,
      :timezone_id
    ]
  end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end
end
