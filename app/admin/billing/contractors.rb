ActiveAdmin.register Contractor do
  menu parent: "Billing",  priority: 2


  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_status
  
  acts_as_export :id, :enabled, :name, :vendor,:customer
  acts_as_import resource_class: Importing::Contractor

  scope :vendors
  scope :customers

  permit_params :name, :enabled, :vendor, :customer ,:description, :address, :phones, :tech_contact, :fin_contact, :smtp_connection_id

  config.batch_actions = true
  config.scoped_collection_actions_if = -> { true }

  scoped_collection_action :scoped_collection_update,
                           class: 'scoped_collection_action_button ui',
                           form: -> do
                             boolean = [ ['Yes', 't'], ['No', 'f']]
                             {
                               enabled: boolean,
                               vendor: boolean,
                               customer: boolean,
                               description: 'text',
                               address: 'text',
                               phones: 'text',
                               smtp_connection_id: System::SmtpConnection.all.map { |smtpc| [smtpc.name, smtpc.id] }
                             }
                           end

  includes :smtp_connection

   #todo: check this endpoint is need
   collection_action :is_vendor do
     @contractors = Contractor.where(vendor: params[:vendor_flag])
     render text:                 view_context.options_from_collection_for_select(@contractors, :id, :display_name)
   end
   
   collection_action :get_accounts do
     contractor =  Contractor.find(params[:contractor_id])
     @accounts = contractor.accounts
     render text:                 view_context.options_from_collection_for_select(@accounts, :id, :display_name)
   end

  index do
    selectable_column
    id_column
    actions
    column :enabled
    column :name
    column :vendor
    column :customer
    column :description
    column :address
    column :phones
    column :smtp_connection
  end

  show do |s|
    tabs do
      tab "Details" do
        attributes_table do
          row :id
          row :name
          row :enabled
          row :vendor
          row :customer
          row :description
          row :address
          row :phones
          row :smtp_connection
        end
      end
      tab "Contacts" do
        panel "" do
          table_for s.contacts do
            column :id
            column :email
            column :notes
            column :created_at
            column :updated_at
          end
        end
      end
      tab "Comments" do
          active_admin_comments
      end
    end
  end


  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      f.input :name
      f.input :enabled
      f.input :vendor
      f.input :customer
      f.input :description
      f.input :address
      f.input :phones
      f.input :smtp_connection
    end
    f.actions
  end


  filter :id
  filter :name
  filter :enabled,as: :select, collection: [["Yes", true], ["No", false]]
  filter :vendor,as: :select, collection: [["Yes", true], ["No", false]]
  filter :customer,as: :select, collection: [["Yes", true], ["No", false]]
  

  sidebar :links, only: [:show, :edit] do

    ul do
      li do
        link_to "Gateways" , gateways_path(q: {contractor_id_eq: params[:id]})

      end
      li do
         link_to "Accounts" , accounts_path(q: {contractor_id_eq: params[:id]})
      end


    end
  end


end
