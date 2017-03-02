class Api::Rest::Private::DialpeersController < Api::RestController

  after_filter only: [:index] do
    send_x_headers(@dialpeers)
  end

  before_filter only: [:show, :update, :destroy] do
    @dialpeer = Dialpeer.find(params[:id])
  end


  def index
    @dialpeers = resource_collection(Dialpeer.all)
    respond_with(@dialpeers)
  end

  def show
    respond_with(@dialpeer, location: nil)
  end

  def create
    @dialpeer = Dialpeer.create(dialpeer_params)
    respond_with(@dialpeer, location: nil)
  end

  def update
    @dialpeer.update(dialpeer_params)
    respond_with(@dialpeer, location: nil)
  end

  def destroy
    @dialpeer.destroy!
    respond_with(@dialpeer, location: nil)
  end

  private

  def dialpeer_params
    params.require(:dialpeer).permit(
        :enabled,
        :prefix,
        :src_rewrite_rule,
        :dst_rewrite_rule,
        :acd_limit,
        :asr_limit,
        :gateway_id,
        :routing_group_id,
        :next_rate,
        :connect_fee,
        :vendor_id,
        :account_id,
        :src_rewrite_result,
        :dst_rewrite_result,
        :locked,
        :priority,
        :exclusive_route,
        :capacity,
        :lcr_rate_multiplier,
        :initial_rate,
        :initial_interval,
        :next_interval,
        :valid_from,
        :valid_till,
        :gateway_group_id,
        :test,
        :force_hit_rate,
        :network_prefix_id,
        :created_at,
        :short_calls_limit,
        :external_id
    )
  end

end