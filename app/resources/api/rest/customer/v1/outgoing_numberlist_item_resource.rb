# frozen_string_literal: true

class Api::Rest::Customer::V1::OutgoingNumberlistItemResource < Api::Rest::Customer::V1::BaseResource
  model_name 'Routing::NumberlistItem'

  key_type :integer
  primary_key :id

  attributes :key, :batch_key, :action_id

  has_one :outgoing_numberlist, relation_name: :outgoing_numberlist, foreign_key_on: :related, foreign_key: :numberlist_id

  ransack_filter :numberlist_id, type: :number
  ransack_filter :key, type: :string
  ransack_filter :action_id, type: :number

  def self.default_sort
    [{ field: 'key', direction: :asc }]
  end

  def fetchable_fields
    %i[outgoing_numberlist key action_id]
  end

  def self.creatable_fields(_context)
    %i[outgoing_numberlist key batch_key action_id]
  end

  def self.updatable_fields(_context)
    %i[key action_id]
  end

  before_save do
    ca_scope = CustomersAuth.where(customer_id: context[:customer_id])
    ca_scope = ca_scope.where(account_id: context[:allowed_account_ids]) if context[:allowed_account_ids].present?
    ca_scope = ca_scope.where(dst_numberlist_id: context[:allow_outgoing_numberlists_ids])
    allowed_numberlists = ca_scope.pluck(:dst_numberlist_id)

    unless allowed_numberlists.include?(@model.numberlist_id)
      # raise JSONAPI::Exceptions::RecordNotFound, nil
      _model.errors.add(:base, 'Invalid numberlist')
      raise JSONAPI::Exceptions::ValidationErrors, self
    end
  end

  def self.apply_allowed_accounts(records, options)
    context = options[:context]
    scope = records.where_customer(context[:customer_id])
    scope = scope.where_account(context[:allowed_account_ids]) if context[:allowed_account_ids].present?
    scope = scope.where(numberlist_id: context[:allow_outgoing_numberlists_ids])
    scope
  end
end
