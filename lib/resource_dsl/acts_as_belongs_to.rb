# frozen_string_literal: true

module ResourceDSL
  module ActsAsBelongsTo
    def acts_as_belongs_to(parent_name, options = {})
      options.assert_valid_keys(
        :route_name, :collection_name, :param,
        :parent_class, :class_name,
        :instance_name, :finder,
        :polymorphic, :singleton,
        :optional
      )
      config_opts = options.merge parent_name: parent_name
      config_opts[:param] ||= :"#{parent_name}_id"

      belongs_to parent_name, options

      controller do
        define_method(:belongs_to_opts) do
          return @belongs_to_options if defined?(@belongs_to_options)

          @belongs_to_options = OpenStruct.new(config_opts)
        end

        def resource_parent
          if instance_variable_defined?("@#{belongs_to_opts.parent_name}")
            instance_variable_get("@#{belongs_to_opts.parent_name}")
          end
        end

        def belongs_to_param
          if belongs_to? && (belongs_to_config.required? || resource_parent.present?)
            belongs_to_opts.param
          end
        end

        def path_method_for(opts)
          route_name = belongs_to_opts.route_name.to_s
          route_name = route_name.singularize unless opts.fetch(:collection, false)
          # namespace = opts[:namespace] || :admin
          namespace = ActiveAdmin.application.default_namespace&.to_s&.sub(%r{^/}, '')
          parent_name = resource_parent.present? ? belongs_to_opts.parent_name : nil
          [
            opts[:action], namespace, parent_name, route_name, :path
          ].reject(&:blank?).map(&:to_s).join('_')
        end

        def path_for(link_opts, *args)
          options = args.extract_options!
          if resource_parent.present?
            options[belongs_to_opts.param] = resource_parent.id
          end
          args << options
          public_send(path_method_for(link_opts), *args)
        end

        def new_resource_path(opts = {})
          path_for({ action: :new }, opts)
        end

        def collection_path(opts = {})
          path_for({ collection: true }, opts)
        end

        def resource_path(id_or_record, opts = {})
          path_for({}, id_or_record, opts)
        end

        def edit_resource_path(id_or_record, opts = {})
          path_for({ action: :edit }, id_or_record, opts)
        end

        def resource_collection_name
          belongs_to_opts.collection_name || super
        end

        def skip_resource_params
          []
        end

        def resource_params
          res_params = super.first
          res_params = res_params.except(*skip_resource_params)
          [res_params]
        end

        if method_defined? :create
          def create
            super do |success, _|
              success.html { redirect_to resource_path(resource.id) }
            end
          end
        end

        if method_defined? :update
          def update
            super do |success, _|
              success.html { redirect_to resource_path(resource.id) }
            end
          end
        end

        if method_defined? :destroy
          def destroy
            super do |success, _|
              success.html { redirect_to collection_path }
            end
          end
        end
      end
    end
  end
end
