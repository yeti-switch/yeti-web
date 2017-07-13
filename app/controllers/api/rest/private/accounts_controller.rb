class Api::Rest::Private::AccountsController < Api::RestController

  after_action only: [:index] do
    send_x_headers(@accounts)
  end

  before_action only: [:show, :update, :destroy] do
    @account = Account.find(params[:id])
  end

  def index
    @accounts = resource_collection(Account.all)
    respond_with @accounts
  end

  def show
    respond_with(@account, location: nil)
  end

  def create
    @account = Account.create(account_params)
    respond_with(@account, location: nil)
  end

  def update
    @account.update(account_params)
    respond_with @account, location: nil
  end

  def destroy
    @account.destroy!
    respond_with(@account, location: nil)
  end

  private

  def account_params
    params.require(:account).permit(
      :name,
      :contractor_id,
      :min_balance,
      :max_balance,
      :origination_capacity,
      :termination_capacity,
      :customer_invoice_period_id,
      :vendor_invoice_period_id,
      :customer_invoice_template_id,
      :vendor_invoice_template_id,
      :send_invoices_to,
      :timezone_id
    )
  end
end
