# frozen_string_literal: true

module ResourceDSL
  module ActsAsClone
    def acts_as_clone(*dup_methods)
      before_action only: [:new] do
        copy_resource(dup_methods) if params[:from].present?
      end

      controller do
        protected

        def copy_resource(dup_methods)
          from = active_admin_config.resource_class.find(params[:from])
          attributes = begin
                         from.dup.attributes
                       rescue StandardError
                         {}
                       end
          resource = scoped_collection.new
          dup_methods.each do |m|
            res = from.send(m).dup
            res = if res.respond_to?(:map)
                    res.map(&:dup)
                  else
                    res.dup
                  end
            attributes[m] = res
          end
          attributes.map do |k, v|
            resource.send("#{k}=", v)
          end

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
            .reject { |k| k == 'uuid' or k == 'external_id' } # TODO: improve this
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
