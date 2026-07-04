# frozen_string_literal: true

ActiveAdmin.register Billing::Currency, as: 'Currency' do
  menu parent: %w[Billing Settings], label: 'Currencies', priority: 101

  decorate_with Billing::CurrencyDecorator

  actions :index, :show, :new, :create, :edit, :update
  config.batch_actions = false # no destroy action → the default batch Delete is hidden anyway

  acts_as_audit
  acts_as_safe_destroy
  acts_as_export :id,
                 :name,
                 :rate,
                 [:rate_provider, proc { |row| row.rate_provider&.name }]

  filter :id
  filter :name
  filter :rate
  filter :rate_provider_id_eq, as: :select, label: 'Rate provider', input_html: { class: 'tom-select' }, collection: Billing::CurrencyRateProvider.all

  index do
    selectable_column
    id_column
    actions
    column :name
    column :rate
    column :rate_provider
  end

  show do
    attributes_table do
      row :id
      row :name
      row :rate
      row :rate_provider
    end
  end

  permit_params :name, :rate, :rate_provider_id

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs do
      f.input :name, as: :select, collection: Billing::Currency::NAMES.map { |code, desc| ["#{code} - #{desc}", code] }, input_html: { class: 'tom-select' }
      f.input :rate, input_html: { min: 0 }
      f.input :rate_provider_id, as: :select, input_html: { class: 'tom-select' }, collection: Billing::CurrencyRateProvider.all
    end
    f.actions
  end
end
