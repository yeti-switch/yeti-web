# frozen_string_literal: true

class Api::Rest::Admin::System::NetworkTypeResource < ::BaseResource
  model_name 'System::NetworkType'
  attributes :name
  paginator :paged
  filter :name

  before_remove do
    if _model.networks.any?
      _model.errors.add(:base, 'has related networks')
      raise JSONAPI::Exceptions::ValidationErrors, self
    end
  end
end
