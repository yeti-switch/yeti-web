# frozen_string_literal: true

ActiveAdmin.register Report::IntervalData, as: 'IntervalItem' do
  menu false
  actions :index

  belongs_to :report_interval_cdr, parent_class: Report::IntervalCdr

  config.batch_actions = false

  csv do
    parent.csv_columns.map do |column_name, attribute_name|
      column(column_name, &attribute_name)
    end
  end

  sidebar 'Interval CDR Report', class: 'toggle', priority: 0 do
    div class: :report_sidebar_info do
      attributes_table_for assigns[:report_interval_cdr] do
        row :id
        row :completed
        row :date_start
        row :date_end
        row :interval_length
        row :filter
        row :group_by do
          content_tag :ul do
            assigns[:report_interval_cdr].group_by&.collect { |item| concat(content_tag(:li, item)) }
          end
        end
        row :aggregation_function
        row :aggregate_by
        row :created_at
      end
    end
  end

  filter :id
  filter :timestamp

  contractor_filter :customer_id,
                    label: 'Customer',
                    path_params: { q: { customer_eq: true, ordered_by: :name } },
                    if: proc { parent.group_by.include?('customer_id') }
  contractor_filter :vendor_id,
                    label: 'Vendor',
                    path_params: { q: { vendor_eq: true, ordered_by: :name } },
                    if: proc { parent.group_by.include?('vendor_id') }

  with_options as: :select, input_html: { class: :chosen } do |f|
    f.filter :rateplan_id, if: proc { parent.group_by.include?('rateplan_id') }
    f.filter :routing_group_id, if: proc { parent.group_by.include?('routing_group_id') }
    f.filter :orig_gw_id, if: proc { parent.group_by.include?('orig_gw_id') }
    f.filter :term_gw_id, if: proc { parent.group_by.include?('term_gw_id') }
    f.filter :customer_auth_id, if: proc { parent.group_by.include?('customer_auth_id') }
    f.account_filter :vendor_acc_id, label: 'Vendor acc', if: proc { parent.group_by.include?('vendor_acc_id') }
    f.account_filter :customer_acc_id, label: 'Customer acc', if: proc { parent.group_by.include?('customer_acc_id') }
    f.filter :vendor_invoice_id, if: proc { parent.group_by.include?('vendor_invoice_id') }
    f.filter :customer_invoice_id, if: proc { parent.group_by.include?('customer_invoice_id') }
    f.filter :node_id, if: proc { parent.group_by.include?('node_id') }
    f.filter :pop_id, if: proc { parent.group_by.include?('pop_id') }
    f.filter :dst_country_id, if: proc { parent.group_by.include?('dst_country_id') }
    f.filter :dst_network_id, if: proc { parent.group_by.include?('dst_network_id') }
    f.filter :disconnect_initiator_id, if: proc { parent.group_by.include?('disconnect_initiator_id') },
                                       collection: proc { Cdr::Cdr::DISCONNECT_INITIATORS.invert }
  end

  Report::IntervalCdr::CDR_COLUMNS.each do |key|
    next if key.to_s.end_with?('_id')

    filter key.to_s[0..-4].to_sym, if: proc {
      @report_interval_cdr.group_by_include? key
    }
  end
  filter :aggregated_value

  controller do
    def scoped_collection
      parent.report_records
    end
  end

  index do
    column :id
    column :timestamp
    assigns[:report_interval_cdr].auto_columns.each do |(column_name, attribute_name)|
      column(column_name, &attribute_name)
    end
    column assigns[:report_interval_cdr].aggregation, :aggregated_value
  end
end
