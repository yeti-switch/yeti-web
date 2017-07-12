class Api::Rest::Private::RoutingPlansController < Api::RestController

  after_action only: [:index] do
    send_x_headers(@routing_plans)
  end

  before_action only: [:show, :update, :destroy] do
    @routing_plan = Routing::RoutingPlan.find(params[:id])
  end


  def index
    @routing_plans = resource_collection(Routing::RoutingPlan.all)
    respond_with(@routing_plans)
  end

  def show
    respond_with(@routing_plan, location: nil)
  end

  def create
    @routing_plan = Routing::RoutingPlan.create(routing_plan_params)
    respond_with(@routing_plan, location: nil)
  end

  def update
    @routing_plan.update(routing_plan_params)
    respond_with(@routing_plan, location: nil)
  end

  def destroy
    @routing_plan.destroy!
    respond_with(@routing_plan, location: nil)
  end

  private

  def routing_plan_params
    params.require(:routing_plan).permit(
      :name,
      :rate_date_max,
      :use_lnp,
      :sorting_id
    )
  end
end
