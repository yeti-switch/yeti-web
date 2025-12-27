# frozen_string_literal: true

class Api::Rest::Customer::V1::CheckRateResource < Api::Rest::Customer::V1::BaseResource
  singleton
  model_name 'JsonapiModel::CheckRate'
  primary_key :id
  immutable false

  attributes :rateplan_id, :number, :rates
end
