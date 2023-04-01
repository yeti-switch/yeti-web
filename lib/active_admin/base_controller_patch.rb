# frozen_string_literal: true

ActiveAdmin.before_load do
  ActiveAdmin::BaseController.class_eval do
    include Pundit
    include CaptureError::ControllerMethods

    before_action only: [:index] do
      fix_max_records
      restore_search_filters if respond_to?(:save_filters?) && save_filters?
    end

    before_action do
      left_sidebar!(collapsed: true) if respond_to?(:left_sidebar!)
    end

    after_action do
      save_search_filters if respond_to?(:save_filters?) && save_filters?
    end

    def capture_tags
      { component: 'AdminUI' }
    end

    def capture_user
      return if current_admin_user.nil?

      {
        id: current_admin_user.id,
        username: current_admin_user.username,
        class: 'AdminUser',
        ip_address: '{{auto}}'
      }
    end

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
      active_admin_authorization.authorized?(action, subject, invalid_action:)
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
