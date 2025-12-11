# frozen_string_literal: true

ActiveAdmin.register_page 'Info' do
  menu parent: 'System', priority: 1
  content do
    columns do
      column do
        panel "TOP10 tables in Routing database. Full size: #{ApplicationRecord.db_size}" do
          table_for ApplicationRecord.top_tables do
            column :table do |c|
              "#{c[:table_schema]}.#{c[:table_name]}"
            end
            column :data_size
            column :total_size
          end
        end

        panel 'Build info' do
          data = {
            ui_version: Rails.application.config.app_build_info.fetch('version', 'unknown'),
            routing_version: ApplicationRecord::DB_VER,
            cdr_version: Cdr::Base::DB_VER,
            ruby: "#{RUBY_VERSION}/#{RUBY_PLATFORM}/#{RUBY_RELEASE_DATE}",
            switch_interface: ApplicationRecord::ROUTING_SCHEMA
          }
          attributes_table_for data do
            data.each do |k, v|
              row k do
                strong v
              end
            end
          end
        end

        if YetiConfig.show_config_info.present?
          panel 'Yeti-web config' do
            attributes_table_for(YetiConfig) do
              row :keep_expired_destinations_days
              row :keep_expired_dialpeers_days
              row :keep_balance_notifications_days
              row :calls_monitoring do
                attributes_table_for(YetiConfig.calls_monitoring) do
                  row :write_account_stats
                  row :write_gateway_stats
                end
              end
              row :api do
                attributes_table_for(YetiConfig.api) do
                  row :admin do
                    attributes_table_for(YetiConfig.api.admin) do
                      row :token_lifetime
                    end
                  end
                  row :customer do
                    attributes_table_for(YetiConfig.api.customer) do
                      row :token_lifetime
                      row :call_jwt_lifetime
                      row :outgoing_cdr_hide_fields
                      row :outgoing_statistics_use_customer_duration
                      row :incoming_cdr_hide_fields
                      row :incoming_statistics_use_vendor_duration
                    end
                  end
                end
              end
              row :cdr_export do
                attributes_table_for(YetiConfig.cdr_export) do
                  row :dir_path
                  row :delete_url
                end
              end
              row :role_policy do
                attributes_table_for(YetiConfig.role_policy) do
                  row :when_no_config
                  row :when_no_policy_class
                end
              end
              row :partition_remove_delay do
                attributes_table_for(YetiConfig.partition_remove_delay) do
                  row :'cdr.cdr'
                  row :'auth_log.auth_log'
                  row :'rtp_statistics.rx_streams'
                  row :'rtp_statistics.tx_streams'
                  row :'logs.api_requests'
                end
              end
              row :prometheus do
                attributes_table_for(YetiConfig.prometheus) do
                  row :enabled
                  row :default_labels do
                    YetiConfig.prometheus.default_labels.each { |key, value| div { "#{key}: #{value}" } }
                    nil
                  end
                  row :host
                end
              end
              row :sentry do
                attributes_table_for(YetiConfig.sentry) do
                  row :enabled
                  row :node_name
                  row :environment
                end
              end
              row 'versioning_disable_for_models' do
                YetiConfig.versioning_disable_for_models.each { |value| div { value } }
                nil
              end
            end
          end
        end

        if SystemInfoConfigs.loaded?
          SystemInfoConfigs.configs.each do |name, config|
            panel(name) { attributes_table_for(config, *config.members) }
          end
        else
          text_node 'No System Info'
        end
      end
      column do
        panel "TOP10 tables in CDR database. Full size: #{Cdr::Base.db_size}" do
          table_for Cdr::Base.top_tables do
            column :table do |c|
              "#{c[:table_schema]}.#{c[:table_name]}"
            end
            column :data_size
            column :total_size
          end
        end

        panel 'Replication' do
          if RsReplication.any?
            table_for(RsReplication.order('application_name')) do
              column :application_name
              column :client_addr
              column :backend_start
              column :state
            end
          else
            span do
              text_node 'No replication'
            end
          end
        end
      end
    end
  end
end
