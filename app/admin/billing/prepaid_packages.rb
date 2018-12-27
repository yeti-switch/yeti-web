ActiveAdmin.register Billing::AccountPackageCounter, as: 'Prepaid Packages' do
  menu false
  actions :index
  belongs_to :account, parent_class: Account

  config.batch_actions = false
  config.comments = false
  config.filters = false

  index do
    column :id
    column :prefix
    column :duration
    column :expired_at
  end

  sidebar 'Set Package (current billing period)' do
    active_admin_form_for(Account.find(params[:account_id]),
                          url: url_for(action: :current_package),
                          as: :current_account_package,
                          method: :post) do |f|
      f.input :package, as: :select,
                        include_blank: 'None',
                        input_html: { class: 'chosen' }
      para 'You will be imidiatelly charged fo unknown amount of money ;)'
      f.actions do
        f.action :submit, label: 'Charge money and set prepaid configuration'
      end
    end
  end

  sidebar 'Change Package (next billing period)' do
    active_admin_form_for(Account.find(params[:account_id]),
                          url: url_for(action: :current_package),
                          as: :current_account_package,
                          method: :post) do |f|
      f.input :package, as: :select,
                        include_blank: 'None',
                        input_html: { class: 'chosen' }
      para 'This will be assigned as a value for a next billing period.
            Your account will be charged automatically one day,
            when current billing period ends.
            Date is unknown.
            Amount of money is unknown.'
      f.actions do
        f.action :submit, label: 'Set next prepaid period, charge later'
      end
    end
  end


  collection_action :current_package, method: :post do
    #begin
      pack = AccountPackageOperation.new(account_id: params[:account_id])
      pack.save_current(params[:current_account_package][:package_id])
      flash[:notice] = 'Ok'
    #rescue StandardError => e
    #  flash[:alert] = "Error: #{e.message}"
    #  raise e
    #end

    redirect_to collection_url(account_id: params[:account_id])
  end
end
