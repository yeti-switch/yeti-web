class Api::Rest::Private::RoutingGroupsController < Api::Rest::Private::BaseController

  after_action only: [:index] do
    send_x_headers(@routing_groups)
  end

  before_action only: [:show, :update, :destroy] do
    @routing_group = RoutingGroup.find(params[:id])
  end


  def index
    @routing_groups = resource_collection(RoutingGroup.all)
    respond_with(@routing_groups)
  end

  def show
    respond_with(@routing_group, location: nil)
  end

  def create
    @routing_group = RoutingGroup.create(routing_group_params)
    respond_with(@routing_group, location: nil)
  end

  def update
    @routing_group.update(routing_group_params)
    respond_with(@routing_group, location: nil)
  end

  def destroy
    @routing_group.destroy!
    respond_with(@routing_group, location: nil)
  end

  private

  def routing_group_params
    params.require(:routing_group).permit(:name)
  end
end
