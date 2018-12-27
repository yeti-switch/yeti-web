ActiveAdmin.register Payment do
  menu parent: "Billing", priority: 20

  config.batch_actions = false
  actions :index, :create, :new, :show

  acts_as_async_destroy('Payment')
  acts_as_async_update('Payment',
                       lambda do
                         {
                           account_id: Account.pluck(:name, :id),
                           amount: 'text',
                           notes: 'text'
                         }
                       end)

  acts_as_delayed_job_lock

  permit_params :account_id, :amount, :notes
  scope :all, default: true
  scope :today
  scope :yesterday

  acts_as_export :id,
                 [:account_name, proc { |row| row.account.try(:name) }],
                 :amount, :notes, :created_at


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
  filter :account, input_html: {class: 'chosen'}
  filter :amount
  filter :notes
  filter :created_at, as: :date_time_range
  # filter :created_at

end
