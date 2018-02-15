class Api::Rest::Admin::ContractorResource < JSONAPI::Resource
  attributes :name, :enabled, :vendor, :customer, :description, :address, :phones, :external_id

  has_one :smtp_connection, class_name: 'System::SmtpConnection'

  filter :name

  def self.updatable_fields(_context)
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
    self.updatable_fields(context) + [:external_id]
  end
end
