class Api::Rest::Private::ContractorResource < JSONAPI::Resource
  attributes :name, :enabled, :vendor, :customer, :description, :address, :phones

  has_one :smtp_connection, class_name: 'System::SmtpConnection'

  def self.updatable_fields(context)
    [
      :name,
      :enabled,
      :vendor,
      :customer,
      :description,
      :address,
      :phones,
      :smtp_connection
    ]
  end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end
end
