class ApplicationController < ActionController::Base
  protect_from_forgery

  class Custom404 < StandardError

  end

  class ImportDisabled  < StandardError

  end

  class ImportPending < StandardError
    attr_reader :resource_path
    def initialize(r, message)
       super(message)
       @resource_path = r
    end
  end


  include Concerns::ErrorNotify
  include Concerns::Rescuers
  include Concerns::IndexMaxRecords


  def redirect_to_back(default = root_url)
    if !request.env["HTTP_REFERER"].blank? and request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
      redirect_to :back
    else
      redirect_to default
    end
  end

  def info_for_paper_trail
    {ip: request.env['HTTP_X_REAL_IP'] || request.remote_ip}
  end

  protected


  def user_for_paper_trail
    admin_user_signed_in? ? current_admin_user : 'Unknown user'
  end

  def current_ability
    @current_ability ||= Ability.new(current_admin_user)
  end

end


