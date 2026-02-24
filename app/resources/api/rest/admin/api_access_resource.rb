# frozen_string_literal: true

class Api::Rest::Admin::ApiAccessResource < ::BaseResource
  model_name 'System::ApiAccess'

  attributes :customer_id,
             :login,
             :password,
             :account_ids,
             :allowed_ips

  paginator :paged

  # auto-generated UUID must be "reloaded"
  after_create do
    _model.reload
  end

  def fetchable_fields
    super - [:password]
  end
end
