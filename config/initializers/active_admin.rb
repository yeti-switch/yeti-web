# frozen_string_literal: true

ActiveAdmin.setup do |config|
  config.namespace :root do |admin|
    #        admin.build_menu :utility_navigation do |menu|
    admin.build_menu do |menu|
      menu.add label: 'Billing', priority: 20 do |sub_menu|
        sub_menu.add label: 'Settings', priority: 1000
      end
      menu.add label: 'Equipment', priority: 30 do |sub_menu|
        sub_menu.add label: 'RADIUS', priority: 900
        sub_menu.add label: 'STIR/SHAKEN', priority: 1000
        sub_menu.add label: 'DNS', priority: 2000
      end
      menu.add label: 'Routing', priority: 40
      menu.add label: 'CDR', priority: 50
      menu.add label: 'Reports', priority: 60
      #      menu.add label: "Rate Tools", priority: 65
      menu.add label: 'Realtime Data', priority: 70
      menu.add label: 'Logs', priority: 80
      menu.add label: 'System', priority: 90 do |sub_menu|
        sub_menu.add label: 'Components'
      end
      menu.add label: 'Rate Management', priority: 100

      # http://127.0.0.1:3000/admin/admin_users/1
      menu.add label: proc { display_name current_active_admin_user },
               url: proc { admin_user_path(current_active_admin_user) },
               id: 'current_user',
               if: proc { current_active_admin_user? },
               priority: 9_999_998

      admin.add_logout_button_to_menu menu, 9_999_999
      # can also pass priority & html_options for link_to to use
    end
    admin.build_menu :utility_navigation do
    end
  end
  config.load_paths = [Rails.root.join('app/admin').to_s] #+ Dir.glob(File.join(Rails.root, "app", "admin", "/**/*/"))).uniq

  # == Site Title
  #
  # Set the title that is displayed on the main layout
  # for each of the active admin pages.
  #
  config.site_title = YetiConfig.site_title
  # Set the link url for the title. For example, to take
  # users to your main site. Defaults to no link.
  #
  # config.site_title_link = "/"

  # Set an optional image to be displayed for the header
  # instead of a string (overrides :site_title)
  #
  # Note: Recommended image height is 21px to properly fit in the header
  #
  config.site_title_image = YetiConfig.site_title_image

  # == Default Namespace
  #
  # Set the default namespace each administration resource
  # will be added to.
  #
  # eg:
  #   config.DEFAULT_NAMESPACE = :hello_world
  #
  # This will create resources in the HelloWorld module and
  # will namespace routes to /hello_world/*
  #
  # To set no namespace by default, use:
  config.default_namespace = false
  #
  # Default:
  # config.default_namespace = :admin
  #
  # You can customize the settings for each namespace by using
  # a namespace block. For example, to change the site title
  # within a namespace:
  #
  #   config.namespace :admin do |admin|
  #     admin.site_title = "Custom Admin Title"
  #   end
  #
  # This will ONLY change the title for the admin section. Other
  # namespaces will continue to use the main "site_title" configuration.

  # == User Authentication
  #
  # Active Admin will automatically call an authentication
  # method in a before filter of all controller actions to
  # ensure that there is a currently logged in admin user.
  #
  # This setting changes the method which Active Admin calls
  # within the controller.
  config.authentication_method = :authenticate_admin_user!

  # == Current User
  #
  # Active Admin will associate actions with the current
  # user performing them.
  #
  # This setting changes the method which Active Admin calls
  # to return the currently logged in user.
  config.current_user_method = :current_admin_user

  # == Logging Out
  #
  # Active Admin displays a logout link on each screen. These
  # settings configure the location and method used for the link.
  #
  # This setting changes the path where the link points to. If it's
  # a string, the strings is used as the path. If it's a Symbol, we
  # will call the method to return the path.
  #
  # Default:
  config.logout_link_path = :destroy_admin_user_session_path

  # This setting changes the http method used when rendering the
  # link. For example :get, :delete, :put, etc..
  #
  # Default:
  # config.logout_link_method = :get

  # == Root
  #
  # Set the action to call for the root path. You can set different
  # roots for each namespace.
  #
  # Default:
  # config.root_to = 'dashboard#index'

  # == Admin Comments
  #
  # Admin comments allow you to add comments to any model for admin use.
  # Admin comments are enabled by default.
  #
  # Default:
  # config.comments = true
  config.comments_menu = { parent: 'Logs', priority: 300, label: 'Comments' }

  config.current_filters = false

  #
  # You can turn them on and off for any given namespace by using a
  # namespace config block.
  #
  # Eg:
  #   config.namespace :without_comments do |without_comments|
  #     without_comments.allow_comments = false
  #   end

  # == Batch Actions
  #
  # Enable and disable Batch Actions
  #
  config.batch_actions = true

  # == Pagination
  #
  # Pagination is enabled by default for all resources.
  # You can control the default per page count for all resources here.
  #
  # config.default_per_page = [50, 100, 200, 500]

  # == Register Stylesheets & Javascripts
  #
  # We recommend using the built in Active Admin layout and loading
  # up your own stylesheets / javascripts to customize the look
  # and feel.
  #
  # To load a stylesheet:
  config.register_stylesheet 'yeti/yeti.css'
  config.footer = proc { render partial: 'active_admin/footer' }

  # You can provide an options hash for more control, which is passed along to stylesheet_link_tag():
  #   config.register_stylesheet 'my_print_stylesheet.css', :media => :print
  #
  # To load a javascript file:
  #   config.register_javascript 'my_javascript.js'

  # == CSV options
  #
  # Set the CSV builder separator (default is ",")
  # config.csv_column_separator = ','
  config.csv_options = { col_sep: ',', force_quotes: true }
  config.download_links = [:csv]

  require Rails.root.join('app/lib/policy_adapter')

  config.authorization_adapter = PolicyAdapter
  config.pundit_default_policy = 'DefaultApplicationPolicy'

  # Enables CSV streaming in development and test modes.
  # Useful to test streaming bugs locally.
  config.disable_streaming_in = []
end

Dir[Rails.root.join('lib/active_admin/**/*.rb')].each { |s| require s }

ActiveAdmin.before_load do
  Dir[Rails.root.join('lib/resource_dsl/**/*.rb')].each { |s| require s }

  ActiveAdmin::ResourceDSL.include ResourceDSL::ActsAsClone
  ActiveAdmin::ResourceDSL.include ResourceDSL::ActsAsStatus
  ActiveAdmin::ResourceDSL.include ResourceDSL::ActsAsAudit
  ActiveAdmin::ResourceDSL.include ResourceDSL::ActsAsSafeDestroy
  ActiveAdmin::ResourceDSL.include ResourceDSL::ActsAsStat
  ActiveAdmin::ResourceDSL.include ResourceDSL::ActsAsLock
  ActiveAdmin::ResourceDSL.include ResourceDSL::ActsAsExport
  ActiveAdmin::ResourceDSL.include ResourceDSL::ActsAsCdrStat
  ActiveAdmin::ResourceDSL.include ResourceDSL::ActsAsImport
  ActiveAdmin::ResourceDSL.include ResourceDSL::ActsAsImportPreview
  ActiveAdmin::ResourceDSL.include ResourceDSL::ActsAsBatchChangeable
  ActiveAdmin::ResourceDSL.include ResourceDSL::ReportScheduler
  ActiveAdmin::ResourceController.include ActiveAdmin::PerPageExtension
  ActiveAdmin::BaseController.include ActiveAdmin::WithPayloads
  ActiveAdmin::ResourceDSL.include ResourceDSL::BatchActionUpdate
  ActiveAdmin::ResourceDSL.include ResourceDSL::ActsAsAsyncDestroy
  ActiveAdmin::ResourceDSL.include ResourceDSL::ActsAsAsyncUpdate
  ActiveAdmin::ResourceDSL.include ResourceDSL::ActsAsDelayedJobLock
  ActiveAdmin::ResourceDSL.include ResourceDSL::ActsAsFilterByRoutingTagIds
  ActiveAdmin::ResourceDSL.include ResourceDSL::ActsAsBelongsTo
  ActiveAdmin::ResourceDSL.include ResourceDSL::WithDefaultParams
  ActiveAdmin::ResourceDSL.include ResourceDSL::WithGlobalDSL
  ActiveAdmin::ResourceDSL.include ResourceDSL::BooleanFilter
  ActiveAdmin::ResourceDSL.include ResourceDSL::AssociationAjaxFilter
  ActiveAdmin::ResourceDSL.include ResourceDSL::AccountFilter
  ActiveAdmin::ResourceDSL.include ResourceDSL::ContractorFilter
  ActiveAdmin::ResourceDSL.include ResourceDSL::CountryFilter
  ActiveAdmin::ResourceDSL.include ResourceDSL::NetworkFilter
  ActiveAdmin::ResourceDSL.include ResourceDSL::ActiveSearch

  ActiveAdmin::ResourceDSL.include Rails.application.routes.url_helpers
  ActiveAdmin::ResourceDSL.include ApplicationHelper

  ActiveAdmin::ResourceController.prepend ActiveAdmin::CsvStreamWithErrorHandler

  ActiveAdmin::Filters::FormBuilder.class_eval do
    # Returns the default filter type for a given attribute. If you want
    # to use a custom search method, you have to specify the type yourself.
    def default_input_type(method, _options = {})
      if method.match?(/_(eq|equals|cont|contains|start|starts_with|end|ends_with)\z/)
        :string
      elsif klass._ransackers.key?(method.to_s)
        klass._ransackers[method.to_s].type
      elsif reflection_for(method) || polymorphic_foreign_type?(method)
        :select
      elsif (column = column_for(method))
        case column.type
        when :date, :datetime
          :date_range
        when :string, :text
          :string
        when :integer, :float, :decimal
          :numeric
        when :boolean
          :boolean
        end
      end
    end
  end
end
