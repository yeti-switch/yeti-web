# frozen_string_literal: true

class Api::Rest::Customer::V1::ChartActiveCallResource < Api::Rest::Customer::V1::BaseResource
  model_name 'JsonapiModel::ActiveCallAccount'
  primary_key :id

  before_replace_fields do
    _model.customer = context[:current_customer].customer
  end

  attributes :from_time,
             :to_time,
             :terminated_calls,
             :originated_calls

  has_one :account, class_name: 'Account'
end
