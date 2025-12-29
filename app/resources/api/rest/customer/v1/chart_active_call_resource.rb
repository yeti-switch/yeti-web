# frozen_string_literal: true

class Api::Rest::Customer::V1::ChartActiveCallResource < Api::Rest::Customer::V1::BaseResource
  model_name 'JsonapiModel::ActiveCallAccount'
  primary_key :id
  immutable false

  before_replace_fields do
    _model.customer = context[:auth_context].customer
  end

  attributes :from_time,
             :to_time,
             :terminated_calls,
             :originated_calls

  has_one :account, class_name: 'Account'
end
