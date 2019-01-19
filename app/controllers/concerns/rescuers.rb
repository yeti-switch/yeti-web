# frozen_string_literal: true

module Concerns::Rescuers
  extend ActiveSupport::Concern

  included do
    rescue_from SystemCallError, ActiveAdmin::AccessDenied do |e|
      flash[:warning] = e.message
      redirect_to root_path
    end

    # rescue_from ImportDisabled do |e|
    #   flash[:notice] = e.message
    #   redirect_back fallback_location: root_path
    # end

    rescue_from ApplicationController::ImportDisabled do |e|
      flash[:notice] = e.message
      redirect_back fallback_location: root_path
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

  def render_404(_e = nil)
    if /(jpe?g|png|gif)/i.match?(request.path)
      render text: '404 Yeti Not Found', status: 404
    elsif request.xhr?
      render status: 404, nothing: true
    else
      render template: '404', layout: 'application', status: 404, formats: [:html]
    end
  end
end
