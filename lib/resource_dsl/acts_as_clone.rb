module ResourceDSL

  module ActsAsClone

    def acts_as_clone(*dup_methods)

      before_filter only: [:new] do
        if params[:from].present?
          copy_resource(dup_methods)
        end
      end

      controller do

        protected

        def copy_resource(dup_methods)
          from =  active_admin_config.resource_class.find(params[:from])
          attributes = from.dup.attributes rescue {}
          resource = scoped_collection.new
          dup_methods.each do |m|
            res = from.send(m).dup
            if res.respond_to?(:map)
              res = res.map { |r| r.dup }
            else
              res = res.dup
            end
            attributes[m] = res
          end
          attributes.map { |k, v|
            resource.send("#{k}=", v)
          }

          set_resource_ivar(resource)
        end
      end


      action_item :copy, only: [:show, :edit] do
        if can? :create, resource and (!resource.respond_to?(:live?) or resource.live?)
          link_to "Copy", action: :new, from: resource.id
        end
      end

    end

    def acts_as_clone_with_helper(opts)
      acts_as_clone

      action_item :copy_with_relations, only: [:show, :edit] do
        if can? :create, resource and (!resource.respond_to?(:live?) or resource.live?)
          link_to(opts[:name],  url_for(controller: active_admin_resource_for(opts[:helper]).route_collection_path, action: "new", from: resource.id))
        end
      end
    end

    def act_as_clone_helper_for(klass)

      controller do

        protected

        def fill_resource(klass)
          resource = scoped_collection.new
          @source_object ||= klass.find(params[:from])
          attributes = @source_object.attributes rescue {}
          attributes
            .reject { |k| k == 'uuid' } # TODO: improve this
            .map { |k, v| resource.send("#{k}=", v) }
          set_resource_ivar(resource)
        end

      end

      before_filter only: [:new, :create] do
        if params[:from].present?
          fill_resource(klass)
        end
      end

    end

  end

end
