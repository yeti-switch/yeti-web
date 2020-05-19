# frozen_string_literal: true

# put this in lib/active_admin/filter_saver/controller.rb

module ActiveAdmin
  module FilterSaver
    # Extends the ActiveAdmin controller to persist resource index filters between requests.
    #
    # @author David Daniell / тιηуηυмвєяѕ <info@tinynumbers.com>
    module Controller
      extend ActiveSupport::Concern

      included do
        before_action only: [:index] do
          if request.xhr? && params.key?(:search_filter_switch)
            set_persistent_filters
          end
          if respond_to?(:save_filters?) && save_filters?
            @persistent_filter = save_filters?
            restore_search_filters
          end
          true
        end

        after_action only: [:index] do
          save_search_filters if respond_to?(:save_filters?) && save_filters?
          true
        end
      end

      def save_filters?
        !!current_admin_user.saved_filters[filter_saver_key].try!(:[], 'enabled')
      end

      private

      SAVED_FILTER_KEY = :last_search_filter

      def restore_search_filters
        filter_storage = current_admin_user.saved_filters
        if params[:clear_filters].present?
          params.delete :clear_filters
          if filter_storage.present?
            logger.info { "clearing filter storage for #{filter_saver_key}" }
            filter_storage.delete filter_saver_key
          end
          if request.xhr?
            # we were requested via an ajax post from our custom JS
            # this render will abort the request, which is ok, since a GET request will immediately follow
            current_admin_user.update_column(:saved_filters, filter_storage)
            render(json: { filters_cleared: true }) && return
          end
        elsif filter_storage.present? && params[:action].to_sym == :index && params[:q].blank? && params[:commit].blank?
          saved_filters = filter_storage[filter_saver_key]['search']
          if saved_filters.present?
            flash.now[:notice_message] = 'Filters were restored to previous values' if params[:commit].blank?
            @default_filters_present = true
            params[:q] = saved_filters
          end
        end
        current_admin_user.update_column(:saved_filters, filter_storage)
      end

      def save_search_filters
        if params[:action].to_sym == :index
          filter_storage = current_admin_user.saved_filters
          filter_storage[filter_saver_key] = {
            enabled: true,
            search: params[:q]
          }
          current_admin_user.update_column(:saved_filters, filter_storage)
        end
      end

      # Get a symbol for keying the current controller in the saved-filter session storage.
      def filter_saver_key
        # params[:controller].gsub(/\//, '_').to_sym
        # current_path = request.env['PATH_INFO']
        # current_route = Rails.application.routes.recognize_path(current_path)
        # current_route.sort.flatten.join('-').gsub(/\//, '_')
        @filter_saver_key ||= params['controller'].to_s
      end

      def set_persistent_filters
        return false unless params.key?(:search_filter_switch)

        filter_storage = current_admin_user.saved_filters
        if filter_storage[filter_saver_key].is_a?(Hash)
          filter_storage[filter_saver_key]['enabled'] = (params[:search_filter_switch].to_s == 'true')
        else
          filter_storage[filter_saver_key] = {
            enabled: (params[:search_filter_switch].to_s == 'true')
          }
        end
        current_admin_user.update_column(:saved_filters, filter_storage)
        render(json: { search_filter_switch: save_filters? }) && return
      end
    end
  end
end

ActiveAdmin.before_load do |_app|
  # Add our Extensions
  ActiveAdmin::BaseController.send :include, ActiveAdmin::FilterSaver::Controller
end
