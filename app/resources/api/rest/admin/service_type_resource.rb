# frozen_string_literal: true

class Api::Rest::Admin::ServiceTypeResource < ::BaseResource
  model_name 'Billing::ServiceType'
  paginator :paged

  attribute :name
  attribute :force_renew
  attribute :provisioning_class
  attribute :variables

  ransack_filter :name, type: :string
  ransack_filter :force_renew, type: :boolean
  ransack_filter :provisioning_class, type: :string

  def self.sortable_fields(_ctx = nil)
    %i[id name force_renew provisioning_class]
  end

  def self.creatable_fields(_ctx = nil)
    %i[name force_renew provisioning_class variables]
  end

  def self.updatable_fields(ctx = nil)
    creatable_fields(ctx)
  end
end
