# frozen_string_literal: true

ActiveAdmin.register Report::CustomData, as: 'CustomItem' do
  menu false
  actions :index
  belongs_to :custom_cdr, parent_class: Report::CustomCdr
  config.batch_actions = false

  decorate_with ReportCustomDataDecorator

  action_item :reports, only: :index do
    link_to 'Delete report', custom_cdr_path(assigns[:custom_cdr].id), method: :delete,
                                                                       data: { confirm: I18n.t('active_admin.delete_confirmation') }, class: 'member_link delete_link'
  end

  sidebar 'Custom CDR Report', class: 'toggle', priority: 0 do
    div class: :report_sidebar_info do
      attributes_table_for assigns[:custom_cdr] do
        row :id
        row :date_start
        row :date_end
        row :filter
        row :group_by do
          content_tag :ul do
            assigns[:custom_cdr].group_by_arr.collect { |item| concat(content_tag(:li, item)) }
          end
        end
        row :created_at
      end
    end
  end

  Report::CustomCdr::CDR_COLUMNS.each do |key|
    next if %i[destination_id dialpeer_id].include? key

    filter key.to_s[0..-4].to_sym, if: proc {
      @custom_cdr.group_by_include? key
    }, input_html: { class: 'chosen' }
  end

  controller do
    def scoped_collection
      parent.report_records
    end
  end

  filter :agg_calls_count
  filter :agg_calls_duration
  filter :agg_calls_acd
  filter :agg_asr_origination
  filter :agg_asr_termination
  filter :agg_customer_price
  filter :agg_vendor_price
  filter :agg_profit

  csv do
    parent.csv_columns.map { |c| column c }
  end

  index footer_data: ->(collection) { BillingDecorator.new(collection.totals) } do
    assigns[:custom_cdr].auto_columns.each do |col|
      column col
    end

    column :calls_count, sortable: :agg_calls_count, footer: lambda {
                                                               strong do
                                                                 text_node @footer_data.agg_calls_count.to_s
                                                                 text_node ' calls'
                                                               end
                                                             }, &:agg_calls_count

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

    column :profit, footer: lambda {
      strong do
        @footer_data.money_format :agg_profit
      end
    }, &:decorated_agg_profit
  end
end
