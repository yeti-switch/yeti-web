# frozen_string_literal: true

ActiveAdmin.register Report::IntervalData, as: 'IntervalItem' do
  menu false
  actions :index

  belongs_to :report_interval_cdr, parent_class: Report::IntervalCdr

  config.batch_actions = false

  csv do
    parent.csv_columns.map { |c| column c }
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

  Report::IntervalCdr::CDR_COLUMNS.each do |key|
    next if %i[destination_id dialpeer_id vendor_id].include? key

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
