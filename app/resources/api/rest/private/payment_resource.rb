class Api::Rest::Private::PaymentResource < JSONAPI::Resource
  attributes :amount, :notes

  has_one :account

  def self.updatable_fields(context)
    [
      :account,
      :amount,
      :notes
    ]
  end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end
end
