module ActiveAdmin
  module PerPageExtension

    extend ActiveSupport::Concern

    included do
      before_action only: [:index] do
        setup_pagination_dropdown
      end
    end

    def dynamic_per_page
      per_page_from_user
    end

    def per_page_from_user
      per_page_value(current_admin_user.per_page[request_per_page_key])
    end
    #
    def setup_pagination_dropdown
      per_page_storage = current_admin_user.per_page
      per_page_storage[request_per_page_key] = per_page_value(params[:per_page].to_i, per_page_from_user)
      current_admin_user.update_column(:per_page, per_page_storage) if per_page_changed
    end
    #
    def per_page_value(value, default = GuiConfig.per_page.first)
      Array.wrap(GuiConfig.per_page).include?(value.to_i) ? value.to_i : default.to_i
    end
    #
    def request_per_page_key
      @request_per_page_key ||=  params['controller'].to_s
    end

    def per_page_changed
      admin_user_db = AdminUser.find(current_admin_user.id)
      admin_user_db.per_page[request_per_page_key]!= per_page_from_user
    end

  end
end
