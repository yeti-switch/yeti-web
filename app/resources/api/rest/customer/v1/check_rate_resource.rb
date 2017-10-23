class Api::Rest::Customer::V1::CheckRateResource < BaseResource
  model_name 'JsonapiModel::CheckRate'

  key_type :uuid

  attributes :rateplan_id, :number, :rates

end
