# frozen_string_literal: true

module ResourceDSL
  module ActiveSearch
    def search_support!(search_name: :search, id_column: :id)
      collection_action search_name, method: :get do
        data = resource_class.ransack(params[:q]).result.order(:name)
        result = data.map do |item|
          { id: item[id_column], value: item.display_name }
        end
        render json: result
      end
    end
  end
end
