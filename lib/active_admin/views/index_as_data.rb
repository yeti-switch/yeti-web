module ActiveAdmin
  module Views
    class IndexAsData < ActiveAdmin::Component

      def self.index_name
         "data"
      end

      def build(page_presenter, collection)
        @page_presenter = page_presenter
        @collection = collection

        instance_exec(@collection, &@page_presenter.block)
      end

    end
  end
end