# frozen_string_literal: true

module ResourceDSL
  module ActiveSearch
    def search_support!(search_name: :search, id_column: :id, order_by: :name)
      collection_action search_name, method: :get do
        scope = resource_class.ransack(params[:q]).result
        scope = scope.order(order_by) unless order_by.nil?
        result = scope.map do |item|
          { id: item[id_column], value: item.display_name }
        end
        render json: result
      end
    end
  end
end
