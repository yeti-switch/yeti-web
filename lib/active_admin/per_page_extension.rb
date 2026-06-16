# frozen_string_literal: true

module ActiveAdmin
  # Remembers each admin user's chosen per-page size, per resource (keyed by
  # controller name), in gui.admin_users.per_page (jsonb).
  #
  # Reading costs nothing: current_admin_user is already loaded by the session,
  # so dynamic_per_page just reads its in-memory hash. Writing happens only when
  # the selection actually changes — a single-column update_column, and NO extra
  # SELECT (we compare against the already-loaded value rather than re-fetching).
  #
  # Allowed values and the fallback default come from ActiveAdmin's configured
  # per-page list (config.default_per_page, sourced from yeti_web.yml's
  # admin_ui.per_page). A value not in that list falls back to the first option.
  module PerPageExtension
    extend ActiveSupport::Concern

    included do
      before_action :persist_per_page, only: :index
    end

    # ActiveAdmin's `per_page` calls this (overriding the gem's
    # `params[:per_page] || @per_page`). Returns the user's remembered size for
    # this resource. persist_per_page has already folded any ?per_page= choice
    # into the stored hash, so params are honoured through the same path.
    def dynamic_per_page
      per_page_value(stored_per_page[per_page_key])
    end

    private

    # On an index carrying ?per_page=, remember the (validated) choice for this
    # resource. Persist only when it differs from what's already stored — so a
    # normal page load with an unchanged size issues no write, and no request
    # ever issues an extra SELECT (current_admin_user is already in memory).
    def persist_per_page
      return if params[:per_page].blank? || current_admin_user.nil?

      chosen = per_page_value(params[:per_page])
      store = stored_per_page
      return if store[per_page_key] == chosen

      current_admin_user.update_column(:per_page, store.merge(per_page_key => chosen))
    end

    def stored_per_page
      current_admin_user&.per_page || {}
    end

    def per_page_key
      params[:controller].to_s
    end

    # Coerce to one of the configured per-page options, else the first (default).
    def per_page_value(value)
      options = Array.wrap(ActiveAdmin.application.default_per_page)
      options.include?(value.to_i) ? value.to_i : options.first
    end
  end
end
