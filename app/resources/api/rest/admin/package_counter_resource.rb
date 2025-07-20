# frozen_string_literal: true

class Api::Rest::Admin::PackageCounterResource < ::BaseResource
  model_name 'Billing::PackageCounter'

  attribute :duration
  attribute :exclude
  attribute :prefix
  attribute :service_id

  paginator :paged

  has_one :account, class_name: 'Account', exclude_links: %i[self]
  has_one :service, class_name: 'Service', exclude_links: %i[self]

  relationship_filter :service
  relationship_filter :account
end
