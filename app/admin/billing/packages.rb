ActiveAdmin.register Billing::Package do
  menu parent: "Billing", priority: 22

  config.batch_actions = false

  permit_params :name, :price, :billing_interval, :allow_minutes_aggregation

  acts_as_export :id, :name, :price, :billing_interval, :allow_minutes_aggregation


  filter :id
  filter :name
  filter :prices
  filter :billing_interval
  filter :allow_minutes_aggregation

  index do
    id_column
    actions
    column :name
    column :price
    column :billing_interval
    column :allow_minutes_aggregation
  end


  form do |f|
    f.inputs form_title do
      f.input :name
      f.input :price
      f.input :billing_interval
      f.input :allow_minutes_aggregation
    end
    f.actions
  end

  show do |s|
    tabs do
      tab "Package" do
        attributes_table_for s do
          row :id
          row :name
          row :price
          row :billing_interval
          row :allow_minutes_aggregation
        end
      end
      tab "configuration" do
        table_for resource.configurations do
          column :prefix
          column :amount
        end
      end


    end
  end


end
