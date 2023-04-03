# frozen_string_literal: true

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
      Importing::RoutingGroup,
      Importing::RoutingTagDetectionRule
    ].freeze

    def acts_as_import(options)
      skip_columns = options.delete(:skip_columns) || []

      options = {
        resource_class: config.resource_class,
        resource_label: config.resource_label,
        template: 'shared/import',
        validate: false,
        batch_size: 1000,
        headers_rewrites: {
          'Id' => 'o_id'
        }
      }.merge(options)

      options[:template_object] = Importing::Model.new(
        # "proc" prevents error on `rake db:structure:dump`
        csv_options: { col_sep: ',', row_sep: nil, quote_char: nil }
      )

      options[:back] = proc do
        active_admin_config.namespace.resource_for(options[:resource_class]).route_collection_path
      end

      options[:before_batch_import] = lambda do |importer|
        columns = options[:resource_class].column_names
        # all foreign_key should be skipped, import uses "[foregin_key]_name" columns
        belongs_to_columns = options[:resource_class].reflect_on_all_associations(:belongs_to).map(&:foreign_key)
        columns = columns - belongs_to_columns - skip_columns.map(&:to_s)
        importer.batch_slice_columns(columns)
      end

      if options[:resource_class].respond_to?(:after_import_hook)
        options[:after_import] = proc { |_importer|
          options[:resource_class].after_import_hook
        }
      end

      active_admin_import options

      # we don't want to create new import session if it already exists
      # before_action only: [:import] do
      #   flash[:notice] = 'Import in progress'
      #   if Importing::ImportingDelayedJob.jobs?
      #     redirect_back(fallback_location: root_path) and return
      #   end
      #   if options[:resource_class].any?
      #     flash[:notice] = 'Now your preview data is ready to be imported. Choose one of the actions above'
      #     redirect_back fallback_location: root_path
      #   end
      # end

      before_action only: [:import] do
        # if Importing::ImportingDelayedJob.jobs?
        #   raise ApplicationController::ImportDisabled.new('Import in progress')
        # end
        pending_import = REGISTERED_IMPORTS.detect(&:any?)
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
