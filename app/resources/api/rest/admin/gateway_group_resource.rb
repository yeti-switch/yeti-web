class Api::Rest::Admin::GatewayGroupResource < JSONAPI::Resource
  attributes :name

  has_one :vendor, class_name: 'Contractor'

  def self.updatable_fields(context)
    [
      :name,
      :vendor
    ]
  end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end
end
