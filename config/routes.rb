Yeti::Application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  post 'api/rest/private/auth', to: 'api/rest/private/auth#create'
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
        end

        namespace :private do
          jsonapi_resources :contractors
          jsonapi_resources :accounts
          jsonapi_resources :customers_auths
          jsonapi_resources :destinations
          jsonapi_resources :dialpeers # do
          #   api.resources :dialpeer_next_rates,
          #                 only: [:index, :show, :update, :destroy, :create],
          #                 controller: :dialpeer_next_rates
          # end

          api.resources :gateways, only: [:index, :show, :update, :destroy, :create]
          api.resources :gateway_groups, only: [:index, :show, :update, :destroy, :create]
          api.resources :routing_groups, only: [:index, :show, :update, :destroy, :create]
          api.resources :routing_plans, only: [:index, :show, :update, :destroy, :create]
          api.resources :rateplans, only: [:index, :show, :update, :destroy, :create]
          api.resources :destinations, only: [:index, :show, :update, :destroy, :create]

          api.resources :payments, only: [:index, :show, :create]
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
