ActiveAdmin.register Report::VendorTrafficData, as: 'VendorTrafficData' do
  menu false
  actions :index
  belongs_to :vendor_traffic, parent_class: Report::VendorTraffic

  decorate_with ReportVendorTrafficDataDecorator

  config.batch_actions = false

  filter :calls_count
  filter :calls_duration
  filter :customer, as: :select, input_html: {class: 'chosen'}, collection: proc{ Contractor.where(customer: true) }

  controller do
    def scoped_collection
      parent.report_records
    end
  end

  csv do
    parent.csv_columns.map{|c| column c }
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

  index footer_data: ->(collection){ BillingDecorator.new(collection.totals) } do

    column :customer, footer: -> {
                    strong do
                      "Total:"
                    end
                  }

    column :calls_count, footer: -> do
                         strong do
                           text_node @footer_data[:calls_count]
                           text_node " calls"
                         end
                       end
    column :success_calls_count, footer: -> do
                                 strong do
                                   text_node @footer_data[:success_calls_count]
                                   text_node " calls"
                                 end
                               end

    column :short_calls_count, footer: -> do
                               strong do
                                 text_node @footer_data[:short_calls_count]
                                 text_node " calls"
                               end
                             end

    column :calls_duration, footer: -> do
                            strong do
                              @footer_data.time_format_min :calls_duration
                            end
                          end do |r|
      r.decorated_calls_duration
    end
    column :asr do |r|
      r.decorated_asr
    end
    column :acd do |r|
      r.decorated_acd
    end
    column :origination_cost, footer: -> do
                              strong do
                                @footer_data.money_format :origination_cost
                              end
                            end do |r|
      r.decorated_origination_cost
    end
    column :termination_cost, footer: -> do
                              strong do
                                @footer_data.money_format :termination_cost
                              end
                            end do |r|
      r.decorated_termination_cost
    end
    column :profit, footer: -> do
                    strong do
                      @footer_data.money_format :profit
                    end
                  end do |r|
      r.decorated_profit
    end
    column :first_call_at, footer: -> do
                           strong do
                             text_node @footer_data[:first_call_at]
                           end
                         end
    column :last_call_at, footer: -> do
                          strong do
                            text_node @footer_data[:last_call_at]
                          end
                        end

  end

end
