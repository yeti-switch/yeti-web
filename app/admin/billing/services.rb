# frozen_string_literal: true

ActiveAdmin.register Billing::Service, as: 'Services' do
  menu parent: 'Billing', label: 'Services', priority: 30

  controller do
    def create_resource(object)
      object.save
    rescue Billing::Provisioning::Errors::Error => e
      object.errors.add(:base, e.message)
      false
    rescue SocketError => e
      capture_exception(e)
      object.errors.add(:base, e.message)
      false
    end

    def destroy_resource(object)
      object.destroy
    rescue Billing::Provisioning::PhoneSystems::PhoneSystemsApiClient::NotFoundError => _e
      # continue deleting Service in Yeti side because record already deleted from Phone Systems server
      flash[:warning] = 'The Customer already deleted from the Phone Systems server'
      # perform delete request without the Billing::Provisioning::Base#before_destroy callback
      object.delete
    rescue Billing::Provisioning::Errors::Error => e
      object.errors.add(:base, e.message)
      false
    rescue SocketError => e
      capture_exception(e)
      object.errors.add(:base, e.message)
      false
    end
  end

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_export :id,
                 :name,
                 :type_id,
                 :variables

  decorate_with ServiceDecorator

  includes :type, :account

  filter :id
  filter :created_at
  filter :name
  account_filter :account_id_eq
  filter :type_id,
         as: :select,
         input_html: { class: 'chosen' },
         collection: proc { Billing::ServiceType.all }
  filter :renew_period_id,
         as: :select,
         input_html: { class: 'chosen' },
         collection: proc { Billing::Service::RENEW_PERIODS.invert }
  filter :initial_price
  filter :renew_price
  filter :renew_at

  scope :all
  scope :ready_for_renew
  scope :one_time_services

  index do
    selectable_column
    id_column
    actions
    column :name
    column :account
    column :type
    column :variables, :variables_json
    column :state, :state_badge
    column :initial_price
    column :renew_price
    column :created_at
    column :renew_at
    column :renew_period
    column :uuid
  end

  show do
    columns do
      column do
        attributes_table do
          row :id
          row :uuid
          row :name
          row :account
          row :type
          row :state, &:state_badge
          row :initial_price
          row :renew_price
          row :created_at
          row :renew_at
          row :renew_period
          row :transactions do
            link_to resource.transactions.count,
                    transactions_path(q: { service_id_eq: resource.id, account_id_eq: resource.account_id })
          end
        end
      end
      column do
        panel 'Variables' do
          pre code JSON.pretty_generate(resource.variables)
        end
      end
    end
  end

  permit_params :name, :account_id, :type_id, :variables_json, :initial_price, :renew_price, :renew_at, :renew_period_id

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs do
      f.input :name

      if f.object.new_record?
        f.account_input :account_id
        f.input :type_id,
                as: :select,
                input_html: { class: 'chosen' },
                collection: Billing::ServiceType.all
      end

      f.input :variables_json, label: 'Variables', as: :text

      if f.object.new_record?
        f.input :initial_price
      end

      f.input :renew_price

      if f.object.new_record?
        f.input :renew_at, as: :date_time_picker
        f.input :renew_period_id,
                as: :select,
                input_html: { class: 'chosen' },
                include_blank: Billing::Service::RENEW_PERIOD_EMPTY,
                collection: Billing::Service::RENEW_PERIODS.invert
      end
    end
    f.actions
  end
end
