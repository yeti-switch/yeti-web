# frozen_string_literal: true

module Api
  module Rest
    module Customer
      module V1
        class ProfileResource < Api::Rest::Customer::V1::BaseResource
          singleton
          model_name 'System::CustomerPortalAccessProfile'
          primary_key :id
          exclude_links [:self]

          attribute :account
          attribute :outgoing_rateplans
          attribute :outgoing_cdrs
          attribute :outgoing_cdr_exports
          attribute :outgoing_statistics
          attribute :outgoing_statistics_active_calls
          attribute :outgoing_statistics_acd
          attribute :outgoing_statistics_asr
          attribute :outgoing_statistics_failed_calls
          attribute :outgoing_statistics_successful_calls
          attribute :outgoing_statistics_total_calls
          attribute :outgoing_statistics_total_duration
          attribute :outgoing_statistics_total_price
          attribute :outgoing_numberlists
          attribute :incoming_cdrs
          attribute :incoming_statistics
          attribute :invoices
          attribute :payments
          attribute :services
          attribute :transactions

          def fetchable_fields
            %i[
              account
              outgoing_rateplans
              outgoing_cdrs
              outgoing_cdr_exports
              outgoing_statistics
              outgoing_statistics_active_calls
              outgoing_statistics_acd
              outgoing_statistics_asr
              outgoing_statistics_failed_calls
              outgoing_statistics_successful_calls
              outgoing_statistics_total_calls
              outgoing_statistics_total_duration
              outgoing_statistics_total_price
              outgoing_numberlists
              incoming_cdrs
              incoming_statistics
              invoices
              payments
              services
              transactions
            ]
          end

          def self.find_by_key(_key, options = {})
            customer_portal_access_profile_id = options[:context][:current_customer].customer_portal_access_profile_id
            model = ::System::CustomerPortalAccessProfile.find_by(id: customer_portal_access_profile_id)
            new(model, options[:context])
          end
        end
      end
    end
  end
end
