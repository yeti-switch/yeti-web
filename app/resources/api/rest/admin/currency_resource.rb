# frozen_string_literal: true

class Api::Rest::Admin::CurrencyResource < ::BaseResource
  model_name 'Billing::Currency'
  paginator :paged

  attribute :name
  attribute :rate

  ransack_filter :name, type: :string
  ransack_filter :rate, type: :number

  def self.sortable_fields(_ctx = nil)
    %i[id name rate]
  end

  def self.creatable_fields(_ctx = nil)
    %i[name rate]
  end

  def self.updatable_fields(_ctx = nil)
    %i[name rate]
  end
end
