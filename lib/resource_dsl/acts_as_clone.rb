# frozen_string_literal: true

module ResourceDSL
  module ActsAsClone
    def acts_as_clone(links: [], duplicates: [])
      before_action only: [:new] do
        copy_resource(links: links, duplicates: duplicates) if params[:from].present?
      end

      controller do
        protected

        def copy_resource(links:, duplicates:)
          from = active_admin_config.resource_class.find(params[:from])
          resource = BuildRecordCopy.call(from: from, duplicates: duplicates, links: links)
          set_resource_ivar(resource)
        end
      end

      action_item :copy, only: %i[show edit] do
        if authorized?(:create, resource) && (!resource.respond_to?(:live?) || resource.live?)
          link_to 'Copy', action: :new, from: resource.id
        end
      end
    end

    def acts_as_clone_with_helper(opts)
      acts_as_clone

      action_item :copy_with_relations, only: %i[show edit] do
        if authorized?(:create, resource) && (!resource.respond_to?(:live?) || resource.live?)
          link_to(opts[:name],  url_for(controller: active_admin_resource_for(opts[:helper]).route_collection_path, action: 'new', from: resource.id))
        end
      end
    end

    def act_as_clone_helper_for(klass)
      controller do
        protected

        def fill_resource(klass)
          resource = scoped_collection.new
          @source_object ||= klass.find(params[:from])
          attributes = begin
                         @source_object.attributes
                       rescue StandardError
                         {}
                       end
          attributes
            .reject { |k| %w[uuid external_id].include?(k) }
            .map { |k, v| resource.send("#{k}=", v) }
          set_resource_ivar(resource)
        end
      end

      before_action only: %i[new create] do
        fill_resource(klass) if params[:from].present?
      end
    end
  end
end
