# frozen_string_literal: true

class Api::Rest::Customer::V1::ChartOriginatedCpResource < Api::Rest::Customer::V1::BaseResource
  model_name 'JsonapiModel::OriginatedCps'
  primary_key :id
  immutable false

  before_replace_fields do
    _model.customer = context[:auth_context].customer
  end

  attributes :from_time,
             :to_time,
             :cps

  has_one :account, class_name: 'Account'
end
