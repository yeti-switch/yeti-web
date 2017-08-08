class Api::Rest::Private::ContractorResource < JSONAPI::Resource
  attributes :name, :enabled, :vendor, :customer, :description, :address, :phones, :smtp_connection_id

  def self.updatable_fields(context)
    [
      :name,
      :enabled,
      :vendor,
      :customer,
      :description,
      :address,
      :phones,
      :smtp_connection_id
    ]
  end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end
end
