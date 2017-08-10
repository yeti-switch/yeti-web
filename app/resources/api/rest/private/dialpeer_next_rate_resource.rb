class Api::Rest::Private::DialpeerNextRateResource < JSONAPI::Resource
  attributes :next_rate, :initial_rate, :initial_interval, :next_interval, :connect_fee, :apply_time, :applied,
             :dialpeer_id, :external_id

  # def self.updatable_fields(context)
  #   super
  # end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end
end
