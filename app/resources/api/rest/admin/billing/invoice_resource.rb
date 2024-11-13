# frozen_string_literal: true

class Api::Rest::Admin::Billing::InvoiceResource < ::BaseResource
  model_name 'Billing::Invoice'
  create_form 'ManualInvoiceForm'
  paginator :paged

  attribute :reference
  attribute :state
  attribute :invoice_type
  attribute :start_date
  attribute :end_date
  attribute :pdf_path
  attribute :odt_path
  attribute :amount_spent
  attribute :amount_earned

  attribute :originated_amount_spent
  attribute :originated_amount_earned
  attribute :originated_calls_count
  attribute :originated_successful_calls_count
  attribute :originated_calls_duration
  attribute :originated_billing_duration
  attribute :originated_first_call_at, delegate: :first_originated_call_at
  attribute :originated_last_call_at, delegate: :last_originated_call_at

  attribute :terminated_amount_spent
  attribute :terminated_amount_earned
  attribute :terminated_calls_count
  attribute :terminated_successful_calls_count
  attribute :terminated_calls_duration
  attribute :terminated_billing_duration
  attribute :terminated_first_call_at, delegate: :first_terminated_call_at
  attribute :terminated_last_call_at, delegate: :last_terminated_call_at

  attribute :services_amount_spent
  attribute :services_amount_earned
  attribute :service_transactions_count

  has_one :account, class_name: 'Account', always_include_linkage_data: true
  has_many :originated_destinations, class_name: 'InvoiceOriginatedDestination'
  has_many :originated_networks, class_name: 'InvoiceOriginatedNetwork'
  has_many :terminated_destinations, class_name: 'InvoiceTerminatedDestination'
  has_many :terminated_networks, class_name: 'InvoiceTerminatedNetwork'
  has_many :service_data, class_name: 'InvoiceServiceDatum'

  relationship_filter :account

  ransack_filter :reference, type: :string
  ransack_filter :start_date, type: :datetime
  ransack_filter :end_date, type: :datetime
  ransack_filter :amount_spent, type: :number
  ransack_filter :amount_earned, type: :number
  ransack_filter :state,
                 type: :enum,
                 column: :state_id,
                 collection: Billing::InvoiceState.pluck(:name),
                 verify: ->(values) { Billing::InvoiceState.filter_by(name: values).map(&:id) }
  ransack_filter :invoice_type,
                 type: :enum,
                 column: :type_id,
                 collection: Billing::InvoiceType.pluck(:name),
                 verify: ->(values) { Billing::InvoiceType.filter_by(name: values).map(&:id) }

  ransack_filter :originated_amount_spent, type: :number
  ransack_filter :originated_amount_earned, type: :number
  ransack_filter :originated_calls_count, type: :number
  ransack_filter :originated_successful_calls_count, type: :number
  ransack_filter :originated_calls_duration, type: :number
  ransack_filter :originated_billing_duration, type: :number
  ransack_filter :originated_first_call_at, type: :datetime, column: :first_originated_call_at
  ransack_filter :originated_last_call_at, type: :datetime, column: :last_originated_call_at

  ransack_filter :terminated_amount_spent, type: :number
  ransack_filter :terminated_amount_earned, type: :number
  ransack_filter :terminated_calls_count, type: :number
  ransack_filter :terminated_successful_calls_count, type: :number
  ransack_filter :terminated_calls_duration, type: :number
  ransack_filter :terminated_billing_duration, type: :number
  ransack_filter :terminated_first_call_at, type: :datetime, column: :first_terminated_call_at
  ransack_filter :terminated_last_call_at, type: :datetime, column: :last_terminated_call_at

  ransack_filter :services_amount_spent, type: :number
  ransack_filter :services_amount_earned, type: :number
  ransack_filter :service_transactions_count, type: :number

  ransack_filter :account_id, type: :foreign_key

  def state
    _model.state.name
  end

  def invoice_type
    _model.type.name
  end

  def pdf_path
    return nil if _model.invoice_document&.pdf_data.blank?

    "/api/rest/admin/files/invoice-#{_model.id}.pdf"
  end

  def odt_path
    return nil if _model.invoice_document&.data.blank?

    "/api/rest/admin/files/invoice-#{_model.id}.odt"
  end

  def self.sortable_fields(_ctx = nil)
    super - %i[state invoice_type pdf_path odt_path]
  end

  def self.creatable_fields(_ctx = nil)
    %i[start_date end_date account]
  end

  def self.required_model_includes(_ctx = nil)
    [:invoice_document]
  end

  private

  def wrap_create_form
    @model = create_form_class_name.constantize.new
  end
end
