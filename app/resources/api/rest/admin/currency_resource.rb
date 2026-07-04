# frozen_string_literal: true

class Api::Rest::Admin::CurrencyResource < ::BaseResource
  model_name 'Billing::Currency'
  paginator :paged

  attribute :name
  attribute :rate
  attribute :rate_provider_id

  ransack_filter :name, type: :string
  ransack_filter :rate, type: :number
  ransack_filter :rate_provider_id, type: :number

  def self.sortable_fields(_ctx = nil)
    %i[id name rate rate_provider_id]
  end

  def self.creatable_fields(_ctx = nil)
    %i[name rate rate_provider_id]
  end

  def self.updatable_fields(_ctx = nil)
    %i[name rate rate_provider_id]
  end
end
