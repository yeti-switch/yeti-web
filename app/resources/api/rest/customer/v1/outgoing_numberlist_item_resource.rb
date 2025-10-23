# frozen_string_literal: true

class Api::Rest::Customer::V1::OutgoingNumberlistItemResource < Api::Rest::Customer::V1::BaseResource
  model_name 'Routing::NumberlistItem'

  key_type :integer
  primary_key :id

  attributes :key, :action_id

  has_one :outgoing_numberlist, relation_name: :numberlist, foreign_key_on: :related

  ransack_filter :numberlist_id, type: :number
  ransack_filter :key, type: :string
  ransack_filter :action_id, type: :number

  def self.default_sort
    [{ field: 'key', direction: :asc }]
  end

  def self.apply_allowed_accounts(records, options)
    context = options[:context]
    scope = records.where_customer(context[:customer_id])
    scope = scope.where_account(context[:allowed_account_ids]) if context[:allowed_account_ids].present?
    scope = scope.where(numberlist_id: context[:allow_outgoing_numberlists_ids])
    scope
  end
end
