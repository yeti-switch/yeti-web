# frozen_string_literal: true

ActiveAdmin.register Report::CustomData, as: 'CustomItem' do
  menu false
  actions :index
  belongs_to :custom_cdr, parent_class: Report::CustomCdr
  config.batch_actions = false

  decorate_with ReportCustomDataDecorator

  # Fix ordering for columns that can be null.
  # Null values will be considered as the lowest.
  %i[agg_customer_price agg_calls_acd agg_profit].each do |col|
    order_by(col) do |order_clause|
      is_desc = order_clause.order == 'desc'
      "#{order_clause.table_column} #{order_clause.order} NULLS #{is_desc ? 'LAST' : 'FIRST'}"
    end
  end

  action_item :reports, only: :index do
    link_to 'Delete report',
            custom_cdr_path(assigns[:custom_cdr].id),
            method: :delete,
            data: { confirm: I18n.t('active_admin.delete_confirmation') },
            class: 'member_link delete_link'
  end

  sidebar 'Custom CDR Report', class: 'toggle', priority: 0 do
    div class: :report_sidebar_info do
      attributes_table_for assigns[:custom_cdr] do
        row :id
        row :completed
        row :date_start
        row :date_end
        row :filter
        row :group_by do
          content_tag :ul do
            assigns[:custom_cdr].group_by.collect { |item| concat(content_tag(:li, item)) }
          end
        end
        row :created_at
      end
    end
  end

  assoc_filter_columns = Report::CustomCdr::CDR_COLUMNS - %i[destination_id dialpeer_id customer_id vendor_id vendor_acc_id customer_acc_id]
  assoc_filter_columns.each do |key|
    filter key.to_s[0..-4].to_sym,
           if: proc { @custom_cdr.group_by_include? key },
           input_html: { class: 'chosen' }

    contractor_filter :customer_id_eq,
                      label: 'Customer',
                      path_params: { q: { customer_eq: true } },
                      if: proc { @custom_cdr.group_by_include?(:customer_id) }

    contractor_filter :vendor_id_eq,
                      label: 'Vendor',
                      path_params: { q: { vendor_eq: true } },
                      if: proc { @custom_cdr.group_by_include?(:vendor_id) }

    account_filter :customer_acc_id_eq,
                   label: 'Customer Acc',
                   path_params: { q: { contractor_customer_eq: true } },
                   if: proc { @custom_cdr.group_by_include?(:customer_acc_id) }

    account_filter :vendor_acc_id_eq,
                   label: 'Vendor Acc',
                   path_params: { q: { contractor_vendor_eq: true } },
                   if: proc { @custom_cdr.group_by_include?(:vendor_acc_id) }
  end

  controller do
    def scoped_collection
      parent.report_records
    end
  end

  filter :agg_calls_count
  filter :agg_calls_duration
  filter :agg_successful_calls_count
  filter :agg_short_calls_count
  filter :agg_uniq_calls_count
  filter :agg_calls_acd
  filter :agg_asr_origination
  filter :agg_asr_termination
  filter :agg_customer_price
  filter :agg_vendor_price
  filter :agg_profit

  csv do
    parent.csv_columns.map do |column_name, attribute_name|
      column(column_name, &attribute_name)
    end
  end

  index footer_data: ->(collection) { BillingDecorator.new(collection.totals) } do
    assigns[:custom_cdr].auto_columns.each do |(column_name, attribute_name)|
      column(column_name, &attribute_name)
    end

    column :calls, sortable: :agg_calls_count, footer: lambda {
                                                         strong do
                                                           text_node @footer_data.agg_calls_count.to_s
                                                         end
                                                       }, &:agg_calls_count
    column :successful_calls, sortable: :agg_successful_calls_count, footer: lambda {
      strong do
        text_node @footer_data.agg_successful_calls_count.to_s
      end
    }, &:agg_successful_calls_count

    column :short_calls, sortable: :agg_short_calls_count, footer: lambda {
      strong do
        text_node @footer_data.agg_short_calls_count.to_s
      end
    }, &:agg_short_calls_count

    column :uniq_calls, sortable: :agg_uniq_calls_count, footer: lambda {
      strong do
        text_node @footer_data.agg_uniq_calls_count.to_s
      end
    }, &:agg_uniq_calls_count

    column :calls_duration, sortable: :agg_calls_duration, footer: lambda {
      strong do
        @footer_data.time_format_min :agg_calls_duration
      end
    }, &:decorated_agg_calls_duration

    column :customer_calls_duration, sortable: :agg_customer_calls_duration, footer: lambda {
      strong do
        @footer_data.time_format_min :agg_customer_calls_duration
      end
    }, &:decorated_agg_customer_calls_duration

    column :vendor_calls_duration, sortable: :agg_vendor_calls_duration, footer: lambda {
      strong do
        @footer_data.time_format_min :agg_vendor_calls_duration
      end
    }, &:decorated_agg_vendor_calls_duration

    column :acd, sortable: :agg_calls_acd, footer: lambda {
      strong do
        @footer_data.time_format_min :agg_acd
      end
    }, &:decorated_agg_calls_acd

    column :asr_origination, sortable: :agg_asr_origination, &:decorated_agg_asr_origination
    column :asr_termination, sortable: :agg_asr_termination, &:decorated_agg_asr_termination
    column :origination_cost, sortable: :agg_customer_price, footer: lambda {
      strong do
        @footer_data.money_format :agg_customer_price
      end
    }, &:decorated_agg_customer_price

    column :origination_cost_no_vat, sortable: :agg_customer_price_no_vat, footer: lambda {
      strong do
        @footer_data.money_format :agg_customer_price_no_vat
      end
    }, &:decorated_agg_customer_price_no_vat

    column :termination_cost, sortable: :agg_vendor_price, footer: lambda {
                                                                     strong do
                                                                       @footer_data.money_format :agg_vendor_price
                                                                     end
                                                                   }, &:decorated_agg_vendor_price

    column :profit, sortable: :agg_profit, footer: lambda {
      strong do
        @footer_data.money_format :agg_profit
      end
    }, &:decorated_agg_profit
  end
end
