class Api::Rest::Admin::DialpeerNextRateResource < JSONAPI::Resource
  attributes :next_rate, :initial_rate, :initial_interval, :next_interval, :connect_fee, :apply_time, :applied,
             :external_id

  has_one :dialpeer

  # def self.updatable_fields(context)
  #   super
  # end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end
end
