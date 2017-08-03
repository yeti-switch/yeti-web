module Concerns::Rescuers
  extend ActiveSupport::Concern

  included do

    rescue_from XMLRPC::FaultException, SystemCallError, CanCan::AccessDenied do |e|
      flash[:warning] = e.message
      redirect_to self.root_path
    end

    # rescue_from ImportDisabled do |e|
    #   flash[:notice] = e.message
    #   redirect_to :back
    # end

    rescue_from ApplicationController::ImportDisabled do |e|
      flash[:notice] = e.message
      redirect_to :back
    end


    rescue_from ApplicationController::ImportPending do |e|
      flash[:notice] = e.message
      redirect_to e.resource_path
    end

    unless Rails.env.development?
      rescue_from ActiveRecord::RecordNotFound, AbstractController::ActionNotFound, ApplicationController::Custom404 do |e|
        logger.error e.message
        logger.error e.backtrace.join("\n")
        render_404
      end

    end

  end


  def render_404
    if /(jpe?g|png|gif)/i === request.path
      render text: "404 Yeti Not Found", status: 404
    elsif request.xhr?
      render status: 404, nothing: true
    else
      render template: "404", layout: 'application', status: 404, formats: [:html]
    end
  end


end


