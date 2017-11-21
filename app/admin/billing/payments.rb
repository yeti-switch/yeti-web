ActiveAdmin.register Payment do
  menu parent: "Billing", priority: 20

  config.batch_actions = false
  actions :index, :create, :new, :show

  permit_params :account_id, :amount, :notes
  scope :all, default: true
  scope :today
  scope :yesterday

  acts_as_export

  config.batch_actions = true
  config.scoped_collection_actions_if = -> { true }

  scoped_collection_action :scoped_collection_update,
                           class: 'scoped_collection_action_button ui',
                           form: -> do
                             {
                               account_id: Account.all.map{ |a| [a.name, a.id]},
                               amount: 'text',
                               notes: 'text'
                             }
                           end

  controller do
    def scoped_collection
      Payment.includes(:account)
    end
  end

  form do |f|
    f.inputs form_title do

      f.input :account, input_html: {class: 'chosen'}
      f.input :amount
      f.input :notes


    end
    f.actions
  end

  index footer_data: ->(collection) { collection.select("round(sum(amount),4) as total_amount").take } do
    id_column
    column :account, footer: -> do
                     strong do
                       "Total:"
                     end
                   end
    column :amount, footer: -> do
                    strong do
                      @footer_data[:total_amount]
                    end
                  end
    column :notes
    column :created_at

  end

  filter :id
  filter :accoun, input_html: {class: 'chosen'}
  filter :amount
  filter :notes
  filter :created_at, as: :date_time_range
  # filter :created_at

end
