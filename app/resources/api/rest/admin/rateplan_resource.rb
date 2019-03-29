# frozen_string_literal: true

class Api::Rest::Admin::RateplanResource < BaseResource
  attributes :name

  has_one :profit_control_mode, class_name: 'Routing::RateProfitControlMode'

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
