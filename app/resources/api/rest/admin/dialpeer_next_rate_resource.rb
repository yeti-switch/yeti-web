# frozen_string_literal: true

class Api::Rest::Admin::DialpeerNextRateResource < JSONAPI::Resource
  attributes :next_rate, :initial_rate, :initial_interval, :next_interval, :connect_fee, :apply_time, :applied,
             :external_id

  has_one :dialpeer

  filter :external_id

  # def self.updatable_fields(context)
  #   super
  # end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
