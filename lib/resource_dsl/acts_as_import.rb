module ResourceDSL
  module ActsAsImport

    REGISTERED_IMPORTS = [
        Importing::Dialpeer,
        Importing::Account,
        Importing::CodecGroup,
        Importing::CodecGroupCodec,
        Importing::Contractor,
        Importing::CustomersAuth,
        Importing::Destination,
        Importing::Dialpeer,
        Importing::DisconnectPolicy,
        Importing::Gateway,
        Importing::GatewayGroup,
        Importing::Rateplan,
        Importing::Registration,
        Importing::RoutingGroup
    ]

    def acts_as_import(options)
      options= {
          resource_class: config.resource_class,
          resource_label: config.resource_label,
          template: "shared/import",
          validate: false,
          batch_size: 1000,
          headers_rewrites: {
              'Id' => 'o_id'
          }
      }.merge(options)

      options[:template_object] = Importing::Model.new(
          # "proc" prevents error on `rake db:structure:dump`
          unique_columns_proc: proc { options[:resource_class].import_attributes },
          csv_options: {col_sep: ",", row_sep: nil, quote_char: nil}
      )

      options[:back] = proc { config.namespace.resource_for(options[:resource_class]).route_collection_path }

      options[:after_import] = proc { |importer|
        unique_columns = []
        if importer.model.respond_to?(:unique_columns_values)
          unique_columns = importer.model.unique_columns_values.reject(&:blank?).map(&:to_sym)
        end
        options[:resource_class].after_import_hook(unique_columns)

      } if options[:resource_class].respond_to?(:after_import_hook)

      active_admin_import options

      # we don't want to create new import session if it already exists
      # before_filter only: [:import] do
      #   flash[:notice] = 'Import in progress'
      #   if Importing::ImportingDelayedJob.jobs?
      #     redirect_to :back and return
      #   end
      #   if options[:resource_class].any?
      #     flash[:notice] = 'Now your preview data is ready to be imported. Choose one of the actions above'
      #     redirect_to :back
      #   end
      # end

      before_filter only: [:import] do
        # if Importing::ImportingDelayedJob.jobs?
        #   raise ApplicationController::ImportDisabled.new('Import in progress')
        # end
        pending_import = REGISTERED_IMPORTS.detect {|r| r.any? }
        if pending_import
          raise ApplicationController::ImportPending.new(
              active_admin_config.namespace.resource_for(pending_import).route_collection_path,
              I18n.t('flash.importing.pending')
          )
        end
      end


    end
  end
end

