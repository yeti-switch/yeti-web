ActiveAdmin.register System::CdrConfig do
  menu parent: "System",  priority: 121, label: "CDR writer configuration"
  actions :index,:show,:edit,:update
  config.batch_actions = false
  config.filters = false

  acts_as_audit

  controller do
    def index
      redirect_to system_cdr_config_path(1)
    end
  end

  permit_params :call_duration_round_mode_id

  show do |config|
    attributes_table do
      row :call_duration_round_mode
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      f.input :call_duration_round_mode, hint: I18n.t('hints.system.cdr_config.call_duration_round_mode')
    end
    f.actions
  end

end
