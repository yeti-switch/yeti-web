# frozen_string_literal: true

ActiveAdmin.setup do |config|
  config.namespace :root do |admin|
    #        admin.build_menu :utility_navigation do |menu|
    admin.build_menu do |menu|
      menu.add label: 'Billing', priority: 20
      menu.add label: 'Equipment', priority: 30
      menu.add label: 'Routing', priority: 40
      menu.add label: 'CDR', priority: 50
      menu.add label: 'Reports', priority: 60
      #      menu.add label: "Rate Tools", priority: 65
      menu.add label: 'Realtime Data', priority: 70
      menu.add label: 'Logs', priority: 80
      menu.add label: 'System', priority: 90

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
  config.load_paths = [File.join(Rails.root, 'app', 'admin')] #+ Dir.glob(File.join(Rails.root, "app", "admin", "/**/*/"))).uniq

  # == Site Title
  #
  # Set the title that is displayed on the main layout
  # for each of the active admin pages.
  #
  config.site_title = Rails.configuration.yeti_web['site_title']
  # Set the link url for the title. For example, to take
  # users to your main site. Defaults to no link.
  #
  # config.site_title_link = "/"

  # Set an optional image to be displayed for the header
  # instead of a string (overrides :site_title)
  #
  # Note: Recommended image height is 21px to properly fit in the header
  #
  config.site_title_image = Rails.configuration.yeti_web['site_title_image']

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
  config.comments_menu = false

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

  # == Controller Filters
  #
  # You can add before, after and around filters to all of your
  # Active Admin resources from here.
  #
  config.before_action do
    left_sidebar!(collapsed: true) if respond_to?(:left_sidebar!)
  end

  config.before_action only: [:index] do
    fix_max_records
    restore_search_filters if respond_to?(:save_filters?) && save_filters?
  end

  config.after_action do
    save_search_filters if respond_to?(:save_filters?) && save_filters?
  end

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

  config.authorization_adapter = PolicyAdapter
  config.pundit_default_policy = 'DefaultApplicationPolicy'

  ActiveAdmin::BaseController.class_eval do
    include Pundit

    def pundit_user
      current_admin_user
    end

    protected

    # syntax sugar - skip action argument if it is equal to `params[:action].to_sym`
    # authorized? => authorized?(params[:action].to_sym, resource)
    # authorized?(record) => authorized?(params[:action].to_sym, record)
    def authorized?(action = nil, subject = nil)
      action, subject = normalize_authorized_params(action, subject)
      invalid_action = ->(msg) { capture_message(msg) }
      active_admin_authorization.authorized?(action, subject, invalid_action: invalid_action)
    end

    def authorize!(action = nil, subject = nil)
      action, subject = normalize_authorized_params(action, subject)
      unless authorized?(action, subject)
        subj = active_admin_authorization.pretty_subject(subject)
        user = active_admin_authorization.pretty_user(current_active_admin_user)
        logger.warn { "[POLICY] #{subj} not authorized to perform #{action} for #{user}" }
        raise ActiveAdmin::AccessDenied.new(current_active_admin_user, action, subject)
      end
    end

    private

    def normalize_authorized_params(action, subject)
      if subject.nil? && (!action.is_a?(Symbol) && !action.is_a?(String) && !action.is_a?(NilClass))
        subject = action
        action = nil
      end
      action = params[:action].to_sym if action.nil?
      subject = resource_class if subject.nil?
      [action, subject]
    end

    private

    # https://github.com/activeadmin/activeadmin/issues/3335
    # def interpolation_options
    def flash_interpolation_options
      options = {}

      options[:resource_errors] =
        if resource&.errors&.any?
          "#{resource.errors.full_messages.to_sentence}."
        else
          ''
        end
      options
    end
  end
end
