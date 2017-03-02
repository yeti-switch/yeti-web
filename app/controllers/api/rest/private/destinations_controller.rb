class Api::Rest::Private::DestinationsController < Api::RestController

  after_filter only: [:index] do
    send_x_headers(@destinations)
  end

  before_filter only: [:show, :update, :destroy] do
    @destination = Destination.find(params[:id])
  end


  def index
    @destinations = resource_collection(Destination.all)
    respond_with(@destinations)
  end

  def show
    respond_with(@destination, location: nil)
  end

  def create
    @destination = Destination.create(destination_params)
    respond_with(@destination, location: nil)
  end

  def update
    @destination.update(destination_params)
    respond_with(@destination, location: nil)
  end

  def destroy
    @destination.destroy!
    respond_with(@destination, location: nil)
  end

  private

  def destination_params
    params.require(:destination).permit(
        :enabled,
        :prefix,
        :rateplan_id,
        :next_rate,
        :connect_fee,
        :initial_interval,
        :next_interval,
        :dp_margin_fixed,
        :dp_margin_percent,
        :rate_policy_id,
        :initial_rate,
        :reject_calls,
        :use_dp_intervals,
        :test,
        :valid_from,
        :valid_till,
        :profit_control_mode_id,
        :external_id,
        :asr_limit,
        :acd_limit,
        :short_calls_limit
    )
  end

end
