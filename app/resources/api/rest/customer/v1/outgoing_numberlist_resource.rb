# frozen_string_literal: true

class Api::Rest::Customer::V1::OutgoingNumberlistResource < Api::Rest::Customer::V1::BaseResource
  model_name 'Routing::Numberlist'

  key_type :integer
  primary_key :id

  attributes :name, :default_action_id, :mode_id

  ransack_filter :name, type: :string
  ransack_filter :default_action_id, type: :number
  ransack_filter :mode_id, type: :number
  def self.default_sort
    [{ field: 'name', direction: :asc }]
  end

  def self.apply_allowed_accounts(records, options)
    context = options[:context]
    scope = records.where_customer(context[:customer_id])
    scope = scope.where_account(context[:allowed_account_ids]) if context[:allowed_account_ids].present?
    scope = scope.where(id: context[:allow_outgoing_numberlists_ids])
    scope
  end
end
