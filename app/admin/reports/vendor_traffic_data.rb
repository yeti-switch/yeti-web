# frozen_string_literal: true

ActiveAdmin.register Report::VendorTrafficData, as: 'VendorTrafficData' do
  menu false
  actions :index
  belongs_to :vendor_traffic, parent_class: Report::VendorTraffic

  decorate_with ReportVendorTrafficDataDecorator

  config.batch_actions = false

  filter :calls_count
  filter :calls_duration
  contractor_filter :customer_id_eq, label: 'Customer', q: { q: { customer_eq: true } }

  controller do
    def scoped_collection
      parent.report_records
    end
  end

  csv do
    parent.csv_columns.map { |c| column c }
  end

  sidebar 'Vendor traffic report', priority: 0, only: :index do
    div class: :report_sidebar_info do
      attributes_table_for assigns[:vendor_traffic] do
        row :id
        row :date_start
        row :date_end
        row :vendor
        row :created_at
      end
    end
  end

  index footer_data: ->(collection) { BillingDecorator.new(collection.totals) } do
    column :customer, footer: lambda {
                                strong do
                                  'Total:'
                                end
                              }

    column :calls_count, footer: lambda {
                                   strong do
                                     text_node @footer_data[:calls_count]
                                     text_node ' calls'
                                   end
                                 }
    column :success_calls_count, footer: lambda {
                                           strong do
                                             text_node @footer_data[:success_calls_count]
                                             text_node ' calls'
                                           end
                                         }

    column :short_calls_count, footer: lambda {
                                         strong do
                                           text_node @footer_data[:short_calls_count]
                                           text_node ' calls'
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
    column :acd, &:decorated_acd
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
