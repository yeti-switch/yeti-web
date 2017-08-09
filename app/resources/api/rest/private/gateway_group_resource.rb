class Api::Rest::Private::GatewayGroupResource < JSONAPI::Resource
  attributes :name, :vendor_id

  def self.updatable_fields(context)
    [
      :name,
      :vendor_id
    ]
  end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end
end
