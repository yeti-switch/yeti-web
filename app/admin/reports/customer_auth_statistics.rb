# frozen_string_literal: true

ActiveAdmin.register Stats::CustomerAuthStats, as: 'Customer Auth Statistic' do
  actions :index
  menu parent: 'Reports', label: 'Customer Auth Statistic', priority: 105

  controller do
    def scoped_collection
      super.preload(:customer_auth)
    end
  end

  filter :calls_count
  filter :customer_duration
  filter :customer_price
  filter :customer_price_no_vat
  filter :duration
  filter :timestamp, as: :date_time_range
  filter :vendor_price
  filter :customer_auth, input_html: { class: 'tom-select' }

  index do
    id_column

    column :timestamp
    column 'Customer Auth' do |r|
      r.customer_auth ? auto_link(r.customer_auth) : r.customer_auth_id
    end
    column :calls_count
    column :customer_duration
    column :customer_price
    column :customer_price_no_vat
    column :duration
    column :vendor_price
  end
end
