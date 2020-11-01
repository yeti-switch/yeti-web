# frozen_string_literal: true

class Api::Rest::Admin::Routing::DestinationNextRateResource < ::BaseResource
  model_name 'Routing::DestinationNextRate'
  attributes :next_rate, :initial_rate, :initial_interval, :next_interval, :connect_fee, :apply_time, :applied,
             :external_id

  has_one :destination, class_name: 'Destination'

  filter :external_id

  ransack_filter :initial_rate, type: :number
  ransack_filter :next_rate, type: :number
  ransack_filter :initial_interval, type: :number
  ransack_filter :next_interval, type: :number
  ransack_filter :connect_fee, type: :number
  ransack_filter :apply_time, type: :datetime
  ransack_filter :created_at, type: :datetime
  ransack_filter :updated_at, type: :datetime
  ransack_filter :applied, type: :boolean
  ransack_filter :external_id, type: :number

  # def self.updatable_fields(context)
  #   super
  # end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
