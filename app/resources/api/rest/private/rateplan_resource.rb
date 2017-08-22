class Api::Rest::Private::RateplanResource < JSONAPI::Resource
  attributes :name

  has_one :profit_control_mode, class_name: 'Routing::RateProfitControlMode'

  def self.updatable_fields(context)
    [
      :name,
      :profit_control_mode
    ]
  end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end
end
