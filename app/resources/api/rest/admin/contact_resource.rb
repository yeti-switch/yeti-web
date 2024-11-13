# frozen_string_literal: true

class Api::Rest::Admin::ContactResource < ::BaseResource
  model_name 'Billing::Contact'

  attributes :email, :notes

  paginator :paged

  has_one :contractor, always_include_linkage_data: true

  ransack_filter :email, type: :string
  ransack_filter :notes, type: :string

  def self.records(options = {})
    super(options).contractors
  end
end
