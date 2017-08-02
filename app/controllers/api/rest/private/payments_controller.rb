class Api::Rest::Private::PaymentsController < Api::Rest::Private::BaseController

  after_action only: [:index] do
    send_x_headers(@payments)
  end

  before_action only: [:show, :update, :destroy] do
    @payment = Payment.find(params[:id])
  end

  def index
    @payments = resource_collection(Payment.all)
    respond_with @payments
  end

  def show
    respond_with(@payment, location: nil)
  end

  def create
    @payment = Payment.create(payment_params)
    respond_with(@payment, location: nil)
  end

  private

  def payment_params
    params.require(:payment).permit(
      :account_id,
      :amount,
      :notes
    )
  end
end
