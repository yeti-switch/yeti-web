# frozen_string_literal: true

ActiveAdmin.register Report::CustomerTrafficDataByDestination, as: 'CustomerTrafficDataByDestination' do
  menu false
  actions :index
  belongs_to :customer_traffic, parent_class: Report::CustomerTraffic

  config.batch_actions = false

  filter :calls_count
  filter :calls_duration
  filter :destination_prefix
  filter :dst_country_id, label: 'Country', as: :select, input_html: { class: 'chosen' }, collection: proc { System::Country.collection } ## TODO Why dst_country_id????
  filter :dst_network_id, label: 'Network', as: :select, input_html: { class: 'chosen' }, collection: proc { System::Network.collection }

  decorate_with ReportCustomerTrafficByDestinationDecorator

  controller do
    def scoped_collection
      parent.report_records_by_destination
      # super.report_records
    end
  end

  # TODO use dedicated decorators for CSV data or show measurement units in header
  csv do
    column :destination_prefix
    column :country
    column :network
    column :calls_count
    column :success_calls_count
    column :short_calls_count
    column :calls_duration
    column :customer_calls_duration
    column :vendor_calls_duration
    column :asr
    column :acd
    column :origination_cost
    column :termination_cost
    column :profit
    column :first_call_at
    column :last_call_at
  end

  action_item :by_vendors, only: :index do
    link_to('By vendors', customer_traffic_customer_traffic_data_by_vendors_path(assigns[:customer_traffic].id))
  end

  action_item :by_destinations_vendor, method: :get do
    link_to('By vendors and destinations', customer_traffic_customer_traffic_data_fulls_path(assigns[:customer_traffic].id))
  end

  sidebar 'Customer traffic report', priority: 0, only: :index do
    div class: :report_sidebar_info do
      attributes_table_for assigns[:customer_traffic] do
        row :id
        row :completed
        row :date_start
        row :date_end
        row :customer
        row :created_at
      end
    end
  end

  index footer_data: ->(collection) { BillingDecorator.new(collection.totals) } do
    column :destination_prefix,
           footer: lambda {
             strong do
               'Total:'
             end
           }

    column :country, sortable: 'dst_country_id'
    column :network, sortable: 'dst_network_id'

    column :calls_count, footer: lambda {
                                   strong do
                                     text_node @footer_data[:calls_count]
                                   end
                                 }
    column :success_calls_count, footer: lambda {
                                           strong do
                                             text_node @footer_data[:success_calls_count]
                                           end
                                         }

    column :short_calls_count, footer: lambda {
                                         strong do
                                           text_node @footer_data[:short_calls_count]
                                         end
                                       }

    column :calls_duration, footer: lambda {
                                      strong do
                                        @footer_data.time_format_min :calls_duration
                                      end
                                    }, &:decorated_calls_duration

    column :customer_calls_duration, footer: lambda {
      strong do
        @footer_data.time_format_min :customer_calls_duration
      end
    }, &:decorated_customer_calls_duration

    column :vendor_calls_duration, footer: lambda {
      strong do
        @footer_data.time_format_min :vendor_calls_duration
      end
    }, &:decorated_vendor_calls_duration

    column :asr, &:decorated_asr
    column :acd, footer: lambda {
      strong do
        @footer_data.time_format_min :agg_acd
      end
    }, &:decorated_acd
    column :origination_cost, footer: lambda {
                                        strong do
                                          @footer_data.money_format :origination_cost
                                        end
                                      }, &:decorated_origination_cost
    column :termination_cost, footer: lambda {
                                        strong do
                                          @footer_data.money_format :termination_cost
                                        end
                                      }, &:decorated_termination_cost
    column :profit, footer: lambda {
                              strong do
                                @footer_data.money_format :profit
                              end
                            }, &:decorated_profit
    column :first_call_at, footer: lambda {
                                     strong do
                                       text_node @footer_data[:first_call_at]
                                     end
                                   }
    column :last_call_at, footer: lambda {
                                    strong do
                                      text_node @footer_data[:last_call_at]
                                    end
                                  }
  end
end
