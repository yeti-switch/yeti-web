# frozen_string_literal: true

class Api::Rest::Admin::Routing::RateplanResource < BaseResource
  model_name 'Routing::Rateplan'

  attributes :name

  has_one :profit_control_mode, class_name: 'RateProfitControlMode'

  paginator :paged

  filter :name # DEPRECATED

  ransack_filter :name, type: :string

  def self.updatable_fields(_context)
    %i[
      name
      profit_control_mode
    ]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
