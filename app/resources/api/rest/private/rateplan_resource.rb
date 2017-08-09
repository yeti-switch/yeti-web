class Api::Rest::Private::RateplanResource < JSONAPI::Resource
  attributes :name, :profit_control_mode_id

  def self.updatable_fields(context)
    [
      :name,
      :profit_control_mode_id
    ]
  end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end
end
