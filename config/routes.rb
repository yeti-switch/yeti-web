Yeti::Application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  post 'api/rest/admin/auth', to: 'api/rest/admin/auth#create'
  post 'api/rest/customer/v1/auth', to: 'api/rest/customer/v1/auth#create'
  get 'with_contractor_accounts', to: 'accounts#with_contractor'
  ActiveAdmin.routes(self)

  resources :active_calls, constraints: { id: /[^\/]+/ }, only: [:show, :index, :destroy]

  resources :remote_stats do
    collection do
      get :nodes
      get :hour_nodes
      get :cdrs_summary
      get :cdrs_summary_archive
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
    namespace :rest do
      with_options defaults: {format: :json} do |api|
        namespace :system do
          api.resources :jobs, only: [:index] do
            member do
              put :run
            end
          end

          api.resources :admin_users, only: [:index]
          api.resources :nodes, only: [:index]
          api.resources :ip_access, only: [:index]
        end

        namespace :admin do
          jsonapi_resources :accounts do
            jsonapi_resource :balance, only: [:update]
          end
          jsonapi_resources :contractors
          jsonapi_resources :api_accesses
          jsonapi_resources :customers_auths
          jsonapi_resources :destinations
          jsonapi_resources :dialpeers
          jsonapi_resources :dialpeer_next_rates
          jsonapi_resources :gateways
          jsonapi_resources :gateway_groups
          jsonapi_resources :payments, except: [:update, :destroy]
          jsonapi_resources :rateplans
          jsonapi_resources :routing_groups
          jsonapi_resources :routing_plans
          jsonapi_resources :codec_groups
          jsonapi_resources :destination_rate_policies
          jsonapi_resources :disconnect_policies
          jsonapi_resources :diversion_policies
          jsonapi_resources :dump_levels
          jsonapi_resources :filter_types
          jsonapi_resources :pops
          jsonapi_resources :sdp_c_locations
          jsonapi_resources :session_refresh_methods
          jsonapi_resources :sortings

          namespace :cdr do
            jsonapi_resources :cdrs, only: [:index, :show] do
            end
          end

          namespace :billing do
            jsonapi_resources :invoice_period
            jsonapi_resources :invoice_template
          end

          namespace :system do
            jsonapi_resources :timezones
            jsonapi_resources :dtmf_receive_modes
            jsonapi_resources :dtmf_send_modes
            jsonapi_resources :sensor_levels
            jsonapi_resources :sensors
            jsonapi_resources :smtp_connections
            jsonapi_resources :countries
            jsonapi_resources :networks
          end

          namespace :equipment do
            jsonapi_resources :gateway_rel100_modes
            jsonapi_resources :transport_protocols
            namespace :radius do
              jsonapi_resources :accounting_profiles
              jsonapi_resources :auth_profiles
            end
          end

          namespace :routing do
            jsonapi_resources :areas
            jsonapi_resources :numberlists
            jsonapi_resources :numberlist_items
            jsonapi_resources :numberlist_actions
            jsonapi_resources :rate_profit_control_modes
            jsonapi_resources :routing_tag_detection_rules
            jsonapi_resources :tag_actions
            jsonapi_resources :routing_tags
          end
        end

        namespace :customer do
          namespace :v1 do
            jsonapi_resources :accounts
            jsonapi_resources :rateplans
            jsonapi_resources :rates
            jsonapi_resource :check_rate, only: [:create]
            jsonapi_resources :cdrs, only: [:index, :show]
           end
        end
      end
    end
  end

  #404
  match '*a' => 'application#render_404', via: :get

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.

  #root :to => 'admin/contractors#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
