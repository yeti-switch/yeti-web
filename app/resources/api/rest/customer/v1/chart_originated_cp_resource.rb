# frozen_string_literal: true

class Api::Rest::Customer::V1::ChartOriginatedCpResource < Api::Rest::Customer::V1::BaseResource
  model_name 'JsonapiModel::OriginatedCps'
  key_type :uuid

  before_replace_fields do
    _model.customer = context[:current_customer].customer
  end

  attributes :from_time,
             :to_time,
             :cps

  has_one :account, class_name: 'Account'
end
