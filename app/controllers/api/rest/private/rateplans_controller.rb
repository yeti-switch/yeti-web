class Api::Rest::Private::RateplansController < Api::RestController

  after_action only: [:index] do
    send_x_headers(@rateplans)
  end

  before_action only: [:show, :update, :destroy] do
    @rateplan = Rateplan.find(params[:id])
  end


  def index
    @rateplans = resource_collection(Rateplan.all)
    respond_with(@rateplans)
  end

  def show
    respond_with(@rateplan, location: nil)
  end

  def create
    @rateplan = Rateplan.create(rateplan_params)
    respond_with(@rateplan, location: nil)
  end

  def update
    @rateplan.update(rateplan_params)
    respond_with(@rateplan, location: nil)
  end

  def destroy
    @rateplan.destroy!
    respond_with(@rateplan, location: nil)
  end

  private

  def rateplan_params
    params.require(:rateplan).permit(
      :name,
      :profit_control_mode_id
    )
  end
end
