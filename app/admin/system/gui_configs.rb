# frozen_string_literal: true

ActiveAdmin.register GuiConfig do
  menu parent: 'System', priority: 120, label: 'Global configuration'
  actions :index, :show, :edit, :update
  config.batch_actions = false
  config.filters = false

  acts_as_audit

  controller do
    def index
      redirect_to gui_config_path(1)
    end
  end

  permit_params *GuiConfig::SETTINGS_NAMES

  show do |_config|
    attributes_table do
      GuiConfig::SETTINGS_NAMES.each do |name|
        row name
      end
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      GuiConfig::SETTINGS_NAMES.each do |name|
        f.input name
      end
    end
    f.actions
  end
end
