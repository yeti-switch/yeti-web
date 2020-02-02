# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery

  # https://github.com/paper-trail-gem/paper_trail/blob/v9.0.0/README.md#1b-installation
  before_action :set_paper_trail_whodunnit

  class Custom404 < StandardError
  end

  class ImportDisabled < StandardError
  end

  class ImportPending < StandardError
    attr_reader :resource_path
    def initialize(r, message)
      super(message)
      @resource_path = r
    end
  end

  rescue_from StandardError, with: :capture_error!

  include CaptureError::ControllerMethods
  include Concerns::Rescuers
  include Concerns::IndexMaxRecords

  def redirect_to_back(default = root_url)
    if !request.env['HTTP_REFERER'].blank? && (request.env['HTTP_REFERER'] != request.env['REQUEST_URI'])
      redirect_back fallback_location: root_path
    else
      redirect_to default
    end
  end

  def info_for_paper_trail
    { ip: request.env['HTTP_X_REAL_IP'] || request.remote_ip }
  end

  protected

  def user_for_paper_trail
    admin_user_signed_in? ? current_admin_user.try!(:id) : 'Unknown user'
  end

  def current_ability
    @current_ability ||= Ability.new(current_admin_user)
  end
end
