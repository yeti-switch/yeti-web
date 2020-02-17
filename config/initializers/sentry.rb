# frozen_string_literal: true

require 'capture_error'

if CaptureError.enabled? && !defined?(::Rake)
  CaptureError.configure!
end

ActiveAdmin::BaseController.class_eval do
  include CaptureError::ControllerMethods

  def capture_user
    return if current_admin_user.nil?

    {
      id: current_admin_user.id,
      username: current_admin_user.username,
      class: 'AdminUser'
    }
  end
end
