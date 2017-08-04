ActiveAdmin.register System::LnpResolver do
  actions :all
  menu parent: "System", label: "LNP resolvers", priority: 130
  config.batch_actions = false
  permit_params :name, :address, :port

  filter :id
  filter :name

  index do
    id_column
    column :name
    column :address
    column :port
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      f.input :name, hint: I18n.t('hints.system.lnp_resolver.name')
      f.input :address, hint: I18n.t('hints.system.lnp_resolver.address')
      f.input :port, hint: I18n.t('hints.system.lnp_resolver.port')
    end
    f.actions
  end

end