# frozen_string_literal: true

module ActiveAdmin
  module SortingSaver
    # Persists each admin user's chosen index sort order, per resource (keyed by
    # controller name), in gui.admin_users.saved_sortings (jsonb). Opt-in per
    # resource via a padlock toggle in the index title bar — mirroring the
    # filter saver (ActiveAdmin::FilterSaver::Controller).
    #
    # The analog of saved_filters' params[:q] is params[:order] (e.g. "name_asc").
    # ActiveAdmin's apply_sorting does `params[:order] ||= active_admin_config.sort_order`,
    # so injecting a stored params[:order] in a before_action overrides the
    # per-resource default while still yielding to an explicit column-header click.
    #
    # Reading costs nothing (current_admin_user is already loaded by the session);
    # writing happens only when the order actually changes — a single-column
    # update_column with no extra SELECT.
    module Controller
      extend ActiveSupport::Concern

      included do
        before_action only: [:index] do
          if request.xhr? && params.key?(:sorting_switch)
            set_persistent_sorting
          end
          if respond_to?(:save_sorting?) && save_sorting?
            @persistent_sorting = true
            restore_sorting
          end
          true
        end

        after_action only: [:index] do
          save_sorting if respond_to?(:save_sorting?) && save_sorting?
          true
        end
      end

      def save_sorting?
        !!current_admin_user&.saved_sortings&.dig(sorting_saver_key, 'enabled')
      end

      private

      # Inject the remembered sort before the gem's apply_sorting runs — but only
      # when the user did not just click a column header (params[:order] blank).
      def restore_sorting
        return unless params[:action].to_sym == :index
        return if params[:order].present?

        stored = current_admin_user.saved_sortings.dig(sorting_saver_key, 'order')
        params[:order] = stored if stored.present?
      end

      # Remember the current sort. Skip a blank order (default/restored), and
      # write only when it actually changed.
      def save_sorting
        return unless params[:action].to_sym == :index
        return if params[:order].blank?

        store = current_admin_user.saved_sortings
        return if store.dig(sorting_saver_key, 'order') == params[:order]

        current_admin_user.update_column(
          :saved_sortings,
          store.merge(sorting_saver_key => { 'enabled' => true, 'order' => params[:order] })
        )
      end

      def sorting_saver_key
        @sorting_saver_key ||= params['controller'].to_s
      end

      # AJAX toggle from sorting_persist.js. Enabling captures the current sort
      # (or the resource default) so persistence is meaningful immediately;
      # disabling drops the entry entirely. Rendering here halts the after_action
      # that would otherwise re-persist.
      def set_persistent_sorting
        enabled = params[:sorting_switch].to_s == 'true'
        store = current_admin_user.saved_sortings
        if enabled
          order = params[:order].presence
          order ||= active_admin_config.sort_order if respond_to?(:active_admin_config)
          store[sorting_saver_key] = { 'enabled' => true, 'order' => order }
        else
          store.delete(sorting_saver_key)
        end
        current_admin_user.update_column(:saved_sortings, store)
        render(json: { sorting_switch: enabled }) && return
      end
    end
  end
end

ActiveAdmin.before_load do |_app|
  ActiveAdmin::BaseController.send :include, ActiveAdmin::SortingSaver::Controller
end
