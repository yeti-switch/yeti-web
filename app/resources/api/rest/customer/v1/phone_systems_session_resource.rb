# frozen_string_literal: true

module Api
  module Rest
    module Customer
      module V1
        class PhoneSystemsSessionResource < Api::Rest::Customer::V1::BaseResource
          exclude_links [:self]
          model_name 'PhoneSystemsSessionForm'

          attribute :service
          attribute :phone_systems_url

          before_replace_fields do
            _model.customer = context[:current_customer].customer
            _model.api_access = context[:current_customer]
          end

          def self.creatable_fields(_context)
            [:service]
          end

          def fetchable_fields
            [:phone_systems_url]
          end
        end
      end
    end
  end
end
