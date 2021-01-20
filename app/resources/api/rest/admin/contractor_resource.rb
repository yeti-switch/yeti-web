# frozen_string_literal: true

class Api::Rest::Admin::ContractorResource < BaseResource
  attributes :name, :enabled, :vendor, :customer, :description, :address, :phones, :external_id

  paginator :paged

  has_one :smtp_connection, class_name: 'System::SmtpConnection'

  filter :name

  relationship_filter :smtp_connection

  ransack_filter :name, type: :string
  ransack_filter :enabled, type: :boolean
  ransack_filter :vendor, type: :boolean
  ransack_filter :customer, type: :boolean
  ransack_filter :description, type: :string
  ransack_filter :address, type: :string
  ransack_filter :phones, type: :string
  ransack_filter :external_id, type: :number

  def self.updatable_fields(_context)
    %i[
      name
      enabled
      vendor
      customer
      description
      address
      phones
      smtp_connection
      external_id
    ]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
