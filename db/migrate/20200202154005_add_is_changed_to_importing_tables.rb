class AddIsChangedToImportingTables < ActiveRecord::Migration[5.2]
  def change
    t_names = [
        :import_accounts,
        :import_codec_group_codecs,
        :import_codec_groups,
        :import_contractors,
        :import_customers_auth,
        :import_destinations,
        :import_dialpeers,
        :import_disconnect_policies,
        :import_gateway_groups,
        :import_gateways,
        :import_numberlist_items,
        :import_numberlists,
        :import_rateplans,
        :import_registrations,
        :import_routing_groups
    ]

    t_names.each do |t_name|
      add_column "data_import.#{t_name}", :is_changed, :boolean
    end
  end
end
