# frozen_string_literal: true

class Api::Rest::Admin::ContactResource < ::BaseResource
  model_name 'Billing::Contact'

  attributes :email, :notes

  has_one :contractor

  def self.records(options = {})
    super(options).contractors
  end
end
