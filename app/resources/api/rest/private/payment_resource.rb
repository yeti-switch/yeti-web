class Api::Rest::Private::PaymentResource < JSONAPI::Resource
  attributes :account_id, :amount, :notes

  def self.updatable_fields(context)
    [
      :account_id,
      :amount,
      :notes
    ]
  end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end
end
