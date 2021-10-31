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
