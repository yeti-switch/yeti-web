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

          attribute :outgoing_statistics_acd_value
          attribute :outgoing_statistics_asr_value
          attribute :outgoing_statistics_failed_calls_value
          attribute :outgoing_statistics_successful_calls_value
          attribute :outgoing_statistics_total_calls_value
          attribute :outgoing_statistics_total_duration_value
          attribute :outgoing_statistics_total_price_value

          attribute :outgoing_numberlists
          attribute :incoming_cdrs

          attribute :incoming_statistics

          attribute :incoming_statistics_active_calls
          attribute :incoming_statistics_acd
          attribute :incoming_statistics_asr
          attribute :incoming_statistics_failed_calls
          attribute :incoming_statistics_successful_calls
          attribute :incoming_statistics_total_calls
          attribute :incoming_statistics_total_duration
          attribute :incoming_statistics_total_price

          attribute :incoming_statistics_acd_value
          attribute :incoming_statistics_asr_value
          attribute :incoming_statistics_failed_calls_value
          attribute :incoming_statistics_successful_calls_value
          attribute :incoming_statistics_total_calls_value
          attribute :incoming_statistics_total_duration_value
          attribute :incoming_statistics_total_price_value

          attribute :invoices
          attribute :payments
          attribute :payments_cryptomus
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

              outgoing_statistics_acd_value
              outgoing_statistics_asr_value
              outgoing_statistics_failed_calls_value
              outgoing_statistics_successful_calls_value
              outgoing_statistics_total_calls_value
              outgoing_statistics_total_duration_value
              outgoing_statistics_total_price_value

              outgoing_numberlists
              incoming_cdrs
              incoming_statistics

              incoming_statistics_active_calls
              incoming_statistics_acd
              incoming_statistics_asr
              incoming_statistics_failed_calls
              incoming_statistics_successful_calls
              incoming_statistics_total_calls
              incoming_statistics_total_duration
              incoming_statistics_total_price

              incoming_statistics_acd_value
              incoming_statistics_asr_value
              incoming_statistics_failed_calls_value
              incoming_statistics_successful_calls_value
              incoming_statistics_total_calls_value
              incoming_statistics_total_duration_value
              incoming_statistics_total_price_value

              invoices
              payments
              payments_cryptomus
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
