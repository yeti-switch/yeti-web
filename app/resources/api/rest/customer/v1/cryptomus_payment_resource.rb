# frozen_string_literal: true

class Api::Rest::Customer::V1::CryptomusPaymentResource < Api::Rest::Customer::V1::BaseResource
  model_name 'CustomerApi::CryptomusPayment'
  immutable false

  attributes :amount,
             :notes,
             :url

  has_one :account, foreign_key_on: :related

  before_create { _model.customer_id = context[:customer_id] }
  before_create { _model.allowed_account_ids = context[:allowed_account_ids] }

  def fetchable_fields
    %i[url]
  end

  def self.creatable_fields(_ctx = nil)
    %i[amount notes account]
  end

  def self.create_model
    CustomerApi::CryptomusPaymentForm.new
  end

  def self.find_by_key(key, options = {})
    context = options[:context]
    payment = apply_includes(records(options)).find_by(uuid: key)
    raise JSONAPI::Exceptions::RecordNotFound, key if payment.nil?

    model = CustomerApi::CryptomusPayment.new(payment:)
    new(model, context)
  end

  def self.records(options = {})
    records = Payment.type_cryptomus
    apply_allowed_accounts(records, options)
  end

  def self.apply_allowed_accounts(records, options)
    context = options[:context]
    records = records.ransack(account_contractor_id_eq: context[:customer_id]).result
    records = records.where(account_id: context[:allowed_account_ids]) if context[:allowed_account_ids].present?
    records
  end
end
