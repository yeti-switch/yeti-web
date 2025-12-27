# frozen_string_literal: true

Rails.application.routes.draw do
  def dasherized_namespace(name, options = {}, &block)
    options[:path] = name.to_s.dasherize
    namespace(name.to_s.underscore.to_sym, options, &block)
  end

  def dasherized_resources(name, options = {}, &block)
    options[:controller] ||= name.to_s.underscore.to_sym
    options[:as] ||= name.to_s.underscore.to_sym
    resources(name.to_s.dasherize.to_sym, options, &block)
  end

  def dasherized_resource(name, options = {}, &block)
    options[:controller] ||= name.to_s.underscore.to_sym
    options[:as] ||= name.to_s.underscore.to_sym
    resource(name.to_s.dasherize.to_sym, options, &block)
  end

  devise_for :admin_users, ActiveAdmin::Devise.config

  get 'with_contractor_accounts', to: 'accounts#with_contractor'
  authenticate :admin_user do
    ActiveAdmin.routes(self)
  end

  resources :active_calls, constraints: { id: %r{[^/]+} }, only: %i[show index destroy]

  resources :remote_stats do
    collection do
      get :nodes
      get :hour_nodes
      get :cdrs_summary
      get :profit
      get :duration
    end
    member do
      get :vendors_traffic
      get :customers_traffic
      get :node
      get :account_active_calls
      get :aggregated_node
      get :aggregated_orig_gateway
      get :orig_gateway
      get :aggregated_term_gateway
      get :term_gateway
      get :aggregated_customer_account
      get :customer_account
      get :aggregated_vendor_account
      get :vendor_account
      get :gateway_pdd_distribution
      get :dialpeer_pdd_distribution
    end
  end

  namespace :api do
    resources :cryptomus_callbacks, only: [:create]

    namespace :rest do
      with_options defaults: { format: :json } do |api|
        namespace :system do
          api.resources :admin_users, only: [:index]
          api.resources :nodes, only: [:index]
          api.resources :ip_access, only: [:index]
        end

        namespace :admin do
          dasherized_resource :auth, only: [:create]
          jsonapi_resources :accounts do
            jsonapi_relationships
            jsonapi_resource :balance, only: [:update]
          end
          jsonapi_resources :contractors
          jsonapi_resources :contacts
          jsonapi_resources :api_accesses
          jsonapi_resources :customer_tokens, only: %i[create]
          jsonapi_resources :customers_auths
          jsonapi_resources :rate_groups

          jsonapi_resources :dialpeers
          jsonapi_resources :dialpeer_next_rates
          jsonapi_resources :gateways
          jsonapi_resources :gateway_groups
          jsonapi_resources :payments, except: %i[update destroy]

          jsonapi_resources :routing_plans
          jsonapi_resources :codec_groups

          jsonapi_resources :disconnect_policies
          jsonapi_resources :filter_types
          jsonapi_resources :pops
          jsonapi_resources :nodes
          jsonapi_resources :sdp_c_locations
          jsonapi_resources :session_refresh_methods
          jsonapi_resources :active_calls, only: %i[index show destroy]
          jsonapi_resources :incoming_registrations, only: %i[index]

          jsonapi_resources :cdrs, only: %i[index show update] do
            jsonapi_relationships
            member { get :recording }
          end
          jsonapi_resources :auth_logs, only: %i[index show] do
          end
          jsonapi_resources :cdr_exports, only: %i[index show create destroy] do
            jsonapi_relationships
            member { get :download }
          end

          jsonapi_resources :invoice_template
          jsonapi_resources :invoices, only: %i[index show create destroy] do
            jsonapi_relationships
            member do
              get :pdf
              get :odt
            end
          end
          jsonapi_resources :invoice_originated_destinations, only: %i[index show]
          jsonapi_resources :invoice_originated_networks, only: %i[index show]
          jsonapi_resources :invoice_terminated_destinations, only: %i[index show]
          jsonapi_resources :invoice_terminated_networks, only: %i[index show]
          jsonapi_resources :invoice_service_data, only: %i[index show]
          jsonapi_resources :service_types
          jsonapi_resources :services, only: %i[index show create update]
          jsonapi_resources :transactions, only: %i[index show]

          jsonapi_resources :timezones
          jsonapi_resources :dtmf_receive_modes
          jsonapi_resources :dtmf_send_modes
          jsonapi_resources :sensor_levels
          jsonapi_resources :sensors
          jsonapi_resources :smtp_connections
          jsonapi_resources :countries
          jsonapi_resources :networks
          jsonapi_resources :network_types

          jsonapi_resources :gateway_rel100_modes
          jsonapi_resources :gateway_inband_dtmf_filtering_modes
          jsonapi_resources :gateway_diversion_send_modes
          jsonapi_resources :gateway_network_protocol_priorities
          jsonapi_resources :gateway_media_encryption_modes
          jsonapi_resources :transport_protocols
          jsonapi_resources :registrations
          jsonapi_resources :sip_options_probers

          jsonapi_resources :radius_accounting_profiles
          jsonapi_resources :radius_auth_profiles

          jsonapi_resources :areas
          jsonapi_resources :area_prefixes
          jsonapi_resources :numberlists
          jsonapi_resources :numberlist_items
          jsonapi_resources :routing_tag_detection_rules
          jsonapi_resources :tag_actions
          jsonapi_resources :rateplans
          jsonapi_resources :routing_groups
          jsonapi_resources :routing_tags
          jsonapi_resources :routeset_discriminators
          jsonapi_resources :destinations
          jsonapi_resources :destination_next_rates
          jsonapi_resources :package_counters, only: %i[index show]
        end

        namespace :customer do
          namespace :v1 do
            jsonapi_resources(:accounts, only: %i[index show]) {}
            jsonapi_resources(:rateplans, only: %i[index show]) {}
            jsonapi_resources(:rates, only: %i[index show]) {}
            jsonapi_resources(:outgoing_numberlists, only: %i[index show]) {}
            jsonapi_resources(:outgoing_numberlist_items, only: %i[index show create update destroy]) {}
            jsonapi_resource(:check_rate, only: %i[create]) {}
            jsonapi_resources :cdrs, only: %i[index show] do
              member { get :rec }
            end
            jsonapi_resources :incoming_cdrs, only: %i[index show] do
              member { get :rec }
            end
            jsonapi_resources(:networks, only: %i[index show]) {}
            jsonapi_resources(:network_types, only: %i[index show]) {}
            jsonapi_resources(:network_prefixes, only: %i[index show]) {}
            jsonapi_resources(:chart_active_calls, only: %i[create]) {}
            jsonapi_resources(:chart_originated_cps, only: %i[create]) {}
            jsonapi_resources(:payments, only: %i[index show]) {}
            jsonapi_resources(:cryptomus_payments, only: %i[create show]) {}
            jsonapi_resources :invoices, only: %i[index show] do
              member { get :download }
            end
            jsonapi_resources :cdr_exports, only: %i[index show create] do
              member { get :download }
            end
            jsonapi_resources(:countries, only: %i[index show]) {}
            jsonapi_resources(:services, only: %i[index show]) {}
            jsonapi_resources(:transactions, only: %i[index show]) {}
            jsonapi_resources(:phone_systems_sessions, only: %i[create]) {}
            jsonapi_resource(:profiles, only: %i[show]) {}

            dasherized_resource :auth, only: %i[create show destroy]

            dasherized_resource :call_auth, only: [:create]

            with_options only: [:show] do
              dasherized_resource :origination_statistics
              dasherized_resource :origination_statistics_quality
              dasherized_resource :origination_active_calls
              dasherized_resource :termination_statistics
              dasherized_resource :termination_statistics_quality
              dasherized_resource :termination_active_calls
              dasherized_resource :outgoing_active_calls
            end
          end
        end

        dasherized_namespace :clickhouse_dictionaries do
          with_options only: [:index] do
            dasherized_resources :accounts
            dasherized_resources :areas
            dasherized_resources :contractors
            dasherized_resources :countries
            dasherized_resources :customer_auths
            dasherized_resources :gateways
            dasherized_resources :network_prefixes
            dasherized_resources :networks
            dasherized_resources :nodes
            dasherized_resources :pops
            dasherized_resources :rateplans
            dasherized_resources :routing_plans
          end
        end
      end
    end
  end

  # 404
  match '*a' => 'application#render_404', via: :get
end
