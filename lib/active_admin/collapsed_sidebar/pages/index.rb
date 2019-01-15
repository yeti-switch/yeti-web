# frozen_string_literal: true

module ActiveAdmin
  module CollapsedSidebar
    module Pages
      class Index < ActiveAdmin::Views::Pages::Index
        def main_content_classes
          classes = super
          classes << 'with_default_filters' if assigns.fetch(:default_filters_present, false)
          classes << 'with_persistent_filters' if assigns.fetch(:persistent_filter, false)
          classes
        end
      end
    end
  end
end

ActiveAdmin::ViewFactory.register index_page: ActiveAdmin::CollapsedSidebar::Pages::Index
