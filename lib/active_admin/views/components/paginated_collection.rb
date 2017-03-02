module ActiveAdmin
  module Views

    class PaginatedCollection < ActiveAdmin::Component

      #ovverided to use pagination twice + dropdown
      #
      def build(collection, options = {})

        @collection = collection
        @param_name = options.delete(:param_name)
        @download_links = options.delete(:download_links)
        @display_total = options.delete(:pagination_total) { true }
        if assigns[:skip_drop_down_pagination]
          @per_page = collection.size
        else
          @per_page = GuiConfig.per_page
        end

        unless collection.respond_to?(:num_pages)
          raise(StandardError, "Collection is not a paginated scope. Set collection.page(params[:page]).per(10) before calling :paginated_collection.")
        end

        build_top_pagination_panel #top pagination
        @contents = div(class: "paginated_collection_contents")
        build_pagination_with_formats(options) # bottom pagination
        @built = true
      end


      protected

      def build_top_pagination_panel

        div class: 'pagination_top' do
          build_pagination
          if @per_page.is_a?(Array) && !assigns[:skip_drop_down_pagination]
            build_per_page_select
          end
        end

      end

    end
  end
end
