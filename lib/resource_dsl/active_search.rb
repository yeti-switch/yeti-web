# frozen_string_literal: true

module ResourceDSL
  module ActiveSearch
    def search_support!
      collection_action :search, method: :get do
        data = resource_class.ransack(params[:q]).result
        result = data.map do |item|
          { id: item.id, value: item.display_name }
        end
        render json: result
      end
    end
  end
end
