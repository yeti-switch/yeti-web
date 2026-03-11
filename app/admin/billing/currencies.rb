# frozen_string_literal: true

ActiveAdmin.register Billing::Currency, as: 'Currency' do
  menu parent: %w[Billing Settings], label: 'Currencies', priority: 101

  decorate_with Billing::CurrencyDecorator

  acts_as_audit
  acts_as_safe_destroy
  acts_as_export :id,
                 :name,
                 :rate

  filter :id
  filter :name
  filter :rate

  index do
    selectable_column
    id_column
    actions
    column :name
    column :rate
  end

  show do
    attributes_table do
      row :id
      row :name
      row :rate
    end
  end

  permit_params :name, :rate

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs do
      f.input :name, as: :select, collection: Billing::Currency::NAMES.map { |code, desc| ["#{code} - #{desc}", code] }, input_html: { class: 'tom-select' }
      f.input :rate, input_html: { min: 0 }
    end
    f.actions
  end
end
