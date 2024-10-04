# frozen_string_literal: true

module ActiveAdmin
  module Views
    class PaginatedCollection < ActiveAdmin::Component
      # ovverided to use pagination twice + dropdown
      #
      def build(collection, options = {})
        @collection = collection
        @params = options.delete(:params)
        @param_name = options.delete(:param_name)
        @download_links = options.delete(:download_links)
        @display_total = options.delete(:pagination_total) { true }
        @per_page = if assigns[:skip_drop_down_pagination]
                      collection.size
                    else
                      GuiConfig.per_page
                    end

        unless collection.respond_to?(:total_pages)
          raise(StandardError, 'Collection is not a paginated scope. Set collection.page(params[:page]).per(10) before calling :paginated_collection.')
        end

        build_top_pagination_panel # top pagination
        @contents = div(class: 'paginated_collection_contents')
        build_pagination_with_formats(options) # bottom pagination
        @built = true
      end

      private

      def build_top_pagination_panel
        div class: 'pagination_top' do
          build_pagination
          if @per_page.is_a?(Array) && !assigns[:skip_drop_down_pagination]
            build_per_page_select
          end
        end
      end

      def page_entries_info(options = {})
        if options[:entry_name]
          entry_name   = options[:entry_name]
          entries_name = options[:entries_name] || entry_name.pluralize
        elsif collection_is_empty?
          entry_name   = I18n.t 'active_admin.pagination.entry', count: 1, default: 'entry'
          entries_name = I18n.t 'active_admin.pagination.entry', count: 2, default: 'entries'
        else
          key = "activerecord.models.#{collection.first.class.model_name.i18n_key}"
          entry_name   = I18n.t key, count: 1,               default: collection.first.class.name.underscore.sub('_', ' ')
          entries_name = I18n.t key, count: collection.size, default: entry_name.pluralize
        end

        if @display_total
          if collection.total_pages < 2
            case collection_size
            when 0
              I18n.t('active_admin.pagination.empty',    model: entries_name)
            when 1
              I18n.t('active_admin.pagination.one',      model: entry_name)
            else
              I18n.t('active_admin.pagination.one_page', model: entries_name, n: collection.total_count)
            end
          else
            offset = collection_offset
            total  = collection.total_count
            I18n.t 'active_admin.pagination.multiple',
                   model: entries_name,
                   total:,
                   from: offset + 1,
                   to: offset + current_page_collection_size
          end
        else
          # Do not display total count, in order to prevent a `SELECT count(*)`.
          # To do so we must not call `collection.total_pages`
          offset = (collection.current_page - 1) * collection.limit_value
          I18n.t 'active_admin.pagination.multiple_without_total',
                 model: entries_name,
                 from: offset + 1,
                 to: offset + collection_size
        end
      end
    end
  end
end
